local ScriptHub = {}
ScriptHub.Games = {
    -- format: [id] = "script_name" (lowercase, no .lua)
    [1316421563] = "volleyball4.2",
    [7167470321] = "miningworld",
    [7436755782] = "growagarden",
    [4931927012] = "basketballlegends",
    [2426874309] = "slayertycoon",
    [7513130835] = "untitleddrillgame",
    [1650291138] = "demonfall",
    [286090429] = "arsenal",
    [6407649031] = "noscopearcade",
}

local BaseUrl = "https://raw.githubusercontent.com/omni-cc-create/omni.cc/refs/heads/main/Games/"
local function LoadGameScript(Name)
    local Url = BaseUrl .. Name .. ".lua"
    local Success, Result = pcall(function()
        return loadstring(game:HttpGet(Url, true))()
    end)

    if not Success then
        warn("[omni.cc] failed to load script:", Name)
        warn("[omni.cc] error:", Result)
    else
        print("[omni.cc] loaded:", Name)
    end
end

local GameId = game.GameId
local PlaceId = game.PlaceId
local ScriptName = ScriptHub.Games[PlaceId] or ScriptHub.Games[GameId]

if ScriptName then
    print(("[omni.cc] matched ID (%s), loading: %s"):format(ScriptName == ScriptHub.Games[PlaceId] and "PlaceId" or "GameId", ScriptName))
    LoadGameScript(ScriptName)
else
    print("[omni.cc] unsupported game. loading unsupported script.")
    LoadGameScript("unsupported")
end
