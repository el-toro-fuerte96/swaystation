#!/usr/bin/env bash

WINDOW=$(
    swaymsg -t get_tree |
    jq -r '
        recurse(.nodes[]?, .floating_nodes[]?)
        | select(
            (.type == "con" or .type == "floating_con")
            and .name != null
        )
        | [
            .id,
            (.app_id // .window_properties.class // .window_properties.instance // "unknown"),
            .name,
            (if .type == "floating_con" then "FLOATING" else "TILED" end)
          ]
        | @tsv
    ' | fuzzel --dmenu --prompt="Window picker: " --width=100
)

# no input
if [ -z "$WINDOW" ]; then
    exit 0
fi

# container_id
WIN_ID=$(printf '%s\n' "$WINDOW" | cut -f1)

# assure getting the id
if ! [[ "$WIN_ID" =~ ^[0-9]+$ ]]; then
    exit 1
fi

# Focus selected window
swaymsg "[con_id=$WIN_ID] focus"
