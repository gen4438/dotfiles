return {
  {
    'mg979/vim-visual-multi',
    branch = 'master',
    lazy = true,
    event = 'BufEnter',
    init = function()
      vim.g.VM_mouse_mappings = 1
      -- vim.g.VM_default_mappings = 0
      -- vim.g.VM_maps = {
      -- ["Visual Cursors"] = "ga",
      -- ["Find Under"] = "<leader>n",
      -- ['Find Under'] = '\\*',
      -- ['Find Subword Under'] = '\\*',
      -- ['Toggle Mappings'] = '<Space>'
      -- }

      -- 追加
      vim.api.nvim_set_keymap('x', 'ga', '<Plug>(VM-Visual-Cursors)', { noremap = true, silent = true })
    end,
  },

}
