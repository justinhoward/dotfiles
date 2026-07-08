# ~/.p10k.zsh — Powerlevel10k configuration.
#
# Hand-written (not `p10k configure` output) to stay small and readable. It
# reproduces the old prezto `justinhoward` powerline theme on p10k's fast async
# git backend (gitstatusd): a single-line prompt with the signature blue path
# block and a git block that recolors by state (green=clean, yellow=dirty,
# magenta=merge/conflict), an error/jobs/context cluster on the left, and the
# command timer on the right. No transient prompt and no blank line above, so
# nothing ever reflows or jumps when you hit enter.
#
# Colors are ANSI names (0-15 follow the terminal palette). Retheme by editing
# the *_BACKGROUND / *_FOREGROUND values; run `p10k configure` to start over.

'builtin' 'local' '-a' 'p10k_config_opts'
[[ ! -o 'aliases'         ]] || p10k_config_opts+=('aliases')
[[ ! -o 'sh_glob'         ]] || p10k_config_opts+=('sh_glob')
[[ ! -o 'no_brace_expand' ]] || p10k_config_opts+=('no_brace_expand')
'builtin' 'setopt' 'no_aliases' 'no_sh_glob' 'brace_expand'

() {
  emulate -L zsh -o extended_glob
  unset -m '(POWERLEVEL9K_*|DEFAULT_USER)~POWERLEVEL9K_GITSTATUS_DIR'

  # --- Segments -------------------------------------------------------------
  # One line, like the old theme: [✘ code][jobs][user@host] blue-path git.
  # The trailing powerline arrow is the prompt terminator — no prompt_char.
  typeset -g POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(status background_jobs context dir vcs)
  typeset -g POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(command_execution_time)

  # --- Global look ----------------------------------------------------------
  typeset -g POWERLEVEL9K_MODE=nerdfont-v3          # icon set (needs a Nerd Font)
  typeset -g POWERLEVEL9K_ICON_PADDING=none
  typeset -g POWERLEVEL9K_BACKGROUND=                # unstyled segments: no bg
  typeset -g POWERLEVEL9K_{LEFT,RIGHT}_{LEFT,RIGHT}_WHITESPACE=' '

  # Solid powerline separators (require a Nerd Font / powerline glyphs).
  typeset -g POWERLEVEL9K_LEFT_SEGMENT_SEPARATOR=$'\uE0B0'
  typeset -g POWERLEVEL9K_RIGHT_SEGMENT_SEPARATOR=$'\uE0B2'
  typeset -g POWERLEVEL9K_LEFT_SUBSEGMENT_SEPARATOR=$'\uE0B1'
  typeset -g POWERLEVEL9K_RIGHT_SUBSEGMENT_SEPARATOR=$'\uE0B3'
  typeset -g POWERLEVEL9K_LEFT_PROMPT_FIRST_SEGMENT_START_SYMBOL=
  typeset -g POWERLEVEL9K_LEFT_PROMPT_LAST_SEGMENT_END_SYMBOL=$'\uE0B0'
  typeset -g POWERLEVEL9K_RIGHT_PROMPT_FIRST_SEGMENT_START_SYMBOL=$'\uE0B2'
  typeset -g POWERLEVEL9K_RIGHT_PROMPT_LAST_SEGMENT_END_SYMBOL=

  # Single line, no blank line above, no transient collapse — nothing reflows.
  typeset -g POWERLEVEL9K_PROMPT_ADD_NEWLINE=false
  typeset -g POWERLEVEL9K_TRANSIENT_PROMPT=off
  typeset -g POWERLEVEL9K_INSTANT_PROMPT=off
  typeset -g POWERLEVEL9K_DISABLE_CONFIGURATION_WIZARD=true

  # --- status: red ✘ + exit code on the far left, only on failure -----------
  typeset -g POWERLEVEL9K_STATUS_OK=false           # success = absence of the ✘
  typeset -g POWERLEVEL9K_STATUS_ERROR=true
  typeset -g POWERLEVEL9K_STATUS_ERROR_BACKGROUND=black
  typeset -g POWERLEVEL9K_STATUS_ERROR_FOREGROUND=red
  typeset -g POWERLEVEL9K_STATUS_ERROR_VISUAL_IDENTIFIER_EXPANSION='✘'

  # --- background jobs: cyan cog, no count ----------------------------------
  typeset -g POWERLEVEL9K_BACKGROUND_JOBS_BACKGROUND=black
  typeset -g POWERLEVEL9K_BACKGROUND_JOBS_FOREGROUND=cyan
  typeset -g POWERLEVEL9K_BACKGROUND_JOBS_VERBOSE=false

  # --- context: user@host, only over SSH or as root -------------------------
  typeset -g POWERLEVEL9K_CONTEXT_ROOT_BACKGROUND=black
  typeset -g POWERLEVEL9K_CONTEXT_ROOT_FOREGROUND=yellow
  typeset -g POWERLEVEL9K_CONTEXT_{REMOTE,REMOTE_SUDO}_BACKGROUND=black
  typeset -g POWERLEVEL9K_CONTEXT_{REMOTE,REMOTE_SUDO}_FOREGROUND=white
  typeset -g POWERLEVEL9K_CONTEXT_ROOT_TEMPLATE='%n@%m'
  typeset -g POWERLEVEL9K_CONTEXT_TEMPLATE='%n@%m'
  # Hide entirely when local and non-root.
  typeset -g POWERLEVEL9K_CONTEXT_{DEFAULT,SUDO}_{CONTENT,VISUAL_IDENTIFIER}_EXPANSION=

  # --- dir: the signature blue block, fish-style shortened parents ----------
  # All text is black for readability on blue; repo roots / project markers and
  # the current dir stay full and bold to stand out. No folder icon (the old
  # theme had none).
  typeset -g POWERLEVEL9K_DIR_BACKGROUND=blue
  typeset -g POWERLEVEL9K_DIR_FOREGROUND=black
  typeset -g POWERLEVEL9K_DIR_ANCHOR_FOREGROUND=black
  typeset -g POWERLEVEL9K_DIR_ANCHOR_BOLD=true
  typeset -g POWERLEVEL9K_DIR_VISUAL_IDENTIFIER_EXPANSION=
  typeset -g POWERLEVEL9K_SHORTEN_STRATEGY=truncate_to_unique
  typeset -g POWERLEVEL9K_SHORTEN_DELIMITER=
  typeset -g POWERLEVEL9K_SHORTEN_DIR_LENGTH=1
  typeset -g POWERLEVEL9K_DIR_TRUNCATE_BEFORE_MARKER=false
  typeset -g POWERLEVEL9K_DIR_MAX_LENGTH=80
  typeset -g POWERLEVEL9K_DIR_SHOW_WRITABLE=v3        # lock icon when not writable
  local anchor_files=(
    .git .svn .hg .bzr
    .node-version .python-version .ruby-version .go-version .java-version
    .tool-versions .mise.toml .shorten_folder_marker
    Cargo.toml composer.json go.mod package.json Gemfile
  )
  typeset -g POWERLEVEL9K_SHORTEN_FOLDER_MARKER="(${(j:|:)anchor_files})"

  # --- vcs (git): one block, recolors by state, concise built-in markers ----
  # gitstatusd (async) draws e.g. " main ⇡1 *2 +3 !4 ?5"; the block background
  # is the state color. green=clean, yellow=dirty, magenta=merge/conflict.
  typeset -g POWERLEVEL9K_VCS_BACKENDS=(git)
  typeset -g POWERLEVEL9K_VCS_CLEAN_BACKGROUND=green
  typeset -g POWERLEVEL9K_VCS_CLEAN_FOREGROUND=black
  typeset -g POWERLEVEL9K_VCS_MODIFIED_BACKGROUND=yellow
  typeset -g POWERLEVEL9K_VCS_MODIFIED_FOREGROUND=black
  typeset -g POWERLEVEL9K_VCS_UNTRACKED_BACKGROUND=yellow
  typeset -g POWERLEVEL9K_VCS_UNTRACKED_FOREGROUND=black
  typeset -g POWERLEVEL9K_VCS_CONFLICTED_BACKGROUND=magenta
  typeset -g POWERLEVEL9K_VCS_CONFLICTED_FOREGROUND=white
  typeset -g POWERLEVEL9K_VCS_LOADING_BACKGROUND=8
  typeset -g POWERLEVEL9K_VCS_LOADING_FOREGROUND=white

  # --- command timer (>= 2s), right side ------------------------------------
  typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_THRESHOLD=2
  typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_PRECISION=0
  typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_FORMAT='d h m s'
  typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_BACKGROUND=black
  typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_FOREGROUND=yellow

  typeset -g POWERLEVEL9K_DISABLE_HOT_RELOAD=true
  (( ! $+functions[p10k] )) || p10k reload
}

typeset -g POWERLEVEL9K_CONFIG_FILE=${${(%):-%x}:a}
(( ${#p10k_config_opts} )) && setopt ${p10k_config_opts[@]}
'builtin' 'unset' 'p10k_config_opts'
