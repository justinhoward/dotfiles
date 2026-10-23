import test from 'node:test';
import assert from 'node:assert/strict';
import fs from 'node:fs';

const source = fs.readFileSync(new URL('../home/dot_config/stylus/github-terminal.user.css', import.meta.url), 'utf8');
const fixture = fs.readFileSync(new URL('fixtures/github-code.html', import.meta.url), 'utf8');
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
  assert.ok(fields[0].selectors.endsWith(':not(:where( #read-only-cursor-text-area, textarea[class*="Textarea__"]))'));
  assert.match(fields[0].body, /border-width:\s*1px\s*!important/);
  assert.match(fields[0].body, /border-color:\s*var\(--terminal-border\)\s*!important/);
  assert.doesNotMatch(fields[0].selectors, /\[readonly\]|aria-readonly/, 'Ordinary readonly fields still need form styling');
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
