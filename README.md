# 📝 DailyNotes.nvim
A Neovim plugin to take daily notes. 

- [Disclaimer](#disclaimer)

- [Features](#features)
 
- [Installation](#installation)

- [Options](#options)

- [Functions](#functions)

- [Commands](#commands)

## Disclaimer
If you have issues, don't hesitate to report them.

However, I mainly make these plugins strictly for personal use.

## Features
- **Daily notes**


## Installation
Minimal Lazy.nvim example (no keybinds, up to you to call the functions by hand)
```lua
{
    "radioactivepb/dailynotes.nvim"
}
```
Lazy.nvim example with default opts (uses default keybinds, see [Options](#options) for details)
```lua
{
    "radioactivepb/dailynotes.nvim",
    opts = {}
}
```
## Options
Many options are available for easy keybindings
```lua
{
    "radioactivepb/dailynotes.nvim",
    --- Default options shown
    opts = {
        --- Storage path for notes
		path = vim.fn.stdpath("data") .. "/dailynotes.nvim",
        --- Enable nerd font icons in calendar mode
		icons = false,
        --- Disable the default keybinds
		disable_default_keybinds = false,
        --- Keybind functions
		keybinds = {
			today = "<leader>no",
			calendar = "<leader>nc",
		},

    }
}
```

## Functions
```lua
--- Opens today's note
require("dailynotes").today
--- Toggles the notes calendar
require("dailynotes").calendar
```

## Commands
```vim
DailyNotes today
DailyNotes calendar
```
