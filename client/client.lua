local ox_target = exports.ox_target
local sellingNPCLocation = lib.points.new(Config.Selling.coords, 40)
local textUI = false
local smeltStarted = false
local smeltingInputOptions = {}
local sellingInputOptions = {}

-- Ensures all options from Config.SmeltingOptions are inserted into the Input Dialog
for k, v in pairs(Config.SmeltingOptions) do
    if v.smeltable then
        table.insert(smeltingInputOptions, {value = k, label = v.label})
    end
end 

-- Ensures all options from Config.SmeltingOptions are inserted into the Input Dialog
if Config.Selling.enabled then 
    for k, v in pairs(Config.SmeltingOptions) do
        local label = v.label
        if string.sub(k, 1, 4) == "raw_" then
            label = string.sub(v.label, 5)
        end
        table.insert(sellingInputOptions, { value = k, label = label })
    end
end 

-- Create blip for smelting location
local smeltBlip = AddBlipForCoord(Config.SmeltingLocation.x, Config.SmeltingLocation.y, Config.SmeltingLocation.z)
SetBlipSprite(smeltBlip, Config.BlipSettings.smeltSettings.blipSprite)
SetBlipColour(smeltBlip, Config.BlipSettings.smeltSettings.blipColor)
SetBlipScale(smeltBlip, Config.BlipSettings.smeltSettings.blipScale)
SetBlipAsShortRange(smeltBlip, true)
BeginTextCommandSetBlipName("STRING")
AddTextComponentString(Config.BlipSettings.smeltSettings.blipName)
EndTextCommandSetBlipName(smeltBlip)

-- Create blip for selling location
if Config.Selling.enabled then 
    local sellBlip = AddBlipForCoord(Config.Selling.coords.x, Config.Selling.coords.y, Config.Selling.coords.z)
    SetBlipSprite(sellBlip, Config.BlipSettings.sellSettings.blipSprite)
    SetBlipColour(sellBlip, Config.BlipSettings.sellSettings.blipColor)
    SetBlipScale(sellBlip, Config.BlipSettings.sellSettings.blipScale)
    SetBlipAsShortRange(sellBlip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(Config.BlipSettings.sellSettings.blipName)
    EndTextCommandSetBlipName(sellBlip)
end

-- Create zones, blips & zone functions for mining
for k, v in pairs(Config.MiningLocations) do
    local miningZones = lib.points.new(v, 3)
    local mineBlip = AddBlipForCoord(v.x, v.y, v.z)
    SetBlipSprite(mineBlip, Config.BlipSettings.mineSettings.blipSprite)
    SetBlipColour(mineBlip, Config.BlipSettings.mineSettings.blipColor)
    SetBlipScale(mineBlip, Config.BlipSettings.mineSettings.blipScale)
    SetBlipAsShortRange(mineBlip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(Config.BlipSettings.mineSettings.blipName)
    EndTextCommandSetBlipName(mineBlip)
    function miningZones:onEnter()
        if not Config.EnableNightMining then
            local hour = GetClockHours()
            if hour >= 20 or hour <= 4 then return
                lib.notify({
                    title = Notify.title,
                    description = Notify.mineAtNight,
                    icon = Notify.icon,
                    type = 'error',
                    position = Notify.position
                })
            end
        end
        local hasPick = lib.callback.await('lation_mining:hasItem', source, Config.PickaxeItemName)
        if hasPick >= 1 then
            textUI = true
            checkTextUI()
        else
            lib.notify({
                title = Notify.title,
                description = Notify.noPickaxe,
                icon = Notify.icon,
                type = 'error',
                position = Notify.position
            })
        end
    end
    function miningZones:onExit()
        lib.hideTextUI()
        textUI = false
    end
    function miningZones:nearby()
        if not Config.EnableNightMining then
            local hour = GetClockHours()
            if hour >= 20 or hour <= 4 then
                return
            else 
                if IsControlJustPressed(0, 38) then
                    local hasPick = lib.callback.await('lation_mining:hasItem', source, Config.PickaxeItemName)
                    if hasPick >= 1 then
                        lib.hideTextUI()
                        startMining()
                    else
                        -- no pickaxe
                    end
                end
            end
        else 
            if IsControlJustPressed(0, 38) then
                local hasPick = lib.callback.await('lation_mining:hasItem', source, Config.PickaxeItemName)
                if hasPick >= 1 then
                    lib.hideTextUI()
                    startMining()
                else
                    -- no pickaxe
                end
            end
        end
    end
end

-- Checks if the TextUI should be displayed or not and responds
function checkTextUI()
    if textUI then 
        lib.showTextUI(TextUI.label, {
            position = TextUI.position,
            icon = TextUI.icon
        })
    else
        lib.hideTextUI()
    end
end

-- Function that handles the mining process
function startMining()
    local durability = lib.callback.await('lation_mining:checkMetadata', 100, Config.PickaxeItemName)
    if durability ~= 0 then 
        if lib.progressCircle({
            label = ProgressCircle.miningLabel,
            duration = math.random(Config.MinMiningTime, Config.MaxMiningTime),
            position = ProgressCircle.position,
            useWhileDead = false,
            canCancel = true,
            disable = {car = true, move = true, combat = true},
            anim = {dict = 'melee@hatchet@streamed_core', clip = 'plyr_rear_takedown_b'},
            prop = {bone = 28422, model = 'prop_tool_pickaxe', pos = vec3(0.09, -0.05, -0.02), rot = vec3(-78.0, 13.0, 28.0)}
        }) then 
            textUI = true
            checkTextUI()
            local commonChance, mediumChance, rareChance = 60, 30, 10
            local totalChance = commonChance + mediumChance + rareChance
            local randomValue = math.random(1, totalChance)
            if randomValue <= commonChance then
                local reward = Config.CommonRewards[math.random(1, #Config.CommonRewards)]
                lib.callback('lation_mining:rewardMineItem', source, cb, reward)
            elseif randomValue <= commonChance + mediumChance then
                local reward = Config.MediumRewards[math.random(1, #Config.MediumRewards)]
                lib.callback('lation_mining:rewardMineItem', source, cb, reward)
            else
                local reward = Config.RareRewards[math.random(1, #Config.RareRewards)]
                lib.callback('lation_mining:rewardMineItem', source, cb, reward)
            end
        else
            lib.notify({
                title = Notify.title,
                description = Notify.cancelledMining,
                icon = Notify.icon,
                type = 'error',
                position = Notify.position
            })
            textUI = true
            checkTextUI()
        end
    else
        lib.notify({
            title = Notify.title,
            description = Notify.noDurability,
            icon = Notify.icon,
            type = 'error',
            position = Notify.position
        })
    end
end

-- Function that handles the smelting process
function startSmelt()
    if Config.Selling.enabled then
        local smeltInput = lib.inputDialog('Choose Material', {
            {type = 'select', label = 'Raw Material', description = 'What do you want to smelt?', required = true, icon = 'recycle', options = smeltingInputOptions},
            {type = 'number', label = 'Quantity', description = 'How many do you want to smelt?', icon = 'hashtag', required = true}
        })
        if smeltInput == nil then 
            smeltStarted = false
        else
            local hasItem = lib.callback.await('lation_mining:hasItem', source, smeltInput[1])
            if hasItem >= smeltInput[2] and smeltInput[2] ~= 0 and smeltInput[2] > 0 then
                local removeItem = nil
                local giveItem = nil
                local duration = nil
                for k, v in pairs(Config.SmeltingOptions) do 
                    if k == smeltInput[1] then 
                        removeItem = k
                        giveItem = k
                        duration = v.duration
                    end
                end
                if duration == nil then 
                    smeltStarted = false
                    return -- Something went wrong?
                else
                    if lib.progressCircle({
                        duration = duration * smeltInput[2],
                        label = ProgressCircle.smeltingLabel,
                        position = ProgressCircle.position,
                        useWhileDead = false,
                        canCancel = true,
                        anim = {dict = 'amb@world_human_stand_fire@male@idle_a', clip = 'idle_a'},
                        disable = {move = true, car = true, combat = true}
                    }) then
                        giveItem = giveItem:gsub("raw_", "")
                        lib.callback('lation_mining:rewardSmeltItem', source, cb, removeItem, giveItem, smeltInput[2])
                        smeltStarted = false
                    else
                        local itemString = smeltInput[1]:gsub('_', ' '):gsub("(%a)([%w_']*)", function(first, rest)
                            return first:upper() .. rest:lower()
                        end)
                        lib.notify({
                            title = Notify.title,
                            description = Notify.cancelledSmelting.. itemString,
                            icon = Notify.icon,
                            type = 'error',
                            position = Notify.position
                        })
                        smeltStarted = false
                    end
                end
            else
                local itemString = smeltInput[1]:gsub('_', ' '):gsub("(%a)([%w_']*)", function(first, rest)
                    return first:upper() .. rest:lower()
                end)
                lib.notify({
                    title = Notify.title,
                    description = Notify.missingItem.. itemString,
                    icon = Notify.icon,
                    type = 'error',
                    position = Notify.position
                })
                smeltStarted = false
            end
        end 
    else 
        -- Config.Selling.enabled not true
    end
end

if Config.Selling.enabled then 
    function startSelling()
        local sellInput = lib.inputDialog('Choose Material', {
            {type = 'select', label = 'Material', description = 'What do you want to sell?', required = true, icon = 'recycle', options = sellingInputOptions},
            {type = 'number', label = 'Quantity', description = 'How many do you want to sell?', icon = 'hashtag', required = true}
        })
        if sellInput == nil then 
            return -- Something went wrong?
        else
            local checkItem = sellInput[1]:gsub('raw_', '')
            local hasItem = lib.callback.await('lation_mining:hasItem', source, checkItem)
            if hasItem >= sellInput[2] and sellInput[2] ~= 0 and sellInput[2] > 0 then
                local price = nil
                for k, v in pairs(Config.SmeltingOptions) do 
                    if k == sellInput[1] then 
                        price = v.price 
                    end
                end
                price = price * sellInput[2]
                local sellItem = checkItem
                if lib.progressCircle({
                    duration = math.random(1500, 2500),
                    label = ProgressCircle.sellingLabel,
                    position = ProgressCircle.position,
                    useWhileDead = false,
                    canCancel = true,
                    anim = {dict = 'mp_common', clip = 'givetake1_a'},
                    disable = {move = true, car = true, combat = true}
                }) then
                    lib.callback('lation_mining:sellItem', source, cb, sellItem, sellInput[2], price)
                else
                    lib.notify({
                        title = Notify.title,
                        description = Notify.cancelledSell,
                        icon = Notify.icon,
                        type = 'error',
                        position = Notify.position
                    })
                end
            else
                lib.notify({
                    title = Notify.title,
                    description = Notify.missingItemSell,
                    icon = Notify.icon,
                    type = 'error',
                    position = Notify.position
                })
            end
        end
    end
end

-- Functions that run if selling is enabled
if Config.Selling.enabled then
    local sellingNPCOptions = {
        {
            icon = Target.sellIcon,
            label = Target.sellLabel,
            onSelect = function()
                startSelling()
            end,
            distance = 2
        }
    }

    function sellingNPCLocation:onEnter()
        spawnSellingNPC()
        ox_target:addLocalEntity(npc, sellingNPCOptions)
    end

    function sellingNPCLocation:onExit()
        DeleteEntity(npc)
        ox_target:removeLocalEntity(npc, nil)
    end

    function spawnSellingNPC()
        lib.RequestModel(Config.Selling.model)
        npc = CreatePed(0, Config.Selling.model, Config.Selling.coords.x, Config.Selling.coords.y, Config.Selling.coords.z, Config.Selling.heading, false, true)
        FreezeEntityPosition(npc, true)
        SetBlockingOfNonTemporaryEvents(npc, true)
        SetEntityInvincible(npc, true)
    end
end

-- Targeting options for smelting
local smeltOptions = {
	{
		icon = Target.smeltIcon,
		label = Target.smeltLabel,
        canInteract = function()
            if smeltStarted then 
                return false 
            else
                return true
            end
        end,
		onSelect = function()
            smeltStarted = true
			startSmelt()
		end,
        distance = 2
	}
}

-- Registering the box zone for the smelting area
ox_target:addBoxZone({
    coords = Config.SmeltingLocation,
    size = vec3(4.0, 3.3, 2.5),
    rotation = 50,
    debug = false,
    options = smeltOptions
})