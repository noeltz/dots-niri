return {
	{
		"github/copilot.vim",
	},
	{
		"NickvanDyke/opencode.nvim",
		dependencies = {
			-- Recommended for `ask()` and `select()`.
			-- Required for default `toggle()` implementation.
			{ "folke/snacks.nvim", opts = { input = {}, picker = {}, terminal = {} } },
		},
	},
}
