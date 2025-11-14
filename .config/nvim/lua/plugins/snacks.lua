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
		indent = {},
		rename = { enabled = true },
		statuscolumn = { enabled = true },
		terminal = {
			win = {
				style = "float",
				border = "single",
			},
			shell = "fish",
		},
		dashboard = { enable = true },
		lazygit = { enable = true },
		-- explorer = {
		-- 	-- replace_netrw = true,
		-- 	trash = true,
		-- 	git_status = true,
		-- },
		picker = {
			enable = true,
		},
		zen = { enable = true, toggles = { dim = false } },
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
		-- Toggle lazygit
		{
			"<leader>tg",
			function()
				Snacks.lazygit()
			end,
			desc = "Toggle lazygit",
			mode = { "n", "t" },
		},
		-- Toggle lazydocker
		{
			"<leader>td",
			function()
				Snacks.terminal({ "lazydocker" })
			end,
			desc = "Toggle lazygit",
			mode = { "n", "t" },
		},
		{
			"<leader>te",
			function()
				Snacks.explorer.open()
			end,
			desc = "Open File Explorer",
		},
		{
			"<leader>tz",
			function()
				Snacks.zen()
			end,
			desc = "Open File Explorer",
		},

		{
			"<leader>wq",
			function()
				Snacks.bufdelete()
			end,
			desc = "Close buffer",
			mode = { "n", "t" },
		},
		-- pícker config to find files
		{
			"<leader>fb",
			function()
				Snacks.picker.buffers()
			end,
			desc = "Buffers",
		},
		{
			"<leader>fc",
			function()
				Snacks.picker.files({ cwd = vim.fn.stdpath("config") })
			end,
			desc = "Find Config File",
		},
		{
			"<leader>ff",
			function()
				Snacks.picker.files()
			end,
			desc = "Find Files",
		},

		{
			"<leader>fp",
			function()
				Snacks.picker.projects()
			end,
			desc = "Projects",
		},
		{
			"<leader>fr",
			function()
				Snacks.picker.recent()
			end,
			desc = "Recent",
		},

		{
			"<leader>fv",
			function()
				Snacks.picker.cliphist()
			end,
			desc = "Clip history",
		},
		{
			"<leader>fl",
			function()
				Snacks.picker.lines()
			end,
			desc = "Buffer lines",
		},
		{
			"<leader>fg",
			function()
				Snacks.picker.grep()
			end,
			desc = "Grep",
		},
		{
			"<leader>ft",
			function()
				Snacks.picker.grep_buffers()
			end,
			desc = "Test",
		},
	},
}
