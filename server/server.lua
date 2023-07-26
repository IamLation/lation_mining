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
    local player = GetPlayer(source)
    local distance = checkPlayerDistance(true, Config.MiningLocations)
    if player then
        if distance then
            AddItem(source, item, 1)
        else
            -- Player is not nearby a mine, potentially cheating?
        end
    end
end)

-- Event used to give an item to player upon succesfully smelting
RegisterNetEvent('lation_mining:rewardSmeltItem')
AddEventHandler('lation_mining:rewardSmeltItem', function(source, rawItem, item, quantity)
    local source = source
    local player = GetPlayer(source)
    local distance = checkPlayerDistance(false, Config.SmeltingLocation)
    if player then
        if distance then
            if quantity <= 0 then
                return
            else
                RemoveItem(source, rawItem, quantity)
                AddItem(source, item, quantity)
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
    local player = GetPlayer(source)
    local distance = checkPlayerDistance(false, Config.Selling.coords)
    if player then
        if distance then
            if quantity <= 0 then
                return
            else
                RemoveItem(source, item, quantity)
                AddMoney(source, Config.Selling.account, sellValue)
                ServerNotify(source, Notify.soldItems.. sellValue, 'success')
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
    local player = GetPlayer(source)
    if player then
        RemoveItem(source, Config.PickaxeItemName, 1)
    end
end)