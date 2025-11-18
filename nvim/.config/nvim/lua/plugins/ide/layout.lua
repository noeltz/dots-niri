return {
	"folke/edgy.nvim",
	event = "VeryLazy",
	opts = {
		animate = {
			enable = false,
		},
		bottom = {
			{
				title = "Diagnostics",
				ft = "trouble",
			},
		},
		left = {
			{
				title = "File Explorer",
				ft = "neo-tree",
				filter = function(buf)
					return vim.b[buf].neo_tree_source == "filesystem"
				end,
				size = {
					width = 0.15,
				},
			},
		},
		right = {
			{
				title = "Copilot Chat",
				ft = "copilot-chat",
				size = {
					width = 0.3,
				},
			},
		},
	},
}
