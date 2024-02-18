# PluginSwitcher
Switch between plugins depending on your needs

## ⚙️ Functionality
- This plugin will let you group your plugins into different profiles and load them according to your needs.<br/>

- Previous session is remembered and your plugins are loaded automatically the next time you open nvim.

## ⚡ Requirements
[Lazy.nvim](https://github.com/folke/lazy.nvim) as plugin manager.<br/>

**Note**: All plugins are loaded using Lazy load. Plugins you wish to manage should be set to ```lazy = true``` in your plugins.lua (or similar) when you declare them.
## 📦 Installation
Only recommended with [lazy.nvim](https://github.com/folke/lazy.nvim):
```lua
{ 'nihancj/plugin-switcher.nvim' }
```

## 🛠️ Setup
Here is an example config:
```lua
require('plugin-switcher').setup({
  -- Group different plugins together with a name
  plugins = {
    minimal = {
      'which-key.nvim',
      'lualine.nvim',
    },
    crazycoder = {
      'telescope.nvim',
      'nvim-lspconfig',
      'nvim-dap',
    },
  },

  -- A function executed after plugins are loaded
  -- is_startup: true if the profile is being loaded when nvim starts.
  hooks = {
    crazycoder = function(is_startup)
      vim.cmd "LspStart"
  end
})
```
##  Commands
```:Pload <profile_name>```
