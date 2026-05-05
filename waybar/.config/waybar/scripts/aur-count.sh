#!/bin/bash

# Count installed packages
aur_count=$(pacman -Qmq | wc -l)
total=$((aur_count))

# Count updates (official + AUR via yay)
updates=$(yay -Qua 2>/dev/null | wc -l)

# Decide class (for coloring)
if [ "$updates" -gt 0 ]; then
    class="updates"
else
    class="updated"
fi

# Output JSON
echo "{\"text\": \"$total\", \"tooltip\": \"Installed: $aur_count\nUpdates: $updates\", \"class\": \"$class\"}"