import test from 'node:test';
import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';
import { stripTypeScriptTypes } from 'node:module';
import { EventEmitter } from 'node:events';
import { createHash } from 'node:crypto';
import { join } from 'node:path';

// Execute the real plugin with a scripted Git process and in-memory Git state.
// No commits, signing keys, hooks, network, or changes to a real checkout.
const source = readFileSync(new URL('../home/dot_config/opencode/plugins/git.ts', import.meta.url), 'utf8');
const load = new Function('Plugin', 'spawn', 'createHash', 'readFile', 'stat', 'join',
  stripTypeScriptTypes(source.replace(/^import .*\n/gm, '')).replace('export default Plugin.define', 'return Plugin.define'));
const sha = digit => digit.repeat(40);
const HEAD = sha('a'), UPSTREAM = sha('b'), ONTO = sha('c'), OTHER = sha('d');
const ok = (stdout = '') => ({ code: 0, stdout, stderr: '' });
const fail = (stderr = '', code = 1) => ({ code, stdout: '', stderr });

async function harness(options = {}) {
  const directory = options.directory ?? '/session/worktree';
  // Deliberately not <cwd>/.git: exercise linked-worktree state detection.
  const gitDirectory = '/canonical/.git/worktrees/session';
  const files = new Map();
  const calls = [], approvals = [], progress = [], mutations = [];
  const controller = new AbortController();
  const state = {
    branch: 'feature', head: HEAD, refs: { 'refs/heads/feature': HEAD, 'feature': HEAD,
      'origin/main': UPSTREAM, 'refs/remotes/origin/main': UPSTREAM,
      'refs/remotes/origin/feature': HEAD, 'feature@{upstream}': 'refs/remotes/origin/feature',
      'new-base': ONTO, 'refs/heads/topic': OTHER, 'topic': OTHER },
    tracked: '', status: '', staged: '', working: '', conflicts: '',
    remotes: '', remoteHead: 'origin/main', defaultBranch: 'main', candidates: [HEAD],
    fork: '', mergeBase: UPSTREAM, ...options.state,
  };
  const file = (name, content = '') => files.set(join(gitDirectory, name), content);
  const rebase = (overrides = {}) => {
    file('rebase-merge', null);
    for (const [name, content] of Object.entries({ 'head-name': 'refs/heads/feature\n',
      'orig-head': `${HEAD}\n`, 'onto': `${ONTO}\n`, 'gpg_sign_opt': '-S\n',
      'git-rebase-todo': `pick ${HEAD} change\n`, ...overrides })) {
      if (content !== null) file(`rebase-merge/${name}`, content);
    }
    state.branch = '';
  };
  const merge = () => { file('MERGE_HEAD', `${ONTO}\n`); file('MERGE_MSG', 'Merge topic\n'); };
  const clear = prefix => {
    for (const key of files.keys()) if (key.startsWith(join(gitDirectory, prefix))) files.delete(key);
  };

  function git(args) {
    const override = options.git?.(args, { state, file, rebase, merge, clear });
    if (override) return override;
    const actual = [...args];
    while (actual[0] === '-c') actual.splice(0, 2);
    const [command, ...flags] = actual;
    if (['rebase', 'merge', 'commit', 'push'].includes(command)) {
      mutations.push(args);
      const result = options.mutate?.(actual, { state, file, rebase, merge, clear });
      if (result) return result;
      if (command === 'rebase' && flags.includes('--abort')) {
        clear('rebase-merge'); clear('rebase-apply'); state.branch = 'feature'; state.conflicts = '';
      } else if (command === 'rebase' && (flags.includes('--continue') || flags.includes('--skip'))) {
        clear('rebase-merge'); state.branch = 'feature'; state.conflicts = '';
      } else if (command === 'merge' && (flags.includes('--continue') || flags.includes('--abort'))) {
        clear('MERGE_HEAD'); clear('MERGE_MSG'); state.conflicts = '';
      }
      return ok('Done.\n');
    }
    if (command === 'rev-parse') {
      if (flags.includes('--absolute-git-dir')) return ok(gitDirectory);
      if (flags.includes('--symbolic-full-name')) {
        const ref = flags.at(-1);
        return state.refs[ref] ? ok(state.refs[ref]) : fail('No upstream configured.');
      }
      const ref = flags.at(-1).replace(/\^\{commit\}$/, '');
      const resolved = ref === 'HEAD' ? state.head : /^[a-f0-9]{40}$/.test(ref) ? ref : state.refs[ref];
      return resolved ? ok(resolved) : fail(`Unknown revision ${ref}.`);
    }
    if (command === 'symbolic-ref') {
      if (flags.at(-1) === 'refs/remotes/origin/HEAD') return state.remoteHead ? ok(state.remoteHead) : fail();
      return state.branch ? ok(flags.includes('--short') ? state.branch : `refs/heads/${state.branch}`) : fail();
    }
    if (command === 'check-ref-format') return /^[\w/-]+$/.test(flags.at(-1)) ? ok() : fail('Invalid branch.');
    if (command === 'config') return state.defaultBranch ? ok(state.defaultBranch) : fail();
    if (command === 'status') return ok(flags.includes('--untracked-files=no') ? state.tracked : state.status);
    if (command === 'diff') {
      if (flags.includes('--diff-filter=U')) return ok(state.conflicts);
      if (flags.includes('--quiet')) return state.staged ? fail() : ok();
      if (flags.includes('--name-only')) return ok('file.txt');
      return ok(flags.includes('--cached') ? state.staged : state.working);
    }
    if (command === 'merge-base') {
      if (flags.includes('--fork-point')) return state.fork ? ok(state.fork) : fail();
      return ok(state.mergeBase);
    }
    if (command === 'log') return ok(flags.includes('-1') ? 'aaaaaaa change\nsignature: G Test signer' : 'aaaaaaa change');
    if (command === 'for-each-ref') return ok(flags.includes('--contains')
      ? state.remotes.split('\n').map(line => line.split('\t')[0]).join('\n') : state.remotes);
    if (command === 'rev-list') return ok(flags.includes('--count') ? String(flags.filter(f => /^[a-f0-9]{40}$/.test(f)).length) : state.candidates.join('\n'));
    throw new Error(`Unexpected git command: ${JSON.stringify(args)}`);
  }

  const spawn = (binary, args, settings) => {
    assert.equal(binary, 'git');
    assert.equal(settings.cwd, directory);
    assert.equal(settings.env.GIT_TERMINAL_PROMPT, '0');
    assert.equal(settings.env.GIT_EDITOR, 'true');
    assert.equal(settings.env.GIT_SEQUENCE_EDITOR, 'true');
    assert.equal(settings.shell, undefined);
    calls.push(args);
    const child = new EventEmitter();
    child.stdout = new EventEmitter(); child.stderr = new EventEmitter();
    child.stdout.setEncoding = child.stderr.setEncoding = function () { return this; };
    queueMicrotask(() => {
      if (settings.signal?.aborted) { child.emit('error', new Error('Operation aborted.')); return; }
      try {
        const result = git(args);
        child.stdout.emit('data', result.stdout); child.stderr.emit('data', result.stderr);
        child.emit('close', result.code, null);
      } catch (error) { child.emit('error', error); }
    });
    return child;
  };
  const missing = () => Object.assign(new Error('Missing file'), { code: 'ENOENT' });
  const readFile = async path => {
    if (!files.has(path)) throw missing();
    return files.get(path);
  };
  const stat = async path => {
    if (!files.has(path)) throw missing();
    return {};
  };
  const tools = new Map();
  const plugin = load({ define: definition => definition }, spawn, createHash, readFile, stat, join);
  await plugin.setup({
    session: { get: async ({ sessionID }) => {
      assert.equal(sessionID, 'session'); return { location: { directory } };
    } },
    tool: { transform: async transform => transform({ add: tool => tools.set(tool.name, tool) }) },
    permission: { assert: async request => {
      approvals.push(request);
      await options.approve?.({ state, file, rebase, merge, clear, controller }, request);
    } },
  });
  const context = { sessionID: 'session', agent: 'build', messageID: 'message', id: 'call',
    signal: controller.signal, progress: async value => { progress.push(value); } };
  const run = async (tool, input = {}) => {
    const result = await tools.get(tool).execute(input, context);
    return JSON.parse(result.content);
  };
  return { tools, state, calls, approvals, progress, mutations, file, rebase, merge, clear, controller, context, run };
}

test('registers narrow schemas including --onto and both positional arguments', async () => {
  const h = await harness();
  assert.deepEqual([...h.tools.keys()], ['git_commit', 'git_rebase', 'git_merge', 'git_push']);
  for (const name of ['git_rebase', 'git_merge']) {
    const schema = h.tools.get(name).input;
    assert.equal(schema.additionalProperties, false);
    for (const absent of ['args', 'exec', 'interactive', 'autostash', 'updateRefs', 'strategy', 'strategyOptions'])
      assert.equal(schema.properties[absent], undefined);
  }
  const props = h.tools.get('git_rebase').input.properties;
  for (const name of ['upstream', 'branch', 'onto', 'root', 'keepBase', 'rebaseMerges', 'autosquash', 'forceRebase',
    'reapplyCherryPicks', 'forkPoint', 'empty', 'keepEmpty', 'signoff', 'committerDateIsAuthorDate', 'resetAuthorDate'])
    assert.ok(props[name], name);
});

test('the shared subprocess runner retains existing commit and push behavior', async () => {
  const staged = await harness({ state: { staged: 'staged contents' } });
  const committed = await staged.tools.get('git_commit').execute({ message: 'Subject\n\nBody' }, staged.context);
  assert.match(committed.content, /signature: G Test signer/);
  assert.deepEqual(staged.mutations[0], ['commit', '-m', 'Subject\n\nBody']);
  assert.deepEqual(staged.approvals[0].resources, ['new']);
  const pushed = await harness({ git: args => args[0] === 'ls-remote' ? ok('ref: refs/heads/main\tHEAD') : undefined });
  const result = await pushed.tools.get('git_push').execute({}, pushed.context);
  assert.match(result.content, /git push origin feature/);
  assert.deepEqual(pushed.mutations[0], ['push', '--set-upstream', 'origin', 'refs/heads/feature:refs/heads/feature']);
  assert.deepEqual(pushed.approvals[0].resources, ['feature']);
});

test('rebase --onto upstream branch freezes revisions, signs, and asks for that branch', async () => {
  const h = await harness();
  const result = await h.run('git_rebase', { upstream: 'origin/main', onto: 'new-base', branch: 'topic' });
  assert.equal(result.status, 'completed');
  assert.equal(h.mutations.length, 1);
  const argv = h.mutations[0];
  assert.ok(argv.includes('--gpg-sign'));
  assert.deepEqual(argv.slice(argv.indexOf('--onto'), argv.indexOf('--onto') + 2), ['--onto', ONTO]);
  assert.deepEqual(argv.slice(argv.indexOf('--')), ['--', UPSTREAM, 'topic']);
  assert.deepEqual(h.approvals[0].resources, ['start:topic']);
  assert.equal(h.approvals[0].action, 'git_rebase');
  assert.equal(h.approvals[0].metadata.head, OTHER);
  for (const flag of ['--verify', '--no-autostash', '--no-update-refs', '--no-rerere-autoupdate']) assert.ok(argv.includes(flag));
});

test('omitted upstream preserves native tracking/fork-point behavior', async () => {
  const h = await harness({ state: { fork: UPSTREAM } });
  await h.run('git_rebase');
  assert.deepEqual(h.mutations[0].slice(-3), ['--', 'refs/remotes/origin/feature', 'feature']);
  assert.ok(h.mutations[0].includes('--fork-point'));
  assert.ok(h.calls.some(args => args.join(' ') === `merge-base --fork-point refs/remotes/origin/feature ${HEAD}`));
});

test('root uses branch as its only positional argument', async () => {
  const h = await harness();
  await h.run('git_rebase', { root: true, branch: 'topic', onto: 'new-base' });
  assert.deepEqual(h.mutations[0].slice(-3), ['--root', '--', 'topic']);
  assert.equal(h.approvals[0].metadata.upstream, undefined);
});

test('--onto merge-base shorthand is resolved to a unique SHA', async () => {
  const h = await harness();
  await h.run('git_rebase', { upstream: 'origin/main', onto: '...new-base', branch: 'topic' });
  assert.equal(h.approvals[0].metadata.onto, UPSTREAM);
  assert.ok(h.calls.some(args => args.join(' ') === `merge-base --all ${HEAD} ${ONTO}`));
  const ambiguous = await harness({ state: { mergeBase: `${UPSTREAM}\n${ONTO}` } });
  await assert.rejects(ambiguous.run('git_rebase', { upstream: 'origin/main', onto: '...new-base' }), /exactly one merge base/);
  assert.equal(ambiguous.mutations.length, 0);
});

test('root with --onto excludes ancestors of the new base from replay checks', async () => {
  const h = await harness();
  await h.run('git_rebase', { root: true, onto: 'new-base' });
  assert.ok(h.calls.some(args => args.join(' ') === `rev-list ${HEAD} --not ${ONTO}`));
});

test('typed replay flags map to Git without allowing a sequence editor', async () => {
  const h = await harness();
  await h.run('git_rebase', { upstream: 'origin/main', rebaseMerges: 'rebase-cousins', autosquash: true,
    forceRebase: true, reapplyCherryPicks: false, empty: 'stop', keepEmpty: false, signoff: true,
    committerDateIsAuthorDate: true, resetAuthorDate: true });
  for (const flag of ['--rebase-merges=rebase-cousins', '--autosquash', '--interactive', '--force-rebase',
    '--no-reapply-cherry-picks', '--empty=stop', '--no-keep-empty', '--signoff',
    '--committer-date-is-author-date', '--reset-author-date']) assert.ok(h.mutations[0].includes(flag), flag);
  const keep = await harness();
  await keep.run('git_rebase', { upstream: 'origin/main', keepBase: true });
  assert.ok(keep.mutations[0].includes('--keep-base'));
  assert.ok(!keep.mutations[0].includes('--onto'));
});

for (const [input, error] of [
  [{ upstream: 'origin/main', onto: 'new-base', keepBase: true }, /mutually exclusive/],
  [{ root: true, upstream: 'origin/main' }, /root cannot/],
  [{ root: true, keepBase: true }, /root cannot/],
  [{ root: true, forkPoint: true }, /root cannot/],
  [{ branch: 'topic' }, /branch requires upstream/],
  [{ upstream: '--exec=touch /tmp/oops' }, /Invalid revision/],
  [{ upstream: 'origin/main', onto: '--exec=bad' }, /Invalid revision/],
  [{ upstream: 'origin/main', branch: '-bad' }, /Invalid revision/],
  [{ upstream: 'origin/main', empty: 'bogus' }, /Invalid empty/],
  [{ action: 'continue', onto: 'new-base' }, /accept only action/],
  [{ action: 'quit' }, /Invalid rebase action/],
]) test(`rejects invalid rebase input ${JSON.stringify(input)}`, async () => {
  const h = await harness();
  await assert.rejects(h.run('git_rebase', input), error);
  assert.equal(h.approvals.length, 0); assert.equal(h.mutations.length, 0);
});

for (const tool of ['git_rebase', 'git_merge']) {
  const input = tool === 'git_rebase' ? { upstream: 'origin/main' } : { ref: 'origin/main' };
  test(`${tool} refuses protected branches, dirty tracked files, and other operations`, async () => {
    for (const branch of ['main', 'master', 'trunk']) {
      const h = await harness({ state: { branch, remoteHead: 'origin/trunk' } });
      await assert.rejects(h.run(tool, input), /protected branch/);
      assert.equal(h.mutations.length, 0);
    }
    const dirty = await harness({ state: { tracked: ' M file.txt\n' } });
    await assert.rejects(dirty.run(tool, input), /Tracked files must be clean/);
    for (const marker of ['MERGE_HEAD', 'CHERRY_PICK_HEAD', 'REVERT_HEAD', 'BISECT_LOG', 'sequencer', 'rebase-merge', 'rebase-apply']) {
      const h = await harness(); h.file(marker, 'state');
      await assert.rejects(h.run(tool, input), /Another Git operation/);
      assert.equal(h.mutations.length, 0);
    }
  });
}

test('rebase checks the whole replay range against other remote branches, exempting only its own', async () => {
  const h = await harness({ state: { candidates: [HEAD, OTHER],
    remotes: 'refs/remotes/origin/feature\t\nrefs/remotes/origin/HEAD\trefs/remotes/origin/main\nrefs/remotes/origin/shared\t' },
    git: args => args[0] === 'rev-list' && args.includes('--count') ? ok('1') : undefined });
  await assert.rejects(h.run('git_rebase', { upstream: 'origin/main' }), /replay range includes commits already on origin\/shared/);
  const check = h.calls.find(args => args[0] === 'rev-list' && args.includes('--count'));
  assert.ok(check.includes(HEAD)); assert.ok(check.includes(OTHER));
  assert.equal(check.at(-1), 'refs/remotes/origin/shared');
  assert.equal(h.approvals.length, 0); assert.equal(h.mutations.length, 0);
});

test('remote-history checks batch large ref inventories instead of spawning once per remote', async () => {
  const h = await harness({ state: { remotes: Array.from({ length: 250 }, (_, i) => `refs/remotes/origin/topic-${i}\t`).join('\n') } });
  await h.run('git_rebase', { upstream: 'origin/main' });
  const counts = h.calls.filter(args => args[0] === 'rev-list' && args.includes('--count'));
  assert.equal(counts.length, 6); // three batches, checked before and after approval
  assert.ok(counts.every(args => args.length <= 105));
});

test('rebases return recoverable conflict state instead of aborting or making an ordinary commit', async () => {
  const h = await harness({ mutate: (args, { rebase, state }) => {
    if (args[0] !== 'rebase') return;
    rebase(); state.conflicts = ' leading name.txt\0second.txt\0';
    return fail('Resolve conflicts.');
  } });
  const result = await h.run('git_rebase', { upstream: 'origin/main' });
  assert.equal(result.status, 'conflicts');
  assert.deepEqual(result.conflicts, [' leading name.txt', 'second.txt']);
  assert.match(result.next, /git_rebase.*continue/);
  assert.equal(h.mutations.length, 1);
});

test('rebase continuation uses saved signing and accepts a detached rebase HEAD', async () => {
  const h = await harness(); h.rebase(); h.state.staged = 'resolved diff';
  assert.equal((await h.run('git_rebase', { action: 'continue' })).status, 'completed');
  const args = h.mutations[0];
  assert.deepEqual(args.slice(args.indexOf('rebase')), ['rebase', '--continue']);
  assert.ok(args.includes('commit.gpgSign=true'));
  assert.deepEqual(h.approvals[0].resources, ['continue:feature']);
});

test('continuation refuses unresolved conflicts and unsigned, exec, update-ref, custom-strategy or autostash state', async () => {
  const conflict = await harness(); conflict.rebase(); conflict.state.conflicts = 'file.txt\0';
  await assert.rejects(conflict.run('git_rebase', { action: 'continue' }), /Unresolved conflicts/);
  for (const [overrides, error] of [
    [{ gpg_sign_opt: null }, /signing-enabled/],
    [{ 'git-rebase-todo': 'exec echo unsafe\n' }, /exec or update-ref/],
    [{ 'git-rebase-todo': 'x echo unsafe\n' }, /exec or update-ref/],
    [{ 'git-rebase-todo': 'update-ref refs/heads/other\n' }, /exec or update-ref/],
    [{ 'update-refs': 'refs/heads/other\n' }, /exec or update-ref/],
    [{ strategy: 'custom\n' }, /custom merge strategy/],
    [{ strategy_opts: '--ours\n' }, /custom merge strategy options/],
    [{ autostash: 'stash-sha\n' }, /automatic stash/],
  ]) {
    const h = await harness(); h.rebase(overrides);
    await assert.rejects(h.run('git_rebase', { action: 'continue' }), error);
    assert.equal(h.mutations.length, 0);
  }
});

test('abort and skip have distinct approvals and explicit data-loss warnings', async () => {
  for (const action of ['abort', 'skip']) {
    const h = await harness(); h.rebase(); h.state.conflicts = 'file.txt\0';
    assert.equal((await h.run('git_rebase', { action })).status, 'completed');
    assert.deepEqual(h.approvals[0].resources, [`${action}:feature`]);
    assert.match(h.approvals[0].metadata.warning, /discard|drops/);
  }
  const external = await harness(); external.rebase({ gpg_sign_opt: null, 'git-rebase-todo': 'exec bad\n' });
  await external.run('git_rebase', { action: 'abort' }); // recovery is still possible
});

test('git am is not mistaken for a rebase, and apply-backend rebase cannot continue', async () => {
  const h = await harness(); h.file('rebase-apply', null); h.file('rebase-apply/applying', '');
  await assert.rejects(h.run('git_rebase', { action: 'abort' }), /git am is not a rebase/);
  const apply = await harness(); apply.file('rebase-apply', null); apply.file('rebase-apply/head-name', 'refs/heads/feature\n');
  await assert.rejects(apply.run('git_rebase', { action: 'continue' }), /signing-enabled/);
  await apply.run('git_rebase', { action: 'abort' });
});

test('merge has explicit fast-forward modes, signed commits, and useful typed options', async () => {
  for (const ff of ['ff', 'no-ff', 'ff-only']) {
    const h = await harness();
    assert.equal((await h.run('git_merge', { ref: 'new-base', ff, message: 'Custom merge', signoff: true,
      verifySignatures: true, allowUnrelatedHistories: true })).status, 'completed');
    const args = h.mutations[0];
    for (const flag of [`--${ff}`, '--gpg-sign', '--no-edit', '--verify', '--signoff', '--verify-signatures', '--allow-unrelated-histories', '--no-overwrite-ignore'])
      assert.ok(args.includes(flag), flag);
    assert.deepEqual(args.slice(args.indexOf('-m'), args.indexOf('-m') + 2), ['-m', 'Custom merge']);
    assert.deepEqual(args.slice(-2), ['--', ONTO]);
    assert.deepEqual(h.approvals[0].resources, ['start:feature']);
  }
});

test('merge conflicts and --no-commit leave a continuable signed merge', async () => {
  for (const conflict of [true, false]) {
    const h = await harness({ mutate: (args, { merge, state, clear }) => {
      if (args.includes('--continue')) { clear('MERGE_HEAD'); return ok(); }
      merge(); state.conflicts = conflict ? 'file.txt\0' : '';
      return conflict ? fail('Conflict.') : ok('Stopped before commit.');
    } });
    const result = await h.run('git_merge', { ref: 'new-base', noCommit: true, ff: 'no-ff' });
    assert.equal(result.status, conflict ? 'conflicts' : 'in-progress');
    assert.match(result.next, /git_merge.*continue/);
    assert.ok(h.mutations[0].includes('--no-commit'));
    h.state.conflicts = ''; h.state.staged = 'resolved';
    await h.run('git_merge', { action: 'continue' });
    assert.deepEqual(h.mutations[1], ['-c', 'commit.gpgSign=true', 'merge', '--continue']);
  }
});

test('merge abort is explicit and a merge within a rebase cannot use git_merge continue', async () => {
  const h = await harness(); h.merge(); h.state.conflicts = 'file.txt\0';
  await assert.rejects(h.run('git_merge', { action: 'continue' }), /Unresolved conflicts/);
  await h.run('git_merge', { action: 'abort' });
  assert.deepEqual(h.approvals[0].resources, ['abort:feature']);
  assert.match(h.approvals[0].metadata.warning, /discard/);
  const nested = await harness(); nested.rebase(); nested.merge();
  await assert.rejects(nested.run('git_merge', { action: 'continue' }), /No standalone merge/);
  const automatic = await harness(); automatic.merge(); automatic.file('MERGE_AUTOSTASH', 'stash-sha\n');
  await assert.rejects(automatic.run('git_merge', { action: 'continue' }), /automatic stash/);
});

test('squash success and conflicts direct agents to git_commit, never merge continue/abort', async () => {
  for (const conflict of [false, true]) {
    const h = await harness({ mutate: (args, { state }) => {
      state.staged = 'squash'; state.conflicts = conflict ? 'file.txt\0' : '';
      return conflict ? fail('Conflict.') : ok('Squashed.');
    } });
    const result = await h.run('git_merge', { ref: 'new-base', squash: true });
    assert.equal(result.status, conflict ? 'conflicts' : 'staged');
    assert.match(result.next, /use git_commit/);
    assert.match(result.next, /continue\/abort do not apply/);
    assert.ok(h.mutations[0].includes('--squash')); assert.ok(h.mutations[0].includes('--no-commit'));
    await assert.rejects(h.run('git_merge', { action: 'continue' }), /No standalone merge/);
  }
  const unchanged = await harness();
  const result = await unchanged.run('git_merge', { ref: 'new-base', squash: true });
  assert.equal(result.status, 'completed');
  assert.equal(result.next, undefined);
});

for (const [input, error] of [
  [{}, /ref is required/],
  [{ ref: '--exec=bad' }, /Invalid revision/],
  [{ ref: 'new-base', ff: 'bad' }, /Invalid ff/],
  [{ ref: 'new-base', squash: true, ff: 'no-ff' }, /incompatible/],
  [{ ref: 'new-base', message: ' ' }, /message must not be empty/],
  [{ action: 'skip' }, /Invalid merge action/],
  [{ action: 'continue', ref: 'new-base' }, /accept only action/],
]) test(`rejects invalid merge input ${JSON.stringify(input)}`, async () => {
  const h = await harness();
  await assert.rejects(h.run('git_merge', input), error);
  assert.equal(h.approvals.length, 0); assert.equal(h.mutations.length, 0);
});

for (const tool of ['git_rebase', 'git_merge']) {
  const input = tool === 'git_rebase' ? { upstream: 'origin/main' } : { ref: 'new-base' };
  test(`${tool} refuses HEAD, index, working-tree and target changes during approval`, async () => {
    for (const change of [
      ({ state }) => { state.head = OTHER; },
      ({ state }) => { state.staged = 'new contents'; },
      ({ state }) => { state.working = 'new contents'; },
      ({ state }) => { state.branch = 'topic'; },
      ({ state }) => { state.refs[tool === 'git_rebase' ? 'origin/main' : 'new-base'] = OTHER; },
    ]) {
      const h = await harness({ approve: change });
      await assert.rejects(h.run(tool, input), /changed during approval/);
      assert.equal(h.mutations.length, 0);
    }
  });
  test(`${tool} respects permission rejection and session cancellation`, async () => {
    const denied = await harness({ approve: () => { throw new Error('Permission denied.'); } });
    await assert.rejects(denied.run(tool, input), /Permission denied/);
    assert.equal(denied.mutations.length, 0);
    const cancelled = await harness({ approve: ({ controller }) => { controller.abort(); } });
    await assert.rejects(cancelled.run(tool, input), /cancelled/);
    assert.equal(cancelled.mutations.length, 0);
  });
}

test('continuation rechecks todo and conflict-resolution content after approval', async () => {
  for (const change of [
    ({ file }) => { file('rebase-merge/git-rebase-todo', 'exec bad\n'); },
    ({ file }) => { file('rebase-merge/message', 'changed message\n'); },
    ({ state }) => { state.staged = 'changed resolution'; },
  ]) {
    const h = await harness({ approve: change }); h.rebase();
    await assert.rejects(h.run('git_rebase', { action: 'continue' }), /changed during approval/);
    assert.equal(h.mutations.length, 0);
  }
});

test('ordinary errors are not mislabeled as conflicts and signing failures retain recoverable state', async () => {
  for (const [tool, input] of [['git_rebase', { upstream: 'origin/main' }], ['git_merge', { ref: 'new-base', squash: true }]]) {
    const h = await harness({ mutate: () => fail('Signing or checkout failed.') });
    await assert.rejects(h.run(tool, input), /failed/);
    assert.equal(h.mutations.length, 1);
  }
  const signing = await harness({ mutate: (args, { rebase }) => { rebase(); return fail('GPG failed.'); } });
  const result = await signing.run('git_rebase', { upstream: 'origin/main' });
  assert.equal(result.status, 'in-progress'); assert.match(result.output, /GPG failed/);
  assert.equal(signing.mutations.length, 1);
});

test('Fence and agent permissions route rebase and merge to the tools', () => {
  const fence = readFileSync(new URL('../home/dot_config/fence/fence.jsonc', import.meta.url), 'utf8');
  assert.doesNotMatch(fence, /"allow"\s*:\s*\["git rebase", "git merge"\]/);
  assert.match(fence, /"git commit",\s*"git rebase",\s*"git merge"/);
  const config = readFileSync(new URL('../home/dot_config/opencode/opencode.jsonc.tmpl', import.meta.url), 'utf8');
  for (const tool of ['git_rebase', 'git_merge'])
    assert.ok(config.includes(`{ "action": "${tool}", "resource": "*", "effect": "ask" }`));
  const instructions = readFileSync(new URL('../home/dot_config/opencode/AGENTS.md.tmpl', import.meta.url), 'utf8');
  assert.match(instructions, /git_rebase.*git_merge/);
  assert.doesNotMatch(instructions, /`rebase`, `merge`, and creating/);
});
