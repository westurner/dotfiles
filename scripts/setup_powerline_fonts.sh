#!/bin/sh
# Install the Powerline-fonts

mkdir -p ~/.fonts
if [ ! -d "powerline-fonts" ]; then
    git clone https://github.com/Lokaltog/powerline-fonts
fi
cd powerline-fonts
if [ -d "$HOME/Library/Fonts" ]; then
    find . -name '*.ttf' -exec cp "{}" ~/Library/Fonts \;
    find . -name '*.otf' -exec cp "{}" ~/Library/Fonts \;
    open "/Applications/Font Book.app"
else
    find . -name '*.ttf' -exec cp "{}" ~/.fonts \;
    find . -name '*.otf' -exec cp "{}" ~/.fonts \;
    fc-cache -vf ~/.fonts
fi
