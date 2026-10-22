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
		"brianhuster/live-preview.nvim",
		cmd = "LivePreview",
		keys = {
			{
				"<leader>lp",
				function()
					-- Each nvim instance runs its own server, so skip ports taken by other instances
					local lp = require("livepreview")
					if not lp.is_running() then
						local utils = require("livepreview.utils")
						local port = 5500
						while #utils.processes_listening_on_port(port) > 0 do
							port = port + 1
						end
						require("livepreview.config").set({ port = port })
					end
					vim.cmd("LivePreview start")
				end,
				ft = { "markdown", "html", "asciidoc", "svg" },
				desc = "Live Preview",
			},
		},
	},
}
