import test from 'node:test';
import assert from 'node:assert/strict';
import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import vm from 'node:vm';
import { fileURLToPath } from 'node:url';
import { isSlackClient, validateCSS, debuggerURL, styleExpression, STYLE_ID,
  STYLE_OWNER, CDPClient, discoverTargets } from '../home/dot_config/slack-terminal/cdp.mjs';
import { optionsFor, parseProcesses, assessListener, launchPlan, launch,
  control, status, watch, readJSON, writeJSON } from '../home/dot_config/slack-terminal/executable_slack-terminal.mjs';

const project = path.dirname(path.dirname(fileURLToPath(import.meta.url)));
const sourceCSS = fs.readFileSync(path.join(project, 'home/dot_config/slack-terminal/slack-terminal.css'), 'utf8');

function fixture(t) {
  const root = fs.mkdtempSync(path.join(os.tmpdir(), 'slack-terminal-test-'));
  t.after(() => fs.rmSync(root, { recursive: true, force: true }));
  const app = path.join(root, 'Slack.app');
  fs.mkdirSync(path.join(app, 'Contents/MacOS'), { recursive: true });
  fs.writeFileSync(path.join(app, 'Contents/MacOS/Slack'), 'fake executable, never run');
  const css = path.join(root, 'theme.css');
  fs.writeFileSync(css, 'body { color: #e2e2e3; }');
  return optionsFor(['launch', '--app', app, '--css', css, '--state-dir', path.join(root, 'state')], {});
}

function fakeOperations(options, processes = []) {
  const calls = [];
  return {
    calls,
    processes: async () => processes,
    isAlive: pid => [process.pid, 9002].includes(pid),
    focus: async () => { calls.push('focus'); },
    port: async () => { calls.push('port'); return 49152; },
    startApp: async (_options, port) => { calls.push(['start-app', port]); return 9001; },
    startWatcher: async (_options, session) => {
      calls.push('start-watcher');
      writeJSON(path.join(options.stateDir, 'session.json'), { ...session, watcherPid: 9002, phase: 'attached', applied: 1 });
      return 9002;
    },
  };
}

test('only HTTPS Slack client routes are eligible, never login/marketing/foreign sites', () => {
  for (const url of ['https://app.slack.com/client/TEXAMPLE', 'https://team.slack.com/messages/general', 'https://app.slack.com/client']) assert.equal(isSlackClient(url), true);
  for (const url of ['https://app.slack.com/signin', 'https://slack.com/', 'http://app.slack.com/client/TEXAMPLE', 'https://app.slack.com.evil.test/client/x', 'https://evilslack.com/client/x', 'file:///client/x', 'not a URL']) assert.equal(isSlackClient(url), false);
});

test('CSS is local, bounded, and data—not JavaScript', () => {
  assert.equal(validateCSS(sourceCSS), sourceCSS);
  assert.equal(validateCSS('/* url(remote) */ body { color: red; }').includes('color'), true);
  for (const css of ['', '@import "remote.css";', 'body { background: url(https://example.org/pixel); }', 'body { background: URL (file:///secret); }', 'a'.repeat(512 * 1024 + 1)]) assert.throws(() => validateCSS(css));
  assert.throws(() => debuggerURL('ws://evil.test:49152/devtools/page/x', 49152));
  assert.throws(() => debuggerURL('ws://127.0.0.1:1234/devtools/page/x', 49152));
  assert.throws(() => debuggerURL('ws://127.0.0.1:49152/devtools/browser/x', 49152));
  assert.throws(() => debuggerURL('ws://user:pass@127.0.0.1:49152/devtools/page/x', 49152));
  assert.equal(debuggerURL('ws://127.0.0.1:49152/devtools/page/x', 49152), 'ws://127.0.0.1:49152/devtools/page/x');
});

test('process lookup matches the exact main executable, not helpers or other apps', () => {
  assert.deepEqual(parseProcesses(' 21 /Applications/Slack.app/Contents/MacOS/Slack\n22 /Applications/Slack.app/Contents/Frameworks/Slack Helper.app/Contents/MacOS/Slack Helper\n23 /Applications/NotSlack.app/Contents/MacOS/Slack\n', '/Applications/Slack.app/Contents/MacOS/Slack'), [{ pid: 21 }]);
});

test('listener must belong to our main process and have only loopback bindings', () => {
  assert.equal(assessListener('p21\nn127.0.0.1:49152\n', 49152, 21), 'safe');
  assert.equal(assessListener('p21\nn[::1]:49152\n', 49152, 21), 'safe');
  assert.equal(assessListener('', 49152, 21), 'pending');
  for (const output of ['p21\nn*:49152\n', 'p21\nn[::]:49152\n', 'p99\nn127.0.0.1:49152\n', 'p21\nn127.0.0.1:49152\np99\nn*:49152\n']) assert.equal(assessListener(output, 49152, 21), 'unsafe');
});

test('launch planning never restarts an ordinary running Slack', () => {
  assert.equal(launchPlan([], null, () => false), 'start');
  assert.equal(launchPlan([{ pid: 21, port: null }], null, () => false), 'focus');
  assert.equal(launchPlan([{ pid: 21, port: 49152 }], { appPid: 21, port: 49152, watcherPid: 22 }, () => false), 'resume');
  assert.equal(launchPlan([{ pid: 21, port: 49152 }], { appPid: 21, port: 49152, watcherPid: 22 }, () => true), 'focus');
  assert.equal(launchPlan([{ pid: 99, port: 49152 }], { appPid: 21, port: 49152 }, () => false), 'focus');
});

test('cold launch starts one app and watcher, retaining a child-published status', async t => {
  const options = fixture(t);
  const operations = fakeOperations(options);
  const result = await launch(options, operations);
  assert.equal(result.action, 'launched');
  assert.deepEqual(operations.calls, ['port', ['start-app', 49152], 'start-watcher']);
  const session = readJSON(path.join(options.stateDir, 'session.json'));
  assert.equal(session.phase, 'attached');
  assert.equal(session.applied, 1);
  assert.equal(fs.statSync(options.stateDir).mode & 0o777, 0o700);
  assert.equal(fs.statSync(path.join(options.stateDir, 'session.json')).mode & 0o777, 0o600);
  assert.equal(fs.existsSync(path.join(options.stateDir, 'launch.lock')), false);
});

test('running Slack is focused even if the CSS file is missing; no process is quit', async t => {
  const options = fixture(t);
  fs.unlinkSync(options.css);
  const operations = fakeOperations(options, [{ pid: 55, port: null }]);
  assert.equal((await launch(options, operations)).action, 'focused');
  assert.deepEqual(operations.calls, ['focus']);
});

test('ordinary Dock relaunch still explains missing styling when old session metadata exists', async t => {
  const options = fixture(t);
  fs.mkdirSync(options.stateDir);
  writeJSON(path.join(options.stateDir, 'session.json'), { appPid: 1, port: 49152, watcherPid: 0, phase: 'stopped' });
  const operations = fakeOperations(options, [{ pid: 55, port: null }]);
  const result = await launch(options, operations);
  assert.equal(result.themed, false);
  assert.match(result.note, /quit normally and relaunch/);
  assert.deepEqual(operations.calls, ['focus']);
});

test('disabled launch is normal Slack without allocating a port/watcher', async t => {
  const options = fixture(t);
  control(options, 'disable');
  fs.unlinkSync(options.css);
  const operations = fakeOperations(options);
  assert.equal((await launch(options, operations)).themed, false);
  assert.deepEqual(operations.calls, ['focus']);
  assert.equal(status(options, operations).enabled, false);
});

test('invalid CSS fails before starting Slack, without leaving the launch lock', async t => {
  const options = fixture(t);
  fs.writeFileSync(options.css, '@import "https://example.org/theme.css";');
  const operations = fakeOperations(options);
  await assert.rejects(launch(options, operations), /Imported styles/);
  assert.deepEqual(operations.calls, []);
  assert.equal(fs.existsSync(path.join(options.stateDir, 'launch.lock')), false);
});

test('dead owned watcher can resume without launching Slack again', async t => {
  const options = fixture(t);
  fs.mkdirSync(options.stateDir);
  writeJSON(path.join(options.stateDir, 'session.json'), { appPid: 9001, port: 49152, watcherPid: 9999, sessionId: 'old' });
  const operations = fakeOperations(options, [{ pid: 9001, port: 49152 }]);
  assert.equal((await launch(options, operations)).action, 'watcher-resumed');
  assert.deepEqual(operations.calls, ['start-watcher', 'focus']);
});

test('malformed state is not overwritten or discarded', async t => {
  const options = fixture(t);
  fs.mkdirSync(options.stateDir);
  const file = path.join(options.stateDir, 'session.json');
  fs.writeFileSync(file, 'user work / invalid JSON');
  await assert.rejects(launch(options, fakeOperations(options)), /left untouched/);
  assert.equal(fs.readFileSync(file, 'utf8'), 'user work / invalid JSON');
});

test('enable/disable/stop only change private control metadata', t => {
  const options = fixture(t);
  control(options, 'disable');
  assert.equal(readJSON(path.join(options.stateDir, 'control.json')).enabled, false);
  control(options, 'enable');
  assert.equal(readJSON(path.join(options.stateDir, 'control.json')).enabled, true);
  writeJSON(path.join(options.stateDir, 'session.json'), { sessionId: 'owned-session' });
  control(options, 'stop');
  assert.equal(readJSON(path.join(options.stateDir, 'control.json')).stopSession, 'owned-session');
});

function minimalDOM() {
  const elements = new Map();
  const document = {
    body: {}, documentElement: {},
    getElementById: id => elements.get(id) || null,
    createElement: tag => {
      const element = { tagName: tag.toUpperCase(), dataset: {}, textContent: '', sheet: {} };
      element.remove = () => elements.delete(element.id);
      return element;
    },
    head: { appendChild: element => elements.set(element.id, element) },
  };
  return { elements, document, URL,
    location: { href: 'https://app.slack.com/client/TEXAMPLE' },
    getComputedStyle: () => ({ backgroundColor: 'rgb(44, 46, 52)', color: 'rgb(226, 226, 227)', fontFamily: 'Victor Mono', fontSize: '13px' }),
  };
}

test('style insertion is idempotent, safely quotes CSS, and removes only our element', () => {
  const context = minimalDOM();
  const css = 'body { color: red; } /* ` ${malicious} </script> " */';
  assert.equal(vm.runInNewContext(styleExpression(css, true), context).applied, true);
  const first = context.elements.get(STYLE_ID);
  assert.equal(first.textContent, css);
  assert.equal(first.dataset.slackTerminal, STYLE_OWNER);
  vm.runInNewContext(styleExpression('body { color: blue; }', true), context);
  assert.equal(context.elements.size, 1);
  assert.equal(context.elements.get(STYLE_ID), first);
  vm.runInNewContext(styleExpression('', false), context);
  assert.equal(context.elements.size, 0);
  const foreign = { tagName: 'STYLE', dataset: {}, textContent: 'user work' };
  context.elements.set(STYLE_ID, foreign);
  assert.equal(vm.runInNewContext(styleExpression(css, true), context).conflict, true);
  vm.runInNewContext(styleExpression('', false), context);
  assert.equal(context.elements.get(STYLE_ID).textContent, 'user work');
});

test('leaving a client route removes our styling without inspecting the new page', () => {
  const context = minimalDOM();
  vm.runInNewContext(styleExpression('body {}', true), context);
  context.location.href = 'https://app.slack.com/signin';
  context.getComputedStyle = () => { throw new Error('Must not inspect the login page'); };
  assert.equal(vm.runInNewContext(styleExpression('body {}', true), context).applied, false);
  assert.equal(context.elements.size, 0);
});

test('blocked inline styling is reported without disabling CSP', () => {
  const context = minimalDOM();
  const original = context.document.createElement;
  context.document.createElement = tag => ({ ...original(tag), sheet: null });
  assert.equal(vm.runInNewContext(styleExpression('body {}', true), context).blocked, true);
});

class FakeSocket extends EventTarget {
  constructor() { super(); this.sent = []; queueMicrotask(() => this.dispatchEvent(new Event('open'))); }
  send(message) {
    const request = JSON.parse(message);
    this.sent.push(request);
    queueMicrotask(() => this.reply({ id: request.id, result: request.method === 'Runtime.evaluate' ?
      { result: { value: { applied: !request.params.expression.includes('if (false)'), background: 'rgb(44, 46, 52)' } } } : {} }));
  }
  reply(message) { this.dispatchEvent(new MessageEvent('message', { data: JSON.stringify(message) })); }
  close() { this.dispatchEvent(new Event('close')); }
}

test('CDP only enables page reload events, deduplicates CSS, and recovers after reload', async () => {
  const socket = new FakeSocket();
  const client = new CDPClient('ws://127.0.0.1:49152/devtools/page/x', { socketFactory: () => socket });
  await client.initialize();
  await client.apply('body {}', true);
  await client.apply('body {}', true);
  assert.deepEqual(socket.sent.map(item => item.method), ['Page.enable', 'Runtime.evaluate']);
  socket.reply({ method: 'Page.domContentEventFired', params: {} });
  await client.apply('body {}', true);
  assert.equal(socket.sent.length, 3);
  await client.apply('', false);
  assert.equal(client.applied, false);
  assert.equal(socket.sent.some(item => /Runtime.enable|Network|Storage|Security|Screenshot|Cookie/.test(item.method)), false);
  client.close();
});

test('pending CDP requests reject on close without timers or unhandled rejections', async () => {
  const socket = new FakeSocket();
  socket.send = () => {};
  const client = new CDPClient('ws://127.0.0.1:49152/devtools/page/x', { socketFactory: () => socket, timeout: 50 });
  const pending = client.request('Page.enable');
  await client.ready;
  socket.close();
  await assert.rejects(pending, /closed/);
  assert.equal(client.pending.size, 0);
});

test('target discovery discards titles/URLs and rejects off-loopback endpoints', async () => {
  const fetcher = async url => {
    assert.equal(url, 'http://127.0.0.1:49152/json/list');
    return { ok: true, text: async () => JSON.stringify([
      { id: 'client', type: 'page', title: 'private channel title', url: 'https://app.slack.com/client/TEXAMPLE', webSocketDebuggerUrl: 'ws://127.0.0.1:49152/devtools/page/client' },
      { id: 'login', type: 'page', url: 'https://app.slack.com/signin', webSocketDebuggerUrl: 'ws://127.0.0.1:49152/devtools/page/login' },
      { id: 'other', type: 'page', url: 'https://example.org/', webSocketDebuggerUrl: 'ws://evil.test:49152/devtools/page/other' },
    ]) };
  };
  assert.deepEqual(await discoverTargets(49152, fetcher), [{ id: 'client', websocket: 'ws://127.0.0.1:49152/devtools/page/client' }]);
  await assert.rejects(discoverTargets(49152, async () => ({ ok: true, text: async () => JSON.stringify([
    { id: 'bad', type: 'page', url: 'https://app.slack.com/client/TEXAMPLE', webSocketDebuggerUrl: 'ws://evil.test:49152/devtools/page/bad' },
  ]) })), /unexpected DevTools/);
});

test('theme keeps controls visible and uses the existing palette', () => {
  const code = sourceCSS.replace(/\/\*[\s\S]*?\*\//g, '');
  // The only permitted hiding rule is the tooltip's noninteractive decoration.
  const withoutArrow = code.replace(/\.c-tooltip__tip__arrow\s*\{\s*display:\s*none\s*!important\s*;\s*\}/g, '');
  assert.doesNotMatch(withoutArrow, /(?:^|[;{])\s*(?:display:\s*none|visibility:\s*hidden|opacity:\s*0\b|pointer-events:\s*none)/m);
  const github = fs.readFileSync(path.join(project, 'home/dot_config/stylus/github-terminal.user.css'), 'utf8');
  const pairs = [...sourceCSS.matchAll(/(--terminal-[\w-]+):\s*(light-dark\(#[\da-f]+, #[\da-f]+\))/g)];
  for (const [, name, value] of pairs) assert.ok(github.includes(`${name}: ${value}`), name);
  assert.match(code, /\.c-tooltip__tip \{[\s\S]*?--foreground: var\(--terminal-fg\)[\s\S]*?background-color: var\(--terminal-surface\)/);
  assert.match(code, /\.c-tooltip__tip \{[^}]*filter: none !important/);
  assert.match(code, /\.c-tooltip__tip__arrow\s*\{\s*display:\s*none\s*!important\s*;\s*\}/);
});

test('rich-text roots and sibling composer placeholders use the message typography', () => {
  const code = sourceCSS.replace(/\/\*[\s\S]*?\*\//g, '');
  const blocks = [...code.matchAll(/([^{}]+)\{([^{}]*)\}/g)];
  for (const selector of ['.p-rich_text_block', '.c-texty_input__placeholder', '.ql-placeholder']) {
    const block = blocks.find(([, selectors, declarations]) =>
      selectors.split(',').map(value => value.trim()).includes(selector) &&
      declarations.includes('font-size:'));
    assert.ok(block, `${selector} must normalize its own font size rather than rely on body inheritance.`);
    assert.match(block[2], /font-family:\s*var\(--terminal-font\) !important;/);
    assert.match(block[2], /font-size:\s*var\(--terminal-size\) !important;/);
    assert.match(block[2], /line-height:\s*var\(--terminal-line-height\) !important;/);
    assert.doesNotMatch(block[1], /\*|\.p-rich_text_block\s+\S/,
      'Normalize the root, not every descendant: emoji and icons keep their own sizes.');
  }
});

test('split send controls share the accent palette in normal and hover states', () => {
  const code = sourceCSS.replace(/\/\*[\s\S]*?\*\//g, '');
  const composer = [...code.matchAll(/([^{}]+)\{([^{}]*)\}/g)]
    .find(([, selector]) => selector.trim() === '.c-wysiwyg_container');
  assert.ok(composer, 'The composer must override Slack’s shared send tokens.');
  assert.match(composer[2], /--TextyTheme-send-bg:\s*var\(--terminal-blue\) !important;/);
  assert.match(composer[2], /--TextyTheme-send-bg-hover:\s*var\(--terminal-blue\) !important;/);
  assert.match(composer[2], /--TextyTheme-send-fg:\s*var\(--terminal-on-accent\) !important;/);
  assert.doesNotMatch(composer[2], /--TextyTheme-send-(?:bg|fg)-disabled:|(?:^|[;{])\s*(?:background|color)\s*:/);
});

test('tooltip/popover positioning shells cannot acquire an opaque fill or border', () => {
  const code = sourceCSS.replace(/\/\*[\s\S]*?\*\//g, '');
  const blocks = [...code.matchAll(/([^{}]+)\{([^{}]*)\}/g)].map(([, selector, declarations]) => ({ selector: selector.trim(), declarations }));
  const tooltipContext = blocks.find(block => block.selector === '.c-tooltip__tip, [role="tooltip"]');
  assert.ok(tooltipContext);
  assert.doesNotMatch(tooltipContext.declarations, /background-color:|\bborder:/);
  const painted = blocks.filter(block => /background-color:|\bborder:/.test(block.declarations));
  for (const block of painted) {
    assert.doesNotMatch(block.selector, /(?:^|,)\s*\.c-popover\s*(?:,|$)/);
    assert.doesNotMatch(block.selector, /(?:^|,)\s*\.p-popover\s*(?:,|$)/);
    assert.doesNotMatch(block.selector, /(?:^|,)\s*\[role="tooltip"\]\s*(?:,|$)/);
  }
  const menu = blocks.find(block => block.selector.includes('.c-menu, .p-flexpane'));
  assert.match(menu.selector, /\[role="dialog"\]:not\(\.c-popover, \.p-popover\)/);
  assert.match(menu.selector, /\[role="menu"\]:not\(\.c-popover, \.p-popover\)/);
});

test('watcher reloads CSS, retains valid edits, disables despite invalid CSS, and stops without quitting Slack', async t => {
  const options = { ...fixture(t), port: 49152, appPid: 9001, sessionId: 'test-watch-session' };
  fs.mkdirSync(options.stateDir);
  writeJSON(path.join(options.stateDir, 'session.json'), { ...options, watcherPid: 0, enabled: true });
  const calls = [];
  const client = {
    applied: false, closed: false, sample: null,
    initialize: async () => {},
    apply: async (css, enabled) => { calls.push({ css, enabled }); client.applied = enabled; },
    close: () => { client.closed = true; },
  };
  let cycle = 0;
  await watch(options, {
    processes: async () => [{ pid: 9001, port: 49152 }],
    listener: async () => 'safe',
  }, {
    discover: async () => [{ id: 'client', websocket: 'ws://127.0.0.1:49152/devtools/page/client' }],
    clientFactory: () => client,
    sleep: async () => {
      cycle++;
      if (cycle === 1) { fs.writeFileSync(options.css, '@import "bad.css";'); control(options, 'disable'); }
      if (cycle === 2) control(options, 'enable');
      if (cycle === 3) fs.writeFileSync(options.css, 'body { color: #123456; background: #abcdef; }');
      if (cycle === 4) control(options, 'stop');
      assert.ok(cycle <= 4, 'Watcher did not honor stop.');
    },
  });
  assert.equal(calls[0].enabled, true);
  assert.equal(calls[1].enabled, false);
  assert.equal(calls[2].css, calls[0].css, 'An invalid edit must retain the previous CSS.');
  assert.match(calls[3].css, /#123456/);
  assert.equal(calls.at(-1).enabled, false);
  assert.equal(client.closed, true);
  assert.equal(status(options).phase, 'stopped');
});

test('watcher refuses foreign/non-loopback listeners before discovery or injection', async t => {
  const options = { ...fixture(t), port: 49152, appPid: 9001, sessionId: 'unsafe-listener-test' };
  fs.mkdirSync(options.stateDir);
  writeJSON(path.join(options.stateDir, 'session.json'), { ...options, watcherPid: 0 });
  await watch(options, {
    processes: async () => [{ pid: 9001, port: 49152 }],
    listener: async () => 'unsafe',
  }, {
    discover: async () => { assert.fail('Must not connect to an unsafe listener.'); },
  });
  assert.equal(status(options).phase, 'error');
  assert.match(status(options).error, /refused to connect/);
});
