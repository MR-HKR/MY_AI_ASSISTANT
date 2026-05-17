#!/bin/bash

state="$1"

if [ "$state" = "play" ]; then
    playerctl -a play

elif [ "$state" = "pause" ]; then
    playerctl -a pause

else
    echo "Use play or pause."
fi