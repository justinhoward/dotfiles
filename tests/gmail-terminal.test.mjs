import test from 'node:test';
import assert from 'node:assert/strict';
import fs from 'node:fs';

const source = fs.readFileSync(new URL('../home/dot_config/stylus/gmail-terminal.user.css', import.meta.url), 'utf8');
const css = source.replace(/\/\*[\s\S]*?\*\//g, '');

// These are structural regression guards, not a CSS parser or browser test.
// This stylesheet has no braces in string values; check that assumption too.
assert.doesNotMatch(css, /"[^"\n]*[{}][^"\n]*"/);
const scopeStart = css.indexOf('@scope');
assert.ok(scopeStart >= 0);
const scopeOpen = css.indexOf('{', scopeStart);
let depth = 1;
let scopeEnd = scopeOpen + 1;
for (; scopeEnd < css.length && depth; scopeEnd++) {
  if (css[scopeEnd] === '{') depth++;
  if (css[scopeEnd] === '}') depth--;
}
assert.equal(depth, 0, 'Scope must close before the document canvas rules');
const shell = css.slice(scopeOpen + 1, scopeEnd - 1);
const outside = css.slice(0, scopeStart) + css.slice(scopeEnd);

function rules(text) {
  return [...text.matchAll(/([^{}]+)\{([^{}]*)\}/g)].map(([, selectors, body]) => ({
    selectors: selectors.trim().replace(/\s+/g, ' '), body,
  }));
}

function rule(selector, text = shell) {
  const matches = rules(text).filter(entry => entry.selectors === selector);
  assert.equal(matches.length, 1, `Expected one rule for ${selector}`);
  return matches[0].body;
}

test('every shell rule is inside the message/editor exclusion scope', () => {
  assert.equal(css.slice(scopeStart, scopeOpen).trim(), '@scope (:root) to (.a3s, [contenteditable="true"])');
  assert.equal((css.match(/@scope/g) || []).length, 1);
  assert.deepEqual(rules(outside).map(entry => entry.selectors), [
    ':root',
    '.a3s, [contenteditable="true"]',
    '.a3s, [contenteditable="true"][role="textbox"], .Am[contenteditable="true"], .Ar[contenteditable="true"]',
    '.a3s::selection, .a3s *::selection, [contenteditable="true"]::selection, [contenteditable="true"] *::selection',
  ]);
  assert.match(rule('.a3s, [contenteditable="true"][role="textbox"], .Am[contenteditable="true"], .Ar[contenteditable="true"]', outside), /color-scheme:\s*light\s*!important/);
});

test('native glyphs are not flattened by whole-control filters or image resets', () => {
  const filters = rules(css).filter(entry => /(?:^|;)\s*(?:-webkit-)?filter\s*:/.test(entry.body));
  assert.deepEqual(filters.map(entry => entry.selectors), [
    ':is(.aaZ, .HM, .I5) :is(.aaB, .aaC, .a1, .aA7, .eT, .eU, .J-Z-M-I-JG):not(:has(svg)), :is(.aaZ, .HM, .I5) .az2 .J-JN-M-I-JG',
  ], 'Only the composer\'s legacy glyph layers may be filtered');
  assert.match(filters[0].body, /filter:\s*brightness\(0\) invert\(1\)\s*!important/);
  assert.match(filters[0].body, /mix-blend-mode:\s*difference\s*!important/);
  assert.doesNotMatch(rule('.T-I'), /background-image\s*:/);
  assert.doesNotMatch(rule('.G-atb .T-I, .G-atb .bzn, .G-atb .amJ'), /background-image\s*:/);
});

test('Compose shares Calendar Create sizing without resizing Send or other primary actions', () => {
  const calendar = fs.readFileSync(new URL('../home/dot_config/stylus/calendar-terminal.user.css', import.meta.url), 'utf8');
  const height = rule(':root', outside).match(/--terminal-compose-height:\s*([^;]+);/)[1];
  assert.equal(height, calendar.match(/--terminal-create-height:\s*([^;]+);/)[1]);
  const compose = rule('.aeN .z0 > .T-I.T-I-KE');
  assert.match(compose, /height:\s*var\(--terminal-compose-height\)\s*!important/);
  assert.match(compose, /min-height:\s*0\s*!important/);
  assert.match(compose, /padding-block:\s*4px\s*!important/);
  assert.match(compose, /line-height:\s*1\.25\s*!important/);
  assert.match(compose, /box-sizing:\s*border-box\s*!important/);
  assert.doesNotMatch(rule('.T-I.T-I-KE, .T-I.T-I-atl, .btA .Uo'), /(?:^|;)\s*(?:height|width|padding|line-height)\s*:/);
});

test('Compose fills the expanded sidebar with gutters while preserving collapsed width and native glyphs', () => {
  const wrapper = rule('.aeN:not(.bhZ) .z0:has(> .T-I.T-I-KE)');
  assert.match(wrapper, /padding-inline:\s*16px\s*!important/);
  assert.match(wrapper, /box-sizing:\s*border-box\s*!important/);
  const stretch = rule('.aeN:not(.bhZ) .z0 > .T-I.T-I-KE');
  assert.match(stretch, /width:\s*100%\s*!important/);
  assert.match(stretch, /min-width:\s*0\s*!important/);
  assert.match(stretch, /margin-inline:\s*0\s*!important/);
  assert.match(stretch, /padding-inline:\s*12px\s*!important/);
  assert.match(rule('.aeN:not(.bhZ) .z0 > .T-I.T-I-KE::before'), /margin-inline:\s*0 8px\s*!important/);
  for (const entry of rules(shell).filter(entry => entry.selectors.includes('.z0'))) {
    assert.doesNotMatch(entry.body, /(?:^|;)\s*(?:display|visibility|position|z-index|pointer-events|transform|background(?:-image|-size)?|content)\s*:/);
    if (/(?:^|;)\s*(?:width|min-width|padding-inline|margin-inline)\s*:/.test(entry.body)) {
      assert.ok(entry.selectors.startsWith('.aeN:not(.bhZ)'), 'Do not stretch or reposition collapsed Compose');
    }
  }
});

test('Compose wrappers reclaim fixed FAB height without changing native vertical margins', () => {
  const wrappers = rule('.aeN .aic:has(.z0 > .T-I.T-I-KE), .aeN .z0:has(> .T-I.T-I-KE)');
  assert.match(wrappers, /height:\s*auto\s*!important/);
  assert.match(wrappers, /min-height:\s*0\s*!important/);
  assert.doesNotMatch(wrappers, /(?:^|;)\s*(?:margin[\w-]*|padding[\w-]*|width|position|display)\s*:/);
});

test('inbox separators paint at the row edge without adding cell borders', () => {
  assert.match(rule('.zA'), /box-shadow:\s*inset 0 -1px 0 var\(--terminal-row-line\)\s*!important/);
  assert.match(rule('.zA > td'), /border-bottom:\s*0\s*!important/);
  assert.doesNotMatch(rule('.zA'), /(?:^|[;{])\s*(?:height|padding|line-height)\s*:/);
  assert.match(rule('.zA.x7, .zA.x7:hover, .zA[aria-selected="true"]'), /--terminal-row-line:\s*var\(--terminal-blue\)/);
});

test('keyboard focus uses a full-row rail, preserving native indicator dimensions', () => {
  assert.match(rule('.zA.btb, .zA:has(> .PF.PE), .zA:focus-visible'), /box-shadow:\s*inset 2px 0 0 var\(--terminal-blue\)/);
  assert.doesNotMatch(rule('.zA > .PF.PE'), /(?:^|[;{])\s*(?:border|width|height|padding|margin)\s*:/);
  assert.match(rule('.zA > .PF.PE'), /border-color:\s*transparent\s*!important/);
  assert.doesNotMatch(shell, /\.zA\.Wz/);
  assert.ok(rule(':focus-visible:not(.zA)'));
});

test('subject and image/translation banners pair themed backgrounds with readable text', () => {
  for (const selector of [
    '.if, .ha, .adn, .adx, .adf, .aHU, .aBj, .aDl, .aYF',
    '.adp, .ado, .h9, .adI',
  ]) {
    const body = rule(selector);
    assert.match(body, /background-color:\s*var\(--terminal-(?:bg|surface)\)\s*!important/);
    assert.match(body, /(?:^|;)\s*color:\s*var\(--terminal-fg\)\s*!important/);
  }
  assert.match(rule('.hP'), /background-color:\s*transparent\s*!important/);
});

test('captured conversation wrappers are themed, not just the inner subject', () => {
  const fixture = fs.readFileSync(new URL('fixtures/gmail-conversation.html', import.meta.url), 'utf8');
  for (const classes of ['V8djrc byY', 'gE iv gt', 'hq gt', 'nH btDi4d rT5Apb tyMQmc', 'nr wR']) {
    assert.ok(fixture.includes(`class="${classes}"`), `Missing captured wrapper ${classes}`);
  }
  const wrappers = rule('.a98.iY, .a98.iY > .nH, .a98.iY :is(.V8djrc.byY, .hj, .bHJ, .h7, .Bk, .G3.G2, .gE, .gA, .gB, .ip, .amr, .nr.wR, .hq, .btDi4d)');
  assert.match(wrappers, /background:\s*var\(--terminal-bg\)\s*!important/);
  assert.match(wrappers, /(?:^|;)\s*color:\s*var\(--terminal-fg\)\s*!important/);
  assert.doesNotMatch(wrappers, /(?:^|;)\s*(?:width|height|padding|margin|position)\s*:/);
  assert.match(rule('.a98.iY .nr.wR .ams'), /background:\s*var\(--terminal-surface\)\s*!important/);
  assert.match(rule('.a98.iY .nr.wR .ams'), /(?:^|;)\s*color:\s*var\(--terminal-fg\)\s*!important/);
});

test('current conversation buttons inherit paired text/icon colors without changing importance', () => {
  const buttons = '.a98.iY :is(button.pYTkkf-JX-I:not(.FqWqLc), button.jWOS7-JX-I)';
  assert.match(rule(buttons), /(?:^|;)\s*color:\s*var\(--terminal-fg\)\s*!important/);
  assert.match(rule(`${buttons}:is(:disabled, [aria-disabled="true"])`), /(?:^|;)\s*color:\s*var\(--terminal-disabled\)\s*!important/);
  assert.match(rule(`${buttons}[aria-pressed="true"]`), /background-color:\s*var\(--terminal-selected\)\s*!important/);
  assert.match(rule('.a98.iY :is(button.pYTkkf-JX-I:not(.FqWqLc), button.jWOS7-JX-I, button.UywwFc-I) svg.aoH'), /fill:\s*currentColor\s*!important/);
  assert.doesNotMatch(shell, /svg[^{}]*path\s*\{/);
});

test('sticky toolbar backdrop and edge fades match the bar without hiding them', () => {
  const fixture = fs.readFileSync(new URL('fixtures/gmail-scroll-header.html', import.meta.url), 'utf8');
  assert.ok(fixture.includes('class="D E G-atb PY" gh="tm"'));
  const backdrop = rule('.G-atb[gh="tm"], .G-atb[gh="tm"] > .G6, .G-atb[gh="tm"]::after, .G-atb[gh="tm"] > .G6::after');
  assert.match(backdrop, /background:\s*var\(--terminal-bg\)\s*!important/);
  assert.doesNotMatch(backdrop, /(?:^|;)\s*(?:display|content|position|z-index|width|height)\s*:/);
  assert.match(rule('.G-atb .YhbRke > .a5D.Ym'), /linear-gradient\(to right, var\(--terminal-bg\), transparent\)/);
  assert.match(rule('.G-atb .YhbRke > .a5D.Yn'), /linear-gradient\(to left, var\(--terminal-bg\), transparent\)/);
  assert.match(rule('.G-atb .H2:is(.bws, [aria-pressed="true"])'), /background:\s*var\(--terminal-selected\)\s*!important/);
});

test('square WebKit scrollbar geometry is opt-in, while Firefox keeps standard scrollbar styling', () => {
  assert.match(shell, /@supports selector\(::-webkit-scrollbar\)/);
  const defaults = rules(shell).filter(entry => entry.selectors === '*').map(entry => entry.body);
  assert.ok(defaults.some(body => /scrollbar-width:\s*thin/.test(body)));
  assert.ok(defaults.some(body => /scrollbar-width:\s*auto\s*!important/.test(body)));
  assert.match(rule('*::-webkit-scrollbar-thumb'), /border-radius:\s*0\s*!important/);
  assert.match(rule('*::-webkit-scrollbar-track, *::-webkit-scrollbar-corner'), /border-radius:\s*0\s*!important/);
  assert.match(rule('*::-webkit-scrollbar'), /width:\s*8px\s*!important/);
});

test('Material colors map at nested Gmail theme scopes, not only the page root', () => {
  const themes = rules(shell).find(entry => entry.selectors.startsWith(':root, body, #gb,'));
  assert.ok(themes);
  for (const owner of ['.bkL', '.qp', '.GYfbG', '.MxSLJe', '.a98', '.IU', '.r4', '.Z3l91d']) {
    assert.ok(themes.selectors.split(', ').includes(owner), `Missing native theme owner ${owner}`);
  }
  for (const [name, value] of [
    ['surface', 'bg'], ['on-surface', 'fg'], ['on-surface-variant', 'muted'],
    ['primary', 'blue'], ['on-primary', 'on-accent'], ['surface-container', 'surface'],
    ['outline-variant', 'border'], ['error', 'red'],
  ]) {
    assert.ok(themes.body.includes(`--gm3-sys-color-${name}: var(--terminal-${value}) !important;`));
  }
  assert.doesNotMatch(themes.body, /(?:^|;)\s*(?![\s-])\w[\w-]*\s*:/, 'Theme layer must contain only custom properties');
});

test('all added inherited Google tokens have a document/editor-root reset', () => {
  const reset = rule('.a3s, [contenteditable="true"]', outside);
  const names = new Set([...shell.matchAll(/(--(?:gm3|og)-[\w-]+)\s*:/g)].map(match => match[1]));
  assert.ok(names.size > 40);
  for (const name of names) {
    assert.match(reset, new RegExp(`${name}:\\s*(?:#[0-9a-f]+|initial)\\s*!important;`), `Inherited token not reset: ${name}`);
  }
  assert.doesNotMatch(reset, /var\(--terminal-/);
  assert.doesNotMatch(reset, /(?:^|;)\s*(?![\s-])\w[\w-]*\s*:/, 'Document reset must only change custom properties');
  assert.match(reset, /--gm3-sys-color-on-surface:\s*#1f1f1f\s*!important/);
  assert.match(reset, /--gm3-sys-color-on-surface-rgb:\s*31, 31, 31\s*!important/);
});

test('Material disabled states avoid incompatible RGB token replacements', () => {
  assert.doesNotMatch(shell, /--gm3-sys-color-[\w-]+-rgb\s*:/);
  const disabled = rule('.pYTkkf-JX-I, .VYBDae-JX-I, .wX4xVc-JX-I, .jWOS7-JX-I, .mUIrbf-I, .UywwFc-I, .FOBRw-I');
  assert.match(disabled, /--gm3-icon-button-filled-tonal-disabled-icon-color:\s*var\(--terminal-disabled\)\s*!important/);
  assert.match(disabled, /--gm3-icon-button-filled-tonal-disabled-container-color:\s*var\(--terminal-surface\)\s*!important/);
  assert.doesNotMatch(disabled, /unselected-icon-color|selected-icon-color|(?:^|;)\s*color\s*:/, 'Importance-selected colors must stay local/native');
});

test('Material text uses label tokens without changing icon font or layout tokens', () => {
  const labels = rule('.mUIrbf-I, .UywwFc-I, .FOBRw-I');
  assert.match(labels, /--gm3-button-text-label-text-font:\s*var\(--terminal-font\)\s*!important/);
  const menu = rule('.O68mGe-M, .aqdrmf-Kf-J8');
  assert.match(menu, /--gm3-list-list-item-label-text-font:\s*var\(--terminal-font\)\s*!important/);
  assert.doesNotMatch(shell, /--gm3-[\w-]*(?:icon-size|line-height|container-height|touch-target-size|label-text-weight)\s*:/);
  assert.match(rule('.tB5Jxf-M-X .O68mGe-M, .tB5Jxf-M-X [role="menu"]'), /border:\s*0\s*!important/);
});

test('Material fixture covers nested themes, disabled states and document class collisions without private data', () => {
  const fixture = fs.readFileSync(new URL('fixtures/gmail-material.html', import.meta.url), 'utf8');
  for (const classes of ['nH aqk aql bkL', 'GYfbG j1GQLc', 'MxSLJe', 'a3s aiL', 'pYTkkf-JX-I FqWqLc bns', 'wX4xVc-JX-I']) {
    assert.ok(fixture.includes(`class="${classes}"`), `Missing ${classes}`);
  }
  assert.ok(fixture.includes('rgba(var(--gm3-sys-color-on-surface-rgb, 31, 31, 31), .38)'));
  assert.doesNotMatch(fixture, /<script|<iframe|https?:|data-message-id=|data-legacy-message-id=|jslog=|[\w.+-]+@[\w.-]+/i);
});

test('Gmail and Calendar share compact header sizing without blanket control/image resets', () => {
  const calendar = fs.readFileSync(new URL('../home/dot_config/stylus/calendar-terminal.user.css', import.meta.url), 'utf8')
    .replace(/\/\*[\s\S]*?\*\//g, '')
    .replace(/body:not\(\[data-viewfamily="EVENT_EDIT"\], \[data-viewfamily="PROPOSE_TIME"\]\) /g, '');
  assert.match(rule(':root', outside), /--terminal-header-height:\s*56px/);
  assert.match(rule(':root', outside), /--terminal-header-control-size:\s*40px/);
  const common = rules(shell).filter(entry => entry.selectors.startsWith('#gb[role="banner"]') && !entry.selectors.includes('.bas'));
  assert.ok(common.length >= 10);
  for (const entry of common) {
    assert.equal(rule(entry.selectors, calendar).replace(/\s+/g, ' ').trim(), entry.body.replace(/\s+/g, ' ').trim(), `Header drift: ${entry.selectors}`);
    assert.doesNotMatch(entry.body, /(?:^|;)\s*(?:overflow|display|visibility|transform|filter|position)\s*:/);
  }
  assert.match(rule('#gb[role="banner"] > .gb_Vd'), /padding:\s*3px 8px\s*!important/);
  assert.doesNotMatch(rule('#gb[role="banner"] > .gb_Vd'), /(?:^|;)\s*(?:height|min-height|max-height)\s*:/);
});

test('Gmail search leaves table/ghost inputs, buttons and containing rows to native layout', () => {
  const geometry = /(?:^|;)\s*(?:height|min-height|max-height|width|min-width|max-width|padding[\w-]*|margin[\w-]*|box-sizing|border|border-width|position|top|left|right|bottom|display|visibility|transform|pointer-events|z-index)\s*:/;
  for (const entry of rules(shell).filter(entry => entry.selectors.includes('[role="search"]'))) {
    assert.doesNotMatch(entry.body, geometry, `Search geometry override: ${entry.selectors}`);
  }
  assert.doesNotMatch(shell, /\.gb_(?:Ne|Le|Ve|4d|Ee|Fe)\b|\.gstt\b/, 'Do not resize search internals or their containing rows');
  assert.match(rule('#gb form[role="search"]'), /outline:\s*1px solid var\(--terminal-border\)/);
  assert.match(shell, /@media screen\s*\{\s*#gb\[role="banner"\]/);
  const fixture = fs.readFileSync(new URL('fixtures/google-header.html', import.meta.url), 'utf8');
  for (const classes of ['gb_Vd gb_Zd gb_dd', 'gb_4d gb_Cd gb_Dd', 'gb_Ne gb_1e', 'gstl_50 gstt', 'gb_Le aJh afOp8c v1GPYd']) {
    assert.ok(fixture.includes(`class="${classes}"`), `Missing header/search structure ${classes}`);
  }
  assert.doesNotMatch(fixture, /<script|<iframe|https?:|data-message-id=|jslog=|[\w.+-]+@[\w.-]+/i);
});

test('border-box menu controls retain a 24px glyph in both dimensions', () => {
  // The shared-header test above also requires this exact rule in Calendar.
  const menu = rule('#gb[role="banner"] > .gb_Vd .gb_cd');
  assert.match(menu, /width:\s*var\(--terminal-header-control-size\)\s*!important/);
  assert.match(menu, /height:\s*var\(--terminal-header-control-size\)\s*!important/);
  assert.match(menu, /box-sizing:\s*border-box\s*!important/);
  const row = Number(rule(':root', outside).match(/--terminal-header-control-size:\s*(\d+)px/)[1]);
  const padding = Number(menu.match(/(?:^|;)\s*padding:\s*(\d+)px\s*!important/)[1]);
  assert.equal(row - 2 * padding, 24, 'Both button dimensions must leave 24px after padding');
  const fixture = fs.readFileSync(new URL('fixtures/google-header.html', import.meta.url), 'utf8');
  assert.match(fixture, /\.gb_cd \{ width: 24px; height: 24px; padding: 12px; \}/);
});

test('advanced-search surfaces and labels have paired colors without repositioning the panel', () => {
  const surfaces = rule('.ZF-zT, .ZF-z6, .ZF-Av :is(.lJ, .lN), .ZF-z6 .SK.z6');
  assert.match(surfaces, /background-color:\s*var\(--terminal-surface\)\s*!important/);
  assert.match(surfaces, /(?:^|;)\s*color:\s*var\(--terminal-fg\)\s*!important/);
  assert.match(rule('.ZF-zT :is(.ZZ, label, legend, .w-Pw, .w-Py, .w-Pz)'), /color:\s*var\(--terminal-fg\)\s*!important/);
  for (const entry of rules(shell).filter(entry => entry.selectors.startsWith('.ZF-'))) {
    assert.doesNotMatch(entry.body, /(?:^|;)\s*(?:height|width|position|top|left|right|bottom|visibility|display|padding|margin|z-index|pointer-events)\s*:/);
  }
  const fixture = fs.readFileSync(new URL('fixtures/gmail-advanced-search.html', import.meta.url), 'utf8');
  for (const classes of ['ZF-Av', 'SK ZF-zT', 'ZZ', 'lJ', 'lN', 'w-Pw']) assert.ok(fixture.includes(`class="${classes}"`));
  assert.doesNotMatch(fixture, /<script|<iframe|https?:|data-message-id=|jslog=|[\w.+-]+@[\w.-]+/i);
});

test('recipient and title fields keep native geometry instead of acquiring generic inset boxes', () => {
  const fields = rule('.aoT, .aoD input, .aoD textarea, :is(.AD, .aaZ, .HM, .I5) :is(input, textarea)');
  assert.match(fields, /background-color:\s*transparent\s*!important/);
  assert.match(fields, /color:\s*var\(--terminal-fg\)\s*!important/);
  assert.doesNotMatch(fields, /(?:^|;)\s*(?:border|padding|margin|height|width|outline|position|display)\s*:/);
  const generic = rules(shell).find(entry => entry.selectors.startsWith(':is(input:not([type="checkbox"]'));
  assert.ok(generic);
  for (const owner of ['.AD', '.aaZ', '.HM', '.I5', '.aoD']) {
    assert.ok(generic.selectors.includes(`${owner} *`), `Composer fields must be excluded: ${owner}`);
  }
});

test('composer toolbar surfaces and states remain readable without changing controls or Send', () => {
  const prefix = ':is(.aaZ, .HM, .I5)';
  assert.match(rule(`${prefix} :is(.btC, .aZ .J-Z)`), /background-color:\s*var\(--terminal-surface\)\s*!important/);
  assert.match(rule(`${prefix} :is(.J-Z-I, .J-Z-M-I, .wG, .az2)`), /color:\s*var\(--terminal-fg\)\s*!important/);
  assert.match(rule(`${prefix} :is(.J-Z-I-KO, .J-Z-M-I-KO, .wG.e9, [aria-pressed="true"])`), /background-color:\s*var\(--terminal-selected\)\s*!important/);
  assert.match(rule(`${prefix} :is(.J-Z-I-JE, .J-Z-M-I-JE, [aria-disabled="true"])`), /color:\s*var\(--terminal-disabled\)\s*!important/);
  assert.match(rule(`${prefix} :is(.aDh, .btC, .aZ) svg.aoH`), /fill:\s*currentColor\s*!important/);
  for (const entry of rules(shell).filter(entry => entry.selectors.startsWith(prefix))) {
    assert.doesNotMatch(entry.body, /(?:^|;)\s*(?:height|width|padding|margin|position|display|visibility|background-image|background-size|opacity)\s*:/);
    assert.doesNotMatch(entry.selectors, /\.T-I|\.Uo|\.Am|\.Ar|\.a3s|contenteditable/);
  }
});

test('composer fixture covers external recipient fields, legacy/SVG glyphs, states and editor exclusions', () => {
  const fixture = fs.readFileSync(new URL('fixtures/gmail-composer.html', import.meta.url), 'utf8');
  for (const classes of ['AD', 'aaZ', 'bAs', 'vO', 'aaA aaB eN', 'aaA aaC eN', 'J-Z-I J-Z-I-KO', 'J-Z-I J-Z-I-JE', 'T-I T-I-atl', 'HM', 'I5']) {
    assert.ok(fixture.includes(`class="${classes}"`), `Missing composer structure: ${classes}`);
  }
  assert.ok(fixture.includes('contenteditable="true"'));
  assert.ok(fixture.includes('class="eK" style="background-color:#123456"'));
  assert.ok(fixture.includes('<div class="a1"><svg class="aoH"'));
  assert.doesNotMatch(fixture, /<script|<iframe|https?:|data-message-id=|jslog=|[\w.+-]+@[\w.-]+/i);
});
