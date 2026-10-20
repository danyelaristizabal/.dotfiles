return {
	-- -- floating terminal windowsconfig = true
	{
		"akinsho/toggleterm.nvim",
		version = "*",
		opts = {
			open_mapping = nil,
			direction = "float",
			float_ops = { border = "rounded" },
		},
	},
	-- local models ai, questions
	{
		"nomnivore/ollama.nvim",
		dependencies = {
			"nvim-lua/plenary.nvim",
		},

		-- All the user commands added by the plugin
		cmd = { "Ollama", "OllamaModel", "OllamaServe", "OllamaServeStop" },

		keys = {
			-- Sample keybind for prompt menu. Note that the <c-u> is important for selections to work properly.
			{
				"<leader>oo",
				":<c-u>lua require('ollama').prompt()<cr>",
				desc = "ollama prompt",
				mode = { "n", "v" },
			},

			-- Sample keybind for direct prompting. Note that the <c-u> is important for selections to work properly.
			{
				"<leader>oG",
				":<c-u>lua require('ollama').prompt('Generate_Code')<cr>",
				desc = "ollama Generate Code",
				mode = { "n", "v" },
			},
		},

		---@type Ollama.Config
		opts = {
			-- your configuration overrides
		},
	},
	-- lsp config lg
	{
		"neovim/nvim-lspconfig",
		dependencies = {
			"folke/lazydev.nvim",
			ft = "lua",
			opts = {
				library = {
					{ path = "${3rd}/luv/library", words = { "vim%.uv" } },
				},
			},
		},
		config = function()
			-- Apply cmp capabilities to all servers
			vim.lsp.config("*", {
				capabilities = require("cmp_nvim_lsp").default_capabilities(),
			})

			vim.lsp.config("gopls", {
				settings = {
					gopls = {
						gofumpt = true,
						analyses = { unusedparams = true, shadow = true },
						staticcheck = true,
					},
				},
			})

			vim.lsp.config("lua_ls", {
				settings = {
					Lua = {
						diagnostics = { globals = { "vim" } },
						workspace = { checkThirdParty = false },
					},
				},
			})

			-- Only activate marksman when .marksman.toml exists to avoid indexing monorepos
			vim.lsp.config("marksman", {
				root_dir = function(fname)
					return vim.fs.root(fname, { ".marksman.toml" }) or vim.fs.dirname(fname)
				end,
			})

			vim.lsp.enable({
				"gopls",
				"rust_analyzer",
				"csharp_ls",
				"lua_ls",
				"ts_ls",
				"pyright",
				"marksman",
			})
		end,
	},
	-- autocompletion
	{
		"hrsh7th/nvim-cmp",
		event = "InsertEnter",
		dependencies = {
			"hrsh7th/cmp-nvim-lsp",
			"L3MON4D3/LuaSnip",
			"saadparwaiz1/cmp_luasnip",
			"rafamadriz/friendly-snippets",
			"hrsh7th/cmp-buffer",
			"hrsh7th/cmp-path",
		},
		config = function()
			local cmp = require("cmp")
			local luasnip = require("luasnip")

			require("luasnip.loaders.from_vscode").lazy_load()

			cmp.setup({
				snippet = {
					expand = function(args)
						luasnip.lsp_expand(args.body)
					end,
				},
				mapping = cmp.mapping.preset.insert({
					["<C-n>"] = cmp.mapping.complete(),
					["<CR>"] = cmp.mapping.confirm({ select = true }),
					["<Tab>"] = cmp.mapping(function(fallback)
						if cmp.visible() then
							cmp.select_next_item()
						elseif luasnip.expand_or_jumpable() then
							luasnip.expand_or_jump()
						else
							fallback()
						end
					end, { "i", "s" }),
					["<S-Tab>"] = cmp.mapping(function(fallback)
						if cmp.visible() then
							cmp.select_prev_item()
						elseif luasnip.jumpable(-1) then
							luasnip.jump(-1)
						else
							fallback()
						end
					end, { "i", "s" }),
				}),
				sources = cmp.config.sources({
					{ name = "nvim_lsp" },
					{ name = "luasnip" },
					{ name = "path" },
					{ name = "buffer" },
				}),
			})
		end,
	},
	-- treesiter
	{
		"nvim-treesitter/nvim-treesitter",
		build = ":TSUpdate",
		event = { "BufReadPost", "BufNewFile", "BufWritePre" },
		main = "nvim-treesitter.configs",
		opts = {
			ensure_installed = { "go", "lua", "c_sharp", "javascript", "graphql", "markdown", "markdown_inline" },
			auto_install = true,
			highlight = {
				enable = true,
				disable = function(lang, buf)
					local max_filesize = 100 * 1024
					local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
					if ok and stats and stats.size > max_filesize then
						return true
					end
				end,
				additional_vim_regex_highlighting = false,
			},
		},
	},
	-- fuzzy finder
	{
		"nvim-telescope/telescope.nvim",
		tag = "0.1.8",
		dependencies = { "nvim-lua/plenary.nvim" },
	},
	-- testing framework
	{
		"nvim-neotest/neotest",
		dependencies = {
			"nvim-neotest/nvim-nio",
			"nvim-lua/plenary.nvim",
			"antoinemadec/FixCursorHold.nvim",
			"nvim-treesitter/nvim-treesitter",
			{
				"fredrikaverpil/neotest-golang", -- Installation
				dependencies = {
					"uga-rosa/utf8.nvim", -- Additional dependency required
				},
			},
		},
		config = function()
			local neotest_golang_opts = {
				sanitize_output = true,
			} -- Specify custom configuration
			require("neotest").setup({
				adapters = {
					require("neotest-golang")(neotest_golang_opts), -- Registration
				},
				benchmark = {
					enabled = true,
				},
				consumers = {},
				default_strategy = "integrated",
				diagnostic = {
					enabled = true,
					severity = 1,
				},
				discovery = {
					concurrent = 0,
					enabled = true,
				},
				floating = {
					max_height = 0.6,
					max_width = 0.6,
					options = {},
				},
				highlights = {
					adapter_name = "NeotestAdapterName",
					border = "NeotestBorder",
					dir = "NeotestDir",
					expand_marker = "NeotestExpandMarker",
					failed = "NeotestFailed",
					file = "NeotestFile",
					focused = "NeotestFocused",
					indent = "NeotestIndent",
					marked = "NeotestMarked",
					namespace = "NeotestNamespace",
					passed = "NeotestPassed",
					running = "NeotestRunning",
					select_win = "NeotestWinSelect",
					skipped = "NeotestSkipped",
					target = "NeotestTarget",
					test = "NeotestTest",
					unknown = "NeotestUnknown",
					watching = "NeotestWatching",
				},
				icons = {
					child_indent = "│",
					child_prefix = "├",
					collapsed = "─",
					expanded = "╮",
					failed = "",
					final_child_indent = " ",
					final_child_prefix = "╰",
					non_collapsible = "─",
					notify = "",
					passed = "",
					running = "",
					running_animated = { "/", "|", "\\", "-", "/", "|", "\\", "-" },
					skipped = "",
					unknown = "",
					watching = "",
				},
				jump = {
					enabled = true,
				},
				log_level = 3,
				output = {
					enabled = true,
					open_on_run = "short",
				},
				output_panel = {
					enabled = true,
					open = "botright split | resize 15",
				},
				projects = {},
				quickfix = {
					enabled = true,
					open = false,
				},
				run = {
					enabled = true,
				},
				running = {
					concurrent = true,
				},
				state = {
					enabled = true,
				},
				status = {
					enabled = true,
					signs = true,
					virtual_text = false,
				},
				strategies = {
					integrated = {
						height = 40,
						width = 120,
					},
				},
				summary = {
					animated = true,
					count = true,
					enabled = true,
					expand_errors = true,
					follow = true,
					mappings = {
						attach = "a",
						clear_marked = "M",
						clear_target = "T",
						debug = "d",
						debug_marked = "D",
						expand = { "<CR>", "<2-LeftMouse>" },
						expand_all = "e",
						help = "?",
						jumpto = "i",
						mark = "m",
						next_failed = "J",
						output = "o",
						prev_failed = "K",
						run = "r",
						run_marked = "R",
						short = "O",
						stop = "u",
						target = "t",
						watch = "w",
					},
					open = "botright vsplit | vertical resize 50",
				},
				watch = {
					enabled = true,
					symbol_queries = {
						go = "        ;query\n        ;Captures imported types\n        (qualified_type name: (type_identifier) @symbol)\n        ;Captures package-local and built-in types\n        (type_identifier)@symbol\n        ;Captures imported function calls and variables/constants\n        (selector_expression field: (field_identifier) @symbol)\n        ;Captures package-local functions calls\n        (call_expression function: (identifier) @symbol)\n      ",
					},
				},
			})
		end,
	},
	-- linting
	{
		"mfussenegger/nvim-lint",
		event = { "BufReadPre", "BufNewFile" },
		config = function()
			local lint = require("lint")
			lint.linters_by_ft = {
				go = { "golangcilint" },
				javascript = { "eslint_d" },
				typescript = { "eslint_d" },
				sh = { "shellcheck" },
				bash = { "shellcheck" },
				zsh = { "shellcheck" },
				python = { "pylint" },
				markdown = { "markdownlint_cli2" },
			}

			-- Helper function to find the Go module root (directory containing go.mod)
			local function find_go_module_root(start_path)
				local current_dir = start_path
				while current_dir ~= "/" and current_dir ~= "." do
					local go_mod_path = current_dir .. "/go.mod"
					if vim.fn.filereadable(go_mod_path) == 1 then
						return current_dir
					end
					current_dir = vim.fn.fnamemodify(current_dir, ":h")
				end
				return nil
			end

			-- markdownlint-cli2 needs stdin input via --stdin flag
			lint.linters.markdownlint_cli2 = {
				name = "markdownlint-cli2",
				cmd = "markdownlint-cli2",
				stdin = true,
				args = { "--stdin" },
				stream = "stderr",
				ignore_exitcode = true,
				parser = require("lint.parser").from_pattern(
					"stdin:%d+:%d* (.+)",
					{ "message" },
					nil,
					{ ["source"] = "markdownlint" }
				),
			}

			-- Customize golangcilint to run from the module root so it picks up .golangci.yml
			lint.linters.golangcilint.cwd = function()
				local current_file = vim.api.nvim_buf_get_name(0)
				local current_dir = vim.fn.fnamemodify(current_file, ":h")
				local module_root = find_go_module_root(current_dir)
				return module_root or current_dir
			end

			-- Auto-lint on save and when entering buffer
			vim.api.nvim_create_autocmd({ "BufWritePost", "BufEnter" }, {
				callback = function()
					lint.try_lint()
				end,
			})
		end,
	},
	-- case conversion
	{
		"tpope/vim-abolish",
		keys = {
			{ "crs", desc = "snake_case" },
			{ "crc", desc = "camelCase" },
			{ "crm", desc = "PascalCase" },
			{ "cru", desc = "UPPER_SNAKE_CASE" },
			{ "cr-", desc = "kebab-case" },
			{ "crt", desc = "Title Case" },
		},
	},
	-- color scheme.
	{ "rebelot/kanagawa.nvim", as = "kanagawa" },
	-- {
	-- 	"rezniqov/soviet.nvim",
	-- 	lazy = false,
	-- 	priority = 1000,
	-- 	opts = {},
	-- 	config = function(_, opts)
	-- 		require("soviet").setup(opts)
	-- 		vim.cmd.colorscheme("soviet-dark")
	-- 		-- vim.cmd.colorscheme("soviet-light")
	-- 	end,
	-- },
	-- folding in nvim.
	{ "kevinhwang91/nvim-ufo", dependencies = { "kevinhwang91/promise-async" } },
	{ "theprimeagen/harpoon" },
	-- git wrapper
	{ "tpope/vim-fugitive" },
	-- commenter
	{
		"nvim-mini/mini.comment",
		mappings = {
			-- Toggle comment (like `gcip` - comment inner paragraph) for both
			-- Normal and Visual modes
			comment = "gc",

			-- Toggle comment on current line
			comment_line = "gcc",

			-- Toggle comment on visual selection
			comment_visual = "gc",

			-- Define 'comment' textobject (like `dgc` - delete whole comment block)
			-- Works also in Visual mode if mapping differs from `comment_visual`
			textobject = "gc",
		},
	},
	-- Edit and review github issues and pull requests from nvim
	{
		"pwntester/octo.nvim",
		dependencies = {
			"nvim-telescope/telescope.nvim",
			"nvim-tree/nvim-web-devicons",
			"nvim-lua/plenary.nvim",
		},
	},
	-- Format style when saving
	{
		"stevearc/conform.nvim",
		branch = "nvim-0.9",
		opts = {},
	},
	-- games
	{ "theprimeagen/vim-be-good" },
	-- File manager
	{ "stevearc/oil.nvim" },
	{
		"mason-org/mason.nvim",
	},
	-- run tests
	{
		"vim-test/vim-test",
		dependencies = {
			"preservim/vimux",
		},
		config = function()
			vim.keymap.set("n", "<leader>tn", ":TestNearest<CR>", {})
			vim.keymap.set("n", "<leader>T", ":TestSuite<CR>", {})
			vim.cmd("let test#strategy = 'vimux'")
		end,
	},
	-- show keymaps
	{
		"folke/which-key.nvim",
		event = "VeryLazy",
		opts = {
			-- show keymaps without desc (they show as their raw rhs)
			filter = function(mapping)
				return true
			end,
		},
		keys = {
			{
				"<leader>?",
				function()
					require("which-key").show({ global = false })
				end,
				desc = "Buffer Local Keymaps (which-key)",
			},
			{
				"<leader>??",
				function()
					require("which-key").show({ global = true })
				end,
				desc = "All Global Keymaps (which-key)",
			},
		},
	},
	-- dashboard
	{
		"folke/snacks.nvim",
		priority = 1000,
		lazy = false,
		opts = {
			dashboard = {
				enabled = true,
				preset = {
					header = [[
     /\_/\
    ( o.o )
     > ^ <
    /|   |\
   (_|   |_)

      meow
]],
				},
				sections = {
					{ section = "header" },
					{ section = "keys", gap = 1, padding = 1 },
					{ section = "startup" },
				},
			},
		},
	},
	-- better UI for select/input
	{
		"stevearc/dressing.nvim",
		event = "VeryLazy",
		opts = {
			select = {
				backend = { "builtin", "telescope" },
				format_item_override = {},
			},
			input = { enabled = true },
		},
	},
	{
		"pwntester/octo.nvim",
		cmd = "Octo",
		requires = {
			"nvim-lua/plenary.nvim",
			"ibhagwan/fzf-lua",
			"nvim-tree/nvim-web-devicons",
		},
		config = function()
			require("octo").setup()
		end,
	},
	{
		"mesirendon/nvim-ghrelease",
		event = "VeryLazy",
		opts = {
			keymaps = {
				create = "<leader>oR",
			},
		},
	},
}
