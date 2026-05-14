#!/bin/bash

# ┏━━━┳━━┳━┓┏━┳━━━┳┓╋╋┏━━┳━┓┏━┓
# ┗┓┏┓┣┫┣┫┃┗┛┃┃┏━━┫┃╋╋┗┫┣┻┓┗┛┏┛
# ╋┃┃┃┃┃┃┃┏┓┏┓┃┗━━┫┃╋╋╋┃┃╋┗┓┏┛
# ╋┃┃┃┃┃┃┃┃┃┃┃┃┏━━┫┃╋┏┓┃┃╋┏┛┗┓
# ┏┛┗┛┣┫┣┫┃┃┃┃┃┃╋╋┃┗━┛┣┫┣┳┛┏┓┗┓
# ┗━━━┻━━┻┛┗┛┗┻┛╋╋┗━━━┻━━┻━┛┗━┛
# Modified for better unstable connection handling

SESSION_TYPE="$XDG_SESSION_TYPE"
WIFI_DEV=$(nmcli -t -f DEVICE,TYPE device | grep ':wifi' | cut -d: -f1 | head -1)
ENABLED_COLOR="#A3BE8C"
DISABLED_COLOR="#D35F5E"
SIGNAL_ICONS=("󰤟 " "󰤢 " "󰤥 " "󰤨 ")
SECURED_SIGNAL_ICONS=("󰤡" "󰤤" "󰤧" "󰤪")
WIFI_CONNECTED_ICON=" "
ETHERNET_CONNECTED_ICON=" "
ROFI_THEME="$HOME/.config/rofi/rofi-network-manager/style.rasi"

# ─── VPN ────────────────────────────────────────────────────────────────────

VPN_INTERFACE="HomeLab"
VPN_CONNECTED_ICON="󰍁"
VPN_DISCONNECTED_ICON="󰿇"

# ─── Helpers ────────────────────────────────────────────────────────────────

get_connected_wifi() {
    nmcli -t -f ACTIVE,SSID dev wifi | grep '^yes:' | cut -d: -f2
}

get_signal_icon() {
    local signal=$1 security=$2
    local level=$(( signal / 25 ))
    [[ $level -gt 3 ]] && level=3
    if [[ "$security" =~ WPA|WEP ]]; then
        echo "${SECURED_SIGNAL_ICONS[$level]}"
    else
        echo "${SIGNAL_ICONS[$level]}"
    fi
}

# ─── VPN Helpers ────────────────────────────────────────────────────────────

vpn_connected() {
    ip link show "$VPN_INTERFACE" &>/dev/null
}

toggle_vpn() {
    if vpn_connected; then
        if sudo wg-quick down "$VPN_INTERFACE"; then
            notify-send "WireGuard" "VPN disconnected." --icon=network-vpn-disconnected
        else
            notify-send "WireGuard" "Failed to disconnect VPN." --icon=dialog-error
        fi
    else
        if sudo wg-quick up "$VPN_INTERFACE"; then
            notify-send "WireGuard" "VPN connected." --icon=network-vpn
        else
            notify-send "WireGuard" "Failed to connect VPN." --icon=dialog-error
        fi
    fi
}

# ─── Statusbar output ───────────────────────────────────────────────────────

get_status() {
    local eth_dev wifi_dev status_icon status_color text

    while [[ $# -gt 0 ]]; do
        case $1 in
            --enabled-color)  ENABLED_COLOR="$2";  shift 2 ;;
            --disabled-color) DISABLED_COLOR="$2"; shift 2 ;;
            *) shift ;;
        esac
    done

    eth_dev=$(nmcli -t -f DEVICE,TYPE,STATE device | grep ':ethernet:connected' | cut -d: -f1 | head -1)
    wifi_dev=$(nmcli -t -f DEVICE,TYPE,STATE device | grep ':wifi:connected' | cut -d: -f1 | head -1)

    local vpn_icon=""
    vpn_connected && vpn_icon=" $VPN_CONNECTED_ICON"

    if [[ -n "$eth_dev" ]]; then
        status_icon="󰈀"
        status_color=$ENABLED_COLOR
        text="Wired($eth_dev)$vpn_icon"
    elif [[ -n "$wifi_dev" ]]; then
        local wifi_info signal security ssid signal_icon
        wifi_info=$(nmcli --terse --fields IN-USE,SIGNAL,SECURITY,SSID device wifi list --rescan no | grep '^\*')
        IFS=: read -r _ signal security ssid <<< "$wifi_info"
        signal_icon=$(get_signal_icon "$signal" "$security")
        status_icon="$signal_icon"
        status_color=$ENABLED_COLOR
        text="$ssid$vpn_icon"
    else
        status_icon=""
        status_color=$DISABLED_COLOR
        text="Disconnected"
    fi

    if [[ "$SESSION_TYPE" == "wayland" ]]; then
        echo "<span color=\"$status_color\">$status_icon $text</span>"
    else
        echo "%{F$status_color}$status_icon $text%{F-}"
    fi
}

# ─── Wi-Fi toggle ───────────────────────────────────────────────────────────

toggle_wifi() {
    local wifi_status
    wifi_status=$(nmcli -fields WIFI g)
    if [[ "$wifi_status" =~ "enabled" ]]; then
        nmcli radio wifi off && notify-send "Wi-Fi" "Wi-Fi has been disabled." --icon=network-wireless-offline
    else
        nmcli radio wifi on  && notify-send "Wi-Fi" "Wi-Fi has been enabled." --icon=network-wireless
    fi
}

# ─── Connect with retry ─────────────────────────────────────────────────────

# connect_wifi() {
#     local ssid="$1"
#     local max_attempts=3
#     local attempt=1
#     local saved_connections
#     saved_connections=$(nmcli -g NAME connection show)

#     while [[ $attempt -le $max_attempts ]]; do
#         notify-send "Wi-Fi" "Connecting to \"$ssid\"... (attempt $attempt/$max_attempts)" --icon=network-wireless

#         if echo "$saved_connections" | grep -Fxq "$ssid"; then
#             # Known network — just bring it up
#             if nmcli connection up id "$ssid" 2>/dev/null | grep -q "successfully"; then
#                 notify-send "Connected" "Successfully connected to \"$ssid\"." --icon=network-wireless
#                 return 0
#             fi
#         else
#             # New network — ask for password once on first attempt
#             if [[ $attempt -eq 1 ]]; then
#                 wifi_password=$(rofi -dmenu -theme "$ROFI_THEME" -p "Wi-Fi Password: " -password)
#                 [[ -z "$wifi_password" ]] && return 1
#             fi
#             if nmcli device wifi connect "$ssid" password "$wifi_password" 2>/dev/null | grep -q "successfully"; then
#                 notify-send "Connected" "Successfully connected to \"$ssid\"." --icon=network-wireless
#                 return 0
#             fi
#         fi

#         attempt=$(( attempt + 1 ))
#         [[ $attempt -le $max_attempts ]] && sleep 2
#     done

#     notify-send "Connection Failed" "Could not connect to \"$ssid\" after $max_attempts attempts." --icon=network-error
#     return 1
# }

connect_wifi() {
    local ssid="$1"

    # Detect security type
    local security
    security=$(nmcli -t -f SSID,SECURITY device wifi list | \
        grep "^${ssid}:" | head -1 | cut -d: -f2)

    # ─────────────────────────────────────────
    # Enterprise Wi-Fi
    # ─────────────────────────────────────────
    if [[ "$security" =~ WPA2-ENTERPRISE|802.1X ]]; then

        local username password

        username=$(rofi -dmenu -theme "$ROFI_THEME" \
            -p "Username:")
        [[ -z "$username" ]] && return 1

        password=$(rofi -dmenu -theme "$ROFI_THEME" \
            -p "Password:" -password)
        [[ -z "$password" ]] && return 1

        notify-send "Wi-Fi" "Connecting to enterprise network..."

        nmcli connection delete "$ssid" 2>/dev/null

        nmcli connection add \
            type wifi \
            con-name "$ssid" \
            ifname "$WIFI_DEV" \
            ssid "$ssid"

        nmcli connection modify "$ssid" \
            wifi-sec.key-mgmt wpa-eap \
            802-1x.eap peap \
            802-1x.identity "$username" \
            802-1x.password "$password" \
            802-1x.phase2-auth mschapv2

        if nmcli connection up "$ssid"; then
            notify-send "Connected" \
                "Connected to enterprise Wi-Fi \"$ssid\"."
            return 0
        else
            notify-send "Failed" \
                "Could not connect to \"$ssid\"."
            return 1
        fi
    fi

    # ─────────────────────────────────────────
    # Normal WPA/WPA2 network
    # ─────────────────────────────────────────

    local wifi_password
    wifi_password=$(rofi -dmenu -theme "$ROFI_THEME" \
        -p "Wi-Fi Password:" -password)

    [[ -z "$wifi_password" ]] && return 1

    if nmcli device wifi connect "$ssid" password "$wifi_password"; then
        notify-send "Connected" "Connected to \"$ssid\"."
    else
        notify-send "Failed" "Could not connect."
    fi
}

# ─── Manage Wi-Fi ───────────────────────────────────────────────────────────

manage_wifi() {
    notify-send "Wi-Fi" "Scanning for available networks..." --icon=network-wireless

    # Rescan to get fresh results (important for unstable environments)
    nmcli device wifi rescan 2>/dev/null
    sleep 1

    nmcli --terse --fields "IN-USE,SIGNAL,SECURITY,SSID" device wifi list --rescan no > /tmp/wifi_list.txt

    local -A seen_ssids
    local ssids=()
    local formatted_ssids=()
    local active_ssid
    active_ssid=$(get_connected_wifi)

    while IFS=: read -r in_use signal security ssid; do
        [[ -z "$ssid" ]] && continue
        [[ -n "${seen_ssids[$ssid]}" ]] && continue
        seen_ssids[$ssid]=1

        local signal_icon
        signal_icon=$(get_signal_icon "$signal" "$security")

        local formatted="$signal_icon $ssid"
        if [[ "$ssid" == "$active_ssid" ]]; then
            formatted="$WIFI_CONNECTED_ICON $formatted"
        fi

        ssids+=("$ssid")
        formatted_ssids+=("$formatted")
    done < /tmp/wifi_list.txt

    rm -f /tmp/wifi_list.txt

    if [[ ${#ssids[@]} -eq 0 ]]; then
        notify-send "Wi-Fi" "No networks found." --icon=network-error
        return
    fi

    local formatted_list
    formatted_list=$(printf "%s\n" "${formatted_ssids[@]}")

    # Show all available networks
    local chosen_network
    chosen_network=$(echo "$formatted_list" | rofi -dmenu -theme "$ROFI_THEME" -i -p "")
    [[ -z "$chosen_network" ]] && return

    # Find matching SSID
    local chosen_id=""
    for i in "${!formatted_ssids[@]}"; do
        if [[ "${formatted_ssids[$i]}" == "$chosen_network" ]]; then
            chosen_id="${ssids[$i]}"
            break
        fi
    done
    [[ -z "$chosen_id" ]] && return

    # ── Confirmation / Action dialog ──────────────────────────────────────
    local action_prompt
    if [[ "$chosen_id" == "$active_ssid" ]]; then
        # Already connected — offer disconnect or forget
        action_prompt=$(echo -e "  Disconnect\n  Forget Network" \
            | rofi -dmenu -theme "$ROFI_THEME" -p "\"$chosen_id\": ")
    else
        # Not connected — confirm before connecting
        action_prompt=$(echo -e "󰸋  Connect to \"$chosen_id\"\n  Forget Network" \
            | rofi -dmenu -theme "$ROFI_THEME" -p "What would you like to do? ")
    fi

    case "$action_prompt" in
        "󰸋  Connect to \"$chosen_id\"")
            connect_wifi "$chosen_id"
            ;;
        "  Disconnect")
            nmcli device disconnect "$WIFI_DEV" \
                && notify-send "Disconnected" "You have been disconnected from \"$chosen_id\"." --icon=network-wireless-offline
            ;;
        "  Forget Network")
            nmcli connection delete id "$chosen_id" 2>/dev/null \
                && notify-send "Forgotten" "Network \"$chosen_id\" has been removed." --icon=dialog-information
            ;;
    esac
}

# ─── Manage Ethernet ────────────────────────────────────────────────────────

manage_ethernet() {
    local eth_devices
    eth_devices=$(nmcli device status | grep ethernet | awk '{print $1}')
    if [[ -z "$eth_devices" ]]; then
        notify-send "Error" "No Ethernet device found." --icon=network-error
        return
    fi

    local eth_list=""
    for dev in $eth_devices; do
        local dev_status
        dev_status=$(nmcli device status | grep "$dev" | awk '{print $3}')
        if [[ "$dev_status" == "connected" ]]; then
            eth_list+="$ETHERNET_CONNECTED_ICON$dev\n"
        else
            eth_list+="$dev\n"
        fi
    done

    local chosen_device
    chosen_device=$(echo -e "$eth_list" | rofi -dmenu -theme "$ROFI_THEME" -i -p "Select Ethernet Device: ")
    [[ -z "$chosen_device" ]] && return

    chosen_device=$(echo "$chosen_device" | sed "s/$ETHERNET_CONNECTED_ICON//")
    local device_status
    device_status=$(nmcli device status | grep "$chosen_device" | awk '{print $3}')

    if [[ "$device_status" == "connected" ]]; then
        nmcli device disconnect "$chosen_device" \
            && notify-send "Disconnected" "Disconnected from $chosen_device." --icon=network-wired-disconnected
    elif [[ "$device_status" == "disconnected" ]]; then
        nmcli device connect "$chosen_device" \
            && notify-send "Connected" "Connected to $chosen_device." --icon=network-wired
    else
        notify-send "Error" "Unable to determine the status of $chosen_device." --icon=dialog-error
    fi
}

# ─── Main menu ──────────────────────────────────────────────────────────────

main_menu() {
    local status_mode=false

    while [[ $# -gt 0 ]]; do
        case $1 in
            --status)
                status_mode=true
                shift
                ;;
            --enabled-color)
                ENABLED_COLOR="$2"
                shift 2
                ;;
            --disabled-color)
                DISABLED_COLOR="$2"
                shift 2
                ;;
            *)
                shift
                ;;
        esac
    done

    if [[ $status_mode == true ]]; then
        get_status
        exit 0
    fi

    # Start NetworkManager if not running
    if ! pgrep -x "NetworkManager" > /dev/null; then
        local password
        password=$(rofi -dmenu -theme "$ROFI_THEME" -p "Root Password: " -password)
        echo "$password" | sudo -S systemctl start NetworkManager
    fi

    # Build main menu with Wi-Fi toggle button
    local wifi_status wifi_toggle wifi_toggle_command manage_wifi_btn
    wifi_status=$(nmcli -fields WIFI g)

    if [[ "$wifi_status" =~ "enabled" ]]; then
        wifi_toggle="󰤮  Disable Wi-Fi"
        wifi_toggle_command="off"
        manage_wifi_btn="\n  Manage Wi-Fi"
    else
        wifi_toggle="  Enable Wi-Fi"
        wifi_toggle_command="on"
        manage_wifi_btn=""
    fi

    # local chosen_option
    # chosen_option=$(echo -e "$wifi_toggle$manage_wifi_btn\n󰈀  Manage Ethernet" \
    #     | rofi -dmenu -theme "$ROFI_THEME" -p "")
    local vpn_option

    if vpn_connected; then
        vpn_option="$VPN_CONNECTED_ICON  Disconnect VPN"
    else
        vpn_option="$VPN_DISCONNECTED_ICON  Connect VPN"
    fi

    local chosen_option
    chosen_option=$(echo -e "$wifi_toggle$manage_wifi_btn\n󰈀  Manage Ethernet\n$vpn_option" \
        | rofi -dmenu -theme "$ROFI_THEME" -p "")

    case "$chosen_option" in
        "$wifi_toggle")
            nmcli radio wifi "$wifi_toggle_command"
            if [[ "$wifi_toggle_command" == "on" ]]; then
                notify-send "Wi-Fi" "Wi-Fi has been enabled." --icon=network-wireless
            else
                notify-send "Wi-Fi" "Wi-Fi has been disabled." --icon=network-wireless-offline
            fi
            ;;
        "  Manage Wi-Fi")
            manage_wifi
            ;;
        "󰈀  Manage Ethernet")
            manage_ethernet
            ;;
        "$VPN_CONNECTED_ICON  Disconnect VPN")
            toggle_vpn
            ;;
        "$VPN_DISCONNECTED_ICON  Connect VPN")
            toggle_vpn
            ;;
    esac
}

main_menu "$@"