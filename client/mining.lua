-- Initialize config(s)
local shared = require 'config.shared'
local client = require 'config.client'
local icons  = require 'config.icons'

-- Initialize table to store ores
local ores = {}

-- Initialize variable to store inside mine state
local inside = false

-- Localize export
local mining = exports.lation_mining

-- Mine an ore
--- @param zoneId number
--- @param oreId number
local function mineOre(zoneId, oreId)
    if not zoneId or not oreId then return end

    local zone = shared.mining.zones[zoneId]
    if not zone then return end

    local ore = ores[zoneId] and ores[zoneId][oreId]
    if not ore or not DoesEntityExist(ore.entity) then return end

    local level = mining:GetPlayerData('level')
    if level < zone.level then
        ShowNotification(locale('notify.not-experienced'), 'error')
        return
    end

    local pickaxe, item = false, nil
    for pick_level, pick_data in pairs(shared.pickaxes) do
        if pick_level <= level and HasItem(pick_data.item, 1) then
            pickaxe, item = true, pick_data.item
            break
        end
    end
    if not pickaxe then
        ShowNotification(locale('notify.missing-pickaxe'), 'error')
        return
    end

    local metadata = lib.callback.await('lation_mining:getmetadata', false, item)
    local metatype = GetDurabilityType()
    local degrade = shared.pickaxes[level].degrade
    if not metadata or not metadata[metatype] or metadata[metatype] < degrade then
        ShowNotification(locale('notify.pickaxe-no-durability'), 'error')
        return
    end

    local hour = GetClockHours()
    local hours = shared.mining.hours
    if hour < hours.min or hour > hours.max then
        ShowNotification(locale('notify.nighttime'), 'error')
        return
    end

    local duration = math.random(zone.duration.min, zone.duration.max)
    local anim = client.anims.mining
    if not anim or not duration then return end
    anim.duration = duration

    if ProgressBar(anim) then
        DeleteEntity(ore.entity)
        ores[zoneId][oreId] = { respawn = GetGameTimer() + zone.respawn }
        TriggerServerEvent('lation_mining:minedore', zoneId, oreId)
    end
end

-- Spawn an ore
--- @param zoneId number
--- @param oreId number
local function spawnOre(zoneId, oreId)
    if not zoneId or not oreId then return end

    local zone = shared.mining.zones[zoneId]
    if not zone then return end

    local ore = zone.ores[oreId]
    if not ore then return end

    local models = zone.models
    local model = models[math.random(#models)]
    lib.requestModel(model)
    while not HasModelLoaded(model) do Wait(0) end
    local entity = CreateObject(model, ore.x, ore.y, ore.z, false, false, false)
    PlaceObjectOnGroundProperly(entity)
    FreezeEntityPosition(entity, true)
    AddTargetEntity(entity, {
        {
            name = zoneId .. oreId,
            label = locale('target.mine-ore'),
            icon = icons.mine,
            iconColor = icons.mine_color,
            distance = 2,
            canInteract = function()
                return not IsPedInAnyVehicle(cache.ped, true)
            end,
            onSelect = function()
                mineOre(zoneId, oreId)
            end,
            action = function()
                mineOre(zoneId, oreId)
            end
        }
    })

    ores[zoneId][oreId] = { entity = entity, respawn = nil }
end

-- Setup on mine enter
local function enterMine()
    inside = not inside
    for zoneId, zone in pairs(shared.mining.zones) do
        ores[zoneId] = ores[zoneId] or {}
        for oreId, _ in pairs(zone.ores) do
            spawnOre(zoneId, oreId)
        end
    end
end

-- Cleanup on mine exit
local function exitMine()
    inside = not inside
    for zoneId, oreData in pairs(ores) do
        for _, data in pairs(oreData) do
            if data.entity and DoesEntityExist(data.entity) then
                DeleteEntity(data.entity)
            end
        end
        ores[zoneId] = nil
    end
    for _, data in pairs(shared.mining.zones) do
        for _, model in pairs(data.models) do
            SetModelAsNoLongerNeeded(model)
        end
    end
end

-- Ore respawn management thread
CreateThread(function()
    while true do
        if inside then
            for zoneId, oreData in pairs(ores) do
                for oreId, data in pairs(oreData) do
                    if data.respawn and GetGameTimer() >= data.respawn then
                        spawnOre(zoneId, oreId)
                    end
                end
            end
            Wait(1000)
        else
            Wait(10000)
        end
    end
end)

-- Setup on player loaded
AddEventHandler('lation_mining:onPlayerLoaded', function()
    lib.zones.sphere({
        coords = shared.mining.center,
        radius = 400,
        onEnter = enterMine,
        onExit = exitMine,
        debug = shared.setup.debug
    })
end)

-- Cleanup on resource stop
--- @param resourceName string
AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    for zoneId, oreData in pairs(ores) do
        for _, data in pairs(oreData) do
            if data.entity and DoesEntityExist(data.entity) then
                DeleteEntity(data.entity)
            end
        end
        ores[zoneId] = nil
    end
end)