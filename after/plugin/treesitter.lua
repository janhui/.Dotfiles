local ok, configs = pcall(require, 'nvim-treesitter.configs')
if not ok then
	return
end

local parsers = require('nvim-treesitter.parsers')
local parser_configs = parsers.get_parser_configs()
---@diagnostic disable-next-line: inject-field
parser_configs.lox = {
	install_info = {
		url = 'https://github.com/marcuscaisey/lox',
		files = { 'tree-sitter-lox/src/parser.c' },
	},
}

---@diagnostic disable-next-line: missing-fields
require 'nvim-treesitter.configs'.setup {
	-- A list of parser names, or "all" (the five listed parsers should always be installed)
	ensure_installed = {
		"lua",
		"vim",
		"vimdoc",
		"query",
		'comment',
		'git_rebase',
		'gitcommit',
		'go',
		'html',
		'java',
		'json',
		'proto',
		'sql',
		'regex',
		'scheme',
		'yaml',
	},

	-- Install parsers synchronously (only applied to `ensure_installed`)
	sync_install = false,

	-- Automatically install missing parsers when entering buffer
	-- Recommendation: set to false if you don't have `tree-sitter` CLI installed locally
	auto_install = true,

	highlight = {
		enable = true,

		-- Setting this to true will run `:h syntax` and tree-sitter at the same time.
		-- Set this to `true` if you depend on 'syntax' being enabled (like for indentation).
		-- Using this option may slow down your editor, and you may see some duplicate highlights.
		-- Instead of true it can also be a list of languages
		additional_vim_regex_highlighting = false,
	},
	textobjects = {
		select = {
			enable = true,
			lookahead = false,
			keymaps = {
				['af'] = '@function.outer',
				['if'] = '@function.inner',
				['ia'] = '@parameter.inner',
				['aa'] = '@parameter.outer',
				['ic'] = '@call.inner',
				['ac'] = '@call.outer',
				['iv'] = '@assignment.inner',
				['av'] = '@assignment.outer',
				['ib'] = '@block.inner',
				['ab'] = '@block.outer',
			},
		},
		move = {
			enable = true,
			set_jumps = true,
			goto_next_start = {
				[']f'] = '@function.outer',
				[']a'] = '@parameter.inner',
				[']m'] = '@method.outer',
			},
			goto_next_end = {
				[']F'] = '@function.outer',
				[']M'] = '@method.outer',
			},
			goto_previous_start = {
				['[f'] = '@function.outer',
				['[a'] = '@parameter.inner',
				['[m'] = '@method.outer',
			},
			goto_previous_end = {
				['[F'] = '@function.outer',
				['[M'] = '@method.outer',
			},
		},
	},
}
