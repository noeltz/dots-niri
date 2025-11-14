return {
	{
		"nvim-treesitter/nvim-treesitter",
		branch = "master",
		lazy = false,
		build = ":TSUpdate",
		config = function()
			require("nvim-treesitter").setup({
				-- Languages to install
				ensure_installed = {
					"lua",
					"vim",
					"vimdoc",
					"python",
					"javascript",
					"typescript",
					"html",
					"css",
					"json",
					"bash",
					"c",
					"rust",
					"yaml",
					"dockerfile",
					"cpp",
					"fish",
					"markdown",
					"markdown_inline",
				},
				-- Automatically install missing parsers when entering buffer
				auto_install = true,
				highlight = {
					enable = true,
				},
			})
		end,
	},
	{
		"Djancyp/better-comments.nvim",
	},
}
