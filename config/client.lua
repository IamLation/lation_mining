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
            anim = { dict = 'amb@world_human_hammering@male@base', clip = 'base', flag = 1 },
            prop = { bone = 57005, model = 'prop_tool_pickaxe', pos = vec3(0.10, -0.25, 0.0), rot = vec3(90.0, 0.0, 180.0) }
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
