local golangci_lint = "/opt/homebrew/bin/golangci-lint"

local function find_go_module_root(start_path)
	local current_dir = start_path
	while current_dir ~= "/" and current_dir ~= "." do
		if vim.fn.filereadable(current_dir .. "/go.mod") == 1 then
			return current_dir
		end
		current_dir = vim.fn.fnamemodify(current_dir, ":h")
	end
	return nil
end

local function create_floating_window()
	local width = math.floor(vim.o.columns * 0.8)
	local height = math.floor(vim.o.lines * 0.8)
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
	vim.api.nvim_set_option_value("winblend", 0, { win = win })
	return buf, win
end

local function run_in_floating_terminal(cmd, label)
	local buf, _ = create_floating_window()
	vim.api.nvim_set_current_buf(buf)
	vim.fn.termopen(cmd, {
		on_exit = function(_, code)
			vim.schedule(function()
				if code == 0 then
					print(label .. " finished successfully")
				else
					print(label .. " exited with code: " .. code)
				end
			end)
		end,
	})
	vim.cmd("startinsert")
end

-- Finds go.mod root from current buffer and runs cmd there.
-- cmd: string  -> executed as `cd <root> && <cmd>`
-- cmd: function(root) -> string  -> caller builds the full command
local function run_in_go_module(cmd, label)
	local current_file = vim.api.nvim_buf_get_name(0)
	local current_dir = vim.fn.fnamemodify(current_file, ":h")
	local module_root = find_go_module_root(current_dir)

	if not module_root then
		print("Error: Not in a Go module (no go.mod found)")
		return
	end

	local full_cmd
	if type(cmd) == "function" then
		full_cmd = cmd(module_root)
	else
		full_cmd = string.format("cd %s && %s", vim.fn.shellescape(module_root), cmd)
	end

	run_in_floating_terminal(full_cmd, label)
end

vim.keymap.set("n", "<leader>gl", function()
	run_in_go_module(vim.fn.shellescape(golangci_lint) .. " run", "golangci-lint")
end, { desc = "golangci-lint" })

vim.keymap.set("n", "<leader>glf", function()
	local current_file = vim.api.nvim_buf_get_name(0)
	run_in_go_module(function(root)
		return string.format(
			"cd %s && %s run --fix %s",
			vim.fn.shellescape(root),
			vim.fn.shellescape(golangci_lint),
			vim.fn.shellescape(current_file)
		)
	end, "golangci-lint --fix")
end, { desc = "golangci-lint --fix on curr file" })

vim.keymap.set("n", "<leader>gm", function()
	run_in_go_module("mockery", "mockery")
end, { desc = "mockery" })

vim.keymap.set("n", "<leader>gt", function()
	run_in_go_module("go test ./...", "tests")
end, { desc = "go tests" })

vim.keymap.set("n", "<leader>tlp", function()
	run_in_floating_terminal("cd ts/mcdk && npx prettier --write -c .", "prettier")
end, { desc = "mcdk prettier" })

vim.keymap.set("n", "<leader>tle", function()
	run_in_floating_terminal("cd ts/mcdk && npx eslint --fix .", "eslint")
end, { desc = "mcdk eslint" })
