local please = require('please')

-- map please build to <space>pb
vim.keymap.set('n', '<leader>pb', please.build)

-- map please test to <space>pt
vim.keymap.set('n', '<leader>pt', please.test)

vim.keymap.set('n', '<leader>ptt', function()
  require('please').test({ under_cursor = true })
end)
