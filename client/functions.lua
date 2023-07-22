-- You can edit the client-sided functions here if necessary

-- Function used to send client side notifications
function notify(message, type)
    lib.notify({
        title = Notify.title,
        description = message,
        icon = Notify.icon,
        type = type,
        position = Notify.position
    })
end

-- Function used to check if player has item
function hasItem(item)
    local hasItem
    if Config.Framework == 'esx' then
        hasItem = ESX.SearchInventory(item)
        return hasItem
    else
        hasItem = lib.callback.await('lation_mining:getQBItem', false, item)
        if hasItem ~= nil then hasItem.count = hasItem.amount end
        return hasItem
    end
end