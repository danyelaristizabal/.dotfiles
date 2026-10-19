local neotest = require('neotest')

-- Helper function to find the Go module root (directory containing go.mod)
local function find_go_module_root(start_path)
    local current_dir = start_path

    while current_dir ~= "/" and current_dir ~= "." do
        local go_mod_path = current_dir .. "/go.mod"
        if vim.fn.filereadable(go_mod_path) == 1 then
            return current_dir
        end
        current_dir = vim.fn.fnamemodify(current_dir, ":h")
    end

    return nil
end

-- Helper function to find all go.mod directories under go/
local function find_all_go_modules()
    local cwd = vim.loop.cwd()
    local go_dir = cwd .. "/go"

    if vim.fn.isdirectory(go_dir) == 0 then
        return {}
    end

    local modules = {}
    local subdirs = vim.fn.glob(go_dir .. "/*", false, true)

    for _, subdir in ipairs(subdirs) do
        if vim.fn.isdirectory(subdir) == 1 and vim.fn.filereadable(subdir .. "/go.mod") == 1 then
            table.insert(modules, subdir)
        end
    end

    return modules
end

vim.keymap.set('n', '<leader>tn', function()
    neotest.run.run()
end, { desc = "Run nearest test" })

vim.keymap.set('n', '<leader>tf', function()
    neotest.run.run(vim.fn.expand("%"))
end, { desc = "Run tests in file" })

vim.keymap.set('n', '<leader>to', function()
    neotest.output_panel.open()
end, { desc = "Open neotest output panel" })

vim.keymap.set('n', '<leader>ta', function()
    local current_file = vim.api.nvim_buf_get_name(0)
    local current_dir = vim.fn.fnamemodify(current_file, ":h")

    -- Try to find the go.mod for the current buffer
    local module_root = find_go_module_root(current_dir)

    if module_root then
        -- Run tests for the specific Go module
        print("Running tests for module: " .. module_root)
        neotest.run.run(module_root)
    else
        -- Not in a Go module, run all modules
        local modules = find_all_go_modules()
        if #modules > 0 then
            print("Running tests for all " .. #modules .. " Go modules")
            for _, mod in ipairs(modules) do
                neotest.run.run(mod)
            end
        else
            -- Fallback to CWD
            print("No Go modules found, running from CWD")
            neotest.run.run(vim.loop.cwd())
        end
    end
end, { desc = "Run all tests in project/module" })

vim.keymap.set('n', '<leader>tp', function()
    neotest.run.run(vim.fn.fnamemodify(vim.api.nvim_buf_get_name(vim.api.nvim_get_current_buf()), ":h"))
end, { desc = "Run test in package" })

vim.keymap.set('n', '<leader>ts', function()
    neotest.summary.toggle()
end, { desc = "Toggle neotest summary" })
