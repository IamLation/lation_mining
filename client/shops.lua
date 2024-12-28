-- Initialize config(s)
local shared = require 'config.shared'
local client = require 'config.client'
local icons = require 'config.icons'

-- Localize export
local mining = exports.lation_mining

-- Initialize table to store shop(s) data
-- .items, .zone, .ped
local themines = {}

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

-- Is item a pickaxe?
--- @param item string
--- @return boolean
local function isPickaxe(item)
    for _, data in pairs(shared.pickaxes) do
        if item == data.item then
            return true
        end
    end
    return false
end

-- Open "The Mines""
local function openShop()
    local main, stats, leaderboard = {}, {}, {}
    local player = mining:GetPlayerData()

    -- Start of experience/level calculations
    local currentLvlexp = shared.experience[player.level] or 0
    local nextLvlexp = 0
    if shared.experience[player.level + 1] then
        nextLvlexp = shared.experience[player.level + 1]
    end
    local lvlProgress = player.exp - currentLvlexp
    local lvlExpNeeded = nextLvlexp - currentLvlexp
    local progress = 100
    local nextLvlText = locale('player-data.meta-maxed-level')
    local remainderText = locale('player-data.meta-maxed-level')
    if player.level < #shared.experience then
        progress = math.floor((lvlProgress / lvlExpNeeded) * 100)
        ---@diagnostic disable-next-line: undefined-field
        nextLvlText = math.groupdigits(nextLvlexp)
        ---@diagnostic disable-next-line: undefined-field
        remainderText = math.groupdigits(lvlExpNeeded - lvlProgress)
    end

    -- Start building main menu
    main[#main + 1] = {
        title = locale('player-data.level-title', player.level, #shared.experience),
        description = locale('player-data.level-desc', math.groupdigits(player.exp)),
        icon = icons.player_level,
        iconColor = icons.player_level_color,
        progress = progress,
        colorScheme = progress <= 25 and 'red' or progress > 25 and progress <= 75 and 'yellow' or progress > 75 and 'green',
        metadata = {
            { label = locale('player-data.meta-next-level'), value = nextLvlText },
            { label = locale('player-data.meta-remainder'), value = remainderText }
        }
    }

    -- Check if displaying stats
    local show_stats = false
    for _, show in pairs(client.stats) do
        if show then show_stats = true break end
    end
    if show_stats then
        main[#main + 1] = {
            title = locale('player-data.stats-title'),
            description = locale('player-data.stats-desc'),
            icon = icons.view_stats,
            iconColor = icons.view_stats_color,
            menu = 'mine-stats'
        }
    end
    if show_stats and client.stats.mined then
        stats[#stats + 1] = {
            title = locale('stats-menu.mined-title'),
            description = locale('stats-menu.mined-desc', math.groupdigits(player.mined)),
            icon = icons.stats_mined,
            iconColor = icons.stats_mined_color,
        }
    end
    if show_stats and client.stats.smelted then
        stats[#stats + 1] = {
            title = locale('stats-menu.smelted-title'),
            description = locale('stats-menu.smelted-desc', math.groupdigits(player.smelted)),
            icon = icons.stats_smelted,
            iconColor = icons.stats_smelted_color,
        }
    end
    if show_stats and client.stats.earned then
        stats[#stats + 1] = {
            title = locale('stats-menu.earned-title'),
            description = locale('stats-menu.earned-desc', math.groupdigits(player.earned)),
            icon = icons.stats_earned,
            iconColor = icons.stats_earned_color,
        }
    end

    -- Check if displaying leaderboard
    if client.leaderboard then
        main[#main + 1] = {
            title = locale('mine-menu.leaderboards-title'),
            description = locale('mine-menu.leaderboards-desc'),
            icon = icons.mines_leaderboard,
            iconColor = icons.mines_leaderboard_color,
            menu = 'mine-leaderboards'
        }

        local players = lib.callback.await('lation_mining:gettopplayers', false)
        if not players or #players == 0 then players = {} end
        for rank, data in ipairs(players) do
            leaderboard[#leaderboard + 1] = {
                title = data.name,
                description = locale('leaderboard-menu.player-desc', data.level, math.groupdigits(data.exp), math.groupdigits(data.mined)),
                icon = rank <= 3 and icons.leaderboard or nil,
                iconColor = rank == 1 and 'gold' or rank == 2 and 'silver' or rank == 3 and 'brown' or '',
            }
        end
    end

    -- Check if displating shop
    if shared.shops.mine.enable then
        main[#main + 1] = {
            title = locale('mine-menu.shop-title'),
            description = locale('mine-menu.shop-desc'),
            icon = icons.mines_shop,
            iconColor = icons.mines_shop_color,
            menu = 'mine-shop'
        }
    end

    -- Check if displaying pawn shop
    if shared.shops.pawn.enable then
        main[#main + 1] = {
            title = locale('mine-menu.pawn-title'),
            description = locale('mine-menu.pawn-desc'),
            icon = icons.mines_pawn,
            iconColor = icons.mines_pawn_color,
            menu = 'mine-pawn'
        }
    end

    -- Register menus
    lib.registerContext({
        id = 'mine-main',
        title = locale('mine-menu.main-title'),
        options = main
    })
    if client.leaderboard then
        lib.registerContext({
            id = 'mine-leaderboards',
            menu = 'mine-main',
            title = locale('leaderboard-menu.main-title'),
            options = leaderboard
        })
    end
    if show_stats then
        lib.registerContext({
            id = 'mine-stats',
            menu = 'mine-main',
            title = locale('stats-menu.main-title'),
            options = stats
        })
    end

    lib.showContext('mine-main')
end

-- Build shop items
local function createShop()
    if not themines.shop then themines.shop = {} end
    for id, data in ipairs(shared.shops.mine.items) do
        local itemData = GetItemData(data.item) or { label = 'Undefined' }
        local isPick = isPickaxe(data.item)
        themines.shop[#themines.shop + 1] = {
            title = isPick and locale('shop-menu.pickaxe-title', itemData.label, id) or itemData.label,
            ---@diagnostic disable-next-line: undefined-field
            description = locale('shop-menu.item-desc', itemData.label, math.groupdigits(data.price)),
            icon = data.icon or 'fas fa-triangle-exclamation',
            iconColor = data.iconColor or '',
            image = isPick and 'nui://lation_mining/install/images/'..data.item..'.png' or nil,
            event = 'lation_mining:shops:selectquantity',
            args = id
        }
    end
    lib.registerContext({
        id = 'mine-shop',
        menu = 'mine-main',
        title = locale('shop-menu.main-title'),
        options = themines.shop
    })
    if not themines.pawn then themines.pawn = {} end
    for id, data in ipairs(shared.shops.pawn.items) do
        local itemData = GetItemData(data.item) or { label = 'Undefined' }
        themines.pawn[#themines.pawn + 1] = {
            title = itemData.label,
            ---@diagnostic disable-next-line: undefined-field
            description = locale('pawn-menu.item-desc', itemData.label, math.groupdigits(data.price)),
            icon = data.icon or 'fas fa-triangle-exclamation',
            iconColor = data.iconColor or '',
            event = 'lation_mining:pawn:selectquantity',
            args = id
        }
    end
    lib.registerContext({
        id = 'mine-pawn',
        menu = 'mine-main',
        title = locale('pawn-menu.main-title'),
        options = themines.pawn
    })
end

-- Select quantity
--- @param id number
AddEventHandler('lation_mining:shops:selectquantity', function(id)
    if not id then return end
    local config = shared.shops.mine.items[id]
    if not config then return end
    local itemData = GetItemData(config.item) or { label = 'Undefined' }
    local input = lib.inputDialog(itemData.label, {
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
    TriggerServerEvent('lation_mining:completepurchase', id, input[1])
end)

-- Select quantity
--- @param id number
AddEventHandler('lation_mining:pawn:selectquantity', function(id)
    if not id then return end
    local config = shared.shops.pawn.items[id]
    if not config then return end
    local itemData = GetItemData(config.item) or { label = 'Undefined' }
    local input = lib.inputDialog(itemData.label, {
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
    TriggerServerEvent('lation_mining:completesale', id, input[1])
end)

-- Create zone
local function createZone()
    if not themines.zone then themines.zone = {} end
    themines.zone = lib.points.new(shared.shops.location, 150)

    -- onEnter
    function themines.zone:onEnter()
        local hour = GetClockHours()
        if (hour >= shared.shops.hours.min and hour < shared.shops.hours.max) then
            if not themines.ped then
                themines.ped = SpawnPed(shared.shops.model, shared.shops.location)
                if shared.shops.scenario then
                    TaskStartScenarioInPlace(themines.ped, shared.shops.scenario, -1, true)
                end
            end
            AddTargetEntity(themines.ped, {
                {
                    name = 'mine-shop',
                    label = locale('target.mine-shop'),
                    icon = icons.mine_shop,
                    iconColor = icons.mine_shop_color,
                    onSelect = function()
                        PlayPedAmbientSpeechNative(themines.ped, 'GENERIC_HI', 'SPEECH_PARAMS_STANDARD')
                        openShop()
                    end,
                    action = function()
                        PlayPedAmbientSpeechNative(themines.ped, 'GENERIC_HI', 'SPEECH_PARAMS_STANDARD')
                        openShop()
                    end
                }
            })
        end
    end

    -- onExit
    function themines.zone:onExit()
        if themines.ped and DoesEntityExist(themines.ped) then
            DeleteEntity(themines.ped)
            SetModelAsNoLongerNeeded(shared.shops.model)
        end
        RemoveTargetEntity(themines.ped, 'mine-shop')
        themines.ped = nil
    end
end

-- Initialize script
AddEventHandler('lation_mining:onPlayerLoaded', function()
    createBlip(shared.shops.location, shared.shops.blip)
    createShop()
    createZone()
end)