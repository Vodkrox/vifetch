# vifetch

**See your system at a glance, with a spinning 3D logo.**

vifetch shows your distro's logo as a rotating 3D animation right in your terminal, with your system information beside it. It can even stay at the top of the window while you keep working underneath.



## Features

- Clear system information: OS, kernel, uptime, memory, disk, and more
- Works on Linux and macOS
- Fits any window size, even narrow ones
- Customizable colors, size, speed and layout
- Tiny and fast

## Installation

```sh
git clone https://github.com/Vodkrox/vifetch.git
cd vifetch
make
sudo make install
```

## Usage

Just run:

```sh
fetch
```

Want a different logo?

```sh
fetch -l arch
```

Want it to keep spinning?

```sh
fetch --infinite
```

To see it every time you open a terminal, add `fetch` to your shell's startup file 

## Contributing

Ideas, bug reports and pull requests are welcome.
