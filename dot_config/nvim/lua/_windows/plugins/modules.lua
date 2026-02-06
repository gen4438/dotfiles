-- 汎用的なライブラリ
return {
  -- you can use the VeryLazy event for things that can
  -- load later and are not important for the initial UI
  -- { "stevearc/dressing.nvim",      event = "VeryLazy" },

  -- if some code requires a module from an unloaded plugin, it will be automatically loaded.
  -- So for api plugins like devicons, we can always set lazy=true
  { "nvim-tree/nvim-web-devicons", lazy = true },
}
