-- BASIC CONFIG
vim.g.mapleader = " "
vim.o.number = true
vim.o.relativenumber = true
vim.o.wrap = false
vim.o.tabstop = 4
vim.o.shiftwidth = 4
vim.o.expandtab = true
vim.o.swapfile = false
vim.o.scl = "yes"
vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.winborder = "rounded"
vim.o.colorcolumn = "80"
vim.o.termguicolors = true

-- PLUGINS
vim.pack.add({
    { src = "https://github.com/catppuccin/nvim" },
    { src = "https://github.com/stevearc/oil.nvim" },
    { src = "https://github.com/echasnovski/mini.pick" },
    { src = "https://github.com/christoomey/vim-tmux-navigator" },
})

-- Require
require("catppuccin").setup({ flavour = "frappe" })
require("mini.pick").setup()
require("oil").setup()

-- LSP
-- Enable autocomplete
vim.opt.autocomplete = true
vim.opt.completeopt = { "menuone", "noselect", "noinsert", "popup" }

-- Start language servers
local function start_lsp(server_name, cmd, filetypes)
  vim.api.nvim_create_autocmd("FileType", {
    pattern = filetypes,
    callback = function(args)
      vim.lsp.start({
        name = server_name,
        cmd = cmd,
        root_dir = vim.fs.root(args.buf, { ".git", "pyproject.toml", "setup.py", "compile_commands.json" }),
        -- Automatically bind Neovim's completion key to the LSP engine
        on_attach = function(client, bufnr)
          vim.bo[bufnr].omnifunc = "v:lua.vim.lsp.omnifunc"
        end,
      })
    end,
  })
end

-- Launch servers 
start_lsp("pyright", { "pyright-langserver", "--stdio" }, { "python" })
start_lsp("clangd", { "clangd" }, { "c", "cpp", "objc", "objcpp" })
start_lsp("lua_ls", { "lua-language-server" }, { "lua" })

-- Mappings for LSP navigation
vim.keymap.set('n', 'gd', vim.lsp.buf.definition, { desc = "Go to Definition" })
vim.keymap.set('n', 'K', vim.lsp.buf.hover, { desc = "Hover Documentation" })
vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, { desc = "Rename Symbol" })
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = "Next Diagnostic" })
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = "Prev Diagnostic" })
vim.keymap.set('n', '<leader>D', vim.diagnostic.open_float, { desc = "Show Diagnostic" })
vim.keymap.set('n', 'gr', vim.lsp.buf.references, { desc = "Go to References" })
vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, { desc = "Code Action" })

-- COLORSCHEME
vim.cmd("colorscheme catppuccin")
vim.cmd(":hi statusline guibg=purple")


-- OPTIONAL STUFF
-- REMOVE UNUSED PLUGINS

local function pack_clean()
    local active_plugins = {}
    local unused_plugins = {}

    for _, plugin in ipairs(vim.pack.get()) do
        active_plugins[plugin.spec.name] = plugin.active
    end

    for _, plugin in ipairs(vim.pack.get()) do
        if not active_plugins[plugin.spec.name] then
            table.insert(unused_plugins, plugin.spec.name)
        end
    end

    if #unused_plugins == 0 then
        print("No unused plugins.")
        return
    end

    local choice = vim.fn.confirm("Remove unused plugins?", "&Yes\n&No", 2)
    if choice == 1 then
        vim.pack.del(unused_plugins)
    end
end

-- KEYMAPPINGS
vim.keymap.set('n', '<leader>o', ':update<CR> :source<CR>')
vim.keymap.set('n', '<leader>w', ':write<CR>')
vim.keymap.set('n', '<leader>q', ':quit<CR>')
vim.keymap.set('n', '<leader>lf', vim.lsp.buf.format)
vim.keymap.set('n', '<leader>f', ":Pick files<CR>")
vim.keymap.set('n', '<leader>h', ":Pick help<CR>")
vim.keymap.set('n', '<leader>e', ":Oil<CR>")
vim.keymap.set({ 'n', 'v', 'x' }, '<leader>y', '"+y')
vim.keymap.set({ 'n', 'v', 'x' }, '<leader>d', '"+d')
vim.keymap.set('n', '<leader>pc', pack_clean)

