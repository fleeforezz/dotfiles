#!/bin/bash

# ┏━━━┳━━┳━┓┏━┳━━━┳┓╋╋┏━━┳━┓┏━┓
# ┗┓┏┓┣┫┣┫┃┗┛┃┃┏━━┫┃╋╋┗┫┣┻┓┗┛┏┛
# ╋┃┃┃┃┃┃┃┏┓┏┓┃┗━━┫┃╋╋╋┃┃╋┗┓┏┛
# ╋┃┃┃┃┃┃┃┃┃┃┃┃┏━━┫┃╋┏┓┃┃╋┏┛┗┓
# ┏┛┗┛┣┫┣┫┃┃┃┃┃┃╋╋┃┗━┛┣┫┣┳┛┏┓┗┓
# ┗━━━┻━━┻┛┗┛┗┻┛╋╋┗━━━┻━━┻━┛┗━┛
# The program was created by DIMFLIX
# Github: https://github.com/DIMFLIX-OFFICIAL


SESSION_TYPE="$XDG_SESSION_TYPE"
ENABLED_COLOR="#A3BE8C"
DISABLED_COLOR="#D35F5E"
SIGNAL_ICONS=("󰤟 " "󰤢 " "󰤥 " "󰤨 ")
SECURED_SIGNAL_ICONS=("󰤡" "󰤤" "󰤧" "󰤪")
WIFI_CONNECTED_ICON=" "
ETHERNET_CONNECTED_ICON=" "
ROFI_THEME="$HOME/.config/rofi/rofi-network-manager/style.rasi"  # ADD THIS LINE

SSID=$(get_connected_wifi)

get_connected_wifi() {
    nmcli -t -f ACTIVE,SSID dev wifi | grep '^yes:' | cut -d: -f2
}

get_status() {
    local eth_dev wifi_dev status_icon status_color text

    eth_dev=$(nmcli -t -f DEVICE,TYPE,STATE device | grep ':ethernet:connected' | cut -d: -f1)
    wifi_dev=$(nmcli -t -f DEVICE,TYPE,STATE device | grep ':wifi:connected' | cut -d: -f1)

    # Ethernet has priority
    if [[ -n "$eth_dev" ]]; then
        status_icon="󰈀"        # Ethernet icon
        status_color=$ENABLED_COLOR
        text="Wired($eth_dev) "

    elif [[ -n "$wifi_dev" ]]; then
        local wifi_info signal security ssid signal_icon signal_level

        wifi_info=$(nmcli --terse --fields IN-USE,SIGNAL,SECURITY,SSID device wifi list --rescan no | grep '^\*')
        IFS=: read -r _ signal security ssid <<< "$wifi_info"

        signal_level=$((signal / 25))
        signal_icon="${SIGNAL_ICONS[3]}"
        [[ "$signal_level" -lt "${#SIGNAL_ICONS[@]}" ]] && signal_icon="${SIGNAL_ICONS[$signal_level]}"

        [[ "$security" =~ WPA|WEP ]] && signal_icon="${SECURED_SIGNAL_ICONS[$signal_level]}"

        status_icon="$signal_icon"
        status_color=$ENABLED_COLOR
        text="$ssid"

    else
        status_icon=""
        status_color=$DISABLED_COLOR
        text="Disconnected"
    fi

    if [[ "$SESSION_TYPE" == "wayland" ]]; then
        echo "<span color=\"$status_color\">$status_icon $text </span>"
    else
        echo "%{F$status_color}$status_icon $text%{F-}"
    fi
}

manage_wifi() {
    nmcli --terse --fields "IN-USE,SIGNAL,SECURITY,SSID" device wifi list --rescan no > /tmp/wifi_list.txt

    local -A seen_ssids  # Use associative array to track seen SSIDs
    local ssids=()
    local formatted_ssids=()
    local active_ssid
    active_ssid=$(get_connected_wifi)

    while IFS=: read -r in_use signal security ssid; do
        if [ -z "$ssid" ]; then continue; fi
        
        # Skip if we've already seen this SSID
        if [[ -n "${seen_ssids[$ssid]}" ]]; then
            continue
        fi
        seen_ssids[$ssid]=1

        local signal_icon="${SIGNAL_ICONS[3]}"
        local signal_level=$((signal / 25))
        if [[ "$signal_level" -lt "${#SIGNAL_ICONS[@]}" ]]; then
            signal_icon="${SIGNAL_ICONS[$signal_level]}"
        fi

        if [[ "$security" =~ WPA || "$security" =~ WEP ]]; then
            signal_icon="${SECURED_SIGNAL_ICONS[$signal_level]}"
        fi

        # Add connection icon if network is active
        local formatted="$signal_icon $ssid"
        if [[ "$ssid" == "$active_ssid" ]]; then
            formatted="$WIFI_CONNECTED_ICON $formatted"
        fi
        
        ssids+=("$ssid")
        formatted_ssids+=("$formatted")
    done < /tmp/wifi_list.txt

    local formatted_list=""
    for formatted_ssid in "${formatted_ssids[@]}"; do
        formatted_list+="$formatted_ssid\n"
    done

    formatted_list=$(printf "%s" "$formatted_list")

    local chosen_network=$(echo -e "$formatted_list" | rofi -dmenu -theme "$ROFI_THEME" -i -selected-row 1 -p "Wi-Fi SSID: ")
    local ssid_index=-1
    for i in "${!formatted_ssids[@]}"; do
        if [[ "${formatted_ssids[$i]}" == "$chosen_network" ]]; then
            ssid_index=$i
            break
        fi
    done

    local chosen_id="${ssids[$ssid_index]}"

    if [ -z "$chosen_network" ]; then
        rm /tmp/wifi_list.txt
        return
    else
        # Check the state of the selected network
        local device_status=$(nmcli -t -f STATE device show wlan0 | grep STATE | cut -d: -f2)

        # Determine action based on network state
        local action
        if [[ "$chosen_id" == "$active_ssid" ]]; then
            action="  Disconnect"
        else
            action="󰸋  Connect"
        fi

        action=$(echo -e "$action\n  Forget" | rofi -dmenu -theme "$ROFI_THEME" -p "Action: ")
        case $action in
            "󰸋  Connect")
                local success_message="You are now connected to the Wi-Fi network \"$chosen_id\"."
                local saved_connections=$(nmcli -g NAME connection show)
                if [[ $(echo "$saved_connections" | grep -Fx "$chosen_id") ]]; then
                    nmcli connection up id "$chosen_id" | grep "successfully" && notify-send "Connection Established" "$success_message"
                else
                    local wifi_password=$(rofi -dmenu -theme "$ROFI_THEME" -p "Password: " -password)
                    nmcli device wifi connect "$chosen_id" password "$wifi_password" | grep "successfully" && notify-send "Connection Established" "$success_message"
                fi
                ;;
            "  Disconnect")
                nmcli device disconnect wlan0 && notify-send "Disconnected" "You have been disconnected from $chosen_id."
                ;;
            "  Forget")
                nmcli connection delete id "$chosen_id" && notify-send "Forgotten" "The network $chosen_id has been forgotten."
                ;;
        esac
    fi

    rm /tmp/wifi_list.txt
}

manage_ethernet() {
    local eth_devices=$(nmcli device status | grep ethernet | awk '{print $1}')
    if [ -z "$eth_devices" ]; then
        notify-send "Error" "Ethernet device not found."
        return
    fi

    local eth_list=""
    local active_ssid
        active_ssid=$(get_connected_wifi)
    for dev in $eth_devices; do
        local dev_status=$(nmcli device status | grep "$dev" | awk '{print $3}')
        if [ "$dev_status" = "connected" ]; then
            eth_list+="$ETHERNET_CONNECTED_ICON$dev\n"
        else
            eth_list+="$dev\n"
        fi
    done

    local chosen_device=$(echo -e "$eth_list" | rofi -dmenu -theme ~/.config/rofi/rofi-network-manager/style.rasi -i -p "Select Ethernet device: ")

    if [ -z "$chosen_device" ]; then
        return
    fi

    chosen_device=$(echo $chosen_device | sed "s/$ETHERNET_CONNECTED_ICON//")
    local device_status=$(nmcli device status | grep "$chosen_device" | awk '{print $3}')

    if [ "$device_status" = "connected" ]; then
        nmcli device disconnect "$chosen_device" && notify-send "Disconnected" "You have been disconnected from $chosen_device."
    elif [ "$device_status" = "disconnected" ]; then
        nmcli device connect "$chosen_device" && notify-send "Connected" "You are now connected to $chosen_device."
    else
        notify-send "Error" "Unable to determine the action for $chosen_device."
    fi
}

# Главное меню
main_menu() {
    ##==> Получаем необходимые аргументы
    ###############################################
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
        exit 1
    fi

    ##==> Если служба не запущена
    ###############################################
    if ! pgrep -x "NetworkManager" > /dev/null; then
        echo -n "Root Password: "
        read -s password
        echo "$password" | sudo -S systemctl start NetworkManager
    fi

    ##==> Получаем кнопки действий и функцианал для них
    #######################################################
    local wifi_status=$(nmcli -fields WIFI g)
    local wifi_toggle
    if [[ "$wifi_status" =~ "enabled" ]]; then
        wifi_toggle="󱛅  Disable Wi-Fi"
        wifi_toggle_command="off"
        manage_wifi_btn="\n󱓥 Manage Wi-Fi"
    else
        wifi_toggle="󱚽  Enable Wi-Fi"
        wifi_toggle_command="on"
        manage_wifi_btn=""
    fi

    ##==> Выводим Rofi меню
    #######################################################
    local chosen_option=$(echo -e "$wifi_toggle$manage_wifi_btn\n󱓥 Manage Ethernet" | rofi -dmenu -theme ~/.config/rofi/rofi-network-manager/style.rasi -p " Network Management: ")
    case $chosen_option in
        "$wifi_toggle")
            nmcli radio wifi $wifi_toggle_command
            ;;
        "󱓥 Manage Wi-Fi")
            manage_wifi
            ;;
        "󱓥 Manage Ethernet")
            manage_ethernet
            ;;
    esac
}

main_menu "$@"
