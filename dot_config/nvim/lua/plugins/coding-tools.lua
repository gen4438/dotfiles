-- コーディング支援ツール
return {

  -- emmet
  {
    'mattn/emmet-vim',
    lazy = true,
    keys = {
      { "<C-y><C-y>", "<plug>(emmet-expand-abbr)", mode = "i", desc = "Expand Abbreviation" },
    }
  },

  -- snippets
  {
    'SirVer/ultisnips',
    enabled = true,
    lazy = true,
    -- event = 'BufEnter',
    dependencies = {
      'honza/vim-snippets',
    },
    cmd = {
      'UltiSnipsEdit',
      'FzfSnippets',
    },
    cond = function()
      return vim.fn.has('python3') == 1
    end,
    keys = {
      ";fs",
      { "<c-s>", mode = "i" },
      -- { "<c-j>", mode = "i" },
      -- { "<c-k>", mode = "i" },
    },
    init = function()
      vim.g.UltiSnipsSnippetDirectories = { vim.fn.stdpath("config") .. "/UltiSnips", 'UltiSnips' }
      vim.g.UltiSnipsExpandTrigger = "<c-s>"
      -- vim.g.UltiSnipsJumpForwardTrigger = "<c-j>"
      -- vim.g.UltiSnipsJumpBackwardTrigger = "<c-k>"
      -- vim.g.UltiSnipsEditSplit = "vertical"
    end,
    config = function()
      -- fzf-lua で snippet を選択する
      -- https://github.com/ibhagwan/fzf-lua/issues/1392
      -- https://gist.github.com/qanyue/acc75f112489731c28e9893d6e18366e

      local M = {}

      ---@alias trigger string
      ---@alias body string
      ---@alias aligntext string
      ---@alias snip_result table<trigger,body,aligntext>
      ---@alias snips {engine:string,snippets:snip_result}

      -- Query UltiSnips snippets
      ---@return snip_result[]
      function M.query_ultisnips()
        vim.fn["UltiSnips#SnippetsInCurrentScope"](1)
        local list = {}
        local size = 4
        ---@diagnostic disable-next-line: undefined-field
        for key, info in pairs(vim.g.current_ulti_dict_info) do
          local desc = info.description
          if desc == "" then
            desc = "..."
          end
          size = math.max(size, #key)
          table.insert(list, { key, desc })
        end

        -- Sort dictionary
        table.sort(list, function(a, b)
          return a[1] < b[1]
        end)

        for _, item in ipairs(list) do
          local t = item[1] .. string.rep(" ", size - #item[1])
          table.insert(item, t)
        end

        return list
      end

      -- Check if various snippet plugins are supported

      function M.check_ultisnips()
        return vim.fn.exists(":UltiSnipsEdit") == 2
      end

      M.snips = {}
      M.engines = { "snipmate", "ultisnips", "neosnippet", "luasnip" }

      -- Snippet source data retrieval
      ---@return {engine_name:snip_result[]}[] | nil
      function M.get_snippets()
        local source = {}
        local matches = {}
        if M.check_ultisnips() then
          matches["ultisnips"] = M.query_ultisnips()
        end
        if next(matches) == nil then
          local error = "ERROR: Require a supported snip engine !!"
          vim.cmd("redraw")
          vim.cmd("echohl ErrorMsg")
          vim.cmd('echom "' .. error .. '"')
          vim.cmd("echohl None")
          table.insert(source, error)
          return nil
        end

        local snips = {}
        local width = 100
        for engine, result in pairs(matches) do
          for _, item in ipairs(result) do
            local trigger = item[1]
            if trigger:find("^%u") or snips[trigger] then
              goto continue
            end
            local desc = ""
            if engine == "ultisnips" then
              desc = item[2]
            end
            snips[trigger] = item[2]
            local text = item[3] .. " : " .. desc .. " [" .. engine .. "] "
            table.insert(source, text)
            ::continue::
          end
        end
        M.snips = snips
        return source
      end

      ---@param selected_accept string line of selected snippet
      function M.selected_accept(selected_accept)
        local pos = selected_accept:find(":")
        if not pos then
          return
        end
        local trigger = selected_accept:sub(1, pos - 1):gsub("^%s*(.-)%s*$", "%1")
        local engine = ""
        -- Get last [] content
        for match, _ in selected_accept:sub(pos + 1):gmatch("%[(.-)%]") do
          engine = match
        end
        if (trigger and trigger == "") or not vim.list_contains(M.engines, engine) then
          print("Not supported snippet engine or no snippet engine sign")
          return
        end
        M.apply(trigger, engine)
      end

      --- @param snip_engine "snipmate" | "ultisnips" | "neosnippet" | "luasnip"
      --- @param trigger string Snippet name
      function M.apply(trigger, snip_engine)
        vim.cmd("redraw")
        if trigger ~= "" then
          if snip_engine == "ultisnips" then
            if vim.fn.mode(1):find("!") then
              local keys = vim.api.nvim_replace_termcodes("<right>", true, false, true)
              vim.api.nvim_feedkeys(keys, "!", false)
              keys = vim.api.nvim_replace_termcodes(trigger .. "<c-r>=UltiSnips#ExpandSnippet()<cr>", true, false, true)
              vim.api.nvim_feedkeys(keys, "!", false)
            else
              local keys = vim.api.nvim_replace_termcodes(
                "a" .. trigger .. "<c-r>=UltiSnips#ExpandSnippet()<cr>",
                true,
                false,
                true
              )
              vim.api.nvim_feedkeys(keys, "!", false)
            end
          end
        end
      end

      -- Snippet preview
      function M.fzf_preview()
        local fzf_lua = require("fzf-lua")
        local builtin = require("fzf-lua.previewer.builtin")

        -- Inherit from "base" instead of "buffer_or_file"
        local MyPreviewer = builtin.base:extend()

        function MyPreviewer:new(o, opts, fzf_win)
          MyPreviewer.super.new(self, o, opts, fzf_win)
          setmetatable(self, MyPreviewer)
          return self
        end

        function MyPreviewer:populate_preview_buf(entry_str)
          local text = entry_str
          local pos = text:find(":")
          if not pos then
            return {}
          end
          local trigger = text:sub(1, pos - 1):gsub("^%s*(.-)%s*$", "%1")
          local body = M.snips[trigger] or ""
          if body == "" then
            vim.cmd('unsilent echom "SUCK"')
            print(vim.inspect(M.snips))
            return {}
          end
          local tmpbuf = self:get_tmp_buffer()
          -- vim.api.nvim_buf_set_lines(tmpbuf, 0, -1, false, {
          --     string.format("SELECTED FILE: %s", entry_str),
          -- })
          local lines = vim.split(body, "\n")
          vim.api.nvim_buf_set_lines(tmpbuf, 0, -1, false, lines)
          self:set_preview_buf(tmpbuf)
          self.win:update_preview_scrollbar()
        end

        -- Disable line numbering and word wrap
        function MyPreviewer:gen_winopts()
          local new_winopts = {
            wrap = false,
            number = false,
          }
          return vim.tbl_extend("force", self.winopts, new_winopts)
        end

        return MyPreviewer
      end

      -- Use fzf-lua
      function M.fzf()
        -- Get available Snippet data
        local snippets = M.get_snippets()

        -- If no snippets are available, exit
        if not snippets or #snippets == 0 then
          print("No snippets available")
          return
        end

        require("fzf-lua").fzf_exec(snippets, {
          prompt = "Snippets> ",
          previewer = {
            _ctor = function()
              return M.fzf_preview()
            end,
          },
          actions = {
            -- Default action: Apply selected Snippet
            ["default"] = function(selected)
              M.selected_accept(selected[1])
            end,
          },
        })
      end

      vim.api.nvim_create_user_command("FzfSnippets", M.fzf, {})
      vim.api.nvim_set_keymap('n', ';fs', ':FzfSnippets<CR>', { noremap = true, silent = true })
    end
  },
  {
    'honza/vim-snippets',
    lazy = true,
    config = function()
      vim.g.ultisnips_python_style = "google"
    end
  },

  -- コメント操作
  {
    'numToStr/Comment.nvim',
    lazy = true,
    event = 'BufEnter',
    config = function()
      require('Comment').setup {
        ignore = '^$',
        pre_hook = require('ts_context_commentstring.integrations.comment_nvim').create_pre_hook(),
      }
    end
  },
  -- react jsx, tsx のコメント
  {
    'JoosepAlviste/nvim-ts-context-commentstring',
    lazy=true,
    opts = {
      enable_autocmd = false,
    }
  },
}
