local mark = require("harpoon.mark")
local ui = require("harpoon.ui")

vim.keymap.set("n", "<leader>a", mark.add_file, { desc = "Harpoon: add file" })
vim.keymap.set("n", "<C-e>", ui.toggle_quick_menu, { desc = "Harpoon: menu" })
vim.keymap.set("n", "<C-j>", ui.nav_next, { desc = "Harpoon: next file" })
vim.keymap.set("n", "<C-k>", ui.nav_prev, { desc = "Harpoon: prev file" })

require("harpoon").setup({
	menu = {
		width = vim.api.nvim_win_get_width(0) - 4,
	},
})
