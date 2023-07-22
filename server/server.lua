-- Get framework
if Config.Framework == 'esx' then
    ESX = exports["es_extended"]:getSharedObject()
else
    QBCore = exports['qb-core']:GetCoreObject()
end

local function checkPlayerDistance(mines, coords)
    local ped = GetPlayerPed(source)
    local playerPos = (GetEntityCoords(ped))
    if not mines then
        local distance = #(playerPos - coords)
        if distance < 10.0 then
            return true
        end
        return false
    else
        for _, location in pairs(coords) do
            local distance = #(playerPos - location)
            if distance < 10.0 then
                return true
            end
        end
        return false
    end
end

-- Event used to give an item to player upon succesfully mining
RegisterNetEvent('lation_mining:rewardMineItem')
AddEventHandler('lation_mining:rewardMineItem', function(source, item)
    local source = source
    local player = getPlayer(source)
    local distance = checkPlayerDistance(true, Config.MiningLocations)
    if player then
        if distance then
            giveItem(player, item, 1)
        else
            -- Player is not nearby a mine, potentially cheating?
        end
    end
end)

-- Event used to give an item to player upon succesfully smelting
RegisterNetEvent('lation_mining:rewardSmeltItem')
AddEventHandler('lation_mining:rewardSmeltItem', function(source, rawItem, item, quantity)
    local source = source
    local player = getPlayer(source)
    local distance = checkPlayerDistance(false, Config.SmeltingLocation)
    if player then
        if distance then
            if quantity <= 0 then
                return
            else
                removeItem(player, rawItem, quantity)
                giveItem(player, item, quantity)
            end
        else
            -- Player is not nearby smelting area, potentially cheating?
        end
    end
end)

-- Event for paying the player upon successful sale
RegisterNetEvent('lation_mining:sellItem')
AddEventHandler('lation_mining:sellItem', function(source, item, quantity, sellValue)
    local source = source
    local player = getPlayer(source)
    local distance = checkPlayerDistance(false, Config.Selling.coords)
    if player then
        if distance then
            if quantity <= 0 then
                return
            else
                removeItem(player, item, quantity)
                addAccountMoney(player, Config.Selling.account, sellValue)
                serverNotify(source, Notify.soldItems.. sellValue, 'success')
            end
        else
            -- Player is not nearby the selling NPC, potential cheating?
        end
    end
end)

-- Event used to break a pickaxe if enabled
RegisterNetEvent('lation_mining:breakPickaxe')
AddEventHandler('lation_mining:breakPickaxe', function(source)
    local source = source
    local player = getPlayer(source)
    removeItem(player, Config.PickaxeItemName, 1)
end)

-- Callback used to check a players job if Config.RequireJob is true
lib.callback.register('lation_mining:checkJob', function(source)
    local source = source
    local player = nil
    if Config.Framework == 'esx' then
        player = ESX.GetPlayerFromId(source)
        if not player then return end
        local playerJob = player.job.name
        if playerJob == Config.JobName then
            return true
        else
            return false
        end
    else
        player = QBCore.Functions.GetPlayer(source)
        local playerJob = player.PlayerData.job.name
        if playerJob == Config.JobName then
            return true
        else
            return false
        end
    end
end)

-- Callback used to get the item count for QBCore players
lib.callback.register('lation_mining:getQBItem', function(source, item)
    local source = source
    local player = QBCore.Functions.GetPlayer(source)
    local hasItem = player.Functions.GetItemByName(item)
    return hasItem
end)