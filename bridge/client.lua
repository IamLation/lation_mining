-- Initialize global variables to store framework & inventory
Framework, Inventory = nil, nil

-- Initialize global player variables
PlayerLoaded, PlayerData = nil, {}

-- Get framework
local function InitializeFramework()
    if GetResourceState('es_extended') == 'started' then
        ESX = exports['es_extended']:getSharedObject()
        Framework = 'esx'

        RegisterNetEvent('esx:playerLoaded', function(xPlayer)
            PlayerData = xPlayer
            PlayerLoaded = true
            TriggerEvent('lation_mining:onPlayerLoaded')
        end)

        RegisterNetEvent('esx:onPlayerLogout', function()
            table.wipe(PlayerData)
            PlayerLoaded = false
        end)

        AddEventHandler('onResourceStart', function(resourceName)
            if GetCurrentResourceName() ~= resourceName then return end
            PlayerData = GetPlayerData()
            PlayerLoaded = true
            TriggerEvent('lation_mining:onPlayerLoaded')
        end)

    elseif GetResourceState('qbx_core') == 'started' then
        Framework = 'qbx'

        AddEventHandler('QBCore:Client:OnPlayerLoaded', function()
            PlayerData = GetPlayerData()
            PlayerLoaded = true
            TriggerEvent('lation_mining:onPlayerLoaded')
        end)

        RegisterNetEvent('qbx_core:client:playerLoggedOut', function()
            table.wipe(PlayerData)
            PlayerLoaded = false
        end)

        AddEventHandler('onResourceStart', function(resourceName)
            if GetCurrentResourceName() ~= resourceName then return end
            PlayerData = GetPlayerData()
            PlayerLoaded = true
            TriggerEvent('lation_mining:onPlayerLoaded')
        end)
    elseif GetResourceState('qb-core') == 'started' then
        QBCore = exports['qb-core']:GetCoreObject()
        Framework = 'qb'

        AddEventHandler('QBCore:Client:OnPlayerLoaded', function()
            PlayerData = GetPlayerData()
            PlayerLoaded = true
            TriggerEvent('lation_mining:onPlayerLoaded')
        end)

        RegisterNetEvent('QBCore:Client:OnPlayerUnload', function()
            table.wipe(PlayerData)
            PlayerLoaded = false
        end)

        AddEventHandler('onResourceStart', function(resourceName)
            if GetCurrentResourceName() ~= resourceName then return end
            PlayerData = GetPlayerData()
            PlayerLoaded = true
            TriggerEvent('lation_mining:onPlayerLoaded')
        end)
    elseif GetResourceState('ox_core') == 'started' then
        Ox = require '@ox_core.lib.init'
        Framework = 'ox'

        AddEventHandler('ox:playerLoaded', function()
            PlayerData = GetPlayerData()
            PlayerLoaded = true
            TriggerEvent('lation_mining:onPlayerLoaded')
        end)

        AddEventHandler('ox:playerLogout', function()
            table.wipe(PlayerData)
            PlayerLoaded = false
        end)

        AddEventHandler('onResourceStart', function(resourceName)
            if GetCurrentResourceName() ~= resourceName then return end
            PlayerData = GetPlayerData()
            PlayerLoaded = true
            TriggerEvent('lation_mining:onPlayerLoaded')
        end)
    else
        -- Add custom framework here
    end
end

-- Get inventory
local function InitializeInventory()
    if GetResourceState('ox_inventory') == 'started' then
        Inventory = 'ox_inventory'
    elseif GetResourceState('qb-inventory') == 'started' then
        Inventory = 'qb-inventory'
    elseif GetResourceState('qs-inventory') == 'started' then
        Inventory = 'qs-inventory'
    elseif GetResourceState('ps-inventory') == 'started' then
        Inventory = 'ps-inventory'
    elseif GetResourceState('origen_inventory') == 'started' then
        Inventory = 'origen_inventory'
    elseif GetResourceState('codem-inventory') == 'started' then
        Inventory = 'codem-inventory'
    elseif GetResourceState('core_inventory') == 'started' then
        Inventory = 'core_inventory'
    else
        -- Add custom inventory here
    end
end

-- Returns player data
function GetPlayerData()
    if Framework == 'esx' then
        return ESX.GetPlayerData()
    elseif Framework == 'qb' then
        return QBCore.Functions.GetPlayerData()
    elseif Framework == 'qbx' then
        return exports.qbx_core:GetPlayerData()
    elseif Framework == 'ox' then
        return Ox.GetPlayer()
    else
        -- Add custom framework here
    end
end

-- Returns players current inventory data
--- @return any
function GetPlayerInventory()
    if Inventory then
        if Inventory == 'ox_inventory' then
            return exports[Inventory]:GetPlayerItems()
        elseif Inventory == 'qb-inventory' then
            return GetPlayerData().items
        elseif Inventory == 'qs-inventory' then
            return exports[Inventory]:getUserInventory()
        elseif Inventory == 'ps-inventory' then
            return GetPlayerData().items
        elseif Inventory == 'origen_inventory' then
            return exports[Inventory]:GetInventory()
        elseif Inventory == 'codem-inventory' then
            return exports[Inventory]:GetClientPlayerInventory()
        end
    else
        if Framework == 'esx' then
            return GetPlayerData().inventory
        elseif Framework == 'qb' then
            return GetPlayerData().items
        elseif Framework == 'qbx' then
            return print('Are you really not using ox_inventory? Contact support and say: "I\'m special"')
        elseif Framework == 'ox' then
            return print('It is confirmed your insane. Please contact support for mental health evaluation.')
        end
    end
end

-- Return data for item
--- @param item string
function GetItemData(item)
    if not item then return end
    if Inventory then
        if Inventory == 'ox_inventory' then
            return exports.ox_inventory:Items(item)
        elseif Inventory == 'qb-inventory' or Inventory == 'ps-inventory' then
            return QBCore.Shared.Items[item]
        elseif Inventory == 'qs-inventory' then
            local items = exports['qs-inventory']:GetItemList()
            if not items then return end
            return items[item]
        elseif Inventory == 'origen_inventory' then
            local items = exports.origen_inventory:GetItems()
            if not items then return end
            return items[item]
        elseif Inventory == 'codem-inventory' then
            local items = exports['codem-inventory']:GetItemList()
            if not items then return end
            return items[item]
        elseif Inventory == 'core_inventory' then
            -- No available client-side export to get item list
            if Framework == 'qb' then
                return QBCore.Shared.Items[item]
            else
                print('^1[ERROR]: An issue has occured, please contact support at: https://discord.gg/9EbY4nM5uu^0')
            end
        else
            -- Add custom inventory here
        end
    else
        if Framework == 'esx' then
            -- Unlikely to need anything here but.. just in case..
            print('^1[ERROR]: An error has occured with lation_meth - please contact support^0')
        elseif Framework == 'qb' then
            return QBCore.Shared.Items[item]
        elseif Framework == 'qbx' then
            -- Unlikely to need anything here but.. just in case..
            print('^1[ERROR]: Are you really not using ox_inventory? Contact support please lul.^0')
        end
    end
end

-- Returns boolean if player has specified amount of item
--- @param item string
--- @param amount number
--- @return boolean
function HasItem(item, amount)
    if not item or not amount then return false end
    if Inventory then
        if Inventory == 'ox_inventory' then
            return exports[Inventory]:Search('count', item) >= amount
        elseif Inventory == 'core_inventory' then
            return exports[Inventory]:hasItem(item, amount)
        else
            return exports[Inventory]:HasItem(item, amount)
        end
    else
        local player = GetPlayerData()
        if not player then return false end
        local inventory = Framework == 'esx' and player.inventory or player.items
        if not inventory then return false end
        for _, item_data in pairs(inventory) do
            if item_data and item_data.name == item then
                local count = item_data.amount or item_data.count or 0
                if count >= amount then
                    return true
                end
            end
        end
        return false
    end
end

-- Initialize defaults
InitializeFramework()
InitializeInventory()