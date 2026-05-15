#!/bin/bash

# ==============================================================================
# Terminal Colors & Formats
# ==============================================================================
GREEN='\033[0;32m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# ==============================================================================
# Core Engine - DO NOT MODIFY UNLESS YOU KNOW WHAT YOU ARE DOING
# ==============================================================================
declare -a TOOL_NAMES
declare -a TOOL_DESCS
declare -a TOOL_CMDS
declare -a TOOL_STOWS

# Function to add an item to the menu.
# Usage: add_tool "Name" "Description" "Commands to run" "Stow directory (optional)"
add_tool() {
    TOOL_NAMES+=("$1")
    TOOL_DESCS+=("$2")
    TOOL_CMDS+=("$3")
    TOOL_STOWS+=("$4")
}

# ==============================================================================
# REGISTRY: ADD YOUR TOOLS HERE
# ==============================================================================
# Add packages below. They will automatically appear in the menu!
# You can easily scale this by adding more `add_tool` lines.
# Example: add_tool "Tool Name" "What it does" "sudo pacman -S tool" "stow_folder"

add_tool "yay" "AUR helper" "sudo pacman -S --needed base-devel git --noconfirm && git clone https://aur.archlinux.org/yay.git /tmp/yay && cd /tmp/yay && makepkg -si --noconfirm" ""
add_tool "brave" "Brave Browser" "yay -S brave-bin --noconfirm" ""
add_tool "stow" "GNU Stow (Symlink manager)" "sudo pacman -S stow --noconfirm" ""
add_tool "rofi" "Rofi application launcher" "sudo pacman -S rofi --noconfirm" "rofi"
add_tool "jetbrains-font" "Jetbrains Mono Nerd Font" "sudo pacman -S ttf-jetbrains-mono-nerd --noconfirm" ""
add_tool "unzip" "Unzip utility" "sudo pacman -S unzip --noconfirm" ""
add_tool "pokemon-colorscripts" "CLI Pokemon sprites" "yay -S pokemon-colorscripts --noconfirm" ""
add_tool "swww" "Wayland wallpaper daemon" "sudo pacman -S swww --noconfirm" ""
add_tool "vscode" "Visual Studio Code" "yay -S visual-studio-code-bin --noconfirm" ""
add_tool "spotify" "Spotify Launcher" "sudo pacman -S spotify-launcher --noconfirm" ""
add_tool "fcitx5-unikey" "Vietnamese Input Method" "sudo pacman -S fcitx5-im fcitx5-unikey --noconfirm" ""
add_tool "easyeffects-presets" "EasyEffects Audio Presets" "bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/JackHack96/EasyEffects-Presets/master/install.sh)\"" ""
add_tool "postman" "dbgate-bin (Postman alternative)" "yay -S dbgate-bin --noconfirm" ""
add_tool "obsidian" "Obsidian Note Taking" "sudo pacman -S obsidian --noconfirm" ""
add_tool "brightnessctl" "Brightness Control" "sudo pacman -S brightnessctl --noconfirm" ""
add_tool "screenshot-tools" "Grim, Slurp, wl-clipboard..." "sudo pacman -S grim slurp wl-clipboard libcanberra notification-daemon --noconfirm" "screenshot"
add_tool "java-21" "Java 21 OpenJDK" "sudo pacman -S jdk21-openjdk --noconfirm" ""
add_tool "gnome-keyring" "Gnome Keyring & Secrets" "sudo pacman -S gnome-keyring libsecret seahorse --noconfirm" ""
add_tool "neofetch" "Neofetch" "yay -S neofetch --noconfirm" ""
add_tool "nodejs" "NodeJS & NPM" "sudo pacman -S nodejs npm --noconfirm" ""
add_tool "wireguard" "Wireguard Tools" "sudo pacman -S wireguard-tools --noconfirm" ""
add_tool "hyprpicker" "Wayland color picker" "sudo pacman -S hyprpicker --noconfirm" ""
add_tool "fastfetch" "Fastfetch" "sudo pacman -S fastfetch --noconfirm" ""
add_tool "jetbrains-toolbox" "Jetbrains Toolbox" "yay -S jetbrains-toolbox --noconfirm" ""
add_tool "dotnet-sdk" ".NET 8.0 SDK" "sudo pacman -S dotnet-sdk-8.0 --noconfirm" ""
add_tool "dotnet-runtime" ".NET 8.0 Runtime" "sudo pacman -S dotnet-runtime-8.0 --noconfirm" ""
add_tool "aspnet-core" "ASP.NET 8.0 Core" "sudo pacman -S aspnet-runtime-8.0 --noconfirm" ""
add_tool "docker" "Docker & Docker Compose" "sudo pacman -S docker docker-compose docker-buildx --noconfirm && sudo systemctl enable --now docker.service && sudo usermod -aG docker \$USER && newgrp docker" ""
add_tool "mdns-fix" "Fix Disable mDNS for .local" "sudo mkdir -p /etc/systemd/resolved.conf.d && echo -e '[Resolve]\nMulticastDNS=no\nLLMNR=no' | sudo tee /etc/systemd/resolved.conf.d/mdns-fix.conf > /dev/null && sudo systemctl restart systemd-resolved && (sudo wg-quick down HomeLab || true) && (sudo wg-quick up HomeLab || true)" ""
add_tool "libreoffice" "LibreOffice Fresh" "sudo pacman -S libreoffice-fresh --noconfirm" ""
add_tool "antigravity" "Antigravity CLI" "yay -S antigravity --noconfirm" ""
add_tool "emoji-fonts" "Noto Emoji, DejaVu, Liberation" "sudo pacman -S noto-fonts-emoji ttf-dejavu ttf-liberation --noconfirm && fc-cache -fv" ""

# Adding extra dotfiles setup (that only require stow)
add_tool "stow-hypr" "Stow Hyprland config" "" "hypr"
add_tool "stow-kitty" "Stow Kitty terminal config" "" "kitty"
add_tool "stow-nano" "Stow Nano config" "" "nano"
add_tool "stow-poshthemes" "Stow PoshThemes" "" "poshthemes"
add_tool "stow-swaync" "Stow SwayNC config" "" "swaync"
add_tool "stow-tmux" "Stow Tmux config" "" "tmux"
add_tool "stow-wallpapers" "Stow Wallpapers" "" "wallpapers"
add_tool "stow-waybar" "Stow Waybar config" "" "waybar"
add_tool "stow-zsh" "Stow ZSH config" "" "zsh"

# ==============================================================================
# UI & Logic Functions
# ==============================================================================
print_header() {
    clear
    echo -e "${BLUE}${BOLD}======================================================================${NC}"
    echo -e "${CYAN}${BOLD}                 Automated Package & Dotfile Installer                ${NC}"
    echo -e "${BLUE}${BOLD}======================================================================${NC}"
    echo -e "Choose an option by entering its number, or 'q' to quit.\n"
}

run_stow() {
    local stow_dir="$1"
    if [ -n "$stow_dir" ]; then
        if [ -d "$stow_dir" ]; then
            echo -e "${YELLOW}Running stow for '$stow_dir'...${NC}"
            stow "$stow_dir"
            echo -e "${GREEN}Stow setup complete for $stow_dir.${NC}"
        else
            echo -e "${RED}Warning: Stow directory '$stow_dir' not found in current location.${NC}"
        fi
    fi
}

show_menu() {
    print_header
    local count=${#TOOL_NAMES[@]}
    
    # Calculate half to split into two columns for better visibility
    local half=$(( (count + 1) / 2 ))
    
    for (( i=0; i<$half; i++ )); do
        local j=$((i + half))
        
        local left_num=$(printf "%2d" $((i + 1)))
        local left_name="${TOOL_NAMES[$i]}"
        
        if [ $j -lt $count ]; then
            local right_num=$(printf "%2d" $((j + 1)))
            local right_name="${TOOL_NAMES[$j]}"
            printf " ${GREEN}${BOLD}%s)${NC} %-30s | ${GREEN}${BOLD}%s)${NC} %-30s\n" "$left_num" "$left_name" "$right_num" "$right_name"
        else
            printf " ${GREEN}${BOLD}%s)${NC} %-30s |\n" "$left_num" "$left_name"
        fi
    done
    
    echo -e "\n ${GREEN}${BOLD} a)${NC} Install & Stow ALL"
    echo -e " ${GREEN}${BOLD} q)${NC} Quit\n"
}

process_choice() {
    local choice="$1"
    
    if [[ "$choice" == "q" || "$choice" == "Q" ]]; then
        echo -e "${GREEN}Exiting. Have a great day!${NC}"
        exit 0
    elif [[ "$choice" == "a" || "$choice" == "A" ]]; then
        echo -e "${CYAN}${BOLD}You selected to install ALL packages and stow ALL configs.${NC}"
        read -p "Are you sure you want to proceed? (y/n): " confirm
        if [[ "$confirm" == "y" || "$confirm" == "Y" ]]; then
            for (( i=0; i<${#TOOL_NAMES[@]}; i++ )); do
                echo -e "\n${BLUE}${BOLD}--- Processing: ${TOOL_NAMES[$i]} ---${NC}"
                if [ -n "${TOOL_CMDS[$i]}" ]; then
                    eval "${TOOL_CMDS[$i]}"
                fi
                run_stow "${TOOL_STOWS[$i]}"
            done
            echo -e "\n${GREEN}${BOLD}All installations and stows completed!${NC}"
            read -n 1 -s -r -p "Press any key to return to menu..."
        fi
        return
    fi
    
    # Check if choice is a valid number
    if ! [[ "$choice" =~ ^[0-9]+$ ]] || [ "$choice" -lt 1 ] || [ "$choice" -gt ${#TOOL_NAMES[@]} ]; then
        echo -e "${RED}Invalid option. Please try again.${NC}"
        sleep 1
        return
    fi
    
    local idx=$((choice - 1))
    local name="${TOOL_NAMES[$idx]}"
    local desc="${TOOL_DESCS[$idx]}"
    local cmds="${TOOL_CMDS[$idx]}"
    local stow_dir="${TOOL_STOWS[$idx]}"
    
    echo -e "\n${BLUE}${BOLD}You selected: ${name}${NC}"
    echo -e "${CYAN}Description : ${desc}${NC}"
    if [ -n "$cmds" ]; then
        echo -e "${YELLOW}Command(s)  : ${cmds}${NC}"
    fi
    if [ -n "$stow_dir" ]; then
        echo -e "${YELLOW}Stow Config : ./${stow_dir} -> ~/${NC}"
    fi
    
    echo -e "\n${RED}Do you want to proceed with this installation? (y/n)${NC}"
    read -p "> " confirm
    
    if [[ "$confirm" == "y" || "$confirm" == "Y" ]]; then
        echo -e "\n${GREEN}Starting...${NC}"
        if [ -n "$cmds" ]; then
            eval "$cmds"
            if [ $? -ne 0 ]; then
                echo -e "${RED}Warning: Command finished with errors.${NC}"
            fi
        fi
        run_stow "$stow_dir"
        echo -e "\n${GREEN}${BOLD}Done processing ${name}.${NC}"
    else
        echo -e "${YELLOW}Aborted.${NC}"
    fi
    
    echo -e "\nPress any key to return to the menu..."
    read -n 1 -s -r
}

# ==============================================================================
# Main Loop
# ==============================================================================
# Change to script directory so stow works correctly
cd "$(dirname "$0")" || exit

while true; do
    show_menu
    read -p "Select an option: " user_choice
    process_choice "$user_choice"
done