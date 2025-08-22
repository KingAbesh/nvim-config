require("abesh.core.options")
require("abesh.core.keymaps")

-- Make undo persistent like before
vim.opt.undofile = true
vim.opt.undolevels = 10000 -- how many undo steps to keep
vim.opt.undoreload = 100000 -- max lines to save for undo

-- Patch vim.lsp.util.make_position_params to always include position_encoding
do
	local make_position_params = vim.lsp.util.make_position_params

	vim.lsp.util.make_position_params = function(bufnr, offset_encoding)
		bufnr = bufnr or vim.api.nvim_get_current_buf()

		if not offset_encoding then
			local clients = vim.lsp.get_clients({ bufnr = bufnr })
			if #clients > 0 then
				offset_encoding = clients[1].offset_encoding or "utf-16"
			else
				offset_encoding = "utf-16" -- safe default
			end
		end

		return make_position_params(bufnr, offset_encoding)
	end
end

-- Global shims for Neovim deprecations

-- 1. Patch client.supports_method → client:supports_method
vim.lsp.start_client = (function(orig)
	return function(config)
		local client_id = orig(config)
		local client = vim.lsp.get_client_by_id(client_id)
		if client and client.supports_method and not client.__patched then
			client.__patched = true
			local old = client.supports_method
			client.supports_method = function(self, method)
				return old(self, method) or self:supports_method(method)
			end
		end
		return client_id
	end
end)(vim.lsp.start_client)

-- 2. Alias vim.lsp.get_active_clients → vim.lsp.get_clients
if not vim.lsp.get_active_clients then
	vim.lsp.get_active_clients = vim.lsp.get_clients
end

-- 3. Alias old vim.validate signature → new one
if type(vim.validate) == "function" then
	local old_validate = vim.validate
	vim.validate = function(...)
		local args = { ... }
		-- If called with a table, fallback to old
		if type(args[1]) == "table" then
			return old_validate(...)
		end
		-- Else assume new-style
		return old_validate(...)
	end
end

-- Highlight yanked text for 200ms
vim.api.nvim_create_autocmd("TextYankPost", {
	callback = function()
		vim.highlight.on_yank({ higroup = "IncSearch", timeout = 200 })
	end,
})
