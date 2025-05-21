#!/usr/bin/bash

# This is the only file that you download initially
# You run it as "bash rebuild_dot.sh | tee -a rebuild.log".
# Then it will download your favourite apps and config
# files for tmux and neovim and powerline.

not_installed() {
    if command -v $1 2>&1 >/dev/null; then
    	return 1
    else
    	return 0
    fi
}

is_installed() {
    if command -v $1 2>&1 >/dev/null; then
    	return 0
    else
    	return 1
    fi    
}

execute_command() {
    printf "\n\t-> -> -> -> Executing -> $1 "
    eval "$1"
    if [ $? -eq 0 ]; then
        printf "\n\t-> -> -> -> $1 -> successful"
    else
        printf "\n\t-> -> -> -> $1 -> FAILED !!!"
    fi
}

install_if_missing() {
    if not_installed $1
    then
        execute_command "$cmd $1"
    else
	printf "\n\t-> -> -> -> $1 already installed"
    fi
}

delete_folder() {
if test -d $1; then
  printf "\n\tdeleting $1"
  rm -rf $1
fi
}

export PATH=$PATH:$HOME/.local/bin
cmd=""

if is_installed pacman
then
    cmd="sudo pacman -Syu --noconfirm"
    extension="arch"
fi

if is_installed apt-get
then
    cmd="sudo apt-get install -y"
    extension="debian"
    sudo apt-get update
fi

printf "\n-> -> -> -> -> -> -> Distro is $extension based."

printf "\n-> -> -> -> -> -> -> Trying to install git and curl"
for app in git curl;
do
    install_if_missing $app
done

delete_folder $HOME/tempInstall
git clone https://github.com/npquintos/FreshLinuxInstall.git $HOME/tempInstall

printf "\n-> -> -> -> -> -> -> Copying the dot files ..."
for conf in $(ls $HOME/tempInstall/Dots/.*);
do
    printf "\n\tcopying $conf"
    cp $conf $HOME/.
done

printf "\n-> -> -> -> -> -> -> Updating .bashrc to recognize tmx and tmuxn"
cat $HOME/tempInstall/Dots/bashrc >> $HOME/.bashrc

printf "\n-> -> -> -> -> -> -> Trying to install favourite apps"
file="$HOME/tempInstall/Apps/apps.$extension"
grep -v '^#' < "$file" |
{
while IFS= read -r line; 
do
    install_if_missing $line
done;
}
printf "\n-> -> -> -> -> -> -> Downloading latest version of NeoVim"
execute_command "curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.appimage"
chmod u+x nvim-linux-x86_64.appimage
execute_command "sudo ln -s $HOME/nvim-linux-x86_64.appimage /usr/bin/nvim"

printf "\n-> -> -> -> -> -> -> Trying to install nerd fonts ComicShannsMono..."
FONTURL1="https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/FiraCode.zip"
FONTURL2="https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/ComicShannsMono.zip"
FONTURL3="https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/DaddyTimeMono.zip"
# Create a temporary directory
TEMP_DIR=$(mktemp -d)

# Download the font zip file
for font_url in $FONTURL1 $FONTURL2 $FONTURL3;
do
    wget -O "$TEMP_DIR/font.zip" "$font_url"
    
    # Unzip the font file
    unzip "$TEMP_DIR/font.zip" -d "$TEMP_DIR"
done

# Move the font files to the system fonts directory
sudo mv "$TEMP_DIR"/*.{ttf,otf} /usr/local/share/fonts/

# Update the font cache
execute_command "fc-cache -f -v"

printf "\n-> -> -> -> -> -> -> Installing tree-sitter-cli"
execute_command "npm install tree-sitter-cli"

printf "\n-> -> -> -> -> -> -> Trying to install oh-my-posh"
execute_command "curl -s https://ohmyposh.dev/install.sh | bash -s"

printf "\n-> -> -> -> -> -> -> Cleaning up previous Astronvim configuration ..."
delete_folder $HOME/.config/nvim
delete_folder $HOME/.local/share/nvim
delete_folder $HOME/.local/state/nvim
delete_folder $HOME/.cache/nvim

printf "\n-> -> -> -> -> -> -> Copying Astronvim configuration ..."
execute_command "git clone https://github.com/npquintos/AstroNvimV5.git $HOME/.config/nvim"


printf "\n-> -> -> -> -> -> -> Cleaning up ..."
execute_command "rm -rf $HOME/tempInstall"

nvim
printf "\n-> -> -> -> -> -> -> Done. You are all set!"
