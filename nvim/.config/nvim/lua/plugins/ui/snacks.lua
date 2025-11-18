return {
	"folke/snacks.nvim",
	priority = 1000,
	lazy = false,
	---@type snacks.Config
	opts = {
		notifier = { enable = true },
		animate = { enable = true },
		toggle = { enable = true },
		words = { enable = true },
		scroll = { enabled = true },
		input = { enabled = true },
		bufdelete = { enabled = true },
		indent = { enabled = true },
		rename = { enabled = true },
		statuscolumn = { enabled = true },
		terminal = {
			shell = "fish",
		},
		dashboard = { enable = true },
		lazygit = { enable = true },
		-- explorer = {
		-- 	replace_netrw = true, -- Replace netrw with the snacks explorer
		-- 	trash = true, -- Use the system trash when deleting files
		-- },
	},
	keys = {
		-- Terminal toggle
		{
			"<leader>tt",
			function()
				Snacks.terminal()
			end,
			desc = "Toggle terminal",
			mode = { "n", "t" },
		},
		-- Open lazygit
		{
			"<leader>tg",
			function()
				Snacks.lazygit()
			end,
			desc = "Toggle lazygit",
			-- mode = { "n", "t" },
		},
		-- Dismiss notifications
		{
			"<leader>sn",
			function()
				Snacks.notifier.hide()
			end,
			desc = "Dismiss All Notifications",
		},
		-- {
		-- 	"<leader>te",
		-- 	function()
		-- 		Snacks.explorer.open()
		-- 	end,
		-- 	desc = "Open File Explorer",
		-- },
	},
}
