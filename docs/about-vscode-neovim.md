# VSCode Neovim Extension: Features, Limitations, and Configuration Guide

## Overview of VSCode Neovim (vscode-neovim) Extension

The **VSCode Neovim** extension embeds a real Neovim instance into Visual Studio Code, allowing you to use Neovim’s modal editing, custom `init.vim` (or `init.lua`), and many Vim plugins inside VS Code. It integrates Neovim for command-mode operations while preserving VS Code’s own features for things like insert-mode editing and UI rendering. In essence, you get “the best of both worlds” – Neovim’s keybindings and plugins alongside VS Code’s interface and language features. However, due to the fundamental differences between a terminal-based Neovim UI and VS Code’s GUI, **there are several limitations and adjustments needed** when using Neovim inside VSCode. This guide details which Neovim features/plugins work under VSCode, which do not, and how to adapt your configuration accordingly.

[VSCode Neovim Extension GitHub Repository](https://github.com/vscode-neovim/vscode-neovim)

## VSCode vs Neovim – What Can’t Be Done in VSCode?

**1. Neovim UI elements are replaced by VS Code UI:** VSCode handles the editor display (text rendering, gutter, line numbers, status bar, etc.), so Neovim’s own UI customizations won’t fully apply. For example:

- **Statusline and Tabline:** Neovim statusline plugins (like **lualine.vim**) and tabline/bufferline plugins won’t render in VSCode’s interface. VSCode’s native status bar and tab UI remain in control. If you load such plugins, they either have no effect or could cause visual quirks. It’s best to **disable status/tab line plugins** when in VSCode.
- **Colorschemes and Syntax Highlighting:** VSCode uses its theme and syntax engine for coloring code, not Neovim’s. Neovim colorscheme plugins (Catppuccin, Gruvbox, etc.) or Treesitter-based highlighting are unnecessary in VSCode – the extension ignores Neovim’s syntax highlights and uses VSCode’s own mechanism. This means you should disable or ignore Neovim colorscheme settings under VSCode and instead use a matching VSCode theme. (Exception: some _plugin-specific_ highlights can be made to work – see **QuickScope** example in the next section.)
- **Line Numbers, Indent Guides, Bracket Match, etc.:** Those are all handled by VSCode’s settings, not Neovim. Plugins that draw indent lines or bracket highlights aren’t needed (and could conflict). VSCode already provides relative line numbers, indent guides, bracket pair coloring, etc. natively. Any Vim plugin for these should be disabled on VSCode for performance.

**2. Vim Ex commands for file/window management behave differently:** VSCode intercepts many of Neovim’s file and window commands and translates them into VSCode actions. For example, `:e` (edit file), `:q` (quit), `:vsplit`, `:tabnext`, etc., are **remapped to VSCode’s own file-opening and window management**. This means their behavior might not exactly match terminal Neovim. You should _not_ use commands like `:e` in automated scripts or mappings in VSCode, because they won’t work the same way. Instead, use the VSCode extension API to open files or splits if needed. The extension provides a Lua API to call VSCode commands (e.g. `require('vscode').call('<command>')`) from Neovim. In practice, most file management (opening/closing files, splits, tabs) is easier done via VSCode’s UI or command palette. Similarly, the Vim `:write` command now works (since extension v1.18) but previously it was tied to VSCode’s save – now you can use `:w` normally.

**3. Terminal and external commands:** Neovim’s `:terminal` or `:!` shell commands do not open an embedded terminal as they would in a normal Neovim TUI. VSCode won’t display an interactive terminal inside the editor when you call `:terminal` – you should use VSCode’s integrated terminal (e.g. toggle it with a VSCode command) instead. Likewise, **running external shell commands with `:!` can be problematic in VSCode**, especially on Windows. For example, if you select lines and do `:!sort` in Neovim, normally it would pipe the lines through the external `sort` command and replace them with the output. In VSCode, this might fail or produce no output (Windows’ `sort` command usage differs, and the extension may not capture the output to the buffer as expected). As an alternative, **use VS Code’s built-in commands or tasks for such operations**. For instance, to sort lines, you can use the VSCode command **“Sort Lines Ascending/Descending”** instead of `:!sort`. You could even bind a Neovim key to call that VSCode command – e.g., map a key to `lua require('vscode').call('editor.action.sortLinesAscending')`. This leverages VSCode’s own functionality to achieve the result. In general, any frequent shell operation (formatting, filtering text, etc.) likely has a VSCode-native equivalent or extension. On Windows, if you require Unix-like tools, consider enabling the extension’s WSL support to use Neovim and shell commands in a Linux environment (this can improve compatibility for commands like `grep`, `sort`, etc., by running them through WSL’s Bash).

**4. Visual mode and cursor behavior differences:** Scrolling (`<C-d>`, `<C-u>`, etc.) is handled by VSCode’s smooth scrolling, which may feel slightly different than Vim’s. The **jumplist** and jump/definition navigation is tied into VSCode’s navigation history so that VSCode-driven jumps (e.g. Go to Definition) integrate with Vim’s jumps. **Dot (`.`) repeat** works, but with subtle differences (due to how VSCode processes edits) – usually not a big issue, but expect minor quirks in complex insert sequences.

**5. Multiple cursors:** VSCode has powerful multi-cursor support (e.g. Ctrl+D to add the next occurrence, Alt+Click, etc.). The extension tries to integrate with that. By default, Neovim-style multiple cursors are only natively supported in certain modes (insert, visual-line/block) using special mappings (the extension provides default mappings like `mi`, `ma` in visual modes to spawn cursors). The built-in method is somewhat limited, and the developer notes that the _“built-in multi-cursor support may not meet your needs.”_ For advanced usage, they suggest a dedicated plugin `vscode-multi-cursor.nvim`. In your case, you have been using **vim-visual-multi**; this plugin may not fully work in VSCode (its custom UI hints might not render). In fact, you’ve already disabled **multicursor.nvim**, likely referring to the VSCode-specific multi-cursor plugin, and are using _vim-visual-multi_ instead. Be aware that VSCode’s own multi-cursor (multiple carets in the editor) might conflict with Vim’s approach. It could be simpler to disable Vim’s multi-cursor plugins in VSCode and rely on VSCode’s native multi-cursor features (with your own keybindings to invoke “Add Cursor to Next Match” etc., possibly via `vscode.with_insert()` as shown in the extension docs). In summary, multi-cursor works, but you might need to adjust your workflow (e.g. use VSCode shortcuts or the recommended plugin) if the Vim plugins misbehave.

**6. Plugins that open windows or require TUI interactions:** Any plugin that tries to open a **floating window, a file explorer, fuzzy finder UI, or a custom prompt** inside Neovim’s interface will not display properly in VSCode. For example: a fuzzy finder like **Telescope** or **fzf.vim** opens a floating prompt/list in Neovim – under VSCode this either won’t show or is not needed (because VSCode has its own UI for search and file picking). File tree plugins like **NERDTree**, **vinegar**, **oil.nvim**, **neo-tree** are redundant – VSCode’s Explorer sidebar and file tabs are the equivalent. Trying to use them might do nothing or open a buffer that is not integrated with VSCode UI. Similarly, plugins that rely on Neovim’s terminal UI (such as certain debugger UIs, terminal managers, or text UIs) won’t work right. You should use VSCode’s debugger and terminal in those cases. In short, **any plugin that “spawns windows/buffers” for UI should be disabled** in VSCode, and use VSCode’s built-in UI or extensions instead.

**7. Performance considerations:** Because VSCode is doing the rendering, using certain Neovim plugins can actually degrade performance or cause “jitter”. The extension’s documentation specifically warns that **plugins which frequently draw or update the display can cause lag**. This includes things like constantly updating gutter symbols, virtual text, or highlights. If you notice VSCode Neovim feels slow (especially on Windows), you should trim your Neovim plugin usage to only what’s necessary in VSCode. The extension notes to _“disable unneeded plugins, as many of them don’t make sense with VSCode. Specifically, you don’t need any code highlighting, completion, LSP plugins, or plugins that spawn windows/buffers (nerdtree, fuzzy-finders, etc). Most navigation/textobject/editing plugins should be fine.”_. It also mentions avoiding plugins that render a lot of decorators (line markers, etc.) because VSCode handles those natively. On Windows, Neovim + VSCode can be slightly slower due to process overhead; thus it’s even more beneficial to cut out heavy plugins in the VSCode context.

## Adapting Your Neovim Plugins for VSCode

Given the above, the key strategy is: **Disable or replace any Neovim plugin that duplicates VSCode functionality or doesn’t work well in the VSCode environment**, while keeping the useful ones that enhance editing (motions, text objects, etc.). Here we analyze the plugins you listed and categorize which to keep, disable, or configure differently in VSCode:

- **Code Completion & LSP** – You currently use **CoC.nvim** and **nvim-cmp** (with sources like cmp-buffer, cmp-path, etc.), plus **mason.nvim** for LSP management. In VSCode, these are not needed. VSCode’s built-in LSP client and IntelliSense will handle completions, diagnostics, and language features (with language extensions or the built-in VSCode language support). Running a separate completion engine inside Neovim can conflict or at best be redundant. **Disable CoC, nvim-cmp, nvim-lsp, mason, nvim-lint, etc. in the VSCode context**. Instead, configure VSCode’s native IntelliSense (or use VSCode plugins like the official language servers, ESLint, etc.). If you rely on snippet expansion from nvim-cmp, note that VSCode has its own snippet system – you might want to port your snippets to VSCode or use VSCode’s snippet functionality. UltiSnips/vim-snippets similarly become unnecessary (and might not trigger correctly in VSCode insert mode). It’s best to disable UltiSnips and related snippet plugins when in VSCode.

- **Syntax Highlighting & Colorschemes** – As noted, **treesitter** (`nvim-treesitter` and its textobjects, context modules) can be turned off in VSCode. They won’t improve highlighting since VSCode does that, and treesitter’s features like incremental selection or context commenting might not integrate well. Likewise, all those **color scheme plugins** (Catppuccin, Gruvbox, Molokai, etc.) don’t affect VSCode’s UI. You should pick a VSCode theme instead (there are VSCode themes for Gruvbox, Nord, Tokyo Night, etc., so you can match your preferred look). You can disable loading color schemes in your `init.vim` when `g:vscode` is set. The only exception is if a plugin specifically needs certain highlight groups for its logic (e.g., quick-scope’s highlights – see below); otherwise, color plugins are superfluous under VSCode.

- **UI/Decorative Plugins** – Plugins that adjust Neovim’s UI or add decorative elements should be off:
  - **Status line**: **lualine.nvim** – disable in VSCode (no effect, VSCode status bar is used).
  - **Tabline**: **bufferline.nvim** – disable (VSCode’s own tab bar is used).
  - **Startup/dashboard**: (Not explicitly listed, but any such plugin should be off, since VSCode isn’t going to show a Vim start screen).
  - **Indent guides** or **line highlighters**: e.g., **hlchunk.nvim** (highlights indent blocks) – likely not needed, VSCode has indent guides. If `hlchunk.nvim` provides some visual block highlight that VSCode doesn’t have, you might test if it works. If it relies on Neovim highlights, it may not show. It might be safest to disable it and use VSCode’s built-in indent guide or find a VSCode extension for scope highlighting if needed.
  - **Bracket pair highlighter**: not sure if you use one (maybe built into some colorscheme), but VSCode has this built-in. Disable any Vim plugin doing the same.
  - **Which-key**: You have **which-key.nvim**. This plugin shows a popup of possible keybindings after you press the leader key. In VSCode, `which-key.nvim` might not render its popup correctly because it attempts to draw floating text – it may either do nothing or cause a flicker. There is a VSCode extension (“VSpaceCode” or others) that provide similar which-key functionality in VSCode, but using that is separate from Neovim. I would recommend **disabling `which-key.nvim`** in the VSCode config for simplicity, or at least be prepared that its UI might not appear. You could emulate some of its functionality with VSCode keybinding hints or simply rely on remembering keymaps (since VSCode won’t show a nice popup via the Vim plugin).

- **File Explorer / Finder** – You listed **oil.nvim** (a Neovim file explorer) as loaded, and **neo-tree.nvim** and **fzf-lua**/**telescope.nvim** as not loaded (lazy-loaded). **Disable these in VSCode.** They either won’t function or are redundant. Instead, use **VSCode’s Explorer sidebar** for file navigation, and **Ctrl+P** (Quick Open) or **Ctrl+Shift+F** (global search) for finding files and text. If you love fuzzy finding, VSCode’s Ctrl+P is already fuzzy. You can also call it via the extension: for example, mapping `<leader>ff` to `workbench.action.quickOpen` will invoke VSCode’s file picker. The extension wiki suggests doing exactly this – e.g., binding your leader keys to VSCode’s commands (see example in **Configuration** section below). This way, you don’t need Telescope at all in VSCode.

- **Git Integration** – **vim-fugitive** (and the companion **vim-rhubarb** for GitHub) are powerful in Vim, but in VSCode you might prefer the built-in Source Control panel or extensions like GitLens for an even richer experience. Fugitive will partially work (e.g., `:Gedit` might open a commit, and `:Gstatus` might open a file listing in a Vim buffer), but this output won’t be as useful as VSCode’s UI. Using Fugitive inside VSCode is not smooth – for instance, it opens its own temporary buffers which VSCode sees as files, and commands like `:Gdiff` may not display properly. **Recommendation:** Disable Fugitive in VSCode and use VSCode’s git UI for most tasks. For quick Git commands, you can always open the VSCode command palette or integrated terminal. If you absolutely need a Fugitive command, you could try it, but expect quirks. Similarly, **gitsigns.nvim** (for gutter signs) should be off – VSCode already shows modified lines in the gutter by default (and GitLens can show even more, like line blame). Gitsigns might not render its signs or could conflict with VSCode’s rendering, so disabling is safest.

- **Comment toggling** – You have **Comment.nvim** (or perhaps vim-commentary was in your list). These plugins toggle comment prefixes on lines. VSCode has a native _Toggle Line Comment_ and _Toggle Block Comment_ command (usually bound to `Ctrl+/` on Windows/Linux). The vscode-neovim extension actually provides a way to tie into that. In the wiki, they show that using the extension’s provided mappings (like `<Plug>VSCodeCommentary`) will call VSCode’s comment command. In fact, the wiki suggests _not_ using vim-commentary because _“the behavior is already provided by VS Code”_. You can replicate your familiar `gc` mappings to use VSCode’s commenting: for example, in your `init.vim` (inside the VSCode branch) you could add:

  ```vim
  xmap gc  <Plug>VSCodeCommentary
  nmap gc  <Plug>VSCodeCommentary
  omap gc  <Plug>VSCodeCommentary
  nmap gcc <Plug>VSCodeCommentaryLine
  ```

  These `<Plug>` mappings are provided by the extension and will call the VSCode command that comments or uncomments the line/selection. (Under the hood, `VSCodeCommentary` invokes `editor.action.commentLine` in VSCode.) This way you don’t need Comment.nvim at all – VSCode will handle it. So, **disable your Comment.nvim plugin in VSCode** and use the above mappings (or simply use VSCode’s default keybind). If you prefer Comment.nvim’s behavior, it might still work, but keep in mind it might not recognize VSCode’s undo/redo as cleanly. The lean approach is to leverage VSCode for commenting.

- **Movement/Editing Plugins (Generally Safe):** Many purely text-manipulation plugins continue to work fine, since they mostly just issue normal-mode commands. For example: **surround.vim** (you have **nvim-surround** loaded) works for wrapping text with quotes/parentheses – this should work in VSCode as it just manipulates the text buffer. **quick-scope** (highlights targets for `f/F` motions) also works but needed a tweak: by default quick-scope’s highlight groups weren’t shown in VSCode. The fix (from the wiki) is to define those highlight groups yourself so VSCode knows about them. Specifically, add to your config:

  ```vim
  highlight QuickScopePrimary   guifg='#afff5f' gui=underline ctermfg=155 cterm=underline
  highlight QuickScopeSecondary guifg='#5fffff' gui=underline ctermfg=81  cterm=underline
  ```

  This ensures the quick-scope plugin’s highlights (for primary/secondary targets) use explicit groups that the extension will render. After doing this, you should see the underlines/colored letters in VSCode when quick-scope is active (the extension otherwise ignored the default highlight it tried to use). So quick-scope can be kept, just include that config.
  Other navigation plugins like **vim-easymotion**/**hop.nvim**: originally there were issues because easymotion replaced text with letters (which broke VSCode), but the extension’s author provided a special fork and as of 2024 the original _vim-easymotion_ is reported to work with the extension. If you were using easymotion (you listed it as not loaded), you can consider enabling it if needed – but ensure you have an updated version. The extension uses VSCode decorations for it. Since you didn’t list it as currently in use, you might stick to built-in find (or use hop in normal Neovim only).
  **vim-visual-multi** we discussed under multi-cursor – it might partially work (some folks report it working in basic ways), but if you find it slow or glitchy in VSCode, consider using native VSCode multi-cursor.
  **vim-surround** (or nvim-surround) – should work without issue (text edits).
  **vim-commentary** – similar to Comment.nvim, better to map to VSCode’s action as above.
  **Registers, Yank highlight, etc.:** If you have plugins like highlight-yank or register managers, they might work since they just show message or tiny highlights. Highlight-yank (if any) might flash highlight using Vim’s `IncSearch` group – if that doesn’t show in VSCode, it’s a minor issue. Not critical to remove unless it causes errors.
  **Miscellaneous**: You have **dressing.nvim** (UI for vim prompts) – probably not needed in VSCode since VSCode UI handles input prompts differently. It may not do anything, so could disable it. **dressing.nvim** mainly improves the Vim UI for things like `input()` or `vim.ui.select()`, but in VSCode, those might use VSCode’s UI anyway.

- **Debugging** – You have **nvim-dap**, **nvim-dap-ui**, etc. In VSCode, you should use VSCode’s debugger interface (the Run and Debug panel), as it’s more powerful and the Neovim DAP UI won’t show properly. VSCode won’t display the nvim-dap UI (which in Neovim would open split windows or floating windows for scopes, breakpoints, etc.). It’s best to **disable nvim-dap(-ui)** for VSCode and rely on VSCode’s debug integration. (You might keep using nvim-dap in pure Neovim for terminal debugging, but not inside VSCode.)

- **AI Plugins** – You listed **copilot.vim** and **Copilot.lua**, and some ChatGPT.nvim, etc. In VSCode, these are again redundant: it’s preferable to use the **GitHub Copilot VSCode extension** (which provides inline suggestions and a Copilot chat if needed) rather than the vim plugin. The Copilot vim plugin might not even initialize in VSCode (since VSCode already intercepts some key events). So **disable any AI assistant Vim plugins** when in VSCode, and use the official VSCode ones (Copilot, or ChatGPT extension for example). This will likely be faster and more reliable.

- **Misc Tools**:
  - **Terminal integration**: You have `vim-slime` (to send text to a REPL) in the not-loaded list. In VSCode, a popular approach is to use the integrated terminal + its own shortcuts or an extension like `jupyter` for notebooks, etc. `vim-slime` may not work because it typically splits a Tmux pane or terminal buffer to send code. In VSCode you’d instead focus the integrated terminal or use the VSCode Jupyter extension for sending code to a Python REPL, etc. So that stays disabled.
  - **Markdown preview**: You have **markdown-preview\.nvim** – disable it, as VSCode’s Markdown preview (built-in) is excellent. Use `Ctrl+Shift+V` (or command palette) to open preview in VSCode instead.
  - **Session management**: **neovim-session-manager** – in VSCode, you usually reopen a workspace folder and VSCode restores opened files. A Vim session manager that writes session files might not be too useful. Probably disable it in VSCode to avoid confusion.
  - **CSV, DrawIt, etc.**: Niche plugins like **csv.vim** (for CSV alignment) could still work if they just operate on text, but if they rely on curses UI it might not. Likely fine to leave if needed, or use a VSCode CSV extension. **DrawIt** (draw ASCII diagrams with mouse) likely won’t work inside VSCode as expected – best to do such drawing in regular Neovim or find a VSCode alternative.
  - **Alternate buffer kill**: **vim-bufkill** – might not be needed; VSCode handles buffer closing. But it’s benign if it just closes buffers on `:BD`. It might end up calling `:bdelete` which VSCode maps to closing editor, which could work. Not critical, but not necessary either.
  - **Misc not-loaded**: A lot of your not-loaded plugins (like easymotion, emmet, etc.) we’ve covered conceptually: Emmet – use VSCode’s built-in Emmet expansions (no need for emmet-vim). Telescope – not needed. Trouble (diagnostics list) – use VSCode’s Problems panel instead. Undotree – VSCode has a Timeline and undo/redo, though not as visual; you might open the VSCode Timeline for file history, but the Vim undotree UI won’t show. So that stays off.

To summarize, the **general rule** echoed by the extension docs is: _Disable plugins related to code highlighting, completion/LSP, and those that spawn their own UI windows or heavy visual elements in Neovim when using VSCode_. These either conflict with or duplicate VSCode’s native capabilities. On the other hand, **keep plugins that enhance editing productivity** (motions, text objects, surrounds, commentary – albeit redirected to VSCode, etc., and minor utilities). Those tend to work fine since they operate on the text and do not meddle with the UI. If some such plugin has a minor issue (like highlights not appearing), check the extension’s wiki – often there’s a workaround (as we saw for quick-scope and sandwich underlines).

Also note the extension’s advice: if you encounter odd **“visual artifacts”** or glitches, it’s likely due to a Neovim plugin’s visual effect not translating well. _“vscode-neovim does its best to merge the visual effects of Nvim and VSCode, but it’s far from perfect. You may need to disable some Nvim plugins that cause visual effects.”_ If you see garbled text or flicker, try disabling whichever plugin might be drawing it.

## Configuring `init.vim` for VSCode vs Neovim

It’s wise to **separate your VSCode-specific Neovim configuration from your normal Neovim config**. The extension exposes a global variable `g:vscode` inside Neovim when running under VSCode, which you can check in your `init.vim` or `init.lua`. For example, at the very top of your config:

```vim
if exists('g:vscode')
    " VSCode Neovim: load minimal config
    source ~/.config/nvim/init-vscode.vim
else
    " Regular Neovim: load full config
    source ~/.config/nvim/init-regular.vim
endif
```

In Lua, similarly:

```lua
if vim.g.vscode then
    require('vscode-config')   -- your VSCode-specific lua config
else
    require('normal-config')   -- your normal config
end
```

This pattern is recommended by the extension maintainers. It allows you to maintain two sets of settings: one optimized for VSCode, one for standalone Neovim. As one guide puts it, _“It’s good to keep the VSCode-specific config separate from the ordinary one to have fine-grained control… and avoid messing things up.”_. In your case, you plan to detect `g:vscode` and switch which `.lua` files to load – this is exactly the right approach.

**Using Lazy.nvim conditions:** Since you use **lazy.vim** as your plugin manager, take advantage of its conditional loading for VSCode. Lazy.nvim supports a `cond` field for plugins; e.g., `cond = not vim.g.vscode` for plugins to load only outside VSCode, or `cond = vim.g.vscode` for VSCode-specific ones. The extension wiki even provides a snippet for grouping plugins by VSCode vs non-VSCode using Lazy’s import feature. You can define separate plugin spec lists, for example:

- `plugins_vscode.lua` – plugins (or plugin sections) that should load only in VSCode (rare, but e.g. you might include the `vscode-neovim` specific helper plugin or any VSCode-specific keymaps as a “plugin”).
- `plugins_notvscode.lua` – all the regular plugins that should **not** load in VSCode.
- `plugins_always.lua` – plugins that load in both (for truly universal ones, if any).

Then in your Lazy setup call, use `cond` based on `vim.g.vscode` as shown in the wiki. In simpler terms, you can mark each plugin in your lazy config with a condition. For example, in your Lazy spec:

```lua
{ "nvim-treesitter/nvim-treesitter", cond = not vim.g.vscode },
{ "hrsh7th/nvim-cmp", cond = not vim.g.vscode },
{ "tpope/vim-surround", cond = true },  -- loads always
{ "foo/vscode-specific-plugin", cond = vim.g.vscode },
```

This way, when you start VSCode Neovim, lazy.nvim will skip treesitter and nvim-cmp (and all other “not vscode” plugins), loading only the ones allowed. You likely will mark most of your plugins as `cond = not vim.g.vscode` except the ones we identified as safe or always needed (like surround, maybe quick-scope if you configured it, etc.). This is cleaner than peppering `if ... end` around each plugin config manually.

**Settings adjustments:** In your VSCode-specific config file, you may also want to set some Vim options differently or skip some. For example:

- Don’t set `colorcheme` (or if you do, it won’t affect VSCode’s colors – harmless but unnecessary).
- If you have GUI options or different font/UI settings in Neovim, those do nothing in VSCode.
- Some users set `set guicursor` differently for VSCode (as VSCode’s cursor is controlled by settings.json mostly).
- The extension respects certain vim settings but not others. For instance, `number`/`relativenumber` are controlled by VSCode (you set that in settings.json if you want, the extension will sync it). So you don’t need those in your init for VSCode.
- You might want to adjust clipboard: The extension can sync system clipboard by default. It even provides a `g:vscode_clipboard` provider you can use for consistent clipboard across VSCode and Neovim (but likely not needed unless clipboard issues arise).
- Ensure your `init-vscode` does not set up anything that conflicts with VSCode keybindings. E.g., if you had mapping for `<C-s>` in Neovim (which in VSCode is save), you might remove that to let VSCode handle Ctrl+S, etc.

**Keybindings and calling VSCode from Neovim:** One of the powerful things is you can call any VSCode command from a Neovim mapping. The extension exposes `vscode.call()` and `vscode.action()` APIs for synchronous or async command execution. You saw an example above for commenting. Another example: you mentioned using external sort – you could map, say, `<Leader>s` in visual mode to call VSCode’s sort:

```lua
vim.keymap.set('x', '<Leader>s', function() require('vscode').call('editor.action.sortLinesAscending') end)
```

This would sort the selected lines when you press your leader+s in visual mode. Similarly, you can bind keys to toggle the terminal, open command palette, etc., using VSCode’s command IDs. The Medium article you referenced provides a nice set of such bindings (like `<leader>t` to toggle terminal, `<leader>ff` to quick open files, etc.). For example:

- `<Leader>t` mapped to `workbench.action.terminal.toggleTerminal` will open/close VSCode’s integrated terminal.
- `<Leader>sp` to `workbench.actions.view.problems` will open the Problems (diagnostics) pane.
- `<Leader>a` to `editor.action.quickFix` shows code fixes (the lightbulb).
- You can even map VSCode-specific extensions’ commands, like the Code Runner extension’s “Run code” command, etc. The extension docs encourage rebinding your Vim keys to call VSCode features for things that Vim plugins would normally handle, because it’s often more seamless that way.

**Branching in `init.nvim`:** As you indicated, you’ll use `if g:vscode` to conditionally load a different Lua module or config. This is exactly how to do it. Just make sure that any plugin initialization (like the `require("lazy").setup(...)`) is done after that condition is evaluated properly so that `vim.g.vscode` is available (it should be available immediately on startup when under VSCode). Usually, you’d put the condition at the very top of init.lua to set up plugin lists accordingly.

One more thing: since you are concerned about performance on Windows, besides trimming plugins, ensure you use a **recent Neovim version (0.10+)** – which you are (v0.11/v0.12). The extension requires 0.10+ and newer Neovim versions have improved performance and fixed some quirks. On Windows, consider using the 64-bit Neovim binary and, if applicable, try the WSL approach if you work in a Linux environment for better shell command support. Also, check that VSCode isn’t running other conflicting extensions (for example, **do not install the VSCodeVim extension** alongside – it conflicts with vscode-neovim; the extension documentation explicitly warns to uninstall other vim emulation extensions).

## External Commands on Windows – Alternative Solutions

Since you highlighted `:!sort` on Windows not working: by default Neovim on Windows uses the `cmd.exe` shell for `:!` commands, which might behave unexpectedly (`sort` is a valid cmd command but reading/writing might differ). In VSCode, there is no terminal to display the output, so even if Neovim captures it, it could be that the result isn’t placed back into the buffer. If it’s truly not working, here are some alternatives:

- **Use VSCode’s “Sort Lines” command:** Easiest method – select the lines and press the shortcut for “Sort Lines Ascending/Descending” (you can find or set this in Keyboard Shortcuts). This doesn’t require leaving VSCode or messing with Neovim at all. You could also create a Neovim command or mapping that calls this, as described earlier, so it feels like a Vim command.
- **Use an integrated terminal + OS sort:** If for some reason you need to use an external sort (e.g., with unique or complex shell pipes), you could open the VSCode terminal (e.g. PowerShell or bash) and run the sort command there. You’d have to copy-paste in/out manually though – not as smooth as Vim’s `:'<,'>!sort`. But usually the built-in sort covers basic needs.
- **WSL/Linux coreutils:** If you enable `useWSL` in the extension on Windows, your Neovim will run in WSL and `:!sort` will execute in a Linux environment. This might make the traditional `:'<,'>!sort` actually work (since Unix `sort` reads from stdin and Neovim can capture it). However, this is a heavy solution just for sorting lines. It’s more useful if you rely on many UNIX tools in your workflow – in that case, running Neovim through WSL can let you use things like `:grep`, `:make`, etc., with Linux tools on a Windows machine. Only consider this if you’re comfortable with WSL and need a lot of shell integration. Otherwise, lean on VSCode’s features as much as possible for an easier life.

## Conclusion and Next Steps

You now have a clear picture of what **works** in VSCode Neovim and what does not. In summary, _nearly all pure text-editing capabilities of Neovim remain available_, but anything involving Neovim’s own UI (windows, highlights, shell, etc.) may be limited or better handled by VSCode. The extension developers themselves suggest starting with a minimal `init.vim` when using VSCode and only adding back what you truly need. Many of your plugins can be simplified: **disable the heavy ones in VSCode, and replace their functionality with VSCode’s native features or mappings to VSCode commands**. This will give you the optimal experience – the modal editing and Vim efficiency, combined with VSCode’s robust language features and UI.

As you proceed to adjust your `init.nvim`, follow this plan:

- Use `vim.g.vscode` to **conditionally load** different sets of plugins (via Lazy’s `cond` or manual if/else).
- **Disable** the plugins we identified as problematic or redundant (LSP/completion, UI, etc.) in the VSCode branch.
- Where appropriate, add settings or mappings in the VSCode branch to integrate with VSCode’s features (e.g. commenting maps, calling VSCode commands for terminal, search, etc.).
- Test in VSCode with `vscode-neovim.neovimClean` setting (which starts Neovim without plugins) if you run into issues – this helps isolate if a Vim plugin is causing a problem. Then you know to tweak or remove that plugin.
- Keep an eye on the extension’s documentation and wiki for any specific plugin quirks (they have notes for popular plugins). For instance, we applied the quick-scope highlight fix from there and learned about commentary and easymotion updates.

Finally, ensure your VSCode settings (`settings.json`) are set to complement this setup: e.g., enable relative line numbers in VSCode if you want them (since Vim’s `relativenumber` won’t take effect) and check keybinding conflicts (if a Vim key isn’t working, VSCode might have it bound – you may need to unbind the VSCode key or change it). The extension’s logs and “Toggle Keyboard Shortcuts Troubleshooting” in VSCode can help if a key isn’t doing what you expect.

By following this guidance, you’ll trim down your config for VSCode, achieving a faster startup and smoother operation, especially on Windows. You’ll also avoid functionality overlap – letting each side (Neovim and VSCode) handle what it’s best at. Good luck with adjusting your `init.nvim` – once tuned, VSCode Neovim can be a very powerful environment that feels close to your beloved Neovim setup, with the advantage of VSCode’s ecosystem!

## Sources

- VSCode Neovim README – _installation, usage, and plugin guidance_
- VSCode Neovim Wiki – _notes on plugin compatibility (quick-scope, commentary, etc.)_
- Maslov, Nick – _“VSCode + Neovim Setup” article (Medium, Jul 2024)_ – configuration tips and philosophy.
- Personal experience and analysis of your provided plugin list in context of the above official recommendations.
