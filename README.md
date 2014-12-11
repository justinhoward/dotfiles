# Justin Howard's Dotfiles

Most dotfiles solutions cater to a single environment like a certain shell. This project is
intended to organize dotfiles for every environment including non-interactive shells. It uses
a module system like some other dotfile repositories.

Most of the flashy fun stuff in this setup comes from the [Prezto](https://github.com/sorin-ionescu/prezto)
ZSH dotfile system. Be sure to check out what it can do.

## Installation

Clone the repository into your home directory

``` bash
git clone git@github.com:justinhoward/dotfiles.git ~/.dotfiles
```

Run the install script. This will backup your existing dotfiles to `<name>.bak` and symlink
to the ones in the dotfiles repository.

``` bash
~/.dotfiles/install.sh
```

## Fonts

The default theme requires a patched [powerline font](https://github.com/powerline/fonts). You can install one, or change the
theme to a different prezto theme.

## Customizing

Change what modules get loaded when by customizing `config/modules.sh`.

Prezto configuration can be found in the `config/prezto` directory.
All files in this directory will be run immediately before prezto is loaded.

## Modules

A module is a directory inside the `modules` directory. A module is loaded in stages.

The modules get loaded when an "event" is fired.
The built in events are "load", "xorg", "interactive", "login", and "xorg_init". These events will only
get fired if its respective environment is present.

### Condition
If a `condition.sh` file exists in the module's directory, it will be run before
the module is loaded. If the file exits with a non-zero exit code, the module
will not be loaded

### Initialization
Initialization is made up of three stages.

- `preinit`
- `init`
- `postinit`

For each stage, the `<stage>`.sh file will be tried first, and then the `<stage>`
directory. If the `.sh` file exists, and it exits with a zero exit code, the directory will
also be tried. If the directory exists, all files in it will be sourced. If neither the `.sh`
file or the directory exist, the stage will be skipped.

## Environment
Dotfiles creates some variables that are helpful in determining what
environment to run in order to conditionally load configurations.

- `dotfiles_shell`: The name of the running shell. `bash`, `sh`, `ksh`, `zsh`, or empty if unknown.
- `dotfiles_interactive`: `1` if the shell is interactive, empty if not
- `dotfiles_login`: `1` if the shell is a login shell, empty if not
- `dotfiles_xorg`: `1` if the environment is the xorg window manager, empty if not

## Functions
Dotfiles provides some utility functions for loading modules

- `dload(path)`: Provides the `.sh`, then directory loading sequence as used in each
    module load stage
- `dmodload(name)`: Loads the `name` module. Does nothing if the module is already loaded.
- `devent(name)`: Runs the `name` event. If the `devent_<name>` variable is an array
    of module names, those modules will be loaded. See `config/modules.sh`
- `dconfig(name)`: Uses `dload` to load configuration files in the `config` directory

[Licensed](LICENSE.txt) under the MIT License.