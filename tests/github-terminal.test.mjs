import test from 'node:test';
import assert from 'node:assert/strict';
import fs from 'node:fs';

const source = fs.readFileSync(new URL('../home/dot_config/stylus/github-terminal.user.css', import.meta.url), 'utf8');
const fixture = fs.readFileSync(new URL('fixtures/github-code.html', import.meta.url), 'utf8');
const copilot = fs.readFileSync(new URL('fixtures/github-copilot.html', import.meta.url), 'utf8');
const legacyCopilot = fs.readFileSync(new URL('fixtures/github-copilot-legacy.html', import.meta.url), 'utf8');
const css = source.replace(/\/\*[\s\S]*?\*\//g, '');

// Structural guards only; the fixture also supports separate browser checks.
function rules() {
  return [...css.matchAll(/([^{}]+)\{([^{}]*)\}/g)].map(([, selectors, body]) => ({
    selectors: selectors.trim().replace(/\s+/g, ' '), body,
  }));
}

test('code-view textareas are excluded from generic form-field paint and borders', () => {
  const fields = rules().filter(entry => entry.selectors.includes('textarea')
    && /background-color:\s*var\(--terminal-inset\)/.test(entry.body)
    && /(?:^|;)\s*color:\s*var\(--terminal-fg\)/.test(entry.body));
  assert.equal(fields.length, 1);
  assert.match(fields[0].selectors, /^:is\(\.form-control, \.form-select, \.TextInput-wrapper, textarea,/);
  assert.ok(fields[0].selectors.endsWith(':not(:where( #read-only-cursor-text-area, textarea[class*="Textarea__"], [class*="chatForm__"] textarea, [data-copilot-chat-input="true"]))'));
  assert.match(fields[0].body, /border-width:\s*1px\s*!important/);
  assert.match(fields[0].body, /border-color:\s*var\(--terminal-border\)\s*!important/);
  assert.doesNotMatch(fields[0].selectors, /\[readonly\]|aria-readonly/, 'Ordinary readonly fields still need form styling');
});

test('legacy Copilot keeps native transparent editor paint and preview metrics', () => {
  const layers = rules().filter(entry => entry.selectors.includes('[class*="chatForm__"] textarea')
    && !entry.selectors.startsWith(':is('));
  assert.equal(layers.length, 2);
  for (const entry of layers) {
    assert.doesNotMatch(entry.body, /(?:^|;)\s*(?:background(?:-color)?|color|border(?:-width|-color)?|display|visibility|opacity|pointer-events|position|z-index|width|height|padding|margin|font-size|line-height)\s*:/);
  }
  const fonts = layers.find(entry => entry.body.includes('font-family:'));
  assert.ok(fonts.selectors.includes('[class*="chatForm__"] [class*="inputPreview__"]'));
  assert.match(fonts.body, /font-family:\s*var\(--terminal-font\)\s*!important/);
  const disabled = rules().find(entry => entry.selectors.includes(':disabled')
    && entry.body.includes('background-color: var(--terminal-surface)'));
  assert.ok(disabled.selectors.includes(':disabled:not(:where( [class*="chatForm__"] textarea, [data-copilot-chat-input="true"]))'));
  assert.ok(legacyCopilot.includes('class="input__Kzrn2s"'));
  assert.ok(legacyCopilot.includes('class="inputPreview__N7C-Uo"'));
  assert.ok(legacyCopilot.includes('class="mention__LppmWE"'));
  assert.doesNotMatch(legacyCopilot, /<script|<iframe|https?:/i);
});

test('Copilot has one thin composer focus boundary without suppressing toolbar focus', () => {
  const composer = rules().find(entry => entry.selectors === '[data-testid="chat-composer-container"], [class*="chatForm__"]');
  assert.match(composer.body, /background-color:\s*var\(--terminal-inset\)\s*!important/);
  assert.match(composer.body, /border:\s*1px solid var\(--terminal-border\)\s*!important/);
  const focus = rules().find(entry => entry.selectors === '[data-testid="chat-composer-container"]:has([data-copilot-chat-input="true"]:focus), [class*="chatForm__"]:focus-within');
  assert.match(focus.body, /outline:\s*1px solid var\(--terminal-blue\)\s*!important/);
  assert.match(focus.body, /outline-offset:\s*-1px\s*!important/);
  const inner = rules().find(entry => entry.selectors === 'textarea[data-copilot-chat-input="true"]:focus-visible, [class*="chatForm__"] textarea:focus-visible');
  assert.match(inner.body, /outline:\s*none\s*!important/);
  const suppressed = rules().filter(entry => /outline:\s*none/.test(entry.body));
  assert.ok(suppressed.every(entry => !/button|\*/.test(entry.selectors.replace(/\[class\*="[^"]+"\]/g, ''))));
});

test('current Copilot targets captured attributes and leaves visible text and content-box autosizing native', () => {
  assert.ok(copilot.includes('data-testid="chat-composer-container"'));
  assert.ok(copilot.includes('data-copilot-chat-input="true" data-testid="chat-composer-input"'));
  assert.ok(copilot.includes('class="Input__BVltzR InputCssAutosize__cjWBCU responsiveText__Jbmxp6"'));
  assert.ok(copilot.includes('box-sizing: content-box; field-sizing: content; overflow-wrap: anywhere;'));
  assert.ok(copilot.includes('color: var(--fgColor-default);'));
  assert.ok(copilot.includes('>Visible Copilot input text</textarea>'));
  assert.doesNotMatch(copilot, /inputPreview__|<script|<iframe|https?:/i);
  const current = rules().filter(entry => /data-copilot-chat-input|chat-composer-container/.test(entry.selectors));
  assert.equal(current.length, 5);
  for (const entry of current) {
    assert.doesNotMatch(entry.body, /(?:^|;)\s*(?:box-sizing|field-sizing|overflow(?:-wrap|-y)?|display|visibility|opacity|pointer-events|position|z-index|width|height|min-height|padding(?:-inline)?|margin|font-size|line-height)\s*:/);
    assert.doesNotMatch(entry.body, /(?:^|;)\s*color:\s*transparent/);
  }
  const focus = current.find(entry => entry.selectors.includes(':has('));
  assert.ok(focus.selectors.includes('[data-copilot-chat-input="true"]:focus'), 'The outer ring follows the editor, not the toolbar or environment strip');
  assert.doesNotMatch(focus.selectors, /chat-composer-container"\]:focus-within/);
});

test('legacy selection layer shares highlighted code size and ligature settings', () => {
  for (const property of ['font-size', 'font-variant-ligatures']) {
    const matches = rules().filter(entry => entry.selectors.includes('#read-only-cursor-text-area')
      && entry.body.includes(`${property}:`));
    assert.equal(matches.length, 1);
    assert.ok(matches[0].selectors.includes('.react-code-text'));
    assert.match(matches[0].body, new RegExp(`${property}:\\s*(?:var\\(--terminal-size\\)|none)\\s*!important`));
  }
});

test('selection layers retain native interaction, geometry and plain-text visibility', () => {
  const layers = rules().filter(entry => /#read-only-cursor-text-area|Textarea__/.test(entry.selectors));
  for (const entry of layers) {
    assert.doesNotMatch(entry.body, /(?:^|;)\s*(?:display|visibility|opacity|pointer-events|position|z-index|width|height|padding|margin|line-height)\s*:/);
    assert.doesNotMatch(entry.body, /(?:^|;)\s*color:\s*transparent/, 'Do not force plain-text or high-contrast modes invisible');
  }
  assert.ok(fixture.includes('id="read-only-cursor-text-area"'));
  assert.ok(fixture.includes('color:transparent;border:none;font-size:12px'));
  assert.ok(fixture.includes('class="Textarea__Wm0Vhs plainText__p1L5A3"'));
  assert.ok(fixture.includes('id="comment" class="form-control"'));
  assert.ok(fixture.includes('id="readonly-field" readonly'));
  assert.doesNotMatch(fixture, /<script|<iframe|https?:|apple_webhook|jffmrk/i);
});
