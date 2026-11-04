import test from 'node:test';
import assert from 'node:assert/strict';
import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import { spawnSync } from 'node:child_process';
import { fileURLToPath } from 'node:url';

const project = path.dirname(path.dirname(fileURLToPath(import.meta.url)));
const source = path.join(project, 'home');
const helper = path.join(source, 'dot_config/aerospace/executable_workspace.sh');

function fixture(t) {
  const root = fs.mkdtempSync(path.join(os.tmpdir(), 'aerospace-test-'));
  t.after(() => fs.rmSync(root, { recursive: true, force: true }));
  const calls = path.join(root, 'calls');
  fs.writeFileSync(path.join(root, 'aerospace'), `#!/bin/sh
printf '%s\\n' "$*" >> "$AEROSPACE_CALLS"
if [ "$1" = list-monitors ]; then
  [ "\${AEROSPACE_QUERY_FAIL:-0}" = 0 ] || exit 2
  printf '%s\\n' "$AEROSPACE_MONITOR"
fi
`, { mode: 0o755 });
  return (args, monitor = '2', extraEnv = {}) => {
    fs.writeFileSync(calls, '');
    const result = spawnSync('sh', [helper, ...args], {
      encoding: 'utf8',
      env: { ...process.env, PATH: `${root}${path.delimiter}${process.env.PATH}`,
        AEROSPACE_CALLS: calls, AEROSPACE_MONITOR: monitor, ...extraEnv },
    });
    return { ...result, calls: fs.readFileSync(calls, 'utf8').trim().split('\n').filter(Boolean) };
  };
}

test('workspace slots stay local to each focused screen, including empty ones', t => {
  const run = fixture(t);
  for (const monitor of ['1', '2', '3']) {
    for (const slot of ['1', '8']) {
      const result = run(['focus', slot], monitor);
      assert.equal(result.status, 0, result.stderr);
      assert.deepEqual(result.calls, ['list-monitors --focused --format %{monitor-id}', `workspace ${monitor}-${slot}`]);
    }
  }
});

test('sending targets the same screen without following the window', t => {
  const result = fixture(t)(['send', '4'], '3');
  assert.equal(result.status, 0, result.stderr);
  assert.equal(result.calls.at(-1), 'move-node-to-workspace 3-4');
});

test('bad arguments never invoke AeroSpace', t => {
  const run = fixture(t);
  for (const args of [[], ['focus'], ['focus', '1', 'extra'], ['unknown', '1'],
    ['focus', '0'], ['focus', '9'], ['send', '10'], ['focus', '1; echo bad']]) {
    const result = run(args);
    assert.equal(result.status, 2);
    assert.deepEqual(result.calls, []);
  }
});

test('query failures and unexpected monitor IDs never move a window', t => {
  const run = fixture(t);
  for (const monitor of ['', '4', '2\n3']) {
    const result = run(['send', '1'], monitor);
    assert.equal(result.status, 1);
    assert.equal(result.calls.length, 1);
  }
  const failed = run(['send', '1'], '2', { AEROSPACE_QUERY_FAIL: '1' });
  assert.equal(failed.status, 2);
  assert.equal(failed.calls.length, 1);
});

const plugin = path.join(source, 'dot_config/swiftbar/plugins/executable_aerospace.2s.sh');
const sampleWorkspaces = [
  { workspace: '1-1', 'monitor-id': 1, 'workspace-is-visible': true, 'workspace-is-focused': false },
  { workspace: '1-2', 'monitor-id': 1, 'workspace-is-visible': false, 'workspace-is-focused': false },
  { workspace: '1-4', 'monitor-id': 1, 'workspace-is-visible': false, 'workspace-is-focused': false },
  { workspace: '2-1', 'monitor-id': 2, 'workspace-is-visible': true, 'workspace-is-focused': false },
  { workspace: '2-2', 'monitor-id': 2, 'workspace-is-visible': false, 'workspace-is-focused': false },
  { workspace: '3-1', 'monitor-id': 3, 'workspace-is-visible': true, 'workspace-is-focused': true },
];
const sampleWindows = [{ workspace: '1-1' }, { workspace: '1-4' }, { workspace: '3-1' }];

function swiftbarFixture(t) {
  const root = fs.mkdtempSync(path.join(os.tmpdir(), 'swiftbar-spaces-test-'));
  t.after(() => fs.rmSync(root, { recursive: true, force: true }));
  const calls = path.join(root, 'calls');
  const workspacesFile = path.join(root, 'workspaces.json');
  const windowsFile = path.join(root, 'windows.json');
  fs.writeFileSync(path.join(root, 'aerospace'), `#!/bin/sh
printf 'aerospace %s\\n' "$*" >> "$AEROSPACE_CALLS"
[ "$AEROSPACE_QUERY_FAIL" = 0 ] || exit 2
case "$1:$2" in
  list-workspaces:*) cat "$AEROSPACE_WORKSPACES" ;;
  list-windows:--all)
    [ "$AEROSPACE_WINDOWS_FAIL" = 0 ] || exit 2
    cat "$AEROSPACE_WINDOWS"
    ;;
  list-windows:--focused) printf '%s\\n' "$AEROSPACE_LAYOUT" ;;
  reload-config:) ;;
  *) exit 2 ;;
esac
`, { mode: 0o755 });
  return ({ workspaces = sampleWorkspaces, windows = sampleWindows, args = [], env = {} } = {}) => {
    fs.writeFileSync(calls, '');
    fs.writeFileSync(workspacesFile, typeof workspaces === 'string' ? workspaces : JSON.stringify(workspaces));
    fs.writeFileSync(windowsFile, JSON.stringify(windows));
    const result = spawnSync('bash', [plugin, ...args], {
      encoding: 'utf8',
      env: { ...process.env, PATH: `${root}${path.delimiter}${process.env.PATH}`,
        AEROSPACE_CALLS: calls, AEROSPACE_WORKSPACES: workspacesFile, AEROSPACE_WINDOWS: windowsFile,
        AEROSPACE_QUERY_FAIL: '0', AEROSPACE_WINDOWS_FAIL: '0',
        AEROSPACE_LAYOUT: 'h_tiles', ...env },
    });
    return { ...result, calls: fs.readFileSync(calls, 'utf8').trim().split('\n').filter(Boolean) };
  };
}

const withoutANSI = text => text.replace(/\x1b\[[0-9;]*m/g, '');

test('SwiftBar shows occupied and visible workspaces, not the fixed bank of unused slots', t => {
  const result = swiftbarFixture(t)();
  assert.equal(result.status, 0, result.stderr);
  assert.ok(withoutANSI(result.stdout).startsWith('[⦿ ⦿] [•] [⦿] '));
  assert.equal((result.stdout.match(/\x1b\[30;47m/g) ?? []).length, 1);
  for (const workspace of ['1-1', '1-4', '2-1', '3-1']) assert.ok(result.stdout.includes(workspace));
  for (const workspace of ['1-2', '2-2']) assert.ok(!result.stdout.includes(workspace));
  assert.match(result.stdout, /Reload AeroSpace config/);
  assert.doesNotMatch(result.stdout, /Restart yabai/);
  assert.ok(result.calls.every(call => call.startsWith('aerospace ')));
});

test('an unused home workspace is hidden too, and an empty visible screen still has a dot', t => {
  const workspaces = sampleWorkspaces.map(w => w.workspace.startsWith('1-')
    ? { ...w, 'workspace-is-visible': w.workspace === '1-4' } : w);
  const result = swiftbarFixture(t)({ workspaces, windows: [{ workspace: '1-4' }] });
  assert.equal(result.status, 0, result.stderr);
  assert.ok(withoutANSI(result.stdout).startsWith('[⦿] [•] [•] '));
  assert.doesNotMatch(result.stdout, /Monitor 1: 1-1/);
});

test('AeroSpace layout icons cover tiles, accordion and floating', t => {
  const run = swiftbarFixture(t);
  for (const [layout, icon] of [['v_tiles', '󰕰'], ['v_accordion', '󰌨'], ['floating', '']]) {
    const result = run({ env: { AEROSPACE_LAYOUT: layout } });
    assert.ok(result.stdout.split('\n')[0].includes(icon));
  }
});

test('workspace names cannot inject SwiftBar actions through read-only menu labels', t => {
  const name = 'strange|bash=unexpected\nInjected';
  const result = swiftbarFixture(t)({
    workspaces: [{ workspace: name, 'monitor-id': 1, 'workspace-is-visible': true }],
    windows: [],
  });
  assert.equal(result.status, 0, result.stderr);
  assert.match(result.stdout, /Monitor 1: strange bash=unexpected Injected/);
  assert.doesNotMatch(result.stdout, /\|bash=unexpected|\nInjected/);
});

test('missing AeroSpace and failed/malformed snapshots produce a quiet unavailable indicator', t => {
  const run = swiftbarFixture(t);
  for (const options of [
    { env: { AEROSPACE_QUERY_FAIL: '1' } },
    { env: { AEROSPACE_WINDOWS_FAIL: '1' } },
    { workspaces: 'not JSON' },
    { workspaces: {} },
  ]) {
    const result = run(options);
    assert.equal(result.status, 0, result.stderr);
    assert.match(result.stdout, /^Spaces unavailable \|/);
    assert.doesNotMatch(result.stdout, /Restart yabai/);
  }
});

test('the plugin rejects unknown actions without running commands', t => {
  const result = swiftbarFixture(t)({ args: ['restart'] });
  assert.equal(result.status, 2);
  assert.match(result.stderr, /Unknown AeroSpace plugin action/);
  assert.deepEqual(result.calls, []);
});

test('reload targets AeroSpace alone and reports an unavailable server', t => {
  const run = swiftbarFixture(t);
  const result = run({ args: ['reload-aerospace'] });
  assert.equal(result.status, 0, result.stderr);
  assert.equal(result.calls.at(-1), 'aerospace reload-config');
  assert.ok(result.calls.every(call => call.startsWith('aerospace ')));
  const unavailable = run({ args: ['reload-aerospace'], env: { AEROSPACE_QUERY_FAIL: '1' } });
  assert.equal(unavailable.status, 2);
  assert.ok(unavailable.calls.every(call => call.startsWith('aerospace ')));
});

test('chezmoi removes only the obsolete shortcut shim and keeps the independent plugin', () => {
  const config = fs.readFileSync(path.join(source, 'dot_config/aerospace/aerospace.toml.tmpl'), 'utf8');
  assert.match(config, /persistent-workspaces = \['1-1', '2-1', '3-1'\]/);
  assert.match(config, /exec-on-workspace-change = .*swiftbar:\/\/refreshplugin\?name=aerospace/);
  const removal = fs.readFileSync(path.join(source, '.chezmoiremove'), 'utf8');
  assert.match(removal, /^\.config\/skhd\/aerospace\.skhdrc$/m);
  assert.doesNotMatch(removal, /^\.config\/(?:yabai|skhd\/skhdrc|swiftbar)/m);
  assert.equal(fs.existsSync(path.join(source, 'dot_config/skhd/aerospace.skhdrc.tmpl')), false);
  assert.equal(fs.existsSync(plugin), true);
  assert.doesNotMatch(fs.readFileSync(plugin, 'utf8'), /yabai --|skhd --/);
});

test('standalone AeroSpace config owns app/global shortcuts and exits launcher modes explicitly', () => {
  const config = fs.readFileSync(path.join(source, 'dot_config/aerospace/aerospace.toml.tmpl'), 'utf8');
  assert.match(config, /alt-enter = .*kitty --single-instance -d ~/);
  assert.match(config, /alt-space = 'mode app'/);
  assert.match(config, /cmd-h = 'true'/);
  assert.match(config, /f14 = .*\.config\/scripts\/toggle_dark_mode\.scpt/);
  assert.match(config, /alt-m = .*Mission Control/);
  const app = config.split('[mode.app.binding]')[1];
  for (const key of ['enter', 'w', 'm', 's', 'a']) {
    assert.match(app, new RegExp(`^${key} = \\[[\\s\\S]*?'mode main',[\\s\\S]*?\\]`, 'm'));
  }
  assert.match(app, /--new-window https:\/\/music\.youtube\.com/);
  assert.match(app, /\.config\/scripts\/slack_terminal\.sh/);
  assert.match(app, /Authy Desktop\.app/);
  for (const key of ['space', 'alt-space', 'esc']) assert.ok(app.includes(`${key} = 'mode main'`));
  assert.doesNotMatch(config, /skhd --key|yabai -m/);
});

test('AeroSpace uses shared actions rather than manager-specific copies', () => {
  const config = fs.readFileSync(path.join(source, 'dot_config/aerospace/aerospace.toml.tmpl'), 'utf8');
  assert.doesNotMatch(config, /skhd|yabai|trial|rollback|aerospace\/scripts/i);
  assert.equal(fs.existsSync(path.join(source, 'dot_config/aerospace/scripts/executable_slack_terminal.sh')), false);
  assert.equal(fs.existsSync(path.join(source, 'dot_config/aerospace/scripts/toggle_dark_mode.scpt')), false);
});
