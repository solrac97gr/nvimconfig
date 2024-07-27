" Initialize vim-plug
call plug#begin('~/.local/share/nvim/plugged')

" Add the kanagawa.nvim theme plugin
Plug 'rebelot/kanagawa.nvim'

" Add LSP and autocomplete plugins
Plug 'neovim/nvim-lspconfig'
Plug 'hrsh7th/nvim-cmp'
Plug 'hrsh7th/cmp-nvim-lsp'
Plug 'hrsh7th/cmp-buffer'
Plug 'hrsh7th/cmp-path'
Plug 'hrsh7th/cmp-cmdline'
Plug 'saadparwaiz1/cmp_luasnip'
Plug 'L3MON4D3/LuaSnip'

" Add nvim-tree plugin
Plug 'nvim-tree/nvim-tree.lua'
Plug 'nvim-tree/nvim-web-devicons'  " Optional: for file icons

" Add lualine for status line
Plug 'nvim-lualine/lualine.nvim'
Plug 'kyazdani42/nvim-web-devicons'  " Optional: for file icons

" Add gitsigns for git integration
Plug 'lewis6991/gitsigns.nvim'

" Add hop.nvim for easy navigation
Plug 'phaazon/hop.nvim'

" Add dashboard-nvim for a startup dashboard
Plug 'glepnir/dashboard-nvim'

" Add bufferline.nvim for a better buffer line
Plug 'akinsho/bufferline.nvim', {'tag': 'v2.*'}

" Add auto-pairs for automatic closing of brackets and quotes
Plug 'jiangmiao/auto-pairs'

" Add which-key.nvim for keybinding helper
Plug 'folke/which-key.nvim'

call plug#end()

" Always show line numbers
set number

" Show relative line numbers
set relativenumber

" Setup the Theme
lua << EOF
require('kanagawa').setup()
vim.cmd("colorscheme kanagawa")
EOF

" Setup nvim-cmp and LuaSnip
lua << EOF
local cmp = require'cmp'

cmp.setup({
  snippet = {
    expand = function(args)
      require('luasnip').lsp_expand(args.body)
    end,
  },
  mapping = {
    ['<C-b>'] = cmp.mapping(cmp.mapping.scroll_docs(-4), { 'i', 'c' }),
    ['<C-f>'] = cmp.mapping(cmp.mapping.scroll_docs(4), { 'i', 'c' }),
    ['<C-Space>'] = cmp.mapping(cmp.mapping.complete(), { 'i', 'c' }),
    ['<C-y>'] = cmp.config.disable,
    ['<C-e>'] = cmp.mapping({
      i = cmp.mapping.abort(),
      c = cmp.mapping.close(),
    }),
    ['<CR>'] = cmp.mapping.confirm({ select = true }),
    ['<Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      elseif require('luasnip').expand_or_jumpable() then
        require('luasnip').expand_or_jump()
      else
        fallback()
      end
    end, { 'i', 's' }),
    ['<S-Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      elseif require('luasnip').jumpable(-1) then
        require('luasnip').jump(-1)
      else
        fallback()
      end
    end, { 'i', 's' }),
  },
  sources = cmp.config.sources({
    { name = 'nvim_lsp' },
    { name = 'luasnip' },
  }, {
    { name = 'buffer' },
  })
})

local nvim_lsp = require('lspconfig')

local servers = { 'clangd', 'gopls' }
for _, lsp in ipairs(servers) do
  nvim_lsp[lsp].setup {
    capabilities = require('cmp_nvim_lsp').default_capabilities()
  }
end
EOF

" Set up gitsigns with the new highlight configuration
lua << EOF
require('gitsigns').setup {
  signs = {
    add = {text = '+'},
    change = {text = '~'},
    delete = {text = '_'},
    topdelete = {text = '‾'},
    changedelete = {text = '~'},
  },
  current_line_blame = true,
  sign_priority = 6,
  update_debounce = 100,
  status_formatter = nil, -- Use default
  word_diff = false,
}

vim.api.nvim_set_hl(0, 'GitSignsAdd', { link = 'GitGutterAdd' })
vim.api.nvim_set_hl(0, 'GitSignsAddNr', { link = 'GitSignsAddNr' })
vim.api.nvim_set_hl(0, 'GitSignsAddLn', { link = 'GitSignsAddLn' })
vim.api.nvim_set_hl(0, 'GitSignsChange', { link = 'GitGutterChange' })
vim.api.nvim_set_hl(0, 'GitSignsChangeNr', { link = 'GitSignsChangeNr' })
vim.api.nvim_set_hl(0, 'GitSignsChangeLn', { link = 'GitSignsChangeLn' })
vim.api.nvim_set_hl(0, 'GitSignsChangedelete', { link = 'GitGutterChange' })
vim.api.nvim_set_hl(0, 'GitSignsChangedeleteNr', { link = 'GitSignsChangeNr' })
vim.api.nvim_set_hl(0, 'GitSignsChangedeleteLn', { link = 'GitSignsChangeLn' })
vim.api.nvim_set_hl(0, 'GitSignsDelete', { link = 'GitGutterDelete' })
vim.api.nvim_set_hl(0, 'GitSignsDeleteNr', { link = 'GitSignsDeleteNr' })
vim.api.nvim_set_hl(0, 'GitSignsDeleteLn', { link = 'GitSignsDeleteLn' })
vim.api.nvim_set_hl(0, 'GitSignsTopdelete', { link = 'GitGutterDelete' })
vim.api.nvim_set_hl(0, 'GitSignsTopdeleteNr', { link = 'GitSignsDeleteNr' })
vim.api.nvim_set_hl(0, 'GitSignsTopdeleteLn', { link = 'GitSignsDeleteLn' })
EOF

" Set up nvim-tree
lua << EOF
require'nvim-tree'.setup {
  disable_netrw       = true,
  hijack_netrw        = true,
  hijack_cursor       = false,
  update_cwd          = false,
  diagnostics = {
    enable = false,
  },
  update_focused_file = {
    enable      = true,
    update_cwd  = false,
    ignore_list = {}
  },
  system_open = {
    cmd  = nil,
    args = {}
  },
  filters = {
    dotfiles = false,
    custom = {}
  },
  view = {
    width = 30,
    side = 'left',
  }
}
EOF

" Close nvim-tree if it's the last window
augroup NvimTreeAutocmd
  autocmd!
  autocmd BufEnter * ++nested if winnr('$') == 1 && bufname() == 'NvimTree_' . tabpagenr() | quit | endif
augroup END

" Setup lualine
lua << EOF
require('lualine').setup {
  options = {
    theme = 'gruvbox',  -- Change this to your preferred theme
    section_separators = '',
    component_separators = '',
  }
}
EOF

" Setup hop.nvim
lua << EOF
require'hop'.setup()
EOF

" Setup dashboard-nvim
lua << EOF
require('dashboard').setup {
  -- Customize the dashboard here if needed
}
EOF

" Setup bufferline.nvim
lua << EOF
require('bufferline').setup {}
EOF

" Setup which-key.nvim
lua << EOF
require('which-key').setup {}
EOF