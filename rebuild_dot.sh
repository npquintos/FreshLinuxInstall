#!/usr/bin/bash

# This is the only file that you download initially
# You run it as "sudo bash rebuild_dot.sh".
# Then it will download your favourite apps and config
# files for tmux and neovim and powerline.

is_already_installed() {
    if command -v $1 2>&1 >/dev/null
    then
	# echo "returning 0 for $1"
	return 0
    else
	# echo "returning 1 for $1"
	return 1
    fi
}

cmd=""

if is_already_installed pacman
then
    cmd="pacman -Syu"
    extension="arch"
fi
if is_already_installed apt-get
then
    cmd="apt-get install"
    extension="debian"
fi

echo "Distro is $extension based."

echo "Trying to install git and curl"
for app in git curl;
do
    if ! is_already_installed $app
    then
        eval "$cmd $line"
    else
	echo "$app already installed"
    fi
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
    if ! is_already_installed $line
      then
        eval "$cmd $line"
      else
	echo "$line already installed"
    fi
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
