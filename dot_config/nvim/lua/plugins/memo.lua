return {
  {
    "gen4438/memo.nvim",
    opts = {
      -- Main directory for memos
      -- Uses MEMO_DIR environment variable if set, otherwise ~/Documents/my-notes
      memo_dir = vim.fn.expand(vim.env.MEMO_DIR or "~/Documents/my-notes"),

      -- Git settings
      git_autocommit = false,

      -- Template settings
      -- Uses MEMO_DIR/templates if MEMO_DIR is set, otherwise default path
      template_dir = vim.fn.expand(
        vim.env.MEMO_DIR and vim.env.MEMO_DIR .. "/templates" or "~/Documents/my-notes/templates"
      ),
      create_default_templates = false,

      -- Date format settings (using Lua's os.date format)
      date_format = "%Y/%m/%d",
      week_format = "%Y/%m/%d - %Y/%m/%d",
      month_format = "%Y/%m",
      year_format = "%Y",
    },
  }
}
