# Compare the user PATH with the default list below and print the differences.
# With -Overwrite, also replace the user PATH with the list. The system PATH is a
# separate value, and this script does not touch it.
#
# setx PATH can merge the system PATH into the user one and truncate it, so .NET
# writes the value instead. Scoop and installers add entries on their own, so an
# entry they added since the last edit shows up here as extra.
param([switch]$Overwrite)

$default = @(
    "$HOME\windows-setup\bin"
    "$HOME\scoop\persist\uv\tools\shims"
    # current\bin links to scoop's persist folder, the npm storage. It holds the global
    # npm and global tools, and it survives nodejs updates. current holds the nodejs
    # runtime, node.exe. It also holds a bundled npm, and each update replaces both.
    # So current\bin comes first, and npm resolves to the global copy.
    "$HOME\scoop\apps\nodejs\current\bin"
    "$HOME\scoop\apps\nodejs\current"
    "$HOME\scoop\apps\gcc\current\bin"
    "$HOME\scoop\apps\temurin8-jre\current\bin"
    "$HOME\scoop\shims"
    "$HOME\.local\bin"
    "$HOME\AppData\Local\Microsoft\WindowsApps"
    "$HOME\AppData\Local\DockerSandboxes\bin"
)

$current = @([Environment]::GetEnvironmentVariable('Path', 'User') -split ';' |
    Where-Object { $_ } |
    ForEach-Object { $_.TrimEnd('\') })

$missing = @($default | Where-Object { $_ -notin $current })
$extra = @($current | Where-Object { $_ -notin $default })

foreach ($entry in $missing) { "Missing: $entry" }
foreach ($entry in $extra) { "Extra:   $entry" }

if ($missing.Count -eq 0 -and $extra.Count -eq 0) {
    if (($current -join ';') -eq ($default -join ';')) {
        'The user PATH matches the default list.'
    } else {
        'The user PATH has the same entries in a different order.'
    }
}

if ($Overwrite) {
    [Environment]::SetEnvironmentVariable('Path', ($default -join ';'), 'User')
    'Replaced the user PATH with the default list.'
}
