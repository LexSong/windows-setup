# Windows Environments Setup

## Essential Apps

### [Scoop](https://scoop.sh/)

Install Scoop with PowerShell:

    Invoke-Expression (New-Object System.Net.WebClient).DownloadString('https://get.scoop.sh')
    scoop install 7zip aria2 git sudo
    scoop bucket add extras

### Neovim

    scoop install neovim

Also install Visual C++ Redistributable:

    scoop install vcredist2015
    scoop uninstall vcredist2015

### Python

Download and install [Mambaforge](https://github.com/conda-forge/miniforge#mambaforge).

    # `mamba init` won't work
    conda init
    mamba update -n base --all
    # For Neovim
    mamba install pynvim

### Install Python Apps with pipx

    mamba install pipx
    pipx ensurepath

May need reboot to set PATH properly.

    pipx install black
    pipx install flake8
    pipx install neovim-remote
    pipx install reorder-python-imports
    pipx install yamllint

Currently, virtualenv==20.0.34 is not compatible with conda on Windows:

    pipx install pre-commit
    pipx inject pre-commit virtualenv==20.0.33

## Personal Configs

### dotfiles

https://github.com/LexSong/dotfiles

### Neovim Configs

https://github.com/LexSong/nvim

## System Tweaks

### Remap Capslock to Ctrl Key

    curl -O https://raw.githubusercontent.com/LexSong/windows-setup/master/CapslockToCtrl.reg
    sudo reg import CapslockToCtrl.reg

Reboot for the above changes to take effect.

### Enable Virtual Terminal

    reg add HKEY_CURRENT_USER\Console /v VirtualTerminalLevel /t REG_DWORD /d 0x00000001 /f

See https://superuser.com/a/1300251 for more details.

### Remap Hotkeys in Applications with [PowerToys Keyboard Manager](https://docs.microsoft.com/en-us/windows/powertoys/keyboard-manager) 

    scoop install dotnet-sdk powertoys
