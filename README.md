# Legends Focus

* Hi, thank you for using legends_focus!

* If you need help contact us on discord: **https://discord.gg/lgnds**

* This FiveM resource allows server owners to provide a zoom-in focus feature for players. The resource is lightweight and configurable, making it easy to integrate into any server.

## Features

* **Configurable Keybind:** Activate the focus feature using a customizable key.
* **Adjustable Zoom Level:** Modify the zoom intensity through the configuration file.
* **Performance-Friendly:** Minimal resource usage to ensure smooth gameplay.

## Preview
<a href="https://ibb.co/4ZVTLQNJ"><img src="https://i.ibb.co/3yCNbJhk/312-ezgif-com-optimize.gif" alt="312-ezgif-com-optimize" border="0" /></a>

## Installation

1. Download the resouce files.
2. Place the `legends_focus` folder into your server's `resources` directory.
3. Add `ensure legends_focus` to your server's `server.cfg` file to ensure the resource starts.
4. Customize the `config.lua` file to your preferences.

## Configuration

All configuration is done within the `config.lua` file. The resource uses Lua format for easy editing and supports the following structure:

```lua
Config = {}

Config.Key = 137 -- Keybind for focus (default: Caps Lock)
Config.FocusMultiplier = 20.0 -- Lower value = More zoom when focusing
```

### Configuration Options:
- **Key:** The key used to activate the focus feature. Default is `137` (Caps Lock). Refer to the [FiveM Controls Documentation](https://docs.fivem.net/docs/game-references/controls/#controls) for other key codes.
- **FocusMultiplier:** Adjusts the zoom level when focusing. A lower value results in more zoom. Default is `20.0`.

## Support

For support, updates, and community discussion, join our Discord: **https://discord.gg/lgnds**
