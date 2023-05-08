# Justin Howard's Dotfiles

Most dotfiles solutions cater to a single environment like a certain shell. This
project is intended to organize dotfiles for every environment including
non-interactive shells. It uses a module system like some other dotfile
repositories.

Most of the flashy fun stuff in this setup comes from the
[Prezto](https://github.com/sorin-ionescu/prezto) ZSH dotfile system.
Be sure to check out what it can do.

## Installation

Clone the repository into your home directory

```bash
git clone git@github.com:justinhoward/dotfiles.git ~/.dotfiles
```

Run the install script. This will backup your existing dotfiles to `<name>.bak`
and symlink to the ones in the dotfiles repository.

```bash
cd ~/.dotfiles
make
```

## Fonts

The default theme requires a patched
[powerline font](https://github.com/powerline/fonts). You can install one,
or change the theme to a different prezto theme.

## Customizing

Change what modules get loaded when by customizing `config/selected-modules.sh`.

Prezto configuration can be found in the `config/prezto` directory.
All files in this directory will be run immediately before prezto is loaded.

## Updating

To update `dotfiles` itself and all its modules, run `make update`.

## Modules

A module is a directory inside the `modules` directory. Modules can contain a
mixture of scripts to load at runtime, installation scripts, and config files.

### Events

At runtime, modules are only loaded when an "event" is fired.
The built in events are "load", "xorg", "interactive", "login", and "xorg_init".
You can use `config/modules.sh` to change which modules are loaded during
which events. Events are fired in the following order.

- `load`: After the dotfiles library is loaded.
- `xorg`: Only run in an X context
- `interactive`: Only run if in an interactive shell
- `login`: Only run if in a login shell
- `xorg_init`: Only run in an X context.
  This is last, so use it to exec your window manager.

### Parts

Modules can have runtime scripts, installation scripts, and
configuration scripts.

#### Initialization

Initialization happens at runtime when an event is triggered and loads a module.
It is made up of three stages.

- `preinit`
- `init`
- `postinit`

For each stage, the `<stage>`.sh file will be tried first, and then the
`<stage>` directory. If the `.sh` file exists, and it exits with a zero exit
code, the directory will also be tried. If the directory exists, all files in it
will be sourced. If neither the `.sh` file or the directory exist, the stage
will be skipped.

#### Condition

If a `condition.sh` file exists in the module's directory,
it will be run before the module is initialized. If the file
exits with a non-zero exit code, the module will not be initialized.

#### Install

When installing, the installer will try to run each module's
`install.sh` file. This script should do any symlinking,
copying, etc to set up module dependencies.

You can also use an `install` directory to contain scripts to run
during install. See `dload` for details.

#### Configuration

Your module can contain a `config.sh` script or `config` directory
to be copied to `$DOTFILES_PATH/config` before installation. Your
module should use `dconfig` to load those configuration files
at runtime.

## Environment

Dotfiles creates some variables that are helpful in determining what
environment to run in order to conditionally load configurations.

- `dotfiles_platform`: The name of the type of system. `osx`, 'linux', 'freebsd'
- `dotfiles_shell`: The name of the running shell. `bash`, `sh`, `ksh`, `zsh`,
   or empty if unknown.
- `dotfiles_interactive`: `1` if the shell is interactive, empty if not
- `dotfiles_login`: `1` if the shell is a login shell, empty if not
- `dotfiles_virtual`: `1` if the shell is a virtual TTY, empty if not
- `dotfiles_xorg`: `1` if the environment is the xorg window manager, empty if not

## Functions

Dotfiles provides some utility functions for loading modules

- `dbackup(path)`: Backs up the given path to path.bak if it exists. Does not
   back up symbolic links.
- `dcheck(command)`: Checks if `command` is available. Returns a 0 code if it is.
- `dcolors()`: Sets color code variables like `dred`, `dcyan`, `ddefault`, etc.
- `dconfig(name)`: Uses `dload` to load configuration files in the `config` directory
- `denv()`: Sets the dotfiles\_\* variables described above
- `devent(name)`: Runs the `name` event. If the `devent_<name>` variable is an array
  of module names, those modules will be loaded. See `config/modules.sh`
- `dinstall(source, name, dest)`: When `source` is a path, copies `$source` and `$source.sh`
  to `dest` and renames it to `name`. Used for installing config files.
- `dload(path)`: Provides the `.sh`, then directory loading sequence as used in each
  module load stage
- `dmodload(name)`: Loads the `name` module. Does nothing if the module is
   already loaded.
- `drecommend(command)`: If command is not installed, prints a recommendation.
- `dremove(path)`: Backs up and removes the file or directory at `path`.
- `drequire(command)`: If command is not installed, prints an error and exits.
- `dsymlink(target, link)`: Creates a symbolic link from the path `link` to
  `target`. If link exists, it is backed up. `target` is a relative path from
  `$DOTFILES_PATH`.

[Licensed](LICENSE.txt) under the MIT License.
