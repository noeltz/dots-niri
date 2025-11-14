return {
	-- close "" {} [] ''
	{
		"nvim-mini/mini.pairs",
		version = "*",
		event = "VeryLazy",
		opts = {
			skip_next = [=[[%w%%%'%[%"%.%`%$]]=],
			skip_ts = { "string" },
			skip_unbalanced = true,
		},
	},
	-- comments with gc keys
	{ "nvim-mini/mini.comment", version = "*" },
	-- icons
	{ "nvim-mini/mini.icons", version = "*" },
	-- underline current word
	{ "nvim-mini/mini.cursorword", version = "*" },
	-- trail spaces
	{ "nvim-mini/mini.trailspace", version = "*" },
}
