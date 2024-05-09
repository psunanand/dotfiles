-- Use `opts = {}` to force a plugin to be loaded.
--
--  This is equivalent to:
--    require('Comment').setup({})

-- "gc" to comment visual regions/lines

return { 'numToStr/Comment.nvim', event = { 'BufReadPre', 'BufNewFile' }, opts = {} }

-- vim: ts=2 sts=2 sw=2 et
