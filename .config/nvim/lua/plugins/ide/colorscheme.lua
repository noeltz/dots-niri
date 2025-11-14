return {
	-- catppuccin dark
	{
		"catppuccin/nvim",
		lazy = true,
		name = "catppuccin",
		opts = {
			color_overrides = {
				mocha = {
					base = "#090909",
					mantle = "#090909",
				},
			},
			integrations = {
				dashboard = true,
				bufferline = true,
				mason = true,
				mini = true,
				notify = true,
				snacks = true,
				which_key = true,
			},
		},
	},
}
