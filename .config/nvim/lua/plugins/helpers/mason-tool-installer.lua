return {
	"WhoIsSethDaniel/mason-tool-installer.nvim",
	dependecies = {
		"mason-org/mason.nvim",
	},
	config = function()
		require("mason-tool-installer").setup({
			ensure_installed = {
				-- formatters
				"black",
				"isort", -- Python
				"stylua", -- Lua
				"prettierd",
				"prettier", -- JS/TS
				"yamlfmt",

				-- linters
				"flake8", -- Python
				"luacheck", -- Lua
				"eslint_d", -- JS/TS
				"hadolint", -- Docker
				"yamllint",

				-- lsp
				"pyright", -- Python
				"lua-language-server", -- Lua
				"vtsls", -- JS/TS
				"rust-analyzer", -- Rust
				"docker-language-server", -- Dockerfile
				"docker-compose-language-service",
				"yaml-language-server",
				"copilot-language-server",

				-- dap
				"codelldb",
			},
			auto_update = true,
			run_on_start = true,
		})
	end,
}
