-- Initialize config(s)
local server = require 'config.server'

-- Check to see if fm-logs or fmsdk is started
local fmlogs = GetResourceState('fm-logs') == 'started'
local fmsdk = GetResourceState('fmsdk') == 'started'

-- Return an inventory's "durability/quality" types
function GetDurabilityType()
    if Inventory == 'ox_inventory' then
        return 'durability'
    else
        return 'quality'
    end
end

-- Returns an items metadata
--- @param source number Player ID
--- @param item string Item name
function GetMetadata(source, item)
    if not source or not item then return end
    local player = GetPlayer(source)
    if not player then return end
    if Inventory == 'ox_inventory' then
        local data = exports[Inventory]:Search(source, 'slots', item)
        if not data or #data == 0 then return end
        return data[1].metadata
    elseif Inventory == 'core_inventory' then
        local data = exports[Inventory]:getItem(source, item)
        if not data then return end
        return data.info
    else
        local data = exports[Inventory]:GetItemByName(source, item)
        if not data then return end
        return data.info
    end
end

-- Set an items metadata
--- @param source number Player ID 
--- @param item string Item name
--- @param metatype string Metadata type
--- @param metavalue any Metadata value
function SetMetadata(source, item, metatype, metavalue)
    if not source or not item or not metatype or not metavalue then return end
    local player = GetPlayer(source)
    if not player then return end
    if Inventory == 'ox_inventory' then
        local itemData = exports[Inventory]:Search(source, 'slots', item)
        if not next(itemData) then return end
        itemData[1].metadata[metatype] = metavalue
        exports[Inventory]:SetMetadata(source, itemData[1].slot, itemData[1].metadata)
    elseif Inventory == 'codem-inventory' then
        local itemData = exports[Inventory]:GetItemByName(source, item)
        if not itemData then return end
        itemData.info[metatype] = metavalue
        exports[Inventory]:SetItemMetadata(source, itemData.slot, itemData.info)
    elseif Inventory == 'core_inventory' then
        local itemData = exports[Inventory]:getItem(source, item)
        if not itemData then return end
        local slot = exports[Inventory]:getFirstSlotByItem(source, item)
        if not slot then return end
        itemData.info[metatype] = metavalue
        exports[Inventory]:setMetadata(source, slot, itemData.info)
    else
        local itemData = exports[Inventory]:GetItemByName(source, item)
        if not itemData then return end
        itemData.info[metatype] = metavalue
        exports[Inventory]:SetItemData(source, item, 'info', itemData.info)
    end
end

-- Return item metadata to client
--- @param source number
--- @param item string
lib.callback.register('lation_mining:getmetadata', function(source, item)
    return GetMetadata(source, item)
end)

-- Log player events if applicable
--- @param source number Player ID
--- @param title string Log title
--- @param message string Message contents
function PlayerLog(source, title, message)
    if server.logs.service == 'fivemanage' then
        if not fmsdk then return end
        if server.logs.screenshots then
            exports.fmsdk:takeServerImage(source, {
                name = title,
                description = message,
            })
        else
            exports.fmsdk:LogMessage('info', message)
        end
    elseif server.logs.service == 'fivemerr' then
        if not fmlogs then return end
        exports['fm-logs']:createLog({
            LogType = 'Player',
            Message = message,
            Resource = 'lation_mining',
            Source = source,
        }, { Screenshot = server.logs.screenshots })
    elseif server.logs.service == 'discord' then
        local embed = {
            {
                ["color"] = 16711680,
                ["title"] = "**".. title .."**",
                ["description"] = message,
                ["footer"] = {
                    ["text"] = os.date("%a %b %d, %I:%M%p"),
                    ["icon_url"] = server.logs.discord.footer
                }
            }
        }
        PerformHttpRequest(server.logs.discord.link, function()
        end, 'POST', json.encode({username = server.logs.discord.name, embeds = embed, avatar_url = server.logs.discord.image}),
        {['Content-Type'] = 'application/json'})
    end
end