# Configuration

fetch is configured through `~/.config/fetch/config`. If the file doesn't exist, all fields are shown in the default order.

## Fields

List field names one per line to show them, in the order you want. Comment out or remove fields to hide them. If a config file exists, only the fields listed in it are shown.

```
os
host
kernel
uptime
packages
shell
display
wm
theme
icons
font
cursor
terminal
cpu
gpu
memory
swap
disk
ip
battery
locale
colors
```

All fields are optional. You can reorder them however you want.

## Separators

Add `---` on its own line to insert a blank line between groups of fields:

```
os
host
kernel
---
cpu
gpu
memory
```

## Custom fields

Add static text fields with `custom_Label=value`:

```
custom_Pronouns=he/him
custom_Website=example.com
custom_Editor=neovim
```

These render like built-in fields (`Pronouns: he/him`) with the configured label color. You can place them anywhere in the field list and mix them with separators. No command execution — values are static strings only.

## Appearance

```
label_color=magenta
```

Color of the labels (the "CPU:", "Memory:", etc. text). Accepts: `red`, `green`, `yellow`, `blue`, `magenta`, `cyan`, `white`, or an ANSI color number.

```
separator=-
```

Character used for the title separator line. Default is `-`.

```
box=1
```

Draw a Unicode box around the system info. `0` = off (default), `1` = on. Also accepts `yes`/`no`/`true`/`false`.

```
pinned=0
```

Pinned mode (same as `--pinned`): the logo keeps spinning at the top of the terminal while the shell runs in the rows below it, until `fetch --unpin`, another `fetch`, or the shell exits. The logo is shrunk as needed to leave the shell at least 8 rows, and the terminal needs at least 18; on a shorter terminal, or when output isn't a terminal, it falls back to the classic full-screen run. Runs forever unless `--frames` is given. `1` = on (default), `0` = off (same as `--no-pinned`). Also accepts `yes`/`no`/`true`/`false`.

`clear` and Ctrl-L only remove the logo with the shell hooks from `fetch --init <shell>` loaded (`eval "$(fetch --init bash)"` in `~/.bashrc`, `eval "$(fetch --init zsh)"` in `~/.zshrc`, `fetch --init fish | source` in `config.fish`). They stop the pinned logo before clearing.

Pinned mode is best effort. It relies on a terminal scroll region, so full-screen programs (vim, less, htop) and `reset` draw over it or undo it, and very chatty output can occasionally leave a stray glyph. Mouse dragging isn't available in this mode.

```
shading=░▒▓█
```

Shading ramp for the 3D rendering. Characters go from dimmest to brightest. Supports UTF-8. Unset by default, which draws the logo in high-resolution braille (2x4 dots per cell, dithered). Setting a ramp switches to block mode, where edges are drawn with 2x2 quadrant blocks; `░▒▓█` gives the classic look. See [shading-modes.md](shading-modes.md).

## Logo colors

For logos without their own ANSI colors (custom logos, some distros), you can set two-tone coloring:

```
logo_outer=magenta
logo_inner=white
```

`logo_outer` is the extruded side color, `logo_inner` is the front/back face color. Accepts the same color names as `label_color`, or an ANSI number.

## 3D settings

```
light=top-left
```

Light direction. Options: `top-left` (default), `top-right`, `top`, `left`, `right`, `front`, `bottom-left`, `bottom-right`.

```
speed=1.0
```

Rotation speed multiplier. Higher = faster.

```
size=1.0
```

Logo scale. `2.0` for double size, `0.5` for half. Range: 0.5 to 5.0.

```
depth=1.0
```

3D extrusion depth. Higher = chunkier relief. Range: 0.1 to 10.0. If not set, fetch auto-scales depth based on the logo's character variance so flat logos don't look paper-thin.

```
height=36
```

Override the render height in rows. Default is auto (matches the number of info lines).

## Extra disks

Show additional mount points beyond the root filesystem:

```
disk=/home
disk=/data
```

Up to 8 extra mount points. Each one adds a line to the info output.

## Notes

- Lines starting with `#` are comments
- You don't need to remove the hint text in parentheses after values (e.g. `label_color=white (red, green, ...)`). The parser strips those automatically, except for `shading=`, `separator=`, and `disk=` which accept freeform strings
- CLI flags override config file settings
- If no config file exists, everything uses defaults
