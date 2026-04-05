local g = vim.g
local opt = vim.opt

-- == General ==
g.mapleader = " "
opt.mouse = "a"
opt.mousescroll = "ver:25,hor:6"
opt.switchbuf = "usetab"
opt.undofile = true
opt.shada = "'100,<50,s10,:1000,/100,@100,h"
opt.clipboard = "unnamedplus"

vim.cmd("filetype plugin indent on")
if vim.fn.exists("syntax_on") ~= 1 then
  vim.cmd("syntax enable")
end

-- == UI ==
opt.breakindent = true       
opt.breakindentopt = "list:-1"  
opt.colorcolumn   = "+1"       
opt.cursorline    = true       
opt.cursorlineopt = "screenline,number"
opt.linebreak     = true      
opt.list          = true       
opt.listchars = 'extends:…,nbsp:␣,precedes:…,tab:> '
opt.fillchars = 'eob: ,fold:╌'
opt.number        = true       
opt.pumborder     = "rounded"   
opt.pumheight     = 10         
opt.pummaxwidth   = 100        
opt.ruler         = false      
opt.shortmess     = "CFOSWaco" 
opt.showmode      = false      
opt.signcolumn    = "yes"      
opt.splitbelow    = true       
opt.splitkeep     = "screen"   
opt.splitright    = true       
opt.winborder     = "rounded" 
opt.wrap          = false
opt.foldlevel   = 10       
opt.foldmethod  = "indent" 
opt.foldnestmax = 10       
opt.foldtext    = ""       

-- == Editing ==
opt.autoindent   = true    
opt.expandtab     = true    
opt.formatoptions = "rqnl1j"
opt.formatlistpat = [[^\s*[0-9\-\+\*]\+[\.\)]*\s\+]]
opt.ignorecase    = true    
opt.incsearch     = true    
opt.infercase     = true    
opt.shiftwidth    = 2       
opt.smartcase     = true    
opt.smartindent   = true    
opt.spelloptions  = "camel" 
opt.tabstop       = 2       
opt.virtualedit   = "block" 
opt.inccommand = "split"

opt.complete        = ".,w,b,kspell"                 
opt.completeopt     = "menuone,noselect,fuzzy,nosort" 
opt.completetimeout = 100                             

-- == Autocommands ==
local disable_wrap_comments_and_insert_comment_leader = function() 
  vim.cmd('setlocal formatoptions-=c formatoptions-=o') 
end
Config.new_autocmd('FileType', nil, disable_wrap_comments_and_insert_comment_leader, "Proper 'formatoptions'")

local highlight_on_yank = function()
  vim.highlight.on_yank()
end
Config.new_autocmd('TextYankPost', '*', highlight_on_yank, "Highlight yanked text")

local start_terminal_insert = vim.schedule_wrap(function(data)
  if not (vim.api.nvim_get_current_buf() == data.buf and vim.bo.buftype == 'terminal') then 
    return 
  end
  vim.cmd('startinsert')
end)
Config.new_autocmd('TermOpen', 'term://*', start_terminal_insert, 'Start builtin terminal in Insert mode')

Config.new_autocmd(
  'ModeChanged',
  '*:[V\x16]*',
  function() 
    vim.wo.relativenumber = vim.wo.number 
  end,
  'Show relative line numbers'
)
Config.new_autocmd(
  'ModeChanged',
  '[V\x16]*:*',
  function() 
    vim.wo.relativenumber = string.find(vim.fn.mode(), '^[V\22]') ~= nil 
  end,
  'Hide relative line numbers'
)

-- == Diagnostics ==
local diagnostic_opts = {
  signs = { priority = 9999, severity = { min = 'WARN', max = 'ERROR' } },

  underline = { severity = { min = 'HINT', max = 'ERROR' } },

  virtual_lines = false,
  virtual_text = {
    current_line = true,
    severity = { min = 'ERROR', max = 'ERROR' },
  },
  update_in_insert = false,
}
Config.later(function() vim.diagnostic.config(diagnostic_opts) end)
