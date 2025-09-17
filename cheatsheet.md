# My Neovim Cheatsheet

Personal reference for keymaps and essential commands.

## 🚀 Most Used (Learn These First!)

| Key | Action | Notes |
|-----|--------|-------|
| `Ctrl+p` | **Find files** | Fuzzy search - most important! |
| `gh` | **Hover info** | See types, docs, function signatures |
| `Ctrl+t` | **Toggle file tree** | Project overview |
| `Esc` | **Normal mode** | When confused, press this |
| `:w` | **Save** | Write file |
| `:q` | **Quit** | Exit Neovim |

## 📁 File Navigation

| Key | Action |
|-----|--------|
| `Ctrl+p` | Find files (fuzzy search) |
| `<space>ff` | Find files (alternative) |
| `<space>fr` | **Recent files** |
| `<space>fb` | Open buffers |
| `<space>ft` | Git-tracked files only |
| `<space>fg` | **Search inside files** (grep) |
| `Ctrl+t` | Toggle file tree |

## ⚡ LSP (Code Intelligence)

| Key | Action |
|-----|--------|
| `gh` | **Hover info** (types, documentation) |
| `<space>ld` | Go to definition |
| `<space>lr` | Find references |
| `<space>la` | Code actions (auto-fix, imports) |
| `<space>ln` | Rename symbol |
| `<space>lf` | Format file |

## 🔀 Git Integration

| Key | Action |
|-----|--------|
| `<space>dd` | **Unified diff** (+/- view) |
| `<space>du` | Side-by-side diff |
| `<space>dc` | Close diff |
| `<space>gp` | Preview git hunk |
| `<space>gs` | Stage hunk |
| `<space>gR` | Reset hunk |
| `]h` / `[h` | Next/previous git change |
| `<space>gb` | Toggle git blame |

## 🔍 Search & Discovery

| Key | Action |
|-----|--------|
| `<space>fc` | Find commands |
| `<space>fk` | **Find keymaps** |
| `<space>fh` | Find help |
| `/` | Search in file |
| `n` / `N` | Next/previous search result |

## 📝 Markdown Preview (in .md files)

| Key | Action |
|-----|--------|
| `<space>mp` | **Preview with grip (auto browser)** |
| `<space>mo` | Start grip server (manual browser) |
| `<space>ms` | Stop all grip processes |
| `<space>md` | Preview entire directory |

## 🎯 Essential Vim Motions

| Key | Action |
|-----|--------|
| `h j k l` | ← ↓ ↑ → (movement) |
| `w` / `b` | Word forward/backward |
| `0` / `$` | Start/end of line |
| `gg` / `G` | Top/bottom of file |
| `Ctrl+u` / `Ctrl+d` | Scroll half page up/down |

## ✏️ Editing

| Key | Action |
|-----|--------|
| `i` | Insert before cursor |
| `a` | Insert after cursor |
| `I` | Insert at start of line |
| `A` | Insert at end of line |
| `o` | New line below |
| `O` | New line above |
| `v` | Visual mode (character) |
| `V` | Visual mode (line) |
| `y` | Copy (yank) |
| `p` | Paste |
| `d` | Delete |
| `dd` | Delete line |
| `u` | Undo |
| `Ctrl+r` | Redo |

## 🪟 Window Management

| Key | Action |
|-----|--------|
| `Ctrl+w h/j/k/l` | Move between panes |
| `Ctrl+w s` | Split horizontal |
| `Ctrl+w v` | Split vertical |
| `Ctrl+w q` | Close current pane |
| `Ctrl+w w` | Cycle through panes |
| `Ctrl+w =` | Make panes equal size |

## 💡 Pro Tips

- **File Finding**: Use `Ctrl+p` instead of clicking through folders
- **Code Exploration**: `gh` for info → `<space>ld` for definition → `<space>lr` for usage
- **Git Workflow**: `<space>dd` for quick diff, `<space>gp` to preview changes
- **When Lost**: Press `Esc` to get to normal mode, then `:q` to quit
- **Help**: Press `?` in any Telescope or Neo-tree window for context help
- **Discovery**: Use `<space>fk` to find keymaps, `<space>fc` for commands

## 🆘 Emergency Commands

| Command | Action |
|---------|--------|
| `:q` | Quit current window |
| `:qa` | **Quit all windows** |
| `:q!` | Quit without saving |
| `:qa!` | Quit all without saving |
| `:w` | Save |
| `:wq` | Save and quit |
| `:wqa` | Save all and quit all |
| `Esc Esc` | Get back to normal mode |
| `:LspInfo` | Check if LSP is working |
| `:Lazy` | Plugin manager |

---

**Remember**: Vim is modal! Most commands work in Normal mode. Press `Esc` to get there.