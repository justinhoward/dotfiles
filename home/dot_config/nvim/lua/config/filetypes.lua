vim.filetype.add({
  extension = {
    -- Google Apps Script files are JavaScript.
    gs = 'javascript',
  },
  pattern = {
    -- Elastic Beanstalk .ebextensions config files are YAML.
    ['.*/%.ebextensions/.*%.config'] = 'yaml',
  },
})
