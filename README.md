# Neovim Configuration

A high-velocity, cross-platform Neovim configuration designed for lightspeed workflow.

This `init.lua` is built to be portable. It dynamically detects the OS (Linux/Windows) to handle plugin paths automatically, eliminating the need for separate configuration files.

## Philosophy
* **No Counting:** Uses `relativenumber` to allow instant vertical jumps without mental math.
* **Contextual Navigation:** Relies on Fuzzy Finding (`fzf`) and LSP definitions (`gd`) rather than file trees.
* **Keyboard Centric:** Optimized keymappings to minimize keystrokes for common actions.
* **Cross-Platform:** One file for Debian, Kali, and Windows 11.

## Prerequisites

Before linking the configuration, ensure the underlying engines are installed.

| Component | Usage | Linux (Debian/Ubuntu) | Windows (Winget/Scoop) |
| :--- | :--- | :--- | :--- |
| **Neovim** | The Editor | `sudo apt install neovim` | `winget install neovim` |
| **Node.js** | LSP Engine (CoC) | `sudo apt install nodejs` | `winget install CoreyButler.NVMforWindows` |
| **Ripgrep** | Project Search | `sudo apt install ripgrep` | `winget install burke.ripgrep` |
| **FZF** | Fuzzy Finder | `sudo apt install fzf` | `winget install junegunn.fzf` |
| **Go Tools**| Go Analysis (gopls)| `go install golang.org/x/tools/gopls@latest` | `go install golang.org/x/tools/gopls@latest` |

## Installation

### 1. Install Plugin Manager (vim-plug)
Run this command to bootstrap the plugin manager for Neovim:

**Linux / Mac:**
```bash
sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs \
       [https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim](https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim)'

```

**Windows (PowerShell):**

```powershell
iwr -useb [https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim](https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim) |`
    ni "$(@($env:XDG_DATA_HOME, $env:LOCALAPPDATA)[$null -eq $env:XDG_DATA_HOME])/nvim-data/site/autoload/plug.vim" -Force

```

### 2. Symlink the Config

Don't copy the file; symlink it so your repo stays the source of truth.

**Linux:**

```bash
mkdir -p ~/.config/nvim
# Note: Adjust '~/Code/' if your repo is elsewhere
ln -s ~/Code/.my_configs/nvim/init.lua ~/.config/nvim/init.lua

```

**Windows (PowerShell Admin):**

```powershell
New-Item -ItemType SymbolicLink -Path "$env:LOCALAPPDATA\nvim\init.lua" -Target "C:\Users\YOUR_USER\Code\.my_configs\nvim\init.lua"

```

### 3. Initialize & Install Engines

Open Neovim and run the following commands to install plugins and language servers:

```vim
:PlugInstall
:CocInstall coc-go coc-pyright coc-json coc-pairs

```

*Note: If Go autocomplete does not work immediately, ensure `gopls` is in your path.*

---

## Keymappings

**Leader Key:** `,` (Comma)

### Navigation (The "Files" Workflow)

| Mapping | Action | Description |
| --- | --- | --- |
| `,f` | `:Files` | **Fuzzy Find Files**. Type filename, hit enter. |
| `,b` | `:Buffers` | Switch between open files. |
| `,g` | `:Rg` | **Ripgrep**. Search for text *inside* files across the whole project. |
| `F3` | `:NERDTreeToggle` | Toggle the file tree (use sparingly). |

### Intelligence (LSP) & Autocomplete

| Mapping | Action | Description |
| --- | --- | --- |
| `gd` | `Go to Definition` | Teleport to where the function/variable is defined. |
| `gr` | `Find References` | List every file where this function is used. |
| `,a` | `Quick Fix` | Apply code actions (e.g. fix missing imports). |
| `K` | `Hover Doc` | Show documentation/types in a popup. |
| `[g` / `]g` | `Prev/Next Error` | Jump instantly to syntax errors. |
| `Tab` | `Next Suggestion` | Cycle through autocomplete menu options. |
| `Enter` | `Confirm` | Select the highlighted autocomplete suggestion. |

### Integrated Terminal

| Mapping | Action | Description |
| --- | --- | --- |
| `Ctrl + \` | `Toggle Terminal` | Open/Hide the integrated terminal drawer. |
| `Esc` | `Normal Mode` | Exit typing mode to scroll output (use `i` to type again). |

### Window Management

| Mapping | Action | Description |
| --- | --- | --- |
| `,v` | `vsplit` | Split window vertically. |
| `,h` | `split` | Split window horizontally. |
| `Ctrl + h/j/k/l` | `Focus` | Move focus between split windows. |

### Go Specifics

| Mapping | Action | Description |
| --- | --- | --- |
| `,r` | `go run` | Run the current main file (Asynchronous Split). |
| `,t` | `go test` | Run tests for the current package. |

---

## How It Works (Internal Logic)

The `init.lua` is self-referential regarding path management.

**Section 1: Dynamic Paths**
This block automatically detects if it is running on Linux or Windows and adjusts the plugin storage path (`data_path`) accordingly. This prevents directory mismatch errors when syncing this repo across OSs.

```lua
local data_path = vim.fn.stdpath('data') .. '/site/plugged'
local Plug = vim.fn['plug#']
vim.call('plug#begin', data_path)

```

**Section 3: Mapping Function**
To keep the code clean, a local helper function `map()` is defined to handle keybinding verbosity.

```lua
local function map(mode, lhs, rhs, opts)
    vim.keymap.set(mode, lhs, rhs, opts or {silent = true})
end

```


