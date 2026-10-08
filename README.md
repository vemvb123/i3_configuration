# Preview

Some different themes:

<img width="1915" height="1078" alt="20261008_193606" src="https://github.com/user-attachments/assets/9dea70c7-1f1a-442d-9669-317dd49ad5fa" />

<img width="1910" height="1073" alt="20261008_193648" src="https://github.com/user-attachments/assets/ad7f122e-a832-4921-a32c-2fe3e508a1be" />

<img width="1875" height="1080" alt="20261008_193720" src="https://github.com/user-attachments/assets/dd7f0e3c-998c-4ae8-bc77-5e174293aa33" />




# Installation
Install i3 and other dependencies:
```
sudo apt install i3 i3-wm dunst i3lock i3status suckless-tools rxvt-unicode xsel lxappearance scrot
```

I also like to use kitty terminal, and maim as a screenshot tool
```
sudo apt install kitty maim
```

Then clone this repository.
The repository contains a i3/ and i3status/ folder.

If you already have these folders in ~/.config, then make backups
```
mv ~/.config/i3 ~/.config/i3_backup 
mv ~/.config/i3status ~/.config/i3status
```

Or delete them
```
rm -rf ~/.config/i3
rm -rf ~/.config/i3status
```

Then move i3/ and i3status/ from this repo to the ~.config/ folder.
```
mv i3 i3status ~/.config
```

Choose a kitty terminal theme
```
kitten themes
```


## Further configuration
The i3 config contains these values.
These are values for background images, screenshot tool, keyboard language and multi-monitor setup.
Change them to what you find appropriate.

```
# sunshine for remote streaming
# exec --no-startup-id sunshine

# keyboard language
# exec --no-startup-id setxkbmap no

# Multi monitor setup
#exec --no-startup-id xrandr \
#  --output HDMI-0 --mode 1920x1080 --rotate normal --pos 0x420 --primary \
#  --output DP-2   --mode 1920x1080 --rotate left   --pos 1920x0 \
#  --output DP-5   --mode 1920x1080 --rotate left   --pos 3000x0 \
#  --output DP-0   --mode 1920x1080 --rotate left   --pos 4080x0

# Background configuration
#exec --no-startup-id feh --no-fehbg --bg-fill \
#  ~/Pictures/1.png \
#  ~/Pictures/2.jpg \
#  ~/Pictures/3.jpg \
#  ~/Pictures/4.jpg

# start a terminal
bindsym $super+Return exec kitty

# Screenshot tool
bindsym $super+Shift+a exec --no-startup-id maim -s ~/Pictures/Screenshots/$(date +%Y%m%d_%H%M%S).png
```



## Further for ubuntu
Ignore if you don't use ubuntu.

The login screen may not show the i3 window manager.
This is because it will hide the gear icon on the login screen, which is used to choose i3.
To make the gear icon show, install another desktop manager, for example hyperland.
Hyperland will not be used. It's only to make ubuntu show the gear icon on the login screen.
```
sudo apt install hyperland
```


Ubuntu may have keyboard- and mouse input issues for ubuntu.
Do the steps below to fix this.

```
sudo vim /etc/X11/xorg.conf.d/99-libinput.conf
```

Add this to the file:

```
Section "InputClass"
    Identifier "force libinput keyboard"
    MatchIsKeyboard "on"
    MatchDevicePath "/dev/input/event*"
    Driver "libinput"
EndSection

Section "InputClass"
    Identifier "force libinput pointer"
    MatchIsPointer "on"
    MatchDevicePath "/dev/input/event*"
    Driver "libinput"
EndSection

```

## Loading configuration
After having logged into i3,
press Super+Backspace to load this i3 configuration
