local opts = { noremap = true, silent = true }

vim.keymap.set("n", "gd", vim.lsp.buf.definition, vim.tbl_extend("force", opts, { desc = "Go to definition" }))
vim.keymap.set("n", "gD", vim.lsp.buf.declaration, vim.tbl_extend("force", opts, { desc = "Go to declaration" }))
vim.keymap.set("n", "gr", vim.lsp.buf.references, vim.tbl_extend("force", opts, { desc = "Show references" }))
vim.keymap.set("n", "grn", vim.lsp.buf.rename, vim.tbl_extend("force", opts, { desc = "rename" }))
vim.keymap.set(
	"n",
	"<leader>e",
	vim.diagnostic.open_float,
	vim.tbl_extend("force", opts, { desc = "Show diagnostics" })
)
vim.keymap.set(
	"n",
	"<space>ga",
	"<cmd>lua vim.lsp.buf.code_action({apply=true})<CR>",
	vim.tbl_extend("force", opts, { desc = "Code action (apply)" })
)
