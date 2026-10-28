# hyprcurtain

Stream your Hyprland session to Moonlight while your physical screens and input are turned off. The PC locks when the stream ends.

Requires Hyprland, Sunshine, hyprlock, jq, curl, and your user in the input group.

Install it from the AUR with paru or yay:

```
paru -S hyprcurtain
```

```
yay -S hyprcurtain
```

Or install it by hand:

```
git clone https://github.com/ColtNovak/hyprcurtain
cd hyprcurtain
./install.sh
```

Add `require("hyprcurtain")` to the end of `hyprland.lua`, then add this to `sunshine.conf`:

```
capture = wlr
global_prep_cmd = [{"do":"hyprcurtain start","undo":"hyprcurtain stop"}]
```

Put your Sunshine web UI password in `~/.config/hyprcurtain/sunshine-password`, then run:

```
chmod 600 ~/.config/hyprcurtain/sunshine-password
```

Settings go in `~/.config/hyprcurtain/config`.

### Usage

Run `hyprcurtain` to see the commands.
