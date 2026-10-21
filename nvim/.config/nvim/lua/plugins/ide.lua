-- Go first IDE setup + common languages
return {
	-- 1) Making sure dev tools are installed
	{ "mason-org/mason.nvim", opts = {} },
	{
		-- mason.nvim itself has no `ensure_installed`; this plugin provides it
		"WhoIsSethDaniel/mason-tool-installer.nvim",
		dependencies = { "mason-org/mason.nvim" },
		opts = {
			ensure_installed = {
				-- GitUI
				"gitui",
				-- Go
				"gopls",
				"gofumpt",
				"goimports",
				"golangci-lint",
				"delve",
				-- TS/JS
				"vtsls",
				"prettierd",
				"eslint_d",
				-- Lua
				"lua-language-server",
				"stylua",
				-- Bash / Shell
				"bash-language-server",
				"shfmt",
				"shellcheck",
				-- Markdown
				"marksman",
				"markdownlint-cli2",
				"markdown-toc",
			},
		},
	},
	-- code outline :aerialopen
	{
		"stevearc/aerial.nvim",
		opts = {
			layout = {
				min_width = 50,
				max_width = { 80, 0.4 },
			},
		},
	},
	-- 3) Formatting
	{
		"stevearc/conform.nvim",
		event = "BufWritePre",
		cmd = "ConformInfo",
		opts = {
			formatters_by_ft = {
				go = { "gofumpt", "goimports" },
				lua = { "stylua" },
				python = { "isort", "black" },
				javascript = { "prettierd", "prettier", stop_after_first = true },
				typescript = { "prettierd", "prettier", stop_after_first = true },
				json = { "prettierd", "prettier", stop_after_first = true },
				yaml = { "prettierd", "prettier", stop_after_first = true },
				html = { "prettierd", "prettier", stop_after_first = true },
				tmpl = { "templ", "prettierd", "prettier" },
				css = { "prettierd", "prettier", stop_after_first = true },
				sh = { "shfmt" },
				bash = { "shfmt" },
				zsh = { "shfmt" },
				markdown = { "prettierd", "markdownlint-cli2", "markdown-toc" },
				["markdown.mdx"] = { "prettierd", "markdownlint-cli2", "markdown-toc" },
			},
			formatters = {
				["markdown-toc"] = {
					condition = function(_, ctx)
						for _, line in ipairs(vim.api.nvim_buf_get_lines(ctx.buf, 0, -1, false)) do
							if line:find("<!%-%- toc %-%->") then
								return true
							end
						end
					end,
				},
				["markdownlint-cli2"] = {
					condition = function(_, ctx)
						local diag = vim.tbl_filter(function(d)
							return d.source == "markdownlint"
						end, vim.diagnostic.get(ctx.buf))
						return #diag > 0
					end,
				},
			},
			format_on_save = {
				timeout_ms = 3000,
				lsp_format = "fallback",
			},
		},
	},
	{ "ngynkvn/gotmpl.nvim", opts = {} },
	-- 4) Linting
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

			-- Auto-lint on save and when entering buffer
			vim.api.nvim_create_autocmd({ "BufWritePost", "BufEnter" }, {
				group = vim.api.nvim_create_augroup("nvim_lint", { clear = true }),
				callback = function(args)
					local opts = {}
					-- Run golangci-lint from the module root so it picks up .golangci.yml.
					-- nvim-lint only accepts a string cwd, so it is resolved here per buffer.
					if vim.bo[args.buf].filetype == "go" then
						opts.cwd = vim.fs.root(args.buf, "go.mod") or vim.fs.dirname(vim.api.nvim_buf_get_name(args.buf))
					end
					lint.try_lint(nil, opts)
				end,
			})
		end,
	},
	-- 5) Debugging for Go
	{ "mfussenegger/nvim-dap" },
	{
		"leoluz/nvim-dap-go",
		ft = "go",
		config = function()
			local dap = require("dap")

			dap.adapters.go = {
				type = "server",
				port = "${port}",
				executable = {
					command = "dlv",
					args = { "dap", "-l", "127.0.0.1:${port}" },
					env = {
						AWS_PROFILE = os.getenv("AWS_PROFILE"),
						AWS_REGION = os.getenv("AWS_REGION"),
					},
				},
			}
			require("dap-go").setup({
				dap_configurations = {
					{
						type = "go",
						main = "Debug Main",
						request = "launch",
						program = "${workspaceFolder}",
						cwd = "${workspaceFolder}",
					},
					{
						type = "go",
						main = "Debug Current File",
						request = "launch",
						program = "${file}",
						cwd = "${fileDirname}",
					},
				},
			})
			dap.defaults.fallback.terminal_win_cmd = "10split new"
		end,
	},
	{
		"rcarriga/nvim-dap-ui",
		dependencies = {
			"mfussenegger/nvim-dap",
			"nvim-neotest/nvim-nio",
		},
		opts = {
			controls = {
				element = "repl",
				enabled = true,
				icons = {
					disconnect = "",
					pause = "",
					play = "",
					run_last = "",
					step_back = "",
					step_into = "",
					step_out = "",
					step_over = "",
					terminate = "",
				},
			},
			element_mappings = {},
			expand_lines = true,
			floating = {
				border = "single",
				mappings = {
					close = { "q", "<Esc>" },
				},
			},
			force_buffers = true,
			icons = {
				collapsed = "",
				current_frame = "",
				expanded = "",
			},
			layouts = {
				{
					elements = {
						{
							id = "scopes",
							size = 0.25,
						},
						{
							id = "breakpoints",
							size = 0.25,
						},
						{
							id = "stacks",
							size = 0.25,
						},
						{
							id = "watches",
							size = 0.25,
						},
					},
					position = "left",
					size = 40,
				},
				{
					elements = {
						{
							id = "repl",
							size = 0.5,
						},
						{
							id = "console",
							size = 0.5,
						},
					},
					position = "bottom",
					size = 10,
				},
			},
			mappings = {
				edit = "e",
				expand = { "<CR>", "<2-LeftMouse>" },
				open = "o",
				remove = "d",
				repl = "r",
				toggle = "t",
			},
			render = {
				indent = 1,
				max_value_lines = 100,
			},
		},
		config = function(_, opts)
			local dap = require("dap")
			local dapui = require("dapui")

			dapui.setup(opts)
			dap.listeners.after.event_initialized["dapui_auto"] = function()
				dapui.open()
			end
			dap.listeners.before.event_terminated["dapui_auto"] = function()
				dapui.close()
			end
			dap.listeners.before.event_exited["dapui_auto"] = function()
				dapui.close()
			end

			vim.fn.sign_define("DapBreakpoint", { text = "🔴", texthl = "DiagnosticError" })
			vim.fn.sign_define("DapBreakpointRejected", { text = "⚠️", texthl = "DiagnosticWarn" })
			vim.fn.sign_define("DapStopped", { text = "▶️", texthl = "DiagnosticInfo", linehl = "Visual" })
		end,
	},
	{ "theHamsta/nvim-dap-virtual-text", config = true },
	{
		"buoto/gotests-vim",
		init = function()
			vim.g.gotests_template = ""
			vim.g.gotests_template_dir = ""
			-- optional if gotests is not in PATH:
			-- vim.g.gotests_bin = vim.fn.expand("~/go/bin/gotests")
		end,
	},
}
