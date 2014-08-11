# ~/.environment

# The path to the .dotfiles directory
export DOTFILE_PATH=$HOME/.dotfiles

# Run the setup script
[ -f "$DOTFILE_PATH/run.sh"] && . "$DOTFILE_PATH/run.sh"