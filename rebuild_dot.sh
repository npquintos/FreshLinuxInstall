#!/usr/bin/bash

# This is the only file that you download initially
# You run it as "sudo bash rebuild_dot.sh".
# Then it will download your favourite apps and config
# files for tmux and neovim and powerline.

not_installed() {
    return command -v $1 2>&1 >/dev/null
}

is_installed() {
    return ! not_installed $1
}

install_if_missing() {
    if not_installed $1
    then
        eval "$cmd $1"
    else
	echo "$1 already installed"
    fi
}

cmd=""

if is_installed pacman
then
    cmd="pacman -Syu"
    extension="arch"
fi

if is_installed apt-get
then
    cmd="apt-get install"
    extension="debian"
fi

echo "Distro is $extension based."

echo "Trying to install git and curl"
for app in git curl;
do
    install_if_missing $app
done

git clone https://github.com/npquintos/FreshLinuxInstall.git ~/tempInstall

echo "Copying the dot files ..."
for conf in $(ls ~/tempInstall/Dots/.*);
do
    cp $conf ~/.
done

echo "Trying to install favourite apps"
file="~/tempInstall/apps.$extension"
grep -v '^#' < "$file" |
{
while IFS= read -r line; 
do
    install_if_missing $line
done;
}

echo "Trying to install oh-my-posh"
curl -s https://ohmyposh.dev/install.sh | bash -s

echo "Copying Astronvim configuration ..."
git clone https://github.com/npquintos/AstroNvimV5.git ~/.config/nvim
nvim

echo "Cleaning up ..."
rm -rf tempInstall

echo "Done. You are all set!"
