#!/usr/bin/env node
import fs from 'node:fs';
import path from 'node:path';
import os from 'node:os';
import net from 'node:net';
import { spawn, execFile } from 'node:child_process';
import { promisify } from 'node:util';
import { randomUUID } from 'node:crypto';
import { fileURLToPath } from 'node:url';
import { CDPClient, discoverTargets, validateCSS } from './cdp.mjs';

const execute = promisify(execFile);
const self = fileURLToPath(import.meta.url);
const pause = milliseconds => new Promise(resolve => setTimeout(resolve, milliseconds));
const POLL_INTERVAL = 2000;

export function optionsFor(args, environment = process.env) {
  const options = {
    command: args[0] || 'launch',
    app: environment.SLACK_TERMINAL_APP || '/Applications/Slack.app',
    css: environment.SLACK_TERMINAL_CSS || path.join(path.dirname(self), 'slack-terminal.css'),
    stateDir: environment.SLACK_TERMINAL_STATE_DIR || path.join(environment.XDG_STATE_HOME || path.join(os.homedir(), '.local/state'), 'slack-terminal'),
  };
  const flags = { '--app': 'app', '--css': 'css', '--state-dir': 'stateDir', '--port': 'port', '--app-pid': 'appPid', '--session-id': 'sessionId' };
  for (let index = 1; index < args.length; index += 2) {
    const key = flags[args[index]];
    if (!key || !args[index + 1]) throw new Error('Unknown or incomplete option.');
    options[key] = args[index + 1];
  }
  for (const key of ['app', 'css', 'stateDir']) options[key] = path.resolve(options[key]);
  options.executable = path.join(options.app, 'Contents/MacOS/Slack');
  return options;
}

export function readJSON(file, fallback = null) {
  try { return JSON.parse(fs.readFileSync(file, 'utf8')); }
  catch (error) {
    if (error.code === 'ENOENT') return fallback;
    throw new Error(`Cannot read ${path.basename(file)}; it was left untouched.`);
  }
}

export function writeJSON(file, value) {
  const temporary = `${file}.${process.pid}.${randomUUID()}.tmp`;
  fs.writeFileSync(temporary, JSON.stringify(value, null, 2) + '\n', { mode: 0o600, flag: 'wx' });
  fs.renameSync(temporary, file);
}

function prepareState(options) {
  fs.mkdirSync(options.stateDir, { recursive: true, mode: 0o700 });
  fs.chmodSync(options.stateDir, 0o700);
}

function stateFile(options) { return path.join(options.stateDir, 'session.json'); }
function controlFile(options) { return path.join(options.stateDir, 'control.json'); }

function alive(pid) {
  if (!Number.isInteger(pid) || pid <= 0) return false;
  try { process.kill(pid, 0); return true; } catch { return false; }
}

export function parseProcesses(output, executable) {
  return output.split('\n').flatMap(line => {
    const match = line.match(/^\s*(\d+)\s+(.+?)\s*$/);
    return match && match[2] === executable ? [{ pid: Number(match[1]) }] : [];
  });
}

export function assessListener(output, port, appPid) {
  let owner = null;
  let count = 0;
  for (const line of output.split('\n')) {
    if (line.startsWith('p')) owner = Number(line.slice(1));
    if (!line.startsWith('n')) continue;
    count++;
    if (owner !== appPid || ![`127.0.0.1:${port}`, `[::1]:${port}`].includes(line.slice(1))) return 'unsafe';
  }
  return count ? 'safe' : 'pending';
}

export const macOS = {
  isAlive: alive,
  async processes(options) {
    const { stdout } = await execute('/bin/ps', ['-axo', 'pid=,comm='], { maxBuffer: 4 * 1024 * 1024 });
    const processes = parseProcesses(stdout, options.executable);
    return Promise.all(processes.map(async item => {
      const { stdout: args } = await execute('/bin/ps', ['-p', String(item.pid), '-o', 'args=']);
      const port = args.match(/(?:^|\s)--remote-debugging-port=(\d+)(?:\s|$)/);
      return { ...item, port: port ? Number(port[1]) : null };
    }));
  },
  async focus(options) { await execute('/usr/bin/open', ['-a', options.app]); },
  async port() {
    const server = net.createServer();
    await new Promise((resolve, reject) => { server.once('error', reject); server.listen(0, '127.0.0.1', resolve); });
    const port = server.address().port;
    await new Promise(resolve => server.close(resolve));
    return port;
  },
  async startApp(options, port) {
    const child = spawn(options.executable, [`--remote-debugging-address=127.0.0.1`, `--remote-debugging-port=${port}`], {
      detached: true, stdio: 'ignore',
    });
    await new Promise((resolve, reject) => { child.once('spawn', resolve); child.once('error', reject); });
    child.unref();
    return child.pid;
  },
  async startWatcher(options, session) {
    const log = fs.openSync(path.join(options.stateDir, 'watcher.log'), 'a', 0o600);
    try {
      const child = spawn(process.execPath, [self, '_watch', '--app', options.app, '--css', options.css,
        '--state-dir', options.stateDir, '--port', String(session.port), '--app-pid', String(session.appPid),
        '--session-id', session.sessionId], { detached: true, stdio: ['ignore', log, log] });
      await new Promise((resolve, reject) => { child.once('spawn', resolve); child.once('error', reject); });
      child.unref();
      return child.pid;
    } finally { fs.closeSync(log); }
  },
  async listener(options) {
    try {
      const { stdout } = await execute('/usr/sbin/lsof', ['-nP', `-iTCP:${options.port}`, '-sTCP:LISTEN', '-Fpn']);
      return assessListener(stdout, options.port, options.appPid);
    } catch (error) {
      if (error.code === 1 && !error.stdout?.trim() && !error.stderr?.trim()) return 'pending';
      throw new Error('Cannot verify the DevTools listener; no renderer connection will be made.');
    }
  },
};

export function launchPlan(processes, session, isAlive) {
  if (!processes.length) return 'start';
  const managed = session && processes.some(item => item.pid === session.appPid && item.port === session.port);
  if (managed && !isAlive(session.watcherPid)) return 'resume';
  return 'focus';
}

async function withLaunchLock(options, operations, action) {
  const lock = path.join(options.stateDir, 'launch.lock');
  const deadline = Date.now() + 8000;
  let handle;
  while (handle === undefined) {
    try {
      handle = fs.openSync(lock, 'wx', 0o600);
      fs.writeFileSync(handle, JSON.stringify({ pid: process.pid }));
    } catch (error) {
      if (error.code !== 'EEXIST') throw error;
      const owner = readJSON(lock);
      if (owner?.pid && !operations.isAlive(owner.pid)) { fs.unlinkSync(lock); continue; }
      if (Date.now() >= deadline) throw new Error('Another launcher is still starting Slack. Try again shortly.');
      await pause(100);
    }
  }
  try { return await action(); }
  finally { fs.closeSync(handle); fs.unlinkSync(lock); }
}

export async function launch(options, operations = macOS) {
  prepareState(options);
  return withLaunchLock(options, operations, async () => {
    const processes = await operations.processes(options);
    const previous = readJSON(stateFile(options));
    const control = readJSON(controlFile(options), { enabled: true });
    const plan = launchPlan(processes, previous, operations.isAlive);
    const managed = previous && processes.some(item => item.pid === previous.appPid && item.port === previous.port);
    if (plan === 'focus' || control.enabled === false) {
      await operations.focus(options);
      return { action: 'focused', themed: Boolean(managed && control.enabled !== false &&
        operations.isAlive(previous.watcherPid) && previous.enabled && previous.applied),
        note: control.enabled === false ? 'Styling is disabled.' :
          plan === 'focus' && !managed ? 'Slack was already running; quit normally and relaunch to enable styling.' : undefined };
    }
    validateCSS(fs.readFileSync(options.css, 'utf8'));
    if (!fs.existsSync(options.executable)) throw new Error('Slack executable not found. Use --app to select its bundle.');
    const port = plan === 'resume' ? previous.port : await operations.port();
    const appPid = plan === 'resume' ? previous.appPid : await operations.startApp(options, port);
    const session = { sessionId: randomUUID(), appPid, port, css: options.css, enabled: control.enabled !== false,
      watcherPid: 0, phase: 'starting', targets: 0, applied: 0, error: null };
    writeJSON(stateFile(options), session);
    session.watcherPid = await operations.startWatcher(options, session);
    // The watcher owns subsequent updates. Don't overwrite a status it already
    // published while this process was waiting for the child spawn event.
    const current = readJSON(stateFile(options));
    if (current?.sessionId === session.sessionId && !current.watcherPid) writeJSON(stateFile(options), session);
    if (plan === 'resume') await operations.focus(options);
    return { action: plan === 'resume' ? 'watcher-resumed' : 'launched', port,
      note: 'Check status after Slack has loaded. If listener validation fails, quit Slack normally.' };
  });
}

export function status(options, operations = macOS) {
  const session = readJSON(stateFile(options));
  const control = readJSON(controlFile(options), { enabled: true });
  return session ? { ...session, watcherRunning: operations.isAlive(session.watcherPid) } :
    { phase: 'not-managed', enabled: control.enabled !== false, watcherRunning: false };
}

export function control(options, command) {
  prepareState(options);
  const current = readJSON(controlFile(options), { enabled: true });
  if (command === 'enable' || command === 'disable') current.enabled = command === 'enable';
  if (command === 'stop') current.stopSession = readJSON(stateFile(options))?.sessionId || null;
  writeJSON(controlFile(options), current);
  return { requested: command, note: 'A running watcher applies this within two seconds. Slack is not quit.' };
}

export async function watch(options, operations = macOS, {
  discover = discoverTargets, clientFactory = address => new CDPClient(address), sleep = pause,
} = {}) {
  options.port = Number(options.port);
  options.appPid = Number(options.appPid);
  if (!Number.isInteger(options.port) || options.port < 1024 || options.port > 65535 ||
      !Number.isInteger(options.appPid) || options.appPid <= 0 || !options.sessionId) throw new Error('Invalid watcher session.');
  const clients = new Map();
  let stopping = false;
  let fatal = null;
  let css = null;
  let cssVersion = null;
  let lastError = null;
  const stop = () => { stopping = true; };
  process.on('SIGTERM', stop);
  process.on('SIGINT', stop);
  const ownsSession = () => readJSON(stateFile(options))?.sessionId === options.sessionId;
  const publish = update => {
    const state = readJSON(stateFile(options));
    if (state?.sessionId === options.sessionId) writeJSON(stateFile(options), { ...state, watcherPid: process.pid,
      targets: clients.size, applied: [...clients.values()].filter(client => client.applied).length,
      sample: [...clients.values()].find(client => client.sample)?.sample || null, ...update });
  };
  const report = message => {
    if (message !== lastError) { console.error(message); lastError = message; }
  };
  try {
    publish({ phase: 'waiting', error: null });
    while (!stopping && ownsSession()) {
      const control = readJSON(controlFile(options), { enabled: true });
      if (control.stopSession === options.sessionId) break;
      const processes = await operations.processes(options);
      if (!processes.some(item => item.pid === options.appPid && item.port === options.port)) break;
      const listener = await operations.listener(options);
      if (listener === 'unsafe') throw new Error('Unsafe or foreign DevTools listener. Quit Slack normally; the injector refused to connect.');
      if (listener === 'pending') { publish({ phase: 'waiting' }); await sleep(POLL_INTERVAL); continue; }
      try {
        let editError = null;
        if (control.enabled !== false) {
          try {
            const stat = fs.statSync(options.css);
            const version = `${stat.ino}:${stat.size}:${stat.mtimeMs}`;
            if (version !== cssVersion) {
              css = validateCSS(fs.readFileSync(options.css, 'utf8'));
              cssVersion = version;
            }
          } catch (error) {
            if (!css) throw error;
            editError = 'The CSS edit could not be loaded; retaining the last valid stylesheet.';
            report(editError);
          }
        }
        const targets = await discover(options.port);
        const ids = new Set(targets.map(target => target.id));
        for (const [id, client] of clients) {
          if (!ids.has(id) || client.closed) {
            if (!client.closed) await client.apply('', false).catch(() => {});
            client.close(); clients.delete(id);
          }
        }
        for (const target of targets) {
          if (!clients.has(target.id)) {
            const client = clientFactory(target.websocket);
            clients.set(target.id, client);
            try { await client.initialize(); } catch (error) { client.close(); clients.delete(target.id); throw error; }
          }
        }
        const results = await Promise.allSettled([...clients.values()].map(client => client.apply(css || '', control.enabled !== false)));
        const rejected = results.find(result => result.status === 'rejected');
        if (rejected) throw rejected.reason;
        if (!editError) lastError = null;
        publish({ phase: clients.size ? 'attached' : 'waiting', enabled: control.enabled !== false, error: editError });
      } catch (error) {
        // No partial update on an invalid edit; retain the last valid styling.
        report(error.message);
        publish({ error: error.message });
      }
      await sleep(POLL_INTERVAL);
    }
  } catch (error) {
    fatal = error.message;
    report(fatal);
  } finally {
    const cleanup = await Promise.allSettled([...clients.values()].map(client => client.apply('', false)));
    for (const client of clients.values()) client.close();
    process.off('SIGTERM', stop);
    process.off('SIGINT', stop);
    if (ownsSession()) {
      const cleanupFailed = cleanup.some(result => result.status === 'rejected');
      publish({ phase: fatal ? 'error' : 'stopped', watcherPid: 0, applied: 0,
        error: fatal || (cleanupFailed ? 'A renderer could not be cleared. Reload or quit Slack normally to clear residual styling.' : null) });
    }
  }
}

async function main() {
  const options = optionsFor(process.argv.slice(2));
  if (['help', '--help', '-h'].includes(options.command)) {
    console.log('slack-terminal: launch | status | enable | disable | stop\nOptions: --app PATH --css PATH --state-dir PATH\nRequires macOS and Node 22+. Does not modify Slack or quit it automatically.');
    return;
  }
  if (process.platform !== 'darwin') throw new Error('This launcher supports macOS only.');
  if (Number(process.versions.node.split('.')[0]) < 22) throw new Error('Node 22 or newer is required.');
  let result;
  if (options.command === 'launch') result = await launch(options);
  else if (options.command === 'status') result = status(options);
  else if (['enable', 'disable', 'stop'].includes(options.command)) result = control(options, options.command);
  else if (options.command === '_watch') { await watch(options); return; }
  else throw new Error('Unknown command. Use help.');
  console.log(JSON.stringify(result, null, 2));
}

if (process.argv[1] && path.resolve(process.argv[1]) === self) {
  main().catch(error => { console.error(`slack-terminal: ${error.message}`); process.exitCode = 1; });
}
