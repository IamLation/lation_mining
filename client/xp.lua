-- Initialize config(s)
local shared = require 'config.shared'

-- Returns player data from server
--- @param type any
local function GetPlayerData(type)
    return lib.callback.await('lation_mining:getplayerdata', false, type)
end

-- Return xp data
local function getLevelData()
    return shared.experience
end

-- Register export(s)
exports('GetPlayerData', GetPlayerData) --returns player data from server (params: type) (type param optional)
exports('GetLevelData', getLevelData) -- returns xp data
exports('getLevelData', getLevelData) -- alias for GetLevelData