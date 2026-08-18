# Remap CapsLock to Left Ctrl at the driver level, for a keyboard that doesn't
# do it in hardware. Needs admin, and a restart to take effect.
#
# Scancode Map layout: 8 reserved bytes, an entry count (mappings plus the null
# terminator), one 4-byte entry per mapping -- target scancode first, then the
# key being replaced -- and a null entry closing the list. 0x001d is Left Ctrl,
# 0x003a is CapsLock.

$map = [byte[]] @(
    0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00,
    0x02, 0x00, 0x00, 0x00,
    0x1d, 0x00, 0x3a, 0x00,
    0x00, 0x00, 0x00, 0x00
)

Set-ItemProperty `
    -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Keyboard Layout' `
    -Name 'Scancode Map' `
    -Value $map `
    -Type Binary `
    -ErrorAction Stop
