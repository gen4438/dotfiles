return {
  {
    "gen4438/marginalia.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    lazy = true,
    event = "BufEnter",
    config = function()
      require("marginalia").setup({
        include_code = false, -- Include code block in generated Markdown (default: false)
        textobject = "A",     -- Character for text objects/navigation: ia, aa, ]a, [a
        keymaps = {
          annotate = "<leader>maa", -- Visual + Normal mode (default)
          list     = "<leader>mal", -- Normal mode (default)
          manager  = "<leader>mam", -- Normal mode (default)
          search   = "<leader>mas", -- Normal mode (default)
        },
      })
    end
  }
}
