-- Initalize config(s)
local shared = require 'config.shared'
local server = require 'config.server'

-- Localize export
local mining = exports.lation_mining

-- Initialize table to store players
local players = {}

-- Complete smelting action
--- @param ingotId number
RegisterNetEvent('lation_mining:completesmelt', function(ingotId)
    if not source or not ingotId then return end
    local source = source

    local ingot = shared.smelting.ingots[ingotId]
    if not ingot then return end

    local hasItems = true
    for _, req in pairs(ingot.required) do
        if GetItemCount(source, req.item) < req.quantity then
            hasItems = false
            break
        end
    end
    if not hasItems then
        TriggerClientEvent('lation_mining:notify', source, locale('notify.missing-item'), 'error')
        return
    end

    local dist = #(shared.smelting.coords - GetEntityCoords(GetPlayerPed(source))) <= 15
    if not dist then return end

    local canCarry = true
    for _, add in pairs(ingot.add) do
        if not CanCarry(source, add.item, add.quantity) then
            canCarry = false
            break
        end
    end
    if not canCarry then
        TriggerClientEvent('lation_mining:notify', source, locale('notify.cant-carry'), 'error')
        return
    end

    local identifier = GetIdentifier(source)
    if not identifier then return end
    local name = GetName(source)
    if not name then return end

    players[source] = players[source] or { cooldown = 0 }
    local time = os.time()
    if time < players[source].cooldown + math.floor((ingot.duration - 500) / 1000) then return end

    for _, req in pairs(ingot.required) do
        RemoveItem(source, req.item, req.quantity)
    end

    for _, add in pairs(ingot.add) do
        AddItem(source, add.item, add.quantity)
    end

    players[source].cooldown = time

    local addXP = math.random(ingot.xp.min, ingot.xp.max)
    mining:AddPlayerData(source, 'exp', addXP)
    mining:AddPlayerData(source, 'smelted', 1)

    if server.logs.events.smelted then
        PlayerLog(source, locale('logs.smelted-title'), locale('logs.smelted-message', name, identifier, 1, ingot.name))
    end
end)