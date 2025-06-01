# omni.cc
omni.cc is a roblox script hub. it detects the current game and loads the correct script from the `Games/` folder. unsupported games fall back to `unsupported.lua`.


## supported games
| game                 | last updated     | status |
|----------------------|------------------|--------|
| basketball legends   | june 2, 2025     | 🟢     |
| demonfall            | june 2, 2025     | 🟢     |
| grow a garden        | june 2, 2025     | 🟢     |
| mining world         | june 2, 2025     | 🟢     |
| slayer tycoon        | june 2, 2025     | 🟢     |
| untitled drill game  | june 2, 2025     | 🟢     |
| volleyball 4.2       | june 2, 2025     | 🟢     |

**legend**:  
🟢 = working  
🟡 = partial  
🔴 = not supported / not working



## loadstring
```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/omni-cc-create/omni.cc/main/loader.lua"))()
```

