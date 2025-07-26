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

  {
    "jake-stewart/multicursor.nvim",
    enabled = false,
    lazy = true,
    event = "VeryLazy",
    branch = "1.0",
    config = function()
      local mc = require("multicursor-nvim")
      mc.setup()

      local set = vim.keymap.set

      -- Add or skip cursor above/below the main cursor.
      set({ "n", "x" }, "<up>", function() mc.lineAddCursor(-1) end)
      set({ "n", "x" }, "<down>", function() mc.lineAddCursor(1) end)
      set({ "n", "x" }, "<c-up>", function() mc.lineSkipCursor(-1) end)
      set({ "n", "x" }, "<c-down>", function() mc.lineSkipCursor(1) end)

      -- Add or skip adding a new cursor by matching word/selection
      set({ "n", "x" }, "<space>n", function() mc.matchAddCursor(1) end)
      set({ "n", "x" }, "<space>s", function() mc.matchSkipCursor(1) end)
      set({ "n", "x" }, "<space>N", function() mc.matchAddCursor(-1) end)
      set({ "n", "x" }, "<space>S", function() mc.matchSkipCursor(-1) end)

      -- Add and remove cursors with control + left click.
      set("n", "<c-leftmouse>", mc.handleMouse)
      set("n", "<c-leftdrag>", mc.handleMouseDrag)
      set("n", "<c-leftrelease>", mc.handleMouseRelease)

      -- Disable and enable cursors.
      set({ "n", "x" }, "<leader>q", mc.toggleCursor)

      -- Mappings defined in a keymap layer only apply when there are
      -- multiple cursors. This lets you have overlapping mappings.
      mc.addKeymapLayer(function(layerSet)
        -- Select a different cursor as the main one.
        layerSet({ "n", "x" }, "<left>", mc.prevCursor)
        layerSet({ "n", "x" }, "<right>", mc.nextCursor)

        -- Delete the main cursor.
        layerSet({ "n", "x" }, "<leader>x", mc.deleteCursor)

        -- Enable and clear cursors using escape.
        layerSet("n", "<leader><esc>", function()
          if not mc.cursorsEnabled() then
            mc.enableCursors()
          else
            mc.clearCursors()
          end
        end)
      end)

      -- Customize how cursors look.
      local hl = vim.api.nvim_set_hl
      hl(0, "MultiCursorCursor", { link = "Cursor" })
      hl(0, "MultiCursorVisual", { link = "Visual" })
      hl(0, "MultiCursorSign", { link = "SignColumn" })
      hl(0, "MultiCursorMatchPreview", { link = "Search" })
      hl(0, "MultiCursorDisabledCursor", { link = "Visual" })
      hl(0, "MultiCursorDisabledVisual", { link = "Visual" })
      hl(0, "MultiCursorDisabledSign", { link = "SignColumn" })

      -- Pressing `gaip` will add a cursor on each line of a paragraph.
      set({ "n", "x" }, "ga", mc.addCursorOperator)

      -- Clone every cursor and disable the originals.
      set({ "n", "x" }, "<leader><c-q>", mc.duplicateCursors)

      -- Align cursor columns.
      -- set("n", "<leader>a", mc.alignCursors)

      -- -- Split visual selections by regex.
      -- set("x", "S", mc.splitCursors)

      -- -- match new cursors within visual selections by regex.
      -- set("x", "M", mc.matchCursors)

      -- bring back cursors if you accidentally clear them
      set("n", "<leader>gv", mc.restoreCursors)

      -- Add a cursor for all matches of cursor word/selection in the document.
      set({ "n", "x" }, "<space>A", mc.matchAllAddCursors)

      -- -- Rotate the text contained in each visual selection between cursors.
      -- set("x", "<leader>t", function() mc.transposeCursors(1) end)
      -- set("x", "<leader>T", function() mc.transposeCursors(-1) end)

      -- -- Append/insert for each line of visual selections.
      -- -- Similar to block selection insertion.
      -- set("x", "I", mc.insertVisual)
      -- set("x", "A", mc.appendVisual)

      -- -- Increment/decrement sequences, treaing all cursors as one sequence.
      -- set({ "n", "x" }, "g<c-a>", mc.sequenceIncrement)
      -- set({ "n", "x" }, "g<c-x>", mc.sequenceDecrement)

      -- Add a cursor and jump to the next/previous search result.
      set("n", "<space>/n", function() mc.searchAddCursor(1) end)
      set("n", "<space>/N", function() mc.searchAddCursor(-1) end)

      -- Jump to the next/previous search result without adding a cursor.
      set("n", "<space>/s", function() mc.searchSkipCursor(1) end)
      set("n", "<space>/S", function() mc.searchSkipCursor(-1) end)

      -- Add a cursor to every search result in the buffer.
      set("n", "<space>/A", mc.searchAllAddCursors)

      -- -- Pressing `<leader>miwap` will create a cursor in every match of the
      -- -- string captured by `iw` inside range `ap`.
      -- -- This action is highly customizable, see `:h multicursor-operator`.
      -- set({ "n", "x" }, "<leader>m", mc.operator)

      -- -- Add or skip adding a new cursor by matching diagnostics.
      -- set({ "n", "x" }, "]d", function() mc.diagnosticAddCursor(1) end)
      -- set({ "n", "x" }, "[d", function() mc.diagnosticAddCursor(-1) end)
      -- set({ "n", "x" }, "]s", function() mc.diagnosticSkipCursor(1) end)
      -- set({ "n", "x" }, "[S", function() mc.diagnosticSkipCursor(-1) end)

      -- -- Press `mdip` to add a cursor for every error diagnostic in the range `ip`.
      -- set({ "n", "x" }, "md", function()
      --   -- See `:h vim.diagnostic.GetOpts`.
      --   mc.diagnosticMatchCursors({ severity = vim.diagnostic.severity.ERROR })
      -- end)
    end
  }

}
