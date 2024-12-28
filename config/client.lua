return {

    ----------------------------------------------
    --     💃 Customize animations & props
    ----------------------------------------------

    anims = {
        mining = {
            label = 'Mining..',
            position = 'bottom',
            useWhileDead = false,
            canCancel = true,
            disable = { car = true, move = true, combat = true },
            anim = { dict = 'melee@hatchet@streamed_core', clip = 'plyr_rear_takedown_b', flag = 1 },
            prop = { bone = 28422, model = 'prop_tool_pickaxe', pos = vec3(0.09, -0.05, -0.02), rot = vec3(-78.0, 13.0, 28.0) }
        },
        smelting = {
            scenario = 'WORLD_HUMAN_STAND_FIRE'
        }
    },

    ----------------------------------------------
    --     📊 Customize stats & leaderboard
    ----------------------------------------------

    -- Don't want to show the stats menu option at all?
    -- Set all stats below to false!
    stats = {
        -- Do you want to show the ores mined stat?
        mined = true,
        -- Do you want to show the ingots smelted stat?
        smelted = true,
        -- Do you want to show the money earned stat?
        earned = true
    },

    -- Do you want to display the leaderboard?
    -- This shows the top 10 miners by XP
    -- 🗒️ Note: the leaderboard is not updated constantly
    -- It is only updated on server restarts & player logouts
    leaderboard = true

}