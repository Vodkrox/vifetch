# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

`fetch` — a donut.c-inspired system-info fetch tool. It turns an ASCII/Unicode
distro logo into a rotating 3D point cloud (Blinn-Phong shaded) and renders it
in the terminal next to live-updating system info. Everything lives in a
single C file, `fetch.c` (~4700 lines), with no runtime dependencies beyond
libm (Linux) / IOKit+CoreFoundation (macOS). Ports: Linux and macOS.

## Build & run

```
make            # builds ./fetch
./fetch
make clean
```

There is no test suite, linter, or CI config in this repo — verify changes by
building and running `./fetch` (and variants like `./fetch -l arch --no-info`,
`./fetch --shading-chars "░▒▓█"`) in an actual terminal.

Version/codename/arch/OS are baked in at compile time via `-D` flags in the
Makefile, sourced from `VERSION` and `CODENAME` (Makefile default, overridable
via `make CODENAME=...`).

Packaging metadata (`fetch.spec` for RPM, `debian/` for `.deb`, `nix/` for the
flake/home-manager module) mirrors the Makefile build — update `VERSION` and
keep these in sync if changing the build process.

## Architecture

`fetch.c` is organized as a straight-line pipeline, roughly in file order:

1. **Terminal/signal setup** — raw mode via `termios`, `SIGWINCH` handling for
   resize, `cleanup()` restores terminal state on exit (registered via
   `atexit`/signal handlers so it always runs).
2. **UTF-8 helpers** (`utf8_char_len`, `skip_ansi`, `visible_width`,
   `emit_clipped`) — logos and info lines contain multi-byte UTF-8 and inline
   ANSI color codes, so width/truncation must be ANSI- and codepoint-aware
   everywhere.
3. **Shading tables** — by default the logo is drawn in braille (`sub_rows`
   = 4, 2x4 dots per cell, Bayer-dithered via `bayer4`/`braille_bits`).
   Setting a ramp with `--shading-chars`/`shading=` switches to block mode
   (`use_braille` = 0, `sub_rows` = 2): `quadrant_glyphs` (2x2 sub-cell block
   glyphs) plus `shading_chars` (the ramp).
4. **Logo loading** — `load_logo_file()` reads `~/.config/fetch/logo.txt`;
   `load_logo_fastfetch()`/`load_logo_ff_colored()`/`load_logo_ff_plain()`
   shell out to `fastfetch` for its 500+ bundled logos (with per-character
   ANSI colors preserved when present); `detect_distro*()` reads
   `/etc/os-release`; `load_default_logo()` falls back to a built-in Gentoo
   logo. Parsed logo rows land in `logo_data`/`logo_cells` (per-cell UTF-8
   glyph + color).
5. **`char_weight_utf8()`** — maps each glyph to a visual-density weight
   (`@` heavy, `.` light, `█` full, `░` thin); this weight becomes the Z
   height of the logo's heightmap.
6. **Config** (`load_config`, `config_defaults`) — parses
   `~/.config/fetch/config` into the `field_*`/`config_*` globals (field
   list/order via `field_map[]`, custom fields, colors, 3D params, shading,
   box mode, alignment). CLI flags parsed in `main()` override config values.
7. **`gather_*()` functions** — one per info field (`gather_os`,
   `gather_cpu`, `gather_gpu`, `gather_display` (DRM+EDID enumeration),
   `gather_battery`, `gather_packages` (probes emerge/pacman/dpkg/rpm/xbps/
   apk/flatpak/brew/nix in turn), etc.). Each is dispatched by field ID
   (`F_OS`, `F_CPU`, ...) through the `fns[]` table in `main()`, driven by the
   user's configured field order, and appends formatted lines via
   `add_info()`/`add_line()`. Fast-changing fields (uptime, memory, swap,
   battery) are re-gathered every second during the animation loop
   (`is_refresh_pass`).
8. **Point cloud + rendering** — `build_points()` samples the heightmap into
   3D points (`PX/PY/PZ`, normals `NX/NY/NZ`, colors `PCOLOR`), giving
   interior cells multiple Z layers (solid extrusion) and edge cells only
   front/back faces. The main loop in `main()` rotates points each frame,
   projects with a z-buffer (`zbuf`/`lumbuf`/`colorbuf`), computes Blinn-Phong
   lighting against `light_x/y/z`, and picks a glyph per cell via
   `cell_glyph()` (dithered braille via `braille_glyph()`, or in block mode
   a ramp shade or quadrant glyph, whichever matches the cell's ink). The whole frame is assembled into one buffer and written with a
   single `write()` to avoid flicker.
9. **Layout** — `apply_layout()` decides side-by-side vs. stacked (logo above
   info) layout and clipping based on terminal size (`get_term_size`);
   `get_alignment_padding()` applies `v_alignment`/`h_alignment`.

### Key global state

Most state is static globals at file scope (logo buffers, field config,
point-cloud arrays, terminal size) rather than passed through structs — this
is a deliberate donut.c-style single-file design, not an oversight. When
adding a field or option, follow the existing pattern: add an enum value/global,
a `gather_*()` function, a config-file key in `load_config()`/`field_map[]`,
and a CLI flag in `main()` + its `--help` text, keeping README.md and
`docs/configuration.md` in sync with any new flags or config keys.

## Docs

- `docs/configuration.md` — full config-file reference (fields, separators,
  custom fields, appearance/3D options).
- `docs/shading-modes.md` — how the quadrant-block shading works and how to
  set a custom ramp.
- `docs/custom-logos.md` — format for `~/.config/fetch/logo.txt`.

README.md's "How it works" section and Options table are the canonical
user-facing description of the pipeline above; update both the README and the
relevant `docs/*.md` file when behavior changes.
