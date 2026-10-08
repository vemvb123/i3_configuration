# Installation
Install i3 and other dependencies:
```
sudo apt install i3 i3-wm dunst i3lock i3status suckless-tools hsetroot rxvt-unicode xsel lxappearance scrot kitty
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
