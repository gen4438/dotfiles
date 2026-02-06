return {
  {
    "chrisbra/csv.vim",
    lazy = true,
    ft = { 'csv', 'tsv' },
    init = function()
      vim.g.csv_start = 1
      vim.g.csv_end = 1000
    end,
  }
}
