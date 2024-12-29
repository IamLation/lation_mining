-- Initalize config(s)
local shared = require 'config.shared'
local server = require 'config.server'

-- Localize export
local mining = exports.lation_mining

-- Initialize table to store ore data
local ores = {}

-- Ore has been mined
--- @param zoneId number
--- @param oreId number
RegisterNetEvent('lation_mining:minedore', function(zoneId, oreId)
    if not source or not zoneId or not oreId then return end
    local source = source

    local zone = shared.mining.zones[zoneId]
    if not zone then return end

    local ore = zone.ores[oreId]
    if not ore then return end

    ores[zoneId] = ores[zoneId] or {}
    ores[zoneId][oreId] = ores[zoneId][oreId] or {}
    local status = ores[zoneId][oreId][source]
    if status and status.time and status.time > os.time() then return end

    local coords = GetEntityCoords(GetPlayerPed(source))
    if #(coords - ore) > 10 then return end

    local level = mining:GetPlayerData(source, 'level')
    if level < zone.level then return end

    local identifier = GetIdentifier(source)
    if not identifier then return end
    local name = GetName(source)
    if not name then return end

    local pickaxe, data = false, {}
    for pick_level, pick_data in pairs(shared.pickaxes) do
        if pick_level <= level and GetItemCount(source, pick_data.item) > 0 then
            pickaxe, data = true, pick_data
            break
        end
    end
    if not pickaxe then return end

    local items = {}
    for _, add in pairs(zone.reward) do
        local chance = add.chance or 100
        if math.random(100) <= chance then
            local quantity = math.random(add.min, add.max)
            if not CanCarry(source, add.item, quantity) then
                TriggerClientEvent('lation_mining:notify', source, locale('notify.cant-carry'), 'error')
                return
            end
            AddItem(source, add.item, quantity)
            mining:AddPlayerData(source, 'mined', quantity)
            items[#items + 1] = { item = add.item, quantity = quantity }
        end
    end

    local metadata, metatype = GetMetadata(source, data.item), GetDurabilityType()
    if not metadata or not metadata[metatype] or metadata[metatype] < data.degrade then return end

    local durability = metadata[metatype] - data.degrade
    SetMetadata(source, data.item, metatype, durability)

    local addXP = math.random(zone.xp.min, zone.xp.max)
    mining:AddPlayerData(source, 'exp', addXP)

    ores[zoneId][oreId][source] = { time = os.time() + math.floor(zone.respawn / 1000) }

    if server.logs.events.mined then
        local rewards = ''
        for _, reward in ipairs(items) do
            rewards = rewards .. 'x' .. reward.quantity .. ' ' .. reward.item .. ', '
        end
        rewards = rewards:sub(1, -3)
        PlayerLog(source, locale('logs.mined-title'), locale('logs.mined-message', name, identifier, rewards))
    end
end)

-- Ore validation management thread
CreateThread(function()
    while true do
        if next(ores) then
            for zoneId, zoneData in pairs(ores) do
                for oreId, status in pairs(zoneData) do
                    if status.time and status.time <= os.time() then
                        ores[zoneId][oreId][source] = nil
                    end
                end
            end
            Wait(1000)
        else
            Wait(10000)
        end
    end
end)