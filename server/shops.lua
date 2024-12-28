-- Initialize config(s)
local shared = require 'config.shared'
local server = require 'config.server'

-- Localize export
local mining = exports.lation_mining

-- Complete a purchase from The Mines shop
--- @param itemId number
--- @param input number
RegisterNetEvent('lation_mining:completepurchase', function(itemId, input)
    if not source or not itemId or not input then return end
    local source = source

    local item = shared.shops.mine.items[itemId]
    if not item then return end

    if item.level then
        local level = mining:GetPlayerData(source, 'level')
        if level < item.level then
            TriggerClientEvent('lation_mining:notify', source, locale('notify.not-experienced'), 'error')
            return
        end
    end

    local total = math.floor(item.price * input)
    if not total or total < 1 then return end

    local balance = GetPlayerBalance(source, shared.shops.mine.account)
    if not balance or balance < total then
        TriggerClientEvent('lation_mining:notify', source, locale('notify.no-money'), 'error')
        return
    end

    if not CanCarry(source, item.item, input) then
        TriggerClientEvent('lation_mining:notify', source, locale('notify.cant-carry'), 'error')
        return
    end

    local identifier = GetIdentifier(source)
    if not identifier then return end
    local name = GetName(source)
    if not name then return end

    local coords = shared.shops.location
    local dist = #(vec3(coords.x, coords.y, coords.z) - GetEntityCoords(GetPlayerPed(source))) <= 15
    if not dist then return end

    RemoveMoney(source, shared.shops.mine.account, total)

    if item.metadata then
        AddItem(source, item.item, input, item.metadata)
    else
        AddItem(source, item.item, input)
    end

    if server.logs.events.purchased then
        PlayerLog(source, locale('logs.purchased-title'), locale('logs.purchased-message', name, identifier, input, item.item))
    end
end)

-- Complete a sale from The Mines pawn
--- @param itemId number
--- @param input number
RegisterNetEvent('lation_mining:completesale', function(itemId, input)
    if not source or not itemId or not input then return end

    local item = shared.shops.pawn.items[itemId]
    if not item then return end

    local total = math.floor(item.price * input)
    if not total or total < 1 then return end

    local hasItem = GetItemCount(source, item.item) >= input
    if not hasItem then
        TriggerClientEvent('lation_mining:notify', source, locale('notify.no-item'), 'error')
        return
    end

    local coords = shared.shops.location
    local dist = #(vec3(coords.x, coords.y, coords.z) - GetEntityCoords(GetPlayerPed(source))) <= 15
    if not dist then return end

    local identifier = GetIdentifier(source)
    if not identifier then return end
    local name = GetName(source)
    if not name then return end

    RemoveItem(source, item.item, input)
    AddMoney(source, shared.shops.pawn.account, total)

    mining:AddPlayerData(source, 'earned', total)

    if server.logs.events.pawned then
        PlayerLog(source, locale('logs.pawned-title'), locale('logs.pawned-message', name, identifier, input, item.item))
    end
end)