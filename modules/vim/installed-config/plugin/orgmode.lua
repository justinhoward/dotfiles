require('orgmode').setup_ts_grammar()
require('orgmode').setup {
  org_agenda_files = {'~/.org/agendas/**/*.org'},
  org_default_notes_file = '~/.org/refile.org',
}
