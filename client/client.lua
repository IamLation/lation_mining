local qtarget = exports.qtarget
local sellingNPCLocation = lib.points.new(Config.Selling.coords, 40)
local textUI, smeltStarted, failedAntiCheat = false, false, false
local smeltingInputOptions, sellingInputOptions = {}, {}

-- Ensures all options from Config.SmeltingOptions are inserted into the Input Dialog
for k, v in pairs(Config.SmeltingOptions) do
    if v.smeltable then
        table.insert(smeltingInputOptions, {value = k, label = v.label})
    end
end

-- Ensures all options from Config.SmeltingOptions are inserted into the Input Dialog
if Config.Selling.enabled then
    for k, v in pairs(Config.SmeltingOptions) do
        if v.sellable then
            local label = v.label
            if string.sub(k, 1, 4) == "raw_" then
                label = string.sub(v.label, 5)
            end
            table.insert(sellingInputOptions, { value = k, label = label })
        end
    end
end

-- Checks if the TextUI should be displayed or not and responds
local function checkTextUI()
    if textUI then
        lib.showTextUI(TextUI.label, {
            position = TextUI.position,
            icon = TextUI.icon
        })
    else
        lib.hideTextUI()
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
for _, v in pairs(Config.MiningLocations) do
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
                ShowNotification(Notify.mineAtNight, 'error')
            end
        end
        local hasPick = HasItem(Config.PickaxeItemName, 1)
        if hasPick >= 1 then
            textUI = true
            checkTextUI()
        else
            ShowNotification(Notify.noPickaxe, 'error')
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
                    local hasPick = HasItem(Config.PickaxeItemName, 1)
                    if hasPick >= 1 then
                        lib.hideTextUI()
                        startMining()
                    else
                        -- Player does not have a pickaxe
                    end
                end
            end
        else
            if IsControlJustPressed(0, 38) then
                local hasPick = HasItem(Config.PickaxeItemName, 1)
                if hasPick >= 1 then
                    lib.hideTextUI()
                    startMining()
                else
                    -- Player does not have a pickaxe
                end
            end
        end
    end
end

-- Function that handles the mining process
function startMining()
    if failedAntiCheat then
        local success = lib.skillCheck({'easy'}, {'w'})
        if success then
            -- If the player passes, resets and let them continue
            failedAntiCheat = false
        else
            -- If the player fails again, don't let them continue
            return
        end
    end
    if Config.Anticheat then
        local chance = math.random(1, 100)
        if chance <= Config.AnticheatChance then
            local success = lib.skillCheck({'easy'}, {'w'})
            if not success then
                failedAntiCheat = true
                return
            end
        end
    end
    if Config.BreakPickaxe then
        local chance = math.random(1, 100)
        if chance <= Config.BreakChance then
            TriggerServerEvent('lation_mining:breakPickaxe', cache.serverId)
            ShowNotification(Notify.pickaxeBroke, 'error')
        end
    end
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
            TriggerServerEvent('lation_mining:rewardMineItem', cache.serverId, reward)
        elseif randomValue <= commonChance + mediumChance then
            local reward = Config.MediumRewards[math.random(1, #Config.MediumRewards)]
            TriggerServerEvent('lation_mining:rewardMineItem', cache.serverId, reward)
        else
            local reward = Config.RareRewards[math.random(1, #Config.RareRewards)]
            TriggerServerEvent('lation_mining:rewardMineItem', cache.serverId, reward)
        end
    else
        ShowNotification(Notify.cancelledMining, 'error')
        textUI = true
        checkTextUI()
    end
end

-- Function that handles the smelting process
function startSmelt()
    local smeltInput = lib.inputDialog(InputDialog.smeltTitle, {
        {type = 'select', label = InputDialog.smeltSelectMaterial, description = InputDialog.smeltSelectMaterialDesc, required = true, icon = InputDialog.smeltSelectMaterialIcon, options = smeltingInputOptions},
        {type = 'number', label = InputDialog.smeltSelectQuantity, description = InputDialog.smeltSelectQuantityDesc, icon = InputDialog.smeltSelectQuantityIcon, required = true}
    })
    if smeltInput == nil then
        smeltStarted = false
    else
        local hasItem = HasItem(smeltInput[1], smeltInput[2])
        if hasItem ~= nil and hasItem >= smeltInput[2] and smeltInput[2] ~= 0 and smeltInput[2] > 0 then
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
                    TriggerServerEvent('lation_mining:rewardSmeltItem', cache.serverId, removeItem, giveItem, smeltInput[2])
                    smeltStarted = false
                else
                    local itemString = smeltInput[1]:gsub('_', ' '):gsub("(%a)([%w_']*)", function(first, rest)
                        return first:upper() .. rest:lower()
                    end)
                    ShowNotification(Notify.cancelledSmelting.. itemString, 'error')
                    smeltStarted = false
                end
            end
        else
            local itemString = smeltInput[1]:gsub('_', ' '):gsub("(%a)([%w_']*)", function(first, rest)
                return first:upper() .. rest:lower()
            end)
            ShowNotification(Notify.missingItem.. itemString, 'error')
            smeltStarted = false
        end
    end
end

if Config.Selling.enabled then
    function startSelling()
        local sellInput = lib.inputDialog(InputDialog.sellTitle, {
            {type = 'select', label = InputDialog.sellSelectMaterial, description = InputDialog.sellSelectMaterialDesc, required = true, icon = InputDialog.sellSelectMaterialIcon, options = sellingInputOptions},
            {type = 'number', label = InputDialog.sellSelectQuantity, description = InputDialog.sellSelectQuantityDesc, icon = InputDialog.sellSelectQuantityIcon, required = true}
        })
        if sellInput == nil then
            return -- Something went wrong?
        else
            local checkItem = sellInput[1]:gsub('raw_', '')
            local hasItem = HasItem(checkItem, sellInput[2])
            if hasItem ~= nil and hasItem >= sellInput[2] and sellInput[2] ~= 0 and sellInput[2] > 0 then
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
                    TriggerServerEvent('lation_mining:sellItem', cache.serverId, sellItem, sellInput[2], price)
                else
                    ShowNotification(Notify.cancelledSell, 'error')
                end
            else
                ShowNotification(Notify.missingItemSell, 'error')
            end
        end
    end
end

-- Functions that run if selling is enabled
if Config.Selling.enabled then
    function sellingNPCLocation:onEnter()
        spawnSellingNPC()
        qtarget:AddTargetEntity(npc, {
            options = {
                {
                    icon = Target.sellIcon,
                    label = Target.sellLabel,
                    action = function()
                        startSelling()
                    end,
                    distance = 2
                }
            }
        })
    end
    function sellingNPCLocation:onExit()
        DeleteEntity(npc)
        qtarget:RemoveTargetEntity(npc, nil)
    end
    function spawnSellingNPC()
        lib.RequestModel(Config.Selling.model)
        npc = CreatePed(0, Config.Selling.model, Config.Selling.coords.x, Config.Selling.coords.y, Config.Selling.coords.z, Config.Selling.heading, false, true)
        FreezeEntityPosition(npc, true)
        SetBlockingOfNonTemporaryEvents(npc, true)
        SetEntityInvincible(npc, true)
    end
end

-- Registering the box zone for the smelting area
qtarget:AddBoxZone('smelting', Config.SmeltingLocation, 4.0, 4.2, {
    name = 'smeltingZone',
    heading = 50.0,
    debugPoly = false,
    minZ = 30.5,
    maxZ = 32.5,
}, {
    options = {
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
            action = function()
                smeltStarted = true
                startSmelt()
            end
        }
    },
    distance = 2
})