vim.api.nvim_create_autocmd('BufWritePost', {
  callback = function()
    local filepath = vim.api.nvim_buf_get_name(0)
    local plz_root = vim.fs.find('.plzconfig', { upward = true, path = filepath })[1]
    if not plz_root then
      return
    end
    local output_lines = {}
    local on_output = function(_, line)
      table.insert(output_lines, line)
    end
    local on_exit = function()
      vim.print(table.concat(output_lines, '\n'))
    end
    vim.system({ 'wollemi', 'gofmt' }, {
      -- Run in the directory of the saved file since wollemi won't run outside of a plz repo
      cwd = vim.fs.dirname(filepath),
      env = {
        -- wollemi needs GOROOT to be set
        GOROOT = vim.trim(vim.system({ 'go', 'env', 'GOROOT' }):wait().stdout),
        PATH = vim.fn.getenv('PATH'),
      },
      stdout = on_output,
      stderr = on_output,
    }, on_exit)
  end,
  pattern = { '*.go' },
  group = group,
  desc = 'Run wollemi on parent directory of go file',
})
