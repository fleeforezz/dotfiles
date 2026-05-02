#!/usr/bin/env bash

# ~/.config/rofi/waybar-switcher/waybar-switcher.sh

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WAYBAR_DIR="$HOME/.config/waybar"
COLORS_DIR="$WAYBAR_DIR/colors"
STATE_FILE="$HOME/.cache/waybar_state"
ROFI_THEME="$SCRIPT_DIR/style.rasi"

# ── Load last state ──────────────────────────────────────────────────────────
[[ -f "$STATE_FILE" ]] && source "$STATE_FILE"
CURRENT_CONFIG_NAME=$(basename "${SAVED_CONFIG:-}" .jsonc 2>/dev/null)
CURRENT_THEME_NAME=$(basename "${SAVED_STYLE:-}" .css 2>/dev/null)

# ── Validate ─────────────────────────────────────────────────────────────────
if [[ ! -d "$WAYBAR_DIR" ]]; then
    notify-send "Waybar Switcher" "Directory not found: $WAYBAR_DIR" --icon=dialog-error
    exit 1
fi
if [[ ! -d "$COLORS_DIR" ]]; then
    notify-send "Waybar Switcher" "Directory not found: $COLORS_DIR" --icon=dialog-error
    exit 1
fi
if [[ ! -f "$ROFI_THEME" ]]; then
    notify-send "Waybar Switcher" "Theme not found: $ROFI_THEME" --icon=dialog-error
    exit 1
fi

# ── List builders ────────────────────────────────────────────────────────────
layout_list() {
    while IFS= read -r f; do
        name=$(basename "$f" .jsonc)
        if [[ "$name" == "$CURRENT_CONFIG_NAME" ]]; then
            printf "  %s  ●\n" "$name"
        else
            printf "  %s\n" "$name"
        fi
    done < <(find "$WAYBAR_DIR" -maxdepth 1 -name "*.jsonc" | sort)
}

theme_list() {
    while IFS= read -r f; do
        name=$(basename "$f" .css)
        if [[ "$name" == "$CURRENT_THEME_NAME" ]]; then
            printf "󰏘  %s  ●\n" "$name"
        else
            printf "󰏘  %s\n" "$name"
        fi
    done < <(find "$COLORS_DIR" -maxdepth 1 -name "*.css" ! -name "*.bak" | sort)
}

# More robust: just strip known prefix patterns
clean() {
    local s="$1"
    s="${s#  }"        # strip layout prefix
    s="${s#󰏘  }"      # strip theme prefix  
    s="${s%  ●}"       # strip active marker
    printf '%s' "$s" | xargs
}

pick() {
    rofi -dmenu \
        -theme "$ROFI_THEME" \
        -i \
        -p "$1" \
        -mesg "$2"
}

# ── Step 1: Layout ───────────────────────────────────────────────────────────
chosen_layout_label=$(layout_list | pick \
    "󰀂  Layout" \
    "1 / 2  —  Select waybar layout  |  current: ${CURRENT_CONFIG_NAME:-none}")
[[ -z "$chosen_layout_label" ]] && exit 0

chosen_layout_name=$(clean "$chosen_layout_label")
chosen_config=$(find "$WAYBAR_DIR" -maxdepth 1 -name "${chosen_layout_name}.jsonc" | head -1)

if [[ -z "$chosen_config" ]]; then
    notify-send "Waybar Switcher" "Config not found: ${chosen_layout_name}.jsonc" --icon=dialog-error
    exit 1
fi

# ── Step 2: Theme ─────────────────────────────────────────────────────────────
chosen_theme_label=$(theme_list | pick \
    "󰏘  Theme" \
    "2 / 2  —  Select color theme  |  current: ${CURRENT_THEME_NAME:-none}")
[[ -z "$chosen_theme_label" ]] && exit 0

chosen_theme_name=$(clean "$chosen_theme_label")
chosen_theme=$(find "$COLORS_DIR" -maxdepth 1 -name "${chosen_theme_name}.css" | head -1)

if [[ -z "$chosen_theme" ]]; then
    notify-send "Waybar Switcher" "Theme not found: ${chosen_theme_name}.css" --icon=dialog-error
    exit 1
fi

# ── Apply ─────────────────────────────────────────────────────────────────────
ln -sf "$chosen_theme" "$WAYBAR_DIR/style.css"
pkill waybar
sleep 0.3
waybar -c "$chosen_config" -s "$WAYBAR_DIR/style.css" &

# ── Persist ───────────────────────────────────────────────────────────────────
mkdir -p "$(dirname "$STATE_FILE")"
printf 'SAVED_CONFIG="%s"\nSAVED_STYLE="%s"\n' "$chosen_config" "$chosen_theme" > "$STATE_FILE"

notify-send "Waybar Switcher" \
    "Layout: <b>$chosen_layout_name</b>\nTheme: <b>$chosen_theme_name</b>" \
    --icon=preferences-desktop --expire-time=3000