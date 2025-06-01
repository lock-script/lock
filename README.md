# omni.cc
omni.cc is a roblox script hub. it detects the current game and loads the correct script from the `Games/` folder. unsupported games fall back to `unsupported.lua`.


| game                 | last updated     | status |
|----------------------|------------------|--------|
| basketball legends   | june 2, 2025     | 🟢     |
| demonfall            | june 2, 2025     | 🟢     |
| grow a garden        | june 2, 2025     | 🟢     |
| mining world         | june 2, 2025     | 🟢     |
| slayer tycoon        | june 2, 2025     | 🟢     |
| untitled drill game  | june 2, 2025     | 🟢     |
| volleyball 4.2       | june 2, 2025     | 🟢     |
| arsenal              | nil              | 🟠     |
| no scope arcade      | nil              | 🟠     |
| ninja tycoon         | nil              | 🟠     |
| rake reborn          | nil              | 🔴     |
| booga booga reborn   | nil              | 🔴     |
| mortem metallum      | nil              | 🔴     |
| combat warriors      | nil              | 🔴     |
| dingus               | nil              | 🔴     |
| steal time from other| nil              | 🔴     |
| untitled tag game    | nil              | 🔴     |
| wild west            | nil              | 🔴     |
| industrialist        | nil              | 🔴     |
| volleyball legends   | nil              | 🔴     |


**legend**:  
🟢 = working  
🟡 = partial support (some features work)  
🟠 = work in progress (actively being developed)  
🔴 = not supported (planning to make) / not working



## loadstring
```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/omni-cc-create/omni.cc/main/loader.lua"))()
```

