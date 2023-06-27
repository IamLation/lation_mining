local ox_inventory = exports.ox_inventory

lib.callback.register('lation_mining:hasItem', function(source, item)
    local hasItem = ox_inventory:Search(source, 'count', item)
    return hasItem
end)

lib.callback.register('lation_mining:checkMetadata', function(source, item)
    local item = ox_inventory:GetSlotsWithItem(source, Config.PickaxeItemName)
    if item[1].metadata.durability == 0 then 
        ox_inventory:RemoveItem(source, Config.PickaxeItemName, 1)
    end
    return item[1].metadata.durability
end)

lib.callback.register('lation_mining:rewardMineItem', function(source, item)
    local ped = GetPlayerPed(source)
    local playerPos = (GetEntityCoords(ped))
    local distance = checkPlayerDistance(true, Config.MiningLocations)
    local canCarry = ox_inventory:CanCarryItem(source, item, 1)
    if distance then 
        if canCarry then
            ox_inventory:AddItem(source, item, 1)
        else 
            -- player's inventory is full/cannot carry
            -- ox_inventory handles the notification here
        end
    else
        -- player is not nearby a mine, potential cheating?
    end
end)

lib.callback.register('lation_mining:rewardSmeltItem', function(source, rawItem, item, quantity)
    local ped = GetPlayerPed(source)
    local playerPos = (GetEntityCoords(ped))
    local distance = checkPlayerDistance(false, Config.SmeltingLocation)
    local canCarry = ox_inventory:CanCarryItem(source, item, quantity)
    if distance then 
        if canCarry then
            if quantity <= 0 then
                return
            else
                ox_inventory:RemoveItem(source, rawItem, quantity)
                ox_inventory:AddItem(source, item, quantity)
            end
        else 
            -- player's inventory is full/cannot carry
            -- ox_inventory handles the notification here
        end
    else
        -- player is not nearby a mine, potential cheating?
    end
end)

lib.callback.register('lation_mining:sellItem', function(source, item, quantity, sellValue)
    local ped = GetPlayerPed(source)
    local playerPos = (GetEntityCoords(ped))
    local distance = checkPlayerDistance(false, Config.Selling.coords)
    local canCarry = ox_inventory:CanCarryItem(source, item, quantity)
    local xPlayer = ESX.GetPlayerFromId(source)
    if distance then 
        if canCarry then
            if quantity <= 0 then
                return
            else
                ox_inventory:RemoveItem(source, item, quantity)
                xPlayer.addAccountMoney(Config.Selling.account, sellValue)
                TriggerClientEvent('ox_lib:notify', source, { title = Notify.title, description = 'You have been paid $' ..sellValue, icon = Notify.icon, type = 'success', position = Notify.position })
            end
        else 
            -- player's inventory is full/cannot carry
            -- ox_inventory handles the notification here
        end
    else
        -- player is not nearby a mine, potential cheating?
    end
end)

function checkPlayerDistance(mines, coords)
    local ped = GetPlayerPed(source)
    local playerPos = (GetEntityCoords(ped))
    if not mines then 
        local distance = #(playerPos - coords)
        if distance < 5.0 then 
            return true 
        end
        return false 
    else
        for _, location in pairs(coords) do
            local distance = #(playerPos - location)
            if distance < 5.0 then
                return true
            end
        end
        return false
    end
end