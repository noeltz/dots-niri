local function start_lsp(filetype, opts)
	vim.api.nvim_create_autocmd("FileType", {
		pattern = filetype,
		callback = function(args)
			vim.lsp.start(
				vim.tbl_extend("keep", opts, { root_dir = vim.fs.root(0, opts.root_markers), bufnr = args.buf })
			)
		end,
	})
end

start_lsp({ "lua" }, {
	name = "lua_lsp",
	cmd = { "lua-language-server" },
	root_markers = { ".git", ".luacheckrc", ".stylua.toml" },
	settings = {
		Lua = {
			diagnostics = {
				enable = false,
			},
		},
	},
})

start_lsp({
	"javascript",
	"javascriptreact",
	"typescript",
	"typescriptreact",
	"javascript.jsx",
	"typescript.tsx",
}, {
	name = "typescript_lsp",
	cmd = { "vtsls", "--stdio" },
	root_markers = { "package-lock.json", "yarn.lock", "pnpm-lock.yaml", "bun.lockb", "bun.lock", ".git" },
})

start_lsp({ "python" }, {
	name = "python_lsp",
	cmd = { "pyright-langserver", "--stdio" },
	root_markers = {
		"pyrightconfig.json",
		"pyproject.toml",
		"setup.py",
		"setup.cfg",
		"requirements.txt",
		"Pipfile",
		".git",
	},
})

start_lsp({ "rust" }, {
	name = "rust_lsp",
	cmd = { "rust-analyzer" },
	root_markers = { "Cargo.toml", ".git" },
})

start_lsp({ "dockerfile", "yaml.docker-compose" }, {
	name = "docker_lsp",
	cmd = { "docker-language-server", "start", "--stdio" },
	root_markers = {
		"Dockerfile",
		"docker-compose.yaml",
		"docker-compose.yml",
		"compose.yaml",
		"compose.yml",
		"docker-bake.json",
		"docker-bake.hcl",
		"docker-bake.override.json",
		"docker-bake.override.hcl",
	},
})

start_lsp({ "yaml.docker-compose" }, {
	name = "compose-lsp",
	cmd = { "docker-compose-langserver", "--stdio" },
	filetypes = { "yaml.docker-compose" },
	root_markers = { "docker-compose.yaml", "docker-compose.yml", "compose.yaml", "compose.yml" },
	-- single_file_support = true,
})

start_lsp({ "yaml", "yaml.docker-compose", "yaml.gitlab", "yaml.helm-values" }, {
	name = "yaml_lsp",
	cmd = { "yaml-language-server", "--stdio" },
	settings = {
		redhat = { telemetry = { enabled = false } },
		yaml = { format = { enable = true } },
	},
	root_markers = { ".git" },
})

start_lsp({ "*" }, {
	name = "copilot_lsp",
	cmd = { "copilot-language-server", "--stdio" },
	root_markers = { ".git" },
})
