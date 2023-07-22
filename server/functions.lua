-- You can edit the server-sided functions here if necessary

-- Function used to send server side notifications
function serverNotify(source, message, type)
    TriggerClientEvent('ox_lib:notify', source, {
        title = Notify.title,
        description = message,
        icon = Notify.icon,
        type = type,
        position = Notify.position
    })
end

-- Function to get the player
function getPlayer(source)
    local player
    if Config.Framework == 'esx' then
        player = ESX.GetPlayerFromId(source)
        return player
    else
        player = QBCore.Functions.GetPlayer(source)
        return player
    end
end

-- Function to add money to a player
function addAccountMoney(player, account, amount)
    if Config.Framework == 'esx' then
        player.addAccountMoney(account, amount)
    else
        if account == 'money' then account = 'cash' end
        player.Functions.AddMoney(account, amount)
    end
end

-- Function to give an item to a player
function giveItem(player, item, amount)
    if Config.Framework == 'esx' then
        player.addInventoryItem(item, amount)
    else
        player.Functions.AddItem(item, amount)
        TriggerClientEvent('inventory:client:ItemBox', player.PlayerData.source, QBCore.Shared.Items[item], 'add', amount)
    end
end

-- Function to remove an item from a player
function removeItem(player, item, amount)
    if Config.Framework == 'esx' then
        player.removeInventoryItem(item, amount)
    else
        player.Functions.RemoveItem(item, amount)
        TriggerClientEvent('inventory:client:ItemBox', player.PlayerData.source, QBCore.Shared.Items[item], 'remove', amount)
    end
end