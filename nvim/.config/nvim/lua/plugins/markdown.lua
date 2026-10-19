return {
	{
		"MeanderingProgrammer/render-markdown.nvim",
		dependencies = { "nvim-treesitter/nvim-treesitter" },
		ft = { "markdown", "markdown.mdx" },
		opts = {
			code = {
				sign = false,
				width = "block",
				right_pad = 1,
			},
			heading = {
				sign = false,
				icons = {},
			},
			checkbox = {
				enabled = true,
			},
		},
		keys = {
			{
				"<leader>um",
				function()
					local rm = require("render-markdown")
					if rm.get() then rm.disable() else rm.enable() end
				end,
				ft = "markdown",
				desc = "Toggle Render Markdown",
			},
		},
	},
	{
		"iamcco/markdown-preview.nvim",
		cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
		build = function()
			require("lazy").load({ plugins = { "markdown-preview.nvim" } })
			vim.fn["mkdp#util#install"]()
		end,
		config = function()
			vim.cmd([[do FileType]])
		end,
		keys = {
			{
				"<leader>cp",
				"<cmd>MarkdownPreviewToggle<cr>",
				ft = "markdown",
				desc = "Markdown Preview",
			},
		},
	},
}
