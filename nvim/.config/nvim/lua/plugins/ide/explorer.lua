return {
	"nvim-neo-tree/neo-tree.nvim",
	branch = "v3.x",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"MunifTanjim/nui.nvim",
		"nvim-tree/nvim-web-devicons", -- optional, but recommended
	},
	lazy = false, -- neo-tree will lazily load itself
	opts = {
		source_selector = {
			winbar = true,
			content_layout = "center",
		},
		filesystem = {
			filtered_items = {
				hide_dotfiles = false,
				hide_hidden = false,
			},
		},
		default_component_configs = {
			git_status = {
				symbols = {
					untracked = "",
				},
			},
			indent = {
				with_expanders = true,
				expander_collapsed = "",
				expander_expanded = "",
				expander_highlight = "NeoTreeExpander",
			},
		},
	},
}
