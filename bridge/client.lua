PlayerLoaded, PlayerData = nil, {}

local invState = GetResourceState('ox_inventory')
local libState = GetResourceState('ox_lib')

-- Get framework
if GetResourceState('es_extended') == 'started' then
    ESX = exports['es_extended']:getSharedObject()
    Framework = 'esx'

    RegisterNetEvent('esx:playerLoaded', function(xPlayer)
        PlayerData = xPlayer
        PlayerLoaded = true
    end)

    RegisterNetEvent('esx:onPlayerLogout', function()
        table.wipe(PlayerData)
        PlayerLoaded = false
    end)

    AddEventHandler('onResourceStart', function(resourceName)
        if GetCurrentResourceName() ~= resourceName or not ESX.PlayerLoaded then
            return
        end
        PlayerData = ESX.GetPlayerData()
        PlayerLoaded = true
    end)

elseif GetResourceState('qb-core') == 'started' then
    QBCore = exports['qb-core']:GetCoreObject()
    Framework = 'qb'

    AddStateBagChangeHandler('isLoggedIn', '', function(_bagName, _key, value, _reserved, _replicated)
        if value then
            PlayerData = QBCore.Functions.GetPlayerData()
        else
            table.wipe(PlayerData)
        end
        PlayerLoaded = value
    end)

    AddEventHandler('onResourceStart', function(resourceName)
        if GetCurrentResourceName() ~= resourceName or not LocalPlayer.state.isLoggedIn then
            return
        end
        PlayerData = QBCore.Functions.GetPlayerData()
        PlayerLoaded = true
    end)
else
    -- Add support for a custom framework here
    return
end

-- Function to show a notification
ShowNotification = function(message, type)
    if libState == 'started' then
        lib.notify({
            title = Notify.title,
            description = message,
            icon = Notify.icon,
            type = type,
            position = Notify.position
        })
    else
        if Framework == 'esx' then
            ESX.ShowNotification(message)
        elseif Framework == 'qb' then
            QBCore.Functions.Notify(message, type)
        else
            -- Add support for a custom framework here
        end
    end
end

-- Function to check if the player has the given items and amount
HasItem = function(items, amount)
    if invState == 'started' then
        return exports.ox_inventory:Search('count', items)
    else
        if Framework == 'esx' then
            if not ESX.GetPlayerData() or not ESX.GetPlayerData().inventory then
                return 0
            end
            local inventory = ESX.GetPlayerData().inventory
            for _, itemData in pairs(inventory) do
                if itemData.name == items and itemData.count > 0 then
                    return itemData.count
                end
            end
            return 0
        elseif Framework == 'qb' then
            local PlayerData = QBCore.Functions.GetPlayerData()
            if not PlayerData or not PlayerData.items then
                return 0
            end
            for i = 1, #PlayerData.items do
                local itemData = PlayerData.items[i]
                if itemData and itemData.name == items and itemData.amount >= amount then
                    return itemData.amount
                end
            end
            return 0
        else
            -- Add support for a custom framework here
        end
    end
end