#!/bin/sh

userresources=$HOME/.Xresources
usermodmap=$HOME/.Xmodmap
sysresources=/etc/X11/xinit/.Xresources
sysmodmap=/etc/X11/xinit/.Xmodmap
bat_path=/sys/class/power_supply/BAT0
wifi_path=/sys/class/net/wlp3s0
eth_path=/sys/class/net/enp0s25

# merge in defaults and keymaps

if [ -f $sysresources ]; then
    xrdb -merge $sysresources
fi

if [ -f $sysmodmap ]; then
    xmodmap $sysmodmap
fi

if [ -f "$userresources" ]; then
    xrdb -merge "$userresources"
fi

if [ -f "$usermodmap" ]; then
    xmodmap "$usermodmap"
fi

# start some nice programs
if [ -d /etc/X11/xinit/xinitrc.d ] ; then
 for f in /etc/X11/xinit/xinitrc.d/?*.sh ; do
  [ -x "$f" ] && . "$f"
 done
 unset f
fi

# DWM Bar
/home/daniel-arch/dwm-bar/dwm_bar.sh &

# Keyboard Layout
setxkbmap dk &

# Display Resolution
xrandr --output Virtual-1 --mode 1366x768 &

# Compositor
picom -f &

# Wallpaper
nitrogen --restore &

# Loop for startx to keep running
while true; do
    dwm >/dev/null 2>&1
done

# Execute DWM
exec dwm
