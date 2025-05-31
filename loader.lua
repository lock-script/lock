local ScriptHub = {}
ScriptHub.Games = {
    -- Format: [ID] = "script_name" (lowercase, no .lua)
    [123456789] = "examplegame",       -- PlaceId
    [9876543210] = "anothergame",      -- GameId
}

local BaseUrl = "https://raw.githubusercontent.com/omni-cc-create/omni.cc/refs/heads/main/Games/"
local function LoadGameScript(Name)
    local Url = BaseUrl .. Name .. ".lua"
    local Success, Result = pcall(function()
        return loadstring(game:HttpGet(Url, true))()
    end)

    if not Success then
        warn("[omni.cc] Failed to load script:", Name)
        warn("[omni.cc] Error:", Result)
    else
        print("[omni.cc] Loaded:", Name)
    end
end

local GameId = game.GameId
local PlaceId = game.PlaceId
local ScriptName = ScriptHub.Games[PlaceId] or ScriptHub.Games[GameId]

if ScriptName then
    print(("[omni.cc] Matched ID (%s), loading: %s"):format(ScriptName == ScriptHub.Games[PlaceId] and "PlaceId" or "GameId", ScriptName))
    LoadGameScript(ScriptName)
else
    print("[omni.cc] Unsupported game. Loading fallback script.")
    LoadGameScript("unsupported")
end
