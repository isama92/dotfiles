-- You can add your own plugins here or in other files in this directory!
--  I promise not to create any merge conflicts in this directory :)
--
-- See the kickstart.nvim README for more information

---@module 'lazy'
---@type LazySpec
return {
  -- Harpoon: ThePrimeagen's fast file-jumping. Mark a handful of files you keep
  -- returning to, then jump to any of them with a single chord. Think of it as
  -- pinned tabs, but keyboard-first.
  --
  --   <leader>a        add current file to the list
  --   <C-e>            toggle the quick menu (reorder/remove with normal editing)
  --   <leader>1..4     jump straight to marked file 1..4
  --   <C-p> / <C-n>    previous / next marked file
  {
    'ThePrimeagen/harpoon',
    branch = 'harpoon2',
    dependencies = { 'nvim-lua/plenary.nvim' },
    config = function()
      local harpoon = require 'harpoon'
      harpoon:setup()

      vim.keymap.set('n', '<leader>a', function() harpoon:list():add() end, { desc = 'Harpoon: [A]dd file' })
      vim.keymap.set('n', '<C-e>', function() harpoon.ui:toggle_quick_menu(harpoon:list()) end, { desc = 'Harpoon: toggle menu' })

      vim.keymap.set('n', '<leader>1', function() harpoon:list():select(1) end, { desc = 'Harpoon: file 1' })
      vim.keymap.set('n', '<leader>2', function() harpoon:list():select(2) end, { desc = 'Harpoon: file 2' })
      vim.keymap.set('n', '<leader>3', function() harpoon:list():select(3) end, { desc = 'Harpoon: file 3' })
      vim.keymap.set('n', '<leader>4', function() harpoon:list():select(4) end, { desc = 'Harpoon: file 4' })

      vim.keymap.set('n', '<C-p>', function() harpoon:list():prev() end, { desc = 'Harpoon: prev file' })
      vim.keymap.set('n', '<C-n>', function() harpoon:list():next() end, { desc = 'Harpoon: next file' })
    end,
  },
}
