-- Initialize config(s)
local shared = require 'config.shared'
local client = require 'config.client'
local icons  = require 'config.icons'

-- Localize export
local mining = exports.lation_mining

-- Initialize table to store smelting menu
local menu = {}

-- Initialize table to store smelter zones
local smelters = {}

-- Initialize variable to track if player is inside smelting zone
local inside = nil

-- Initialize boolean to track smelting state
local smelting = false

-- Create a blip
--- @param coords vector3|vector4
--- @param data table
local function createBlip(coords, data)
    if not data.enable then return end
    local blip = AddBlipForCoord(coords.x, coords.y, coords.z)
    SetBlipSprite(blip, data.sprite)
    SetBlipColour(blip, data.color)
    SetBlipScale(blip, data.scale)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(data.label)
    EndTextCommandSetBlipName(blip)
end

-- Build smelting menu
local function buildMenu()
    for ingotId, data in ipairs(shared.smelting.ingots) do
        local desc = {}

        for _, req in ipairs(data.required) do
            local label = GetItemData(req.item).label or req.item
            desc[#desc + 1] = string.format("x%d %s", req.quantity, label)
        end

        menu[#menu + 1] = {
            title = data.name,
            description = locale('smelt-menu.ingot-desc', table.concat(desc, ', ')),
            icon = data.icon,
            event = 'lation_mining:smelting:selectquantity',
            args = ingotId
        }
    end

    lib.registerContext({
        id = 'smelt-menu',
        title = locale('smelt-menu.main-title'),
        options = menu
    })
end

-- Runs smelting activity
--- @param ingotId number
--- @param count number
local function startSmelting(ingotId, count)
    if not ingotId or not count or count <= 0 then return end
    local ingot = shared.smelting.ingots[ingotId]
    if not ingot then return end

    local level = mining:GetPlayerData('level')
    if level < ingot.level then
        ShowNotification(locale('notify.not-experienced'), 'error')
        return
    end

    if count > ingot.max then
        ShowNotification(locale('notify.max-ingots', ingot.max), 'error')
        count = ingot.max
    end

    local smelted, saveprogress = 0, 0
    smelting = not smelting

    for i = 1, count do
        if smelted >= ingot.max then break end

        local missing = false
        for _, req in pairs(ingot.required) do
            if not HasItem(req.item, req.quantity) then
                ShowNotification(locale('notify.missing-item'), 'error')
                missing = true
                break
            end
        end

        if missing then break end
        TaskStartScenarioInPlace(cache.ped, client.anims.smelting.scenario, -1, true)

        local start = GetGameTimer()
        local stop = start + ingot.duration

        while GetGameTimer() < stop do
            local elapsed = GetGameTimer() - start
            local progress = math.floor((elapsed / ingot.duration) * 100)

            if progress ~= saveprogress then
                saveprogress = progress
                ShowTextUI(locale('textui.smelt', i, count, progress), icons.smelting)
            end

            Wait(100)
        end

        smelted += 1
        TriggerServerEvent('lation_mining:completesmelt', ingotId, inside)
    end

    ClearPedTasks(cache.ped)
    HideTextUI(locale('textui.smelt', smelted, count, saveprogress))
    smelting = not smelting
end

-- Select quantity
--- @param ingotId number
AddEventHandler('lation_mining:smelting:selectquantity', function(ingotId)
    if not ingotId then return end
    local ingot = shared.smelting.ingots[ingotId]
    if not ingot then return end
    local input = lib.inputDialog(ingot.name, {
        {
            type = 'number',
            icon = icons.input_quantity,
            label = locale('inputs.label'),
            description = locale('inputs.desc'),
            default = 1,
            require = true
        }
    })
    if not input or not input[1] then return end
    startSmelting(ingotId, input[1])
end)

-- Setup on player loaded
AddEventHandler('lation_mining:onPlayerLoaded', function()
    for smelterId, coords in pairs(shared.smelting.coords) do
        local zone = lib.zones.sphere({
            coords = coords,
            radius = 15,
            onEnter = function()
                inside = smelterId
                AddCircleZone({
                    coords = coords,
                    name = 'smelt-zone'..smelterId,
                    radius = 3,
                    debug = shared.setup.debug,
                    options = {
                        {
                            name = 'smelt-zone'..smelterId,
                            label = locale('target.smelt-ore'),
                            icon = icons.smelt,
                            iconColor = icons.smelt_color,
                            distance = 2,
                            canInteract = function()
                                if smelting then return false end
                                return true
                            end,
                            onSelect = function()
                                lib.showContext('smelt-menu')
                            end,
                            action = function()
                                lib.showContext('smelt-menu')
                            end
                        }
                    }
                })
            end,
            onExit = function()
                inside = nil
                RemoveCircleZone('smelt-zone'..smelterId)
            end,
            debug = shared.setup.debug
        })
        smelters[smelterId] = zone
        createBlip(coords, shared.smelting.blip)
    end
    buildMenu()
end)

-- Cleanup on resource stop
--- @param resourceName string
AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    for smelterId, zone in pairs(smelters) do
        if zone  then
            zone:remove()
        end
        smelters[smelterId] = nil
    end
end)