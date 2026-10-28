import test from 'node:test';
import assert from 'node:assert/strict';
import fs from 'node:fs';

const source = fs.readFileSync(new URL('../home/dot_config/stylus/youtube-music-terminal.user.css', import.meta.url), 'utf8');
const github = fs.readFileSync(new URL('../home/dot_config/stylus/github-terminal.user.css', import.meta.url), 'utf8');
const css = source.replace(/\/\*[\s\S]*?\*\//g, '');

// Structural guards only; live app rendering needs separate browser checks.
function rules() {
  return [...css.matchAll(/([^{}]+)\{([^{}]*)\}/g)].map(([, selectors, body]) => ({
    selectors: selectors.trim().replace(/\s+/g, ' '), body,
  }));
}

function rule(selector) {
  const matches = rules().filter(entry => entry.selectors === selector);
  assert.equal(matches.length, 1, `Expected one rule for ${selector}`);
  return matches[0].body;
}

test('Music shares local fonts, palette and options, scoped to the HTTPS Music app', () => {
  assert.match(source, /@name\s+YouTube Music \/ terminal/);
  assert.match(source, /@version\s+1\.0\.1/);
  assert.match(source, /@var select appearance/);
  assert.match(source, /@var text fontFamily/);
  assert.match(source, /@var range fontSize/);
  assert.match(css, /@-moz-document url-prefix\("https:\/\/music\.youtube\.com\/"\)/);
  assert.doesNotMatch(css, /@import|@font-face|url\(/);
  for (const [, name, value] of source.matchAll(/(--terminal-[\w-]+): (light-dark\([^;]+\));/g)) {
    if (name === '--terminal-selected') continue;
    assert.ok(github.includes(`${name}: ${value};`), `Palette drift: ${name}`);
  }
  assert.match(css, /color-scheme:\s*var\(--appearance, light dark\)\s*!important/);
});

test('Music keeps its native rem unit, artwork, scrims, icons and player geometry', () => {
  assert.match(rule('html'), /font-size:\s*10px\s*!important/);
  assert.doesNotMatch(css, /--ytmusic-(?:color-white[\w-]*|color-black[\w-]*|static-[\w-]*|overlay-[\w-]*|nav-bar-height|player-bar-height|guide-width)\s*:/);
  assert.doesNotMatch(css, /(?:^|[;{])\s*(?:visibility|overflow[\w-]*|pointer-events|position|transform|filter|fill|stroke|z-index)\s*:/);
  for (const entry of rules().filter(entry => /(?:^|;)\s*display\s*:/.test(entry.body))) {
    assert.equal(entry.selectors, 'ytmusic-browse-response > #background.ytmusic-browse-response', 'Only the decorative browse backdrop may be hidden');
  }
  for (const entry of rules().filter(entry => /(?:^|;)\s*opacity\s*:/.test(entry.body))) {
    assert.ok(entry.selectors.split(', ').every(selector => selector.endsWith('::placeholder')));
  }
  assert.doesNotMatch(css, /(?:^|[;{])\s*font\s*:/);
  const fonts = rules().find(entry => entry.selectors.startsWith('*:not'));
  assert.ok(fonts.selectors.includes('svg *'));
  assert.ok(fonts.selectors.includes('.material-icons *'));
  assert.ok(fonts.selectors.includes('.html5-video-player *'));
  for (const entry of rules().filter(entry => entry.selectors.includes('ytmusic-player-bar'))) {
    assert.doesNotMatch(entry.body, /(?:^|;)\s*(?:height|width|padding[\w-]*|margin[\w-]*|line-height)\s*:/);
  }
  assert.ok(rule('ytmusic-player-bar:not([player-fullscreened])'));
});

test('browse pages have a flat canvas without hiding the gradient wrapper containing content', () => {
  assert.match(rule('ytmusic-browse-response > #background.ytmusic-browse-response'), /^\s*display:\s*none\s*!important;\s*$/);
  const canvas = rule('ytmusic-browse-response > .background-gradient.ytmusic-browse-response');
  assert.match(canvas, /^\s*background:\s*var\(--terminal-bg\)\s*!important;\s*$/);
  assert.doesNotMatch(css, /(?:^|;)\s*background-image:\s*(?:linear|radial)-gradient/);
});

test('both collapsed and expanded sidebars remain borderless in all scroll states', () => {
  const sidebar = rule('ytmusic-app #guide-wrapper.ytmusic-app, #mini-guide-background.ytmusic-app-layout');
  assert.match(sidebar, /^\s*border-right:\s*0\s*!important;\s*$/);
  assert.doesNotMatch(css, /\.content-scrolled[^{}]*\{/, 'Sidebar paint must not depend on scroll state');
});

test('local seek and volume tokens recolor paint without exposing hidden knobs', () => {
  const slider = rule('ytmusic-player-bar #progress-bar, ytmusic-player-bar .volume-slider, ytmusic-player-bar .expand-volume-slider');
  assert.match(slider, /--paper-slider-active-color:\s*var\(--terminal-blue\)\s*!important/);
  assert.match(slider, /--paper-slider-container-color:\s*var\(--terminal-border\)\s*!important/);
  const knobs = rules().filter(entry => /--paper-slider-knob-color:/.test(entry.body));
  assert.equal(knobs.length, 1);
  assert.ok(knobs[0].selectors.includes('ytmusic-player-bar:hover #progress-bar'));
  assert.ok(knobs[0].selectors.includes('ytmusic-player-bar #progress-bar[focused]'));
  assert.doesNotMatch(css, /--paper-slider-(?:height|knob-size|container-padding)\s*:/);
});

test('selected chips, primary and disabled buttons pair fill and text', () => {
  const selected = rules().find(entry => entry.selectors.startsWith('ytmusic-chip-cloud-chip-renderer[is-selected] a,'));
  assert.match(selected.body, /background:\s*var\(--terminal-selected\)/);
  assert.match(selected.body, /color:\s*var\(--terminal-blue\)/);
  const primary = rule('.ytSpecButtonShapeNextHost.ytSpecButtonShapeNextFilled');
  assert.match(primary, /background:\s*var\(--terminal-blue\)/);
  assert.match(primary, /color:\s*var\(--terminal-on-accent\)/);
  assert.match(rule('.ytSpecButtonShapeNextHost.ytSpecButtonShapeNextFilled:hover:not(:disabled, [aria-disabled="true"])'), /background-color:\s*color-mix\(in srgb, var\(--terminal-blue\)/);
  assert.match(rule('.ytSpecButtonShapeNextHost:is(.ytSpecButtonShapeNextDisabled, :disabled, [aria-disabled="true"])'), /color:\s*var\(--terminal-disabled\)/);
});

test('search and floating surfaces retain visible keyboard focus and boundaries', () => {
  assert.match(rule('ytmusic-search-box .search-box:focus-within'), /outline:\s*1px solid var\(--terminal-blue\)/);
  assert.match(rule(':focus-visible'), /outline:\s*1px solid var\(--terminal-blue\)/);
  assert.match(rule('ytmusic-menu-popup-renderer tp-yt-paper-listbox'), /border:\s*0\s*!important/);
  assert.match(css, /tp-yt-paper-tooltip #tooltip[^{}]*\{[^{}]*border:\s*1px solid var\(--terminal-border\)/);
  assert.match(rule('*::-webkit-scrollbar-thumb'), /border-radius:\s*0\s*!important/);
  for (const entry of rules().filter(entry => entry.selectors.includes('ytmusic-search-box'))) {
    assert.doesNotMatch(entry.body, /(?:^|;)\s*(?:height|width|padding[\w-]*|margin[\w-]*|position|display)\s*:/);
  }
});
