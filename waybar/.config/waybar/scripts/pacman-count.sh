#!/bin/bash

# Count installed packages
pacman_count=$(pacman -Qq | wc -l)
total=$((pacman_count))

# Count updates (official + AUR via yay)
updates=$(pacman -Qua 2>/dev/null | wc -l)

# Decide class (for coloring)
if [ "$updates" -gt 0 ]; then
    class="updates"
else
    class="updated"
fi

# Output JSON
echo "{\"text\": \"󰮯 $total\", \"tooltip\": \"Installed: $pacman_count\nUpdates: $updates\", \"class\": \"$class\"}"