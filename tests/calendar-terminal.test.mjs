import test from 'node:test';
import assert from 'node:assert/strict';
import fs from 'node:fs';

const source = fs.readFileSync(new URL('../home/dot_config/stylus/calendar-terminal.user.css', import.meta.url), 'utf8');
const github = fs.readFileSync(new URL('../home/dot_config/stylus/github-terminal.user.css', import.meta.url), 'utf8');
const fixture = fs.readFileSync(new URL('fixtures/calendar-week.html', import.meta.url), 'utf8');
const month = fs.readFileSync(new URL('fixtures/calendar-month.html', import.meta.url), 'utf8');
const css = source.replace(/\/\*[\s\S]*?\*\//g, '');

// Structural guards only; CSS parsing and live layout need separate checks.
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

test('Calendar uses the shared palette, local fonts, settings and HTTPS route scope', () => {
  assert.match(source, /@name\s+Google Calendar \/ terminal/);
  assert.match(css, /@-moz-document url-prefix\("https:\/\/calendar\.google\.com\/calendar\/"\)/);
  assert.doesNotMatch(css, /@import|@font-face|url\((?!"https:\/\/calendar\.google\.com\/calendar\/"\))/);
  for (const [, name, value] of source.matchAll(/(--terminal-[\w-]+): (light-dark\([^;]+\));/g)) {
    if (name === '--terminal-selected') continue;
    assert.ok(github.includes(`${name}: ${value};`), `Palette drift: ${name}`);
  }
});

test('body/header theme scopes override the actual Material and Calendar token families', () => {
  const tokens = rule(':root, body.DO879e, #gb');
  for (const name of ['--gm3-sys-color-surface', '--gm3-sys-color-on-surface', '--gm3-sys-color-primary', '--gm3-sys-color-on-primary', '--cal-sys-color-now-indicator', '--cal-sys-color-warning', '--cal-sys-color-on-warning-container', '--og-bar-background']) {
    assert.ok(tokens.includes(`${name}: var(--terminal-`), `Missing ${name}`);
  }
  assert.match(tokens, /--gm3-sys-color-on-primary:\s*var\(--terminal-on-accent\)\s*!important/);
  assert.ok(fixture.includes('class="DO879e GrxScd CcsDpe"'));
});

test('native event fills, RSVP variants and absolute scheduling coordinates are not overwritten', () => {
  for (const entry of rules().filter(entry => entry.selectors.includes('[data-eventchip]'))) {
    assert.doesNotMatch(entry.body, /(?:^|;)\s*(?:background(?:-color|-image)?|border(?:-color|-width)?|top|left|right|bottom|width|height|position|z-index|line-height|padding|margin|opacity|text-decoration)\s*:/);
  }
  const ink = rule('[data-eventchip] :is(.lhydbb, .qeMtzb).EiZ8Dd:not(.Gt6oUd, .qqMC3e, .UflSff)');
  assert.match(ink, /color:\s*var\(--terminal-event-ink\)\s*!important/);
  assert.match(rule('body.DO879e.CcsDpe'), /--terminal-event-ink:\s*#131314/);
  assert.match(rule('body.DO879e.PC2yOb'), /--terminal-event-ink:\s*#131314/);
  assert.match(fixture, /class="GTG3wb LKeQwe"/);
  assert.ok(fixture.includes('LKeQwe w9eXqe'));
  assert.ok(fixture.includes('left:50%;width:50%;z-index:6'));
});

test('colored calendar checkboxes, chart segments and icon fonts remain native', () => {
  assert.doesNotMatch(css, /--checkbox-color\s*:/);
  assert.doesNotMatch(css, /\.KGC9Kd[^{}]*\{/);
  assert.doesNotMatch(css, /(?:^|[;{])\s*(?:-webkit-)?filter\s*:/);
  assert.doesNotMatch(css, /(?:^|[;{])\s*font\s*:/);
  const fonts = rules().filter(entry => /font-family:\s*var\(--terminal-font\)/.test(entry.body) && entry.selectors.startsWith('*:not'));
  assert.equal(fonts.length, 1);
  assert.ok(fonts[0].selectors.includes('.google-material-icons *'));
  assert.ok(fonts[0].selectors.includes('.google-material-icons-filled *'));
  assert.ok(fonts[0].selectors.includes('[contenteditable="true"] *'));
  assert.doesNotMatch(css, /svg[^{}]*path\s*\{/);
  assert.ok(fixture.includes('--checkbox-color:#4B99D2'));
});

test('captured grid pseudo-lines and sidebar fade change paint, not geometry or scrolling', () => {
  assert.match(rule('.BiKU4b, .sJ9Raf:after, .INK2ed, .gZ8fdb, .E42vBe, .qLWd9c'), /border-color:\s*var\(--terminal-border\)\s*!important/);
  assert.match(rule('.hEtGGf:after'), /linear-gradient\(to left, var\(--terminal-bg\), transparent\)/);
  assert.doesNotMatch(css, /(?:^|;)\s*(?:display|visibility|overflow(?:-x|-y)?|pointer-events|transform)\s*:/);
  assert.match(rule('.GTG3wb[data-eventchip], .GTG3wb[data-eventchip] :is(.lhydbb, .qeMtzb)'), /min\(var\(--terminal-size\), 12px\)/);
});

test('stacked month/all-day positioning keeps its native em unit separate from label text', () => {
  const slots = rule('.PTdDEc, .vEJ0bc');
  assert.match(slots, /font-size:\s*var\(--cal-stacked-layout-chip-container-height, 24px\)\s*!important/);
  assert.doesNotMatch(slots, /--terminal-size|min\(/, 'UI text settings must not shrink em-based row spacing');
  assert.match(rule('.KF4T6b'), /font-size:\s*min\(var\(--terminal-size\), 12px\)\s*!important/);
  for (const selector of ['.PTdDEc, .vEJ0bc', '.KF4T6b']) {
    assert.doesNotMatch(rule(selector), /(?:^|;)\s*(?:height|width|top|left|position|line-height|padding|margin|transform|z-index|background(?:-color)?|border)\s*:/);
  }
  assert.doesNotMatch(css, /--cal-stacked-layout-chip-(?:container-)?height\s*:/, 'Consume native density tokens; do not redefine them');
  const controls = rules().find(entry => entry.selectors.startsWith(':is(button, input, select, textarea,'));
  assert.ok(controls);
  assert.ok(controls.selectors.endsWith(':not(:where(.PTdDEc, .vEJ0bc, [data-eventchip], [data-eventchip] *))'));
});

test('month fixture exercises em-positioned button slots in both native densities', () => {
  assert.ok(month.includes('data-viewkey="MONTH"'));
  assert.ok(month.includes('class="Defj0e"'));
  assert.ok(month.includes('<button class="vEJ0bc" data-eventchip'));
  for (const [height, bar] of [[24, 22], [20, 18]]) {
    assert.ok(month.includes(`--cal-stacked-layout-chip-container-height: ${height}px;`));
    assert.ok(month.includes(`--cal-stacked-layout-chip-height: ${bar}px;`));
  }
  for (const row of [0, 1, 2, 3]) assert.ok(month.includes(`top:${row}em`));
  assert.ok(month.includes('class="KF4T6b KCIIIb"'));
});

test('today date buttons are excluded from generic control recoloring and labels inherit paired text', () => {
  assert.ok(rule('.pYTkkf-Bz112c-LgbsSe, .nUt0vb:not(.sOjuj, .nSCxEf)'));
  assert.match(rule('.FOBRw-LgbsSe, .nUt0vb.gPr58d'), /color:\s*var\(--terminal-on-accent\)\s*!important/);
  assert.match(rule('.VAKbPe[aria-checked="true"], .wc0xVe .nUt0vb.aOXrUc'), /color:\s*var\(--terminal-blue\)\s*!important/);
  assert.match(css, /\.AeBiU-vQzf8d[^{}]*\{\s*color:\s*inherit\s*!important/);
  assert.match(fixture, /class="IOneve pWJCO p6vobf"/);
});

test('Create fits its text/icon height and the sidebar width without stretching its popup', () => {
  assert.match(rule(':root'), /--terminal-create-height:\s*calc\(max\(24px, var\(--terminal-size\) \* 1\.25\) \+ 8px\)/);
  const create = rule('.dwlvNd .nUt0vb.gPr58d');
  assert.match(create, /height:\s*var\(--terminal-create-height\)\s*!important/);
  assert.match(create, /padding:\s*4px 12px\s*!important/);
  assert.match(rule('.dwlvNd .nUt0vb.gPr58d > .x5FT4e'), /font-size:\s*inherit\s*!important/);
  assert.match(rule('.dwlvNd:has(.nUt0vb.gPr58d):not(.K36rb *, .KMkTad *)'), /width:\s*calc\(256px - 32px\)\s*!important/);
  const stretch = rule('.dwlvNd:not(.K36rb *, .KMkTad *) > .tB5Jxf-xl07Ob-XxIAqe-OWXEXe-oYxtQd, .dwlvNd:not(.K36rb *, .KMkTad *) .nUt0vb.gPr58d');
  assert.match(stretch, /width:\s*100%\s*!important/);
  for (const entry of rules().filter(entry => entry.selectors.includes('.dwlvNd'))) {
    assert.doesNotMatch(entry.body, /(?:^|;)\s*(?:display|visibility|position|z-index|pointer-events|transform)\s*:/);
    if (/width\s*:/.test(entry.body)) assert.ok(entry.selectors.includes(':not(.K36rb *, .KMkTad *)'), 'Do not stretch a collapsed-drawer Create');
  }
  assert.ok(fixture.includes('aria-haspopup="menu" aria-expanded="false"'));
  assert.ok(fixture.includes('class="tB5Jxf-xl07Ob-XxIAqe-OWXEXe-oYxtQd"'));
  assert.ok(fixture.includes('class="google-material-icons notranslate fPL74e"'));
});

test('Create sidebar spacer and edge fades share the compact button sizing', () => {
  assert.match(rule(':root'), /--terminal-create-space:\s*calc\(var\(--terminal-create-height\) \+ 28px\)/);
  const spacer = rule('body[data-viewfamily="EVENT"] .KKOvEb:has(> .dwlvNd .nUt0vb.gPr58d) .QQYuzf .LXjtcc');
  assert.match(spacer, /height:\s*var\(--terminal-create-space\)\s*!important/);
  const fades = rule('body[data-viewfamily="EVENT"] .KKOvEb:has(> .dwlvNd .nUt0vb.gPr58d) .hEtGGf:before, body[data-viewfamily="EVENT"] .KKOvEb:has(> .dwlvNd .nUt0vb.gPr58d) .hEtGGf:after');
  assert.match(fades, /top:\s*var\(--terminal-create-space\)\s*!important/);
  assert.ok(fixture.includes('class="LXjtcc"'));
});

test('compact header retains control space and reclaims the matching content height only on screen', () => {
  const regularView = 'body:not([data-viewfamily="EVENT_EDIT"], [data-viewfamily="PROPOSE_TIME"])';
  const header = rule(`${regularView} #gb[role="banner"]`);
  assert.match(header, /height:\s*var\(--terminal-header-height\)\s*!important/);
  assert.match(rule(':root'), /--terminal-header-height:\s*56px/);
  assert.match(rule(':root'), /--terminal-header-control-size:\s*40px/);
  assert.match(rule(`${regularView} #gb[role="banner"] > .gb_Vd`), /padding:\s*3px 8px\s*!important/);
  const menu = rule(`${regularView} #gb[role="banner"] > .gb_Vd .gb_cd`);
  assert.match(menu, /width:\s*var\(--terminal-header-control-size\)\s*!important/);
  assert.match(menu, /height:\s*var\(--terminal-header-control-size\)\s*!important/);
  assert.match(css, /@media screen\s*\{\s*body:not\(\[data-viewfamily="EVENT_EDIT"\], \[data-viewfamily="PROPOSE_TIME"\]\)/);
  assert.match(rule(`${regularView} .KKOvEb:has(> #gb[role="banner"]) > .SGWAac`), /height:\s*calc\(100% - var\(--terminal-header-height\)\)\s*!important/);
  assert.match(rule('body.lzJw2b[data-viewfamily="EVENT"] .KKOvEb:has(> #gb[role="banner"]) > .SGWAac'), /height:\s*calc\(100% - var\(--terminal-header-height\) - 47px\)\s*!important/);
  assert.doesNotMatch(header, /overflow|transform|display|visibility/);
  assert.doesNotMatch(rule(`${regularView} #gb[role="banner"] > .gb_Vd`), /(?:^|;)\s*(?:height|min-height|max-height)\s*:/);
});

test('Calendar search keeps native field, button and row geometry in every state', () => {
  const geometry = /(?:^|;)\s*(?:height|min-height|max-height|width|min-width|max-width|padding[\w-]*|margin[\w-]*|box-sizing|border|border-width|position|top|left|right|bottom|display|visibility|transform|pointer-events|z-index)\s*:/;
  for (const entry of rules().filter(entry => entry.selectors.includes('[role="search"]'))) {
    assert.doesNotMatch(entry.body, geometry, `Search geometry override: ${entry.selectors}`);
  }
  assert.doesNotMatch(css, /\.gb_(?:Ne|Le|Ve|4d|Ee|Fe)\b/, 'Do not resize search internals or their containing rows');
  assert.match(rule('#gb form[role="search"]'), /outline:\s*1px solid var\(--terminal-border\)/);
});

test('keyboard focus, floating surfaces and square supported scrollbars have boundaries', () => {
  assert.match(rule(':focus-visible'), /outline:\s*1px solid var\(--terminal-blue\)\s*!important/);
  assert.match(css, /\.ne2Ple-z59Tgd[^{}]*\{[^{}]*border:\s*1px solid var\(--terminal-border\)\s*!important/);
  assert.match(rule('.tB5Jxf-xl07Ob-XxIAqe [role="menu"], .OFaVze .pIQtMd, .OFaVze [role="listbox"]'), /border:\s*0\s*!important/);
  assert.match(css, /@supports selector\(::-webkit-scrollbar\)/);
  assert.match(rule('*::-webkit-scrollbar-thumb'), /border-radius:\s*0\s*!important/);
  assert.match(rule('*::-webkit-scrollbar-track, *::-webkit-scrollbar-corner'), /border-radius:\s*0\s*!important/);
});

test('fixture contains no copied account data, scripts or network assets', () => {
  assert.doesNotMatch(fixture, /<script|<iframe|https?:|parentsquare|@|data-eventid=|data-calendarid=|jslog=/i);
  assert.doesNotMatch(month, /<script|<iframe|https?:|parentsquare|@|data-eventid=|data-calendarid=|jslog=/i);
});
