#!/bin/bash

# Function to set the master playback volume
set_master_playback_vol() {
    local value=$1
    amixer sset 'PCM' ${value}%
}

# Function to set the speakers volume
set_speakers_vol() {
    local value=$1
    amixer sset 'Line' ${value}%
}

# Function to set the headphones volume
set_headphones_vol() {
    local value=$1
    amixer sset 'HP' ${value}%
}

# Function to set the microphone volume
set_mic_vol() {
    local value=$1
    amixer sset 'PGA' ${value}%
}

# Function to mute the headphones
mute_headphones() {
    amixer sset 'HP' mute
}

# Function to unmute the headphones
unmute_headphones() {
    amixer sset 'HP' unmute
}

# Function to mute the speakers
mute_speakers() {
    amixer sset 'Line' mute
}

# Function to unmute the speakers
unmute_speakers() {
    amixer sset 'Line' unmute
}

# Function to mute the microphone
mute_mic() {
    amixer cset numid=35 off,off
}

# Function to unmute the microphone
unmute_mic() {
    amixer cset numid=35 on,on
}

# Function to save the ALSA settings
save_settings() {
    alsactl store
}

# Display help message
display_help() {
    echo "Usage: $0 device action"
    echo "Supported actions: 0-100 (set volume percentage), mute, unmute"
    echo "Supported devices and actions"
    echo "master:     volume"
    echo "mic:        volume, mute, unmute"
    echo "speakers:   volume, mute, unmute"
    echo "headphones: volume, mute, unmute"
    echo ""
    echo "Other commands:"
    echo "save - saves the current ALSA settings"
    echo "help - displays this help message"

    echo ""
    echo "Examples:"
    echo "  Set master playback volume to 80%: $0 master 80"
    echo "  Mute the microphone: $0 mic mute"
    echo "  Unmute the speakers: $0 speakers unmute"
    echo "  Save the ALSA settings: $0 save"
}

# Check if the number of arguments is valid
if [ "$#" -ne 1 ] && [ "$#" -ne 2 ]; then
    display_help
    exit 1
fi

if [ "$1" == "save" ]; then
    save_settings
    exit 0
elif [ "$1" == "help" ]; then
    display_help
    exit 0
fi

device=$1
action=$2

# Remove trailing % if present
action=${action%\%}

# Check if the action is invalid
if ! { [[ $action =~ ^[0-9]+$ && $action -ge 0 && $action -le 100 ]] || [ "$action" == "mute" ] || [ "$action" == "unmute" ]; }; then
    echo "Invalid action. Supported actions: 0-100 (set volume percentage), mute, unmute."
    display_help
    exit 1
fi

# Perform action based on the device
case "$device" in
    mic)
        if [ "$action" == "mute" ]; then
            mute_mic
        elif [ "$action" == "unmute" ]; then
            unmute_mic
        else
            set_mic_vol $action
        fi
        ;;
    speakers)
        if [ "$action" == "mute" ]; then
            mute_speakers
        elif [ "$action" == "unmute" ]; then
            unmute_speakers
        else
            set_speakers_vol $action
        fi
        ;;
    headphones)
        if [ "$action" == "mute" ]; then
            mute_headphones
        elif [ "$action" == "unmute" ]; then
            unmute_headphones
        else
            set_headphones_vol $action
        fi
        ;;
    master)
        set_master_playback_vol $action
        ;;
    *)
        echo "Invalid command. Supported devices/commands: master, mic, speakers, headphones, save."
        exit 1
        ;;
esac
