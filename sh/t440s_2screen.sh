#!/bin/sh
xrandr --output VIRTUAL1 --off \
       --output eDP1 --mode 1920x1080 --pos 0x1200 --rotate normal \
       --output DP1 --off \
       --output HDMI2 --off \
       --output HDMI1 --off \
       --output DP2-1 --off \
       --output DP2-2 --mode 1920x1200 --pos 0x0 --rotate normal \
       --output DP3 --off \
       --output DP4 --off \
       --output DP5 --off
