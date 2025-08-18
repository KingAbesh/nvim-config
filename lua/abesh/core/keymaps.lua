vim.g.mapleader = " "
vim.g.maplocalleader = " "

local keymap = vim.keymap -- for conciseness

---------------------
-- General Keymaps -------------------

-- use jk to exit insert mode
keymap.set("i", "jk", "<ESC>", { desc = "Exit insert mode with jk" })

-- clear search highlights
keymap.set("n", "<leader>nh", ":nohl<CR>", { desc = "Clear search highlights" })

-- delete single character without copying into register
-- keymap.set("n", "x", '"_x')

-- increment/decrement numbers
keymap.set("n", "<leader>+", "<C-a>", { desc = "Increment number" }) -- increment
keymap.set("n", "<leader>-", "<C-x>", { desc = "Decrement number" }) -- decrement

-- window management
keymap.set("n", "<leader>sv", "<C-w>v", { desc = "Split window vertically" }) -- split window vertically
keymap.set("n", "<leader>sh", "<C-w>s", { desc = "Split window horizontally" }) -- split window horizontally
keymap.set("n", "<leader>se", "<C-w>=", { desc = "Make splits equal size" }) -- make split windows equal width & height
keymap.set("n", "<leader>sx", "<cmd>close<CR>", { desc = "Close current split" }) -- close current split window

keymap.set("n", "<leader>to", "<cmd>tabnew<CR>", { desc = "Open new tab" }) -- open new tab
keymap.set("n", "<leader>tx", "<cmd>tabclose<CR>", { desc = "Close current tab" }) -- close current tab
keymap.set("n", "<leader>tn", "<cmd>tabn<CR>", { desc = "Go to next tab" }) --  go to next tab
keymap.set("n", "<leader>tp", "<cmd>tabp<CR>", { desc = "Go to previous tab" }) --  go to previous tab
keymap.set("n", "<leader>tf", "<cmd>tabnew %<CR>", { desc = "Open current buffer in new tab" }) --  move current buffer to new tab

vim.api.nvim_set_keymap("n", "<F5>", ":lua require'dap'.continue()<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<F10>", ":lua require'dap'.step_over()<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<F11>", ":lua require'dap'.step_into()<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<F12>", ":lua require'dap'.step_out()<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap(
	"n",
	"<leader>b",
	":lua require'dap'.toggle_breakpoint()<CR>",
	{ noremap = true, silent = true }
)
vim.api.nvim_set_keymap(
	"n",
	"<leader>B",
	":lua require'dap'.set_breakpoint(vim.fn.input('Breakpoint condition: '))<CR>",
	{ noremap = true, silent = true }
)

-- Toggle LazyGit floating terminal
local function open_lazygit(cmd)
	for _, win in ipairs(vim.api.nvim_list_wins()) do
		local buf = vim.api.nvim_win_get_buf(win)
		local name = vim.api.nvim_buf_get_name(buf)
		if name:match("lazygit") then
			if #vim.api.nvim_list_wins() > 1 then
				vim.api.nvim_win_close(win, true) -- close floating win
			else
				vim.cmd("quit") -- fallback if it's the only window
			end
			return
		end
	end

	local width = math.floor(vim.o.columns * 0.9)
	local height = math.floor(vim.o.lines * 0.9)
	local row = math.floor((vim.o.lines - height) / 2)
	local col = math.floor((vim.o.columns - width) / 2)

	local buf = vim.api.nvim_create_buf(false, true)
	local win = vim.api.nvim_open_win(buf, true, {
		relative = "editor",
		width = width,
		height = height,
		row = row,
		col = col,
		style = "minimal",
		border = "rounded",
	})

	-- run lazygit inside terminal
	vim.fn.termopen(cmd or { "lazygit" }, {
		on_exit = function(_, code, _)
			if code == 0 then -- only close on successful exit
				if vim.api.nvim_win_is_valid(win) then
					vim.api.nvim_win_close(win, true)
				end
			else
				vim.notify("LazyGit exited with code " .. code, vim.log.levels.ERROR)
			end
		end,
	})

	vim.cmd("startinsert")

	-- q to quit window
	vim.api.nvim_buf_set_keymap(buf, "n", "q", "<cmd>close<cr>", { noremap = true, silent = true })
end

-- Main keymap
keymap.set("n", "<leader>lg", function()
	open_lazygit("lazygit")
end, { desc = "Toggle LazyGit (floating)" })

-- Optional: Expose as commands too
vim.api.nvim_create_user_command("LazyGit", function()
	open_lazygit("lazygit")
end, {})
vim.api.nvim_create_user_command("LazyGitConfig", function()
	open_lazygit("lazygit -ucf " .. vim.fn.expand("~/.config/lazygit/config.yml"))
end, {})
vim.api.nvim_create_user_command("LazyGitCurrentFile", function()
	local file = vim.fn.expand("%:p") -- absolute path
	open_lazygit("lazygit --filter " .. file)
end, {})
vim.api.nvim_create_user_command("LazyGitFilter", function(opts)
	open_lazygit("lazygit --filter " .. opts.args)
end, { nargs = 1 })
vim.api.nvim_create_user_command("LazyGitFilterCurrentFile", function()
	open_lazygit("lazygit --filter " .. vim.fn.expand("%"))
end, {})
