# xs
Terminal user interface for package managers, written in POSIX sh. [Credit for the base idea goes to u/jjzmajic](https://old.reddit.com/r/voidlinux/comments/es8zgf/tiny_convenience_function_i_think_would_be_worth/).

## Deps
This program requires the `fzf` package on all distros. For example, on Arch and its derivatives:
```sh
pacman -S fzf
```

On Voidlinux in particular, you need the `xtools` package as well as `fzf` as it handles package fetching in a clean way. You can install it like this:
```sh
xbps-install -S xtools
```

## Usage
`xs [-i/--install]`: launches the installer tui

`xs [-r/--remove]`: launches the uninstaller tui

`xs [-h/--help]`: prints help

`xs --yay-install`: launches the aur installer tui

`xs --yay-remove`: launches the aur uninstaller tui

## Installation
```sh
curl -fsSL https://github.com/the-unwelcome/xs/raw/main/xs.sh -o xs && chmod a+x xs
```

## Uninstallation
Just remove the `xs` file.

## Preview
![image](https://user-images.githubusercontent.com/64506392/199857017-d4cf8880-b71e-4e65-ae37-83bcbffc6373.png)
