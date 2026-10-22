vim.g.mapleader = " "

vim.keymap.set("n", "<leader>pv", ":Oil<CR>", { noremap = true, silent = true, desc = "Open file manager" })

vim.keymap.set("n", "<leader>gu", ":r !uuidgen<CR>0v$y", { noremap = true, silent = true, desc = "Insert UUID" })

vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move selection down" })
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move selection up" })

vim.keymap.set("n", "J", "mzJ`z", { desc = "Join lines without moving cursor" })

vim.keymap.set("n", "<C-d>", "<C-d>zz", { desc = "Scroll half page down, centered" })
vim.keymap.set("n", "<C-u>", "<C-u>zz", { desc = "Scroll half page up, centered" })

vim.keymap.set("n", "n", "nzzzv", { desc = "Next search result, centered" })
vim.keymap.set("n", "N", "Nzzzv", { desc = "Prev search result, centered" })

-- terminal
vim.keymap.set("n", "<leader>tt", "<cmd>ToggleTerm<cr>", { desc = "Toggle terminal" })

-- paste and copy again to buffer
vim.keymap.set("x", "<leader>p", [["_dP]], { desc = "Paste without losing buffer" })

-- yank selection/motion to system clipboard
vim.keymap.set({ "n", "v" }, "<leader>y", [["+y]], { desc = "Yank to clipboard" })

-- yank entire line to system clipboard
vim.keymap.set("n", "<leader>Y", [["+Y]], { desc = "Yank line to clipboard" })

-- map Ctrl+C to Esc in insert mode
vim.keymap.set("i", "<C-c>", "<Esc>", { desc = "Escape insert mode" })

-- disabling Q
vim.keymap.set("n", "Q", "<nop>", { desc = "Disabled (prevent ex mode)" })

-- this so useful %s/wordUnderTheCursor/wordToReplaceWith/gI
vim.keymap.set(
	"n",
	"<leader>s",
	[[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]],
	{ desc = "Substitute word under cursor" }
)

-- make a file executable
vim.keymap.set("n", "<leader>x", "<cmd>!chmod +x %<CR>", { silent = true, desc = "chmod +x current file" })

vim.keymap.set("n", "<leader><leader>", function()
	vim.cmd("so")
end, { desc = "Source current file" })

local map = vim.keymap.set

-- Register global which-key groups
vim.api.nvim_create_autocmd("User", {
	pattern = "VeryLazy",
	once = true,
	callback = function()
		local ok, wk = pcall(require, "which-key")
		if not ok then
			return
		end
		wk.add({
			{ "<leader>p", group = "Project/Files" },
			{ "<leader>g", group = "Git/Generate" },
			{ "<leader>v", group = "VimWithMe" },
			{ "<leader>s", group = "Search/Substitute" },
			{ "<leader>m", group = "Markdown" },
			{ "<leader>a", group = "AI/Harpoon" },
			{ "<leader>t", group = "Terminal/Tests" },
		})
	end,
})

vim.api.nvim_create_autocmd("FileType", {
	pattern = "go",

	callback = function(ev)
		local buf = ev.buf
		local dap = require("dap")
		local dapui = require("dapui")
		local wkok, wk = pcall(require, "which-key")
		if wkok then
			wk.add({
				{ "<leader>t", group = "Tests", buffer = buf },
				{ "<leader>d", group = "Debug", buffer = buf },
				{ "<leader>l", group = "Linter", buffer = buf },
			})
		end
		-- ==== Debugging <leader>d ==== --
		-- Breakpoints --
		map("n", "<leader>db", function()
			dap.toggle_breakpoint()
		end, { desc = "Breakpoint: Toggle", buffer = buf })

		map("n", "<leader>dB", function()
			vim.ui.input({ prompt = "Breakpoint condition: " }, function(cond)
				if cond and #cond > 0 then
					dap.set_breakpoint(cond)
				end
			end)
		end, { desc = "Breakpoint: Conditional", buffer = buf })

		map("n", "<leader>dC", function()
			dap.clear_breakpoints()
		end, { desc = "Breakpoint: Clear All", buffer = buf })

		-- Controls --
		map("n", "<leader>dc", function()
			dap.continue()
		end, { desc = "Start/Continue", buffer = buf })

		map("n", "<leader>di", function()
			dap.step_into()
		end, { desc = "Step Into", buffer = buf })

		map("n", "<leader>do", function()
			dap.step_over()
		end, { desc = "Step Over", buffer = buf })

		map("n", "<leader>dO", function()
			dap.step_out()
		end, { desc = "Step Out", buffer = buf })

		map("n", "<leader>dr", function()
			dap.restart()
		end, { desc = "Restart", buffer = buf })

		map("n", "<leader>dS", function()
			dap.terminate()
		end, { desc = "Stop", buffer = buf })

		-- UI/Introspection
		map("n", "<leader>du", function()
			dapui.toggle()
		end, { desc = "DAP UI: Toggle", buffer = buf })

		map("n", "<leader>ds", function()
			dapui.open({})
		end, { desc = "View: Scopes/Stacks/Breakpoints", buffer = buf })

		map("n", "<leader>dv", function()
			require("dap.ui.widgets").hover()
		end, { desc = "Inspect Variable (hover)", buffer = buf })
	end,
})
