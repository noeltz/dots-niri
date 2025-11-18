return {
	"folke/edgy.nvim",
	event = "VeryLazy",
	opts = {
		animate = { enabled = false }, -- optional: disable animations
		exit_when_last = true, -- close Neo-tree when it's the last window
		bottom = {},
		left = {
			{
				title = "Files",
				ft = "neo-tree",
				filter = function(buf)
					return vim.b[buf].neo_tree_source == "filesystem"
				end,
				size = { width = 35 },
				open = "Neotree position=left filesystem",
			},
		},
		right = {},
		top = {},
	},
}
