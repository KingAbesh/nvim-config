local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable", -- latest stable release
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)

-- Only load plugins if NOT in VS Code
if not vim.g.vscode then
	require("lazy").setup({
		{ "LazyVim/LazyVim" },
		{ import = "lazyvim.plugins.extras.dap.core" },
		{ import = "abesh.plugins" },
		{ import = "abesh.plugins.lsp" },
	}, {
		checker = {
			enabled = true,
			notify = false,
		},
		change_detection = {
			notify = false,
		},
	})
end
