#!/bin/bash

# Install oh-my-zsh if not installed
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo "Installing Oh My Zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
else
    echo "Oh My Zsh is already installed."
fi 

# Install eza if not installed
if ! command -v eza &> /dev/null; then
    echo "Installing eza..."
    yay -S eza -y
else
    echo "eza is already installed."
fi

# Install Tmux if not installed
if ! command -v tmux &> /dev/null; then
    echo "Installing Tmux..."
    sudo pacman -S tmux -y
else
    echo "Tmux is already installed."
fi 

# Clone Tmux Plugin Manager if not installed
if [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
    echo "Installing Tmux Plugin Manager..."
    git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
else
    echo "Tmux Plugin Manager is already installed."
fi

# Install Spicetify-cli if not installed
if ! command -v spicetify &> /dev/null; then
    echo "Installing Spicetify-cli..."
    yay -S spicetify-cli -y
else
    echo "Spicetify-cli is already installed."
fi

# Install EasyEffects if not installed
if ! command -v easyeffects &> /dev/null; then
    echo "Installing EasyEffects..."
    sudo pacman -S easyeffects -y
else
    echo "EasyEffects is already installed."
fi

# Install waybar if not installed
if ! command -v waybar &> /dev/null; then
    echo "Installing waybar..."
    sudo pacman -S waybar -y
else
    echo "waybar is already installed."
fi

# Install swaybar if not installed
if ! command -v swaybar &> /dev/null; then
    echo "Installing swaybar..."
    sudo pacman -S swaybg swaybar -y
else
    echo "swaybar is already installed."
fi

# Install fcitx5 if not installed
if ! command -v fcitx5 &> /dev/null; then
    echo "Installing fcitx5..."
    sudo pacman -S fcitx5 fcitx5-configtool fcitx5-gtk fcitx5-qt fcitx5-unikey -y
else
    echo "fcitx5 is already installed."
fi 

echo "Installation script completed."