return {
	"saghen/blink.cmp",
	dependencies = {
		"L3MON4D3/LuaSnip",
		"nvim-mini/mini.icons",
		"onsails/lspkind.nvim",
		"rafamadriz/friendly-snippets",
	},
	version = "1.*",

	---@module 'blink.cmp'
	---@type blink.cmp.Config
	opts = {
		-- 'default' (recommended) for mappings similar to built-in completions (C-y to accept)
		-- 'super-tab' for mappings similar to vscode (tab to accept)
		-- 'enter' for enter to accept
		-- 'none' for no mappings
		--
		-- All presets have the following mappings:
		-- C-space: Open menu or open docs if already open
		-- C-n/C-p or Up/Down: Select next/previous item
		-- C-e: Hide menu
		-- C-k: Toggle signature help (if signature.enabled = true)
		--
		-- See :h blink-cmp-config-keymap for defining your own keymap
		keymap = { preset = "default" },

		appearance = {
			nerd_font_variant = "mono",
		},

		completion = {
			list = { selection = { auto_insert = true } },
			documentation = { auto_show = true, auto_show_delay_ms = 200 },
			ghost_text = { enabled = true },

			menu = {
				border = "single",
				max_height = 10,
				scrollbar = true,
				draw = {
					components = {
						kind_icon = {
							text = function(ctx)
								if vim.tbl_contains({ "Path" }, ctx.source_name) then
									local mini_icon, _ = require("mini.icons").get_icon(ctx.item.data.type, ctx.label)
									if mini_icon then
										return mini_icon .. ctx.icon_gap
									end
								end

								local icon = require("lspkind").symbolic(ctx.kind, { mode = "symbol" })
								return icon .. ctx.icon_gap
							end,

							highlight = function(ctx)
								if vim.tbl_contains({ "Path" }, ctx.source_name) then
									local mini_icon, mini_hl =
										require("mini.icons").get_icon(ctx.item.data.type, ctx.label)
									if mini_icon then
										return mini_hl
									end
								end
								return ctx.kind_hl
							end,
						},
						kind = {
							-- Optional, use highlights from mini.icons
							highlight = function(ctx)
								if vim.tbl_contains({ "Path" }, ctx.source_name) then
									local mini_icon, mini_hl =
										require("mini.icons").get_icon(ctx.item.data.type, ctx.label)
									if mini_icon then
										return mini_hl
									end
								end
								return ctx.kind_hl
							end,
						},
					},
				},
			},
		},
	},
}
