import test from 'node:test';
import assert from 'node:assert/strict';
import fs from 'node:fs';

const source = fs.readFileSync(new URL('../home/dot_config/firefox/chrome/userChrome.css', import.meta.url), 'utf8');
const css = source.replace(/\/\*[\s\S]*?\*\//g, '').replace(/^@import[^;]+;/gm, '');

// Structural guards only; Firefox profile CSS needs a restart to check visually.
function rule(selector) {
  const matches = [...css.matchAll(/([^{}]+)\{([^{}]*)\}/g)]
    .filter(([, selectors]) => selectors.trim().replace(/\s+/g, ' ') === selector);
  assert.equal(matches.length, 1, `Expected one rule for ${selector}`);
  return matches[0][2];
}

test('Firefox removes the toolbar/page separator without changing toolbar layout', () => {
  const root = rule(':root');
  assert.match(root, /--chrome-content-separator-color:\s*transparent\s*!important/);
  assert.match(rule('#navigator-toolbox'), /^\s*border-bottom:\s*0\s*!important;\s*$/);
  assert.match(root, /--tabs-navbar-separator-color:\s*transparent\s*!important/);
  assert.match(root, /--tabs-navbar-separator-style:\s*none\s*!important/);
  assert.match(rule('#nav-bar'), /^\s*border-top:\s*0\s*!important;\s*$/);
});

test('horizontal tabs share a 32px minimum with no vertical margins, leaving vertical sizing native', () => {
  const tabs = rule('#TabsToolbar, #tabbrowser-tabs[orient="horizontal"]');
  assert.match(tabs, /--tab-min-height:\s*32px\s*!important/);
  assert.match(tabs, /--tab-margin-block:\s*0px\s*!important/);
  assert.match(tabs, /--tab-block-margin:\s*0px\s*!important/);
  assert.match(tabs, /--tabstrip-min-height:\s*var\(--tab-min-height\)\s*!important/);
  assert.doesNotMatch(rule(':root'), /--tab-(?:min-height|margin-block|block-margin)\s*:/);
  assert.doesNotMatch(css, /#tabbrowser-tabs\[orient="vertical"\]/);
  const toolbar = rule('#TabsToolbar');
  assert.match(toolbar, /min-height:\s*var\(--tab-min-height\)\s*!important/);
  assert.match(toolbar, /padding-block:\s*0\s*!important/);
  assert.match(toolbar, /border-block:\s*0\s*!important/);
  assert.doesNotMatch(toolbar, /(?:^|;)\s*(?:height|max-height|overflow|display|visibility)\s*:/);
});

test('tab backgrounds are borderless flat fills with an inset keyboard focus outline', () => {
  const background = rule('.tab-background');
  assert.match(background, /border:\s*0\s*!important/);
  assert.match(background, /outline:\s*none\s*!important/);
  assert.doesNotMatch(css, /border-bottom-(?:width|color)\s*:/);
  const selected = rule('.tabbrowser-tab:is([visuallyselected], [multiselected]) > .tab-stack > .tab-background, .tab-background:is([selected], [multiselected])');
  assert.match(selected, /background:\s*var\(--terminal-hover\)\s*!important/);
  const focus = rule('#tabbrowser-tabs[tablist-has-focus] .tabbrowser-tab.tablist-keyboard-focus > .tab-stack > .tab-background');
  assert.match(focus, /outline:\s*1px solid var\(--terminal-blue\)\s*!important/);
  assert.match(focus, /outline-offset:\s*-1px\s*!important/);
});

test('only outer vertical button gaps are removed, not traffic lights, icon padding or drag spacers', () => {
  assert.match(rule('#TabsToolbar-customization-target, #TabsToolbar .toolbarbutton-1'), /^\s*padding-block:\s*0\s*!important;\s*$/);
  assert.doesNotMatch(css, /(?:\.titlebar-buttonbox(?:-container)?|\.titlebar-spacer|\[movingtab\]|\.tab-close-button|\.tab-icon-overlay|\.tab-context-line|\.tab-group-line)[^{}]*\{/);
  assert.doesNotMatch(css, /--tab-(?:content-button-size|content-button-padding|padding-inline)\s*:/);
});

test('browser field, popup and keyboard focus boundaries remain intact', () => {
  assert.match(rule(':focus-visible'), /outline:\s*1px solid var\(--terminal-blue\)\s*!important/);
  assert.match(rule('panel::part(content), menupopup::part(content)'), /border:\s*1px solid var\(--terminal-border\)\s*!important/);
  assert.match(rule('#urlbar-background, .urlbar-background, .urlbarView-background, .searchbar-textbox'), /border-width:\s*1px\s*!important/);
});
