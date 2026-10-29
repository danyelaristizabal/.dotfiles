local Terminal = require("toggleterm.terminal").Terminal

-- toggle terminal by number: 1<leader>tt, 2<leader>tt, etc.
vim.keymap.set({ "n", "t" }, "<leader>tn", function()
	local count = vim.v.count1
	vim.cmd(count .. "ToggleTerm")
end, { desc = "Toggle terminal (by number)" })

-- next/prev terminal while inside terminal mode
local terms = require("toggleterm.terminal")

local function switch_term(delta)
	local all = terms.get_all(true)
	if #all < 2 then
		return
	end
	local cur = all[1]
	for _, t in ipairs(all) do
		if t:is_focused() then
			cur = t
			break
		end
	end
	local idx
	for i, t in ipairs(all) do
		if t.id == cur.id then
			idx = i
			break
		end
	end
	local next_idx = ((idx - 1 + delta) % #all) + 1
	cur:close()
	all[next_idx]:open()
end

vim.keymap.set("t", "<C-h>", function()
	switch_term(-1)
end, { desc = "Prev terminal" })
vim.keymap.set("t", "<C-l>", function()
	switch_term(1)
end, { desc = "Next terminal" })

-- exit terminal insert mode without closing (double-tap so single Esc passes through to TUIs)
vim.keymap.set("t", "<Esc><Esc>", [[<C-\><C-n>]], { desc = "Exit terminal insert mode" })

-- close whichever terminal is currently focused
vim.keymap.set("t", "<leader>tt", function()
	for _, t in ipairs(require("toggleterm.terminal").get_all(true)) do
		if t:is_focused() then
			t:close()
			return
		end
	end
end, { desc = "Close active terminal" })

-- persistent TUI terminals
local claude = Terminal:new({ cmd = "claude", count = 100, direction = "float", hidden = true })

local lazygit = Terminal:new({ cmd = "lazygit", count = 102, direction = "float", hidden = true })

-- Browser view of the current API spec, picked by its first key:
--   openapi:  Redocly builds a static HTML page and opens it
--   asyncapi: bundled into one file first (the browser can't resolve local $refs), then Studio
-- Both show a snapshot: run it again to rebuild. Only mapped in yaml buffers.
local studio

local function open_spec_viewer()
	if studio then
		studio:shutdown()
	end
	local file = vim.api.nvim_buf_get_name(0)
	local src = vim.fn.shellescape(file)
	local cmd
	if vim.fn.search("^openapi:", "nw") > 0 then
		local html = vim.fn.shellescape(vim.fn.tempname() .. ".html")
		cmd = string.format("npx -y @redocly/cli build-docs %s -o %s && open %s", src, html, html)
	else
		local bundled = vim.fn.shellescape(vim.fn.tempname() .. ".yaml")
		cmd = string.format(
			"npx -y @asyncapi/cli bundle %s -o %s && npx -y @asyncapi/cli start studio -f %s",
			src,
			bundled,
			bundled
		)
	end
	studio = Terminal:new({
		cmd = cmd,
		dir = vim.fn.fnamemodify(file, ":h"),
		count = 103,
		direction = "float",
		hidden = true,
	})
	studio:toggle()
end

vim.api.nvim_create_autocmd("FileType", {
	pattern = "yaml",
	callback = function(args)
		vim.keymap.set("n", "<leader>ta", open_spec_viewer, { buffer = args.buf, desc = "API spec viewer" })
	end,
})

vim.keymap.set({ "n", "t" }, "<leader>tc", function()
	claude:toggle()
end, { desc = "claude" })

vim.keymap.set({ "n", "t" }, "<leader>trc", function()
	irc:toggle()
end, { desc = "irc" })

vim.keymap.set({ "n", "t" }, "<leader>lg", function()
	lazygit:toggle()
end, { desc = "lazygit" })
