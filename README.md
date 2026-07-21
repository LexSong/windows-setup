# Windows Setup

## Step 1: Desktop Apps

On a fresh machine, type this into a cmd prompt — winget the apps without
touching Edge:

    winget install Google.Chrome
    winget install Valve.Steam

Then open this page in Chrome and copy-paste the next step.

## Step 2: Bootstrap

Run in a regular (non-admin) cmd prompt:

    curl -LO https://raw.githubusercontent.com/LexSong/windows-setup/main/bootstrap.cmd
    bootstrap.cmd

The script is linear on purpose: it stops at the first failure and is safe to
run again after fixing the problem. It installs Scoop and Git, checks out the
bare [dotfiles](https://github.com/LexSong/dotfiles) repo into the home
directory, then installs everything else: CLI tools, MSYS2 + fish (the daily
shell), fonts, uv and npm tools. Desktop apps are not covered by the script.
See the comments in [bootstrap.cmd](bootstrap.cmd) for details.

## WSL and Docker Sandboxes

WSL is not preinstalled. Run this in an **admin** prompt, then reboot:

    wsl --install

After the reboot, install Docker Sandboxes:

    winget install Docker.sbx

## Remap Capslock to Ctrl Key

Skip this if the keyboard already remaps in hardware.

1.  Download the [CapslockToCtrl.reg](https://raw.githubusercontent.com/LexSong/windows-setup/main/CapslockToCtrl.reg) registry file and double-click it.
2.  Click Yes on both the UAC security prompt and the registry confirmation.
3.  Restart the computer for the key remapping to take effect.

## Related Repos

- dotfiles: https://github.com/LexSong/dotfiles
- Neovim config: https://github.com/LexSong/nvim
