:: bootstrap.cmd -- set up a fresh Windows machine from zero.
::
:: On a fresh machine, open a regular (non-admin) cmd prompt and run:
::
::     curl -LO https://raw.githubusercontent.com/LexSong/windows-setup/main/bootstrap.cmd
::     bootstrap.cmd
::
:: Linear on purpose: every step carries "|| exit /b" so the script stops
:: at the first failure (batch keeps going on errors by default). Echo is
:: left ON so the failing line is visible. The few lines WITHOUT the guard
:: are allowed to fail so a crashed run can simply be re-run.

setlocal
set "PATH=%USERPROFILE%\scoop\shims;%PATH%"

:: --- Scoop (PowerShell only as a subprocess, just for the installer) ---
if not exist "%USERPROFILE%\scoop" powershell -NoProfile -ExecutionPolicy Bypass -Command "irm get.scoop.sh | iex" || exit /b

:: --- Git, plus the helpers scoop itself uses for downloads/archives ---
call scoop install 7zip git aria2 || exit /b

:: --- Dotfiles: bare repo in %USERPROFILE%\.dotfiles, work tree = home ---
git init --bare "%USERPROFILE%\.dotfiles" || exit /b
git --git-dir="%USERPROFILE%\.dotfiles" remote add origin https://github.com/LexSong/dotfiles
git --git-dir="%USERPROFILE%\.dotfiles" fetch origin || exit /b
git --git-dir="%USERPROFILE%\.dotfiles" --work-tree="%USERPROFILE%" checkout main || exit /b

:: MSYS2 honors an existing HOME env var instead of /home/<user>, so fish
:: reads ~/.config/fish from the real Windows home. This is the only glue.
setx HOME "%USERPROFILE%" || exit /b

:: --- Scoop packages (snapshot of the working machine, 2026-07-22) ---

:: Shells and editor
call scoop install neovim msys2 pwsh || exit /b

:: Neovim needs the VC++ runtime: install it system-wide, then drop the package.
call scoop install vcredist2022 || exit /b
call scoop uninstall vcredist2022 || exit /b

:: Essential command-line tools
call scoop install bat diffutils dust fd fzf just ripgrep scoop-search topgrade || exit /b

:: Programming languages and dev tooling
call scoop install gcc jq nodejs pixi ruff rust sqlite stylua taplo tree-sitter uv || exit /b

:: Media and documents
call scoop install ffmpeg pandoc || exit /b

:: Download, sync, and backup
call scoop install rclone restic megacmd || exit /b

:: Android
call scoop install adb scrcpy || exit /b

:: Misc:
::   czkawka - duplicate finder
::   innounp - Inno Setup unpacker
::   llama-swap - local LLM proxy
call scoop install czkawka innounp llama-swap || exit /b

:: --- Extras bucket: GUI apps and tools ---
:: (re-adding an existing bucket fails harmlessly)
call scoop bucket add extras
call scoop install avidemux CrystalDiskMark IrfanView krokiet mitmproxy qbittorrent rapidee spacesniffer typora vlc winmerge || exit /b

:: --- Fonts: "CaskaydiaMono Nerd Font", used by the Windows Terminal profile ---
call scoop bucket add nerd-fonts
call scoop install CascadiaMono-NF || exit /b

:: Minecraft: Prism Launcher (personal build) + Java 8 for old versions
call scoop bucket add java
call scoop bucket add my-scoop-bucket https://github.com/LexSong/my-scoop-bucket
call scoop install temurin8-jre prismlauncher-np || exit /b

:: --- MSYS2 + fish (the daily shell) ---
:: Windows Terminal profile launches it with:
::   msys2_shell.cmd -msys2 -defterm -here -no-start -full-path -shell fish
set "MSYS2=%USERPROFILE%\scoop\apps\msys2\current"
"%MSYS2%\usr\bin\bash.exe" -lc true || exit /b
:: -Syu runs twice on purpose: the first pass may upgrade only the core
:: (msys2-runtime, pacman) and stop there; the second pass updates the rest.
"%MSYS2%\usr\bin\pacman.exe" -Syu --noconfirm || exit /b
"%MSYS2%\usr\bin\pacman.exe" -Syu --noconfirm || exit /b
"%MSYS2%\usr\bin\pacman.exe" -S --needed --noconfirm fish || exit /b

:: --- Python CLI tools (no global python -- everything through uv) ---
uv tool install gallery-dl || exit /b
uv tool install git-filter-repo || exit /b
uv tool install huggingface-hub || exit /b
uv tool install reorder-python-imports || exit /b
uv tool install yt-dlp || exit /b

:: --- npm global tools ---
call npm install -g cspell prettier pyright || exit /b

:: --- Neovim config ---
if not exist "%LOCALAPPDATA%\nvim" (git clone https://github.com/LexSong/nvim "%LOCALAPPDATA%\nvim" || exit /b)

:: --- Windows Terminal settings ---
:: TODO: windows-terminal-settings will move to its own git repo; once that
:: exists, clone it here and enable the copy into WT's LocalState.
:: copy /Y "%USERPROFILE%\windows-terminal-settings\settings.json" "%LOCALAPPDATA%\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"

:: --- Desktop apps via winget ---
:: (no || exit /b: winget errors on already-installed apps, and a re-run
:: of this script should not stop here; WSL and Docker Sandboxes are
:: manual steps -- see README.md)
winget install Google.Chrome
winget install Valve.Steam

echo Done. Open the "MSYS2 Fish" profile in Windows Terminal.
