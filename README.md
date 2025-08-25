# Windows Environments Setup

## Essential Apps

### Install Desktop Applications with WinGet

Install apps with winget, avoid opening Edge:

    winget install Google.Chrome
    winget install Valve.Steam

### [Scoop](https://scoop.sh/)

Install Scoop with PowerShell:

    irm get.scoop.sh | iex
    scoop install 7zip aria2 git pwsh
    scoop bucket add extras

### Neovim

Install Neovim:

    scoop install neovim

Also install Visual C++ Redistributable:

    scoop install vcredist2022
    scoop uninstall vcredist2022

### Python

Use `pixi` and `uv` to install conda and python environments instead.

    scoop install pixi
    scoop install uv

Use `uv tool` to install Python apps instead if they're not available in Scoop.

    scoop install ruff
    uv tool install reorder-python-imports

## Personal Configs

### dotfiles

https://github.com/LexSong/dotfiles

### Neovim Configs

https://github.com/LexSong/nvim

## System Tweaks

### Remap Capslock to Ctrl Key

1.  Download the [CapslockToCtrl.reg](https://raw.githubusercontent.com/LexSong/windows-setup/master/CapslockToCtrl.reg) registry file and double-click it.
2.  Click Yes on both the UAC security prompt and the registry confirmation.
3.  Restart the computer for the key remapping to take effect.
