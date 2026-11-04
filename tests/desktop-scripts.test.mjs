import test from 'node:test';
import assert from 'node:assert/strict';
import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const source = path.join(path.dirname(path.dirname(fileURLToPath(import.meta.url))), 'home');
const read = file => fs.readFileSync(path.join(source, file), 'utf8');

test('AeroSpace, skhd and SwiftBar all reference the central desktop actions', () => {
  const aerospace = read('dot_config/aerospace/aerospace.toml.tmpl');
  const skhd = read('dot_config/skhd/skhdrc');
  const swiftbar = read('dot_config/swiftbar/plugins/executable_dark_mode.10s.sh');
  const inputMute = read('dot_config/swiftbar/plugins/executable_input_mute.10s.sh');
  for (const config of [aerospace, skhd]) {
    assert.match(config, /\.config\/scripts\/slack_terminal\.sh/);
    assert.match(config, /\.config\/scripts\/toggle_dark_mode\.scpt/);
  }
  assert.match(swiftbar, /\.config\/scripts\/toggle_dark_mode\.scpt/);
  assert.match(inputMute, /\.config\/scripts\/toggle_input_mute\.scpt/);
  for (const config of [aerospace, skhd, swiftbar, inputMute]) {
    assert.doesNotMatch(config, /\.config\/(?:skhd|aerospace)\/scripts\/(?:slack_terminal\.sh|toggle_dark_mode\.scpt|toggle_input_mute\.scpt)/);
  }
});

test('the shared actions and wallpaper assets are window-manager-neutral', () => {
  const slack = read('dot_config/scripts/executable_slack_terminal.sh');
  const dark = read('dot_config/scripts/toggle_dark_mode.scpt');
  const mute = read('dot_config/scripts/toggle_input_mute.scpt');
  for (const script of [slack, dark, mute]) assert.doesNotMatch(script, /skhd|yabai|aerospace/i);
  assert.match(slack, /slack-terminal\/slack-terminal\.mjs/);
  assert.match(dark, /\.config\/scripts\/wallpapers\//);
  for (const name of ['dark.png', 'light.png']) {
    const image = fs.readFileSync(path.join(source, 'dot_config/scripts/wallpapers', name));
    assert.deepEqual([...image.subarray(0, 8)], [137, 80, 78, 71, 13, 10, 26, 10]);
  }
});

test('old skhd paths remain compatible through relative chezmoi symlinks', () => {
  const links = [
    ['scripts/symlink_slack_terminal.sh', 'scripts/slack_terminal.sh', 'scripts/slack_terminal.sh'],
    ['scripts/symlink_toggle_dark_mode.scpt', 'scripts/toggle_dark_mode.scpt', 'scripts/toggle_dark_mode.scpt'],
    ['scripts/symlink_toggle_input_mute.scpt', 'scripts/toggle_input_mute.scpt', 'scripts/toggle_input_mute.scpt'],
    ['resources/symlink_dark.png', 'resources/dark.png', 'scripts/wallpapers/dark.png'],
    ['resources/symlink_light.png', 'resources/light.png', 'scripts/wallpapers/light.png'],
  ];
  const root = path.join(path.sep, 'config');
  for (const [file, oldPath, newPath] of links) {
    const target = read(`dot_config/skhd/${file}`).trim();
    assert.equal(path.resolve(root, 'skhd', path.dirname(oldPath), target), path.join(root, newPath));
  }
});
