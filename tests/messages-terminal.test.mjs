import test from 'node:test';
import assert from 'node:assert/strict';
import fs from 'node:fs';

const source = fs.readFileSync(new URL('../home/dot_config/stylus/messages-terminal.user.css', import.meta.url), 'utf8');
const github = fs.readFileSync(new URL('../home/dot_config/stylus/github-terminal.user.css', import.meta.url), 'utf8');
const css = source.replace(/\/\*[\s\S]*?\*\//g, '');

// Structural guards only; these do not claim to validate a paired account.
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

test('Messages shares local fonts, palette and options, scoped to web app routes', () => {
  assert.match(source, /@name\s+Google Messages \/ terminal/);
  assert.match(source, /@version\s+1\.0\.2/);
  for (const setting of ['select appearance', 'text fontFamily', 'range fontSize']) {
    assert.ok(source.includes(`@var ${setting}`));
  }
  assert.match(css, /@-moz-document url-prefix\("https:\/\/messages\.google\.com\/web\/"\)/);
  assert.doesNotMatch(css, /@import|@font-face|url\(/);
  for (const [, name, value] of source.matchAll(/(--terminal-[\w-]+): (light-dark\([^;]+\));/g)) {
    if (name === '--terminal-selected') continue;
    assert.ok(github.includes(`${name}: ${value};`), `Palette drift: ${name}`);
  }
});

test('Material colors override body themes and match accent ink with fill', () => {
  const tokens = rule(':root, body');
  for (const name of ['background', 'surface', 'surface-container', 'on-surface', 'outline', 'primary', 'on-primary', 'error']) {
    assert.ok(tokens.includes(`--mat-sys-${name}: var(--terminal-`), `Missing Material ${name}`);
  }
  assert.match(tokens, /--mat-sys-on-primary:\s*var\(--terminal-on-accent\)\s*!important/);
  assert.match(tokens, /--focus-ring-color:\s*var\(--terminal-blue\)\s*!important/);
});

test('branded headers and the nested Google account bar use the shared page background', () => {
  assert.match(rule('mw-branded-header'), /--branded-header-bg-color:\s*var\(--terminal-bg\)\s*!important/);
  assert.match(rule('mw-landing-page-header'), /--landing-page-header-bg-color:\s*var\(--terminal-bg\)\s*!important/);
  const accountBar = rule('#gb');
  assert.match(accountBar, /--og-bar-background:\s*var\(--terminal-bg\)\s*!important/);
  assert.match(accountBar, /background-color:\s*var\(--terminal-bg\)\s*!important/);
  assert.match(accountBar, /(?:^|;)\s*color:\s*var\(--terminal-fg\)\s*!important/);
  assert.doesNotMatch(accountBar, /(?:^|;)\s*(?:height|width|padding[\w-]*|margin[\w-]*|border)\s*:/);
});

test('incoming, SMS and RCS bubbles keep distinct fills with readable edit and selection states', () => {
  const bubbles = rule('mws-message-part-content');
  assert.match(bubbles, /--incoming-bg-color:\s*var\(--terminal-surface\)/);
  assert.match(bubbles, /--rcs-incoming-bg-color:\s*var\(--terminal-surface\)/);
  for (const protocol of ['xms', 'rcs']) {
    assert.ok(bubbles.includes(`--${protocol}-outgoing-bg-color: var(--terminal-selected)`));
    assert.ok(bubbles.includes(`--${protocol}-outgoing-color: var(--terminal-fg)`));
    assert.ok(bubbles.includes(`--${protocol}-outgoing-edit-color: var(--terminal-fg)`));
    assert.ok(bubbles.includes(`--${protocol}-outgoing-selection-bg-color: var(--terminal-hover)`));
  }
  assert.match(rule(':root body.material-next-msg mws-message-part-content.is-focused.incoming'), /background:\s*var\(--terminal-hover\)\s*!important/);
  assert.match(rule('mws-message-status'), /--msg-info-failed-color:\s*var\(--terminal-red\)/);
  assert.match(rule('mws-message-status'), /--msg-status-read-icon-color:\s*var\(--terminal-blue\)/);
  assert.match(rule('.text-msg a'), /color:\s*var\(--terminal-blue\)/);
});

test('composer owns one field boundary and supports both textarea and contenteditable inputs', () => {
  const composer = rule('mws-message-compose');
  assert.match(composer, /--message-compose-input-border-override:\s*1px solid var\(--terminal-border\)/);
  assert.match(composer, /--input-bg-color:\s*var\(--terminal-inset\)/);
  assert.match(rule('mws-message-compose .input-box:focus-within'), /outline:\s*1px solid var\(--terminal-blue\)/);
  assert.ok(rule('mws-message-compose :is(input, textarea, [contenteditable="true"]):focus-visible'));
  assert.match(rule('input, textarea, select, [data-e2e-message-input-box]'), /color:\s*var\(--terminal-fg\)/);
  assert.match(rule('mw-fab-link'), /--fab-label-color:\s*var\(--terminal-on-accent\)/);
});

test('QR pixels, media, emoji and icon fonts keep native rendering and hit targets', () => {
  assert.doesNotMatch(css, /(?:^|[;{])\s*(?:visibility|overflow[\w-]*|pointer-events|position|transform|filter|fill|stroke|z-index|line-height|font)\s*:/);
  for (const entry of rules().filter(entry => /(?:^|;)\s*display\s*:/.test(entry.body))) {
    assert.equal(entry.selectors, '#gb :is(.gb_X, .gb_Z)', 'Only decorative account rings may be hidden');
  }
  for (const entry of rules().filter(entry => /(?:^|;)\s*opacity\s*:/.test(entry.body))) {
    assert.ok(entry.selectors.split(', ').every(selector => selector.endsWith('::placeholder')));
  }
  assert.doesNotMatch(css, /--(?:mat|mdc)-[\w-]*(?:height|width|size|padding|touch-target)[\w-]*\s*:(?!\s*var\(--terminal-size)/);
  assert.doesNotMatch(css, /(?:^|;)\s*(?:height|width|padding[\w-]*|margin[\w-]*)\s*:(?!\s*8px)/);
  assert.doesNotMatch(css, /(?:^|})\s*(?:img|video|canvas|svg|mws-message-wrapper)\b[^{}]*\{/);
  const fonts = rules().find(entry => entry.selectors.startsWith('*:not'));
  for (const exception of ['.material-icons *', '.google-symbols *', 'mat-icon *', 'svg *', '.emoji *', '.animated-emoji *']) {
    assert.ok(fonts.selectors.includes(exception), `Missing font exclusion: ${exception}`);
  }
});

test('only Google account ring layers are hidden, not the photo, account action or focus', () => {
  const hidden = rules().filter(entry => /display:\s*none/.test(entry.body));
  assert.equal(hidden.length, 1);
  assert.equal(hidden[0].selectors, '#gb :is(.gb_X, .gb_Z)');
  assert.match(hidden[0].body, /^\s*display:\s*none\s*!important;\s*$/);
  assert.match(rule(':focus-visible'), /outline:\s*1px solid var\(--terminal-blue\)/);
});

test('portaled surfaces, focus and square scrollbars remain visible without elevation', () => {
  const surfaces = rule('.mat-mdc-dialog-surface, .mat-mdc-menu-panel, .mat-mdc-select-panel, .mat-mdc-tooltip-surface, .mat-mdc-snackbar-surface');
  assert.match(surfaces, /background:\s*var\(--terminal-surface\)/);
  assert.match(surfaces, /color:\s*var\(--terminal-fg\)/);
  assert.match(surfaces, /border:\s*1px solid var\(--terminal-border\)/);
  assert.match(rule(':focus-visible'), /outline:\s*1px solid var\(--terminal-blue\)/);
  assert.match(rule('*::-webkit-scrollbar-thumb'), /border-radius:\s*0\s*!important/);
});
