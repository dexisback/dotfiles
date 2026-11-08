#!/bin/bash

NORMAL=24
BIG=64

while true; do
    xdotool keydown Ctrl
    gsettings set org.cinnamon.desktop.interface cursor-size $BIG

    xdotool keyup Ctrl
    gsettings set org.cinnamon.desktop.interface cursor-size $NORMAL
done
