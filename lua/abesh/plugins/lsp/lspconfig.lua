return {
	"neovim/nvim-lspconfig",
	event = { "BufReadPre", "BufNewFile" },
	dependencies = {
		"mason-org/mason-lspconfig.nvim",
		"hrsh7th/cmp-nvim-lsp",
		{ "antosha417/nvim-lsp-file-operations", config = true },
		{ "folke/neodev.nvim", opts = {} },
		"mfussenegger/nvim-dap",
		"leoluz/nvim-dap-go",
	},
	config = function()
		local ok_lsp, lspconfig = pcall(require, "lspconfig")
		if not ok_lsp then
			return
		end

		local cmp_nvim_lsp = require("cmp_nvim_lsp")
		local capabilities = cmp_nvim_lsp.default_capabilities()

		-- Global on_attach
		local on_attach = function(client, bufnr)
			if not vim.g.vscode then
				vim.api.nvim_create_autocmd("CursorHold", {
					buffer = bufnr,
					callback = function()
						vim.lsp.buf.clear_references()
					end,
				})
			end
			local opts = { buffer = bufnr, silent = true }
			local keymap = vim.keymap
			keymap.set("n", "gR", "<cmd>Telescope lsp_references<CR>", opts)
			keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
			keymap.set("n", "gd", "<cmd>Telescope lsp_definitions<CR>", opts)
			keymap.set("n", "gi", "<cmd>Telescope lsp_implementations<CR>", opts)
			keymap.set("n", "gt", "<cmd>Telescope lsp_type_definitions<CR>", opts)
			keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, opts)
			keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
			keymap.set("n", "<leader>D", "<cmd>Telescope diagnostics bufnr=0<CR>", opts)
			keymap.set("n", "<leader>d", vim.diagnostic.open_float, opts)
			keymap.set("n", "[d", vim.diagnostic.goto_prev, opts)
			keymap.set("n", "]d", vim.diagnostic.goto_next, opts)
			keymap.set("n", "K", vim.lsp.buf.hover, opts)
			keymap.set("n", "<leader>rs", ":LspRestart<CR>", opts)
		end

		-- Mason LSPConfig v2+ setup
		require("mason").setup()
		require("mason-lspconfig").setup({
			ensure_installed = { "lua_ls", "gopls", "graphql" },
			automatic_enable = false,
		})

		-- Configure Lua
		-- vim.lsp.config("lua_ls", {
		-- 	capabilities = capabilities,
		-- 	on_attach = on_attach,
		-- 	settings = {
		-- 		Lua = {
		-- 			diagnostics = { globals = { "vim" } },
		-- 			completion = { callSnippet = "Replace" },
		-- 		},
		-- 	},
		-- })

		-- Configure Go
		-- vim.lsp.config("gopls", {
		-- 	capabilities = capabilities,
		-- 	on_attach = on_attach,
		-- 	cmd = { "gopls" },
		-- 	filetypes = { "go", "gomod", "gowork", "gotmpl" },
		-- 	root_dir = lspconfig.util.root_pattern("go.work", "go.mod", ".git"),
		-- 	settings = {
		-- 		gopls = {
		-- 			analyses = {
		-- 				unusedparams = true,
		-- 				nilness = true,
		-- 				shadow = true,
		-- 			},
		-- 			staticcheck = true,
		-- 			gofumpt = true,
		-- 		},
		-- 	},
		-- })

		-- Configure GraphQL
		-- vim.lsp.config("graphql", {
		-- 	capabilities = capabilities,
		-- 	on_attach = on_attach,
		-- 	filetypes = { "graphql", "gql", "svelte", "typescriptreact", "javascriptreact" },
		-- })

		-- Go format-on-save
		vim.api.nvim_create_autocmd("BufWritePre", {
			pattern = "*.go",
			callback = function()
				vim.lsp.buf.format({ async = false })
				vim.lsp.buf.code_action({
					context = { only = { "source.organizeImports" } },
					apply = true,
				})
			end,
		})

		-- Debugging for Go
		require("dap-go").setup()

		-- Diagnostic symbols
		local signs = { Error = " ", Warn = " ", Hint = "󰠠 ", Info = " " }
		for type, icon in pairs(signs) do
			local hl = "DiagnosticSign" .. type
			vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
		end
	end,
}
