return {
	"akinsho/bufferline.nvim",
	version = "*",
	-- event = "VeryLazy",
	-- keys = {
	-- 	{ "<leader>bp", "<Cmd>BufferLineTogglePin<CR>", desc = "Toggle Pin" },
	-- 	{ "<leader>bP", "<Cmd>BufferLineGroupClose ungrouped<CR>", desc = "Delete Non-Pinned Buffers" },
	-- 	{ "<leader>br", "<Cmd>BufferLineCloseRight<CR>", desc = "Delete Buffers to the Right" },
	-- 	{ "<leader>bl", "<Cmd>BufferLineCloseLeft<CR>", desc = "Delete Buffers to the Left" },
	-- 	{ "<S-h>", "<cmd>BufferLineCyclePrev<cr>", desc = "Prev Buffer" },
	-- 	{ "<S-l>", "<cmd>BufferLineCycleNext<cr>", desc = "Next Buffer" },
	-- },
	opts = {
		options = {
        -- stylua: ignore
			-- diagnostics = "lint",
			-- always_show_bufferline = true,
			-- diagnostics_indicator = function(_, _, diag)
			-- 	-- local icons = LazyVim.config.icons.diagnostics
			-- 	local ret = (diag.error and icons.Error .. diag.error .. " " or "")
			-- 		.. (diag.warning and icons.Warn .. diag.warning or "")
			-- 	return vim.trim(ret)
			-- end,
			offsets = {
				{
					-- filetype = "Netrw",
					-- text = "Neo Tree",
					-- highlight = "Directory",
					-- text_align = "left",
				},
			},
		},
	},
}
