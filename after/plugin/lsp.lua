local lspconfig = require('lspconfig')
local configs = require('lspconfig.configs')
local cmp_nvim_lsp = require('cmp_nvim_lsp')
local telescope_builtin = require('telescope.builtin')
local mason_lspconfig = require('mason-lspconfig')
local mason = require('mason')
local lsp_zero = require('lsp-zero')

vim.opt.completeopt = {'menu', 'menuone', 'noselect'}


local cmp = require('cmp')
local luasnip = require('luasnip')

local select_opts = {behavior = cmp.SelectBehavior.Select}

cmp.setup({
  snippet = {
    expand = function(args)
      luasnip.lsp_expand(args.body)
    end
  },
  sources = {
    {name = 'path'},
    {name = 'nvim_lsp', keyword_length = 1},
    {name = 'buffer', keyword_length = 3},
    {name = 'luasnip', keyword_length = 2},
  },
  window = {
    documentation = cmp.config.window.bordered()
  },
  formatting = {
    fields = {'menu', 'abbr', 'kind'},
    format = function(entry, item)
      local menu_icon = {
        nvim_lsp = 'λ',
        luasnip = '⋗',
        buffer = 'Ω',
        path = '🖫',
      }

      item.menu = menu_icon[entry.source.name]
      return item
    end,
  },
  mapping = {
    ['<Up>'] = cmp.mapping.select_prev_item(select_opts),
    ['<Down>'] = cmp.mapping.select_next_item(select_opts),
    ["<CR>"] = cmp.mapping.confirm({
      behavior = cmp.ConfirmBehavior.Insert,
      select = true,
    }),
  },
})


lsp_zero.on_attach(function(client, bufnr)
  lsp_zero.default_keymaps({buffer = bufnr})
end)

mason.setup()
mason_lspconfig.setup({
  automatic_installation = true,
})

configs.please = {
  default_config = {
    cmd = { 'plz', 'tool', 'lps' },
    filetypes = { 'please' },
    root_dir = function(fname)
      return vim.fs.dirname(vim.fs.find('.plzconfig', { upward = true, path = vim.fs.dirname(fname) })[1])
    end,
  },
}

lspconfig.bashls.setup({
  capabilities = cmp_nvim_lsp.default_capabilities(),
})

lspconfig.ccls.setup({
  capabilities = cmp_nvim_lsp.default_capabilities(),
  root_dir = function()
    return vim.fn.getcwd()
  end,
})

lspconfig.lua_ls.setup({
  settings = {
    Lua = {
      runtime = {
        version = 'LuaJIT',
      },
      workspace = {
        checkThirdParty = false,
      },
      telemetry = {
        enable = false,
      },
      diagnostics = {
        disable = {
          'redefined-local',
        },
      },
      format = {
        enable = false,
      },
    },
  },
})


-- Bodge to silence the 'No code actions available' message which gets logged when I run the source.organizeImports code
-- action on save in a Go file and the imports are already organised.
local notify = vim.notify
vim.notify = function(msg, level, opts)
  if msg == 'No code actions available' then
    return
  end
  notify(msg, level, opts)
end

local gopls_group = vim.api.nvim_create_augroup('gopls', { clear = true })
lspconfig.gopls.setup({
  capabilities = cmp_nvim_lsp.default_capabilities(),
  settings = {
    gopls = {
      directoryFilters = { '-plz-out' },
      linksInHover = false,
      analyses = {
        unusedparams = true,
      },
      usePlaceholders = false,
      semanticTokens = true,
      codelenses = {
        gc_details = true,
      },
      staticcheck = true,
    },
 },
  on_attach = function(_, bufnr)
    vim.api.nvim_create_autocmd({ 'BufEnter', 'InsertLeave', 'BufWritePost', 'CursorHold' }, {
      callback = vim.lsp.codelens.refresh,
      group = gopls_group,
      buffer = bufnr,
      desc = 'Refresh codelenses when gopls is running',
    })
    vim.api.nvim_create_autocmd('BufWritePre', {
      callback = function()
        vim.lsp.buf.code_action({ context = { only = { 'source.organizeImports' } }, apply = true })
      end,
      group = gopls_group,
      buffer = bufnr,
      desc = 'Organize imports before saving',
    })
  end,
  
  root_dir = function(fname)
    local go_mod = vim.fs.find('go.mod', { upward = true, path = vim.fs.dirname(fname) })[1]
    if go_mod then
      return vim.fs.dirname(go_mod)
    end

    -- Set GOPATH if we're in a directory called 'src' containing a .plzconfig
    local plzconfig_path = vim.fs.find('.plzconfig', { upward = true, path = vim.fs.dirname(fname) })[1]
    if plzconfig_path then
      local plzconfig_dir = vim.fs.dirname(plzconfig_path)
      if plzconfig_dir and vim.fs.basename(plzconfig_dir) == 'src' then
        vim.env.GOPATH = string.format('%s:%s/plz-out/go', vim.fs.dirname(plzconfig_dir), plzconfig_dir)
      end
    end

    return vim.fn.getcwd()
  end,

})

lspconfig.intelephense.setup({
  capabilities = cmp_nvim_lsp.default_capabilities(),
})

lspconfig.yamlls.setup({
  capabilities = cmp_nvim_lsp.default_capabilities(),
  settings = {
    yaml = {
      validate = false,
    },
  },
})

lspconfig.jsonls.setup({
  capabilities = cmp_nvim_lsp.default_capabilities(),
})


vim.lsp.set_log_level(vim.log.levels.OFF)

vim.diagnostic.config({
  float = {
    source = 'always',
  },
  severity_sort = true,
})
require("nvim-lightbulb").setup({
  autocmd = { enabled = true }
})
local protocol = require('vim.lsp.protocol')

local augroup = vim.api.nvim_create_augroup('lsp', { clear = true })

vim.api.nvim_create_autocmd('LspAttach', {
  group = augroup,
  desc = 'Set LSP keymaps and create codelens autocmd',
  callback = function(args)
    vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, { buffer = true })
    vim.keymap.set('n', '<leader>cl', vim.lsp.codelens.run, { buffer = true })
    vim.keymap.set({ 'n', 'v' }, '<leader>ca', vim.lsp.buf.code_action, { buffer = true })
    vim.keymap.set('n', '<leader>fm', function()
      vim.lsp.buf.format({ timeout_ms = 5000 })
    end, { buffer = true })

    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if client and client.supports_method(protocol.Methods.textDocument_codeLens) then
      vim.api.nvim_create_autocmd({ 'BufEnter', 'InsertLeave', 'BufWritePost', 'CursorHold' }, {
        callback = vim.lsp.codelens.refresh,
        group = augroup,
        buffer = args.buf,
        desc = 'Refresh codelenses automatically in this buffer',
      })
    end

    -- Disable LSP formatting with gq, see :help lsp-defaults
    vim.bo[args.buf].formatexpr = nil
  end,
})

vim.keymap.set('n', '<c-s>', telescope_builtin.lsp_document_symbols)
vim.keymap.set('n', '<leader>ss', telescope_builtin.lsp_dynamic_workspace_symbols)
vim.keymap.set('n', 'gd', telescope_builtin.lsp_definitions)
vim.keymap.set('n', 'gr', function()
  telescope_builtin.lsp_references({
    jump_type = 'never',
   })
end)
vim.keymap.set('n', 'gi', telescope_builtin.lsp_implementations)
vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename)
