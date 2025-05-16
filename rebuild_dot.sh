#!/usr/bin/bash

# This is the only file that you download initially
# You run it as "bash rebuild_dot.sh".
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

install_if_missing() {
    if not_installed $1
    then
        eval "$cmd $1"
    else
	echo "$1 already installed"
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
fi

echo "Distro is $extension based."

echo "Trying to install git and curl"
for app in git curl;
do
    install_if_missing $app
done

git clone https://github.com/npquintos/FreshLinuxInstall.git $HOME/tempInstall

echo "Copying the dot files ..."
for conf in $(ls $HOME/tempInstall/Dots/.*);
do
    cp $conf $HOME/.
done

echo "Updating .bashrc to recognize tmx and tmuxn"
cat $HOME/tempInstall/Dots/bashrc >> $HOME/.bashrc

echo "Trying to install favourite apps"
file="$HOME/tempInstall/Apps/apps.$extension"
grep -v '^#' < "$file" |
{
while IFS= read -r line; 
do
    install_if_missing $line
done;
}

echo "Trying to install nerd fonts ComicShannsMono..."
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
fc-cache -f -v

echo "Trying to install oh-my-posh"
curl -s https://ohmyposh.dev/install.sh | bash -s

echo "Copying Astronvim configuration ..."
git clone https://github.com/npquintos/AstroNvimV5.git $HOME/.config/nvim
nvim

echo "Cleaning up ..."
rm -rf tempInstall

echo "Done. You are all set!"
