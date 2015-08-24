#!/bin/sh
xrandr --output VIRTUAL1 --off \
       --output eDP1 --mode 1920x1080 --pos 3120x328 --rotate normal \
       --output DP1 --off \
       --output DP2-1 --mode 1920x1200 --pos 0x0 --rotate left \
       --output DP2-2 --mode 1920x1200 --pos 1200x0 --rotate normal \
       --output DP2-3 --off \
       --output HDMI2 --off \
       --output HDMI1 --off \
       --output DP2 --off
