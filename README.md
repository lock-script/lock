# omni.cc
omni.cc is a roblox script hub. it detects the current game and loads the correct script from the `Games/` folder. unsupported games fall back to `unsupported.lua`.

## loadstring
```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/omni-cc-create/omni.cc/main/loader.lua"))()
```

## supported games

| game              | placeid(s)         | status |
|-------------------|--------------------|--------|
| blox fruits       | 2753915549         | 🟢     |
| combat warriors   | 4282985734         | 🟢     |
| bedwars           | 6872265039         | 🟡     |
| anime adventures  | 8304191830         | 🔴     |
| deepwoken         | 4111023553         | 🔴     |

**legend**:  
🟢 = working  
🟡 = partial  
🔴 = not supported
