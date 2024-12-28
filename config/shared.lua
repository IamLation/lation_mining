return {

    -- ⚠️ WARNING: When you are working with this script, never do "restart lation_mining"
    -- ⚠️ This will cause issues, data loss & more! You must restart the script like this:
    -- ⚠️ "stop lation_mining" ..wait a couple seconds.. then "ensure lation_mining"

    -- 🔎 Looking for more high quality scripts?
    -- 🛒 Shop Now: https://lationscripts.com
    -- 💬 Join Discord: https://discord.gg/9EbY4nM5uu
    -- 😢 How dare you leave this option false?!
    YouFoundTheBestScripts = false,

    ----------------------------------------------
    --        🛠️ Setup the basics below
    ----------------------------------------------

    setup = {
        -- Use only if needed, directed by support or know what you're doing
        -- Notice: enabling debug features will significantly increase resmon
        -- And should always be disabled in production
        debug = false,
        -- Set your interaction system below
        -- Available options are: 'ox_target', 'qb-target', 'interact' & 'custom'
        -- 'custom' needs to be added to client/functions.lua
        interact = 'ox_target',
        -- Set your notification system below
        -- Available options are: 'ox_lib', 'esx', 'qb', 'okok', 'sd-notify', 'wasabi_notify' & 'custom'
        -- 'custom' needs to be added to client/functions.lua
        notify = 'ox_lib',
        -- Set your progress bar system below
        -- Available options are: 'ox_lib', 'qbcore' & 'custom'
        -- 'custom' needs to be added to client/functions.lua
        -- Any custom progress bar must also support animations
        progress = 'ox_lib',
        -- Do you want to be notified via server console if an update is available?
        -- True if yes, false if no
        version = true,
    },

    ----------------------------------------------
    --       📈 Customize the XP system
    ----------------------------------------------

    experience = {
        -- The number in these [brackets] are the level
        -- The number after = is the exp required to reach that level
        -- Be sure levels *always* start at level 1 with 0 exp
        [1] = 0,
        [2] = 2500,
        [3] = 10000,
        [4] = 20000,
        [5] = 50000,
        -- You can add or remove levels as you wish
    },

    ----------------------------------------------
    --       🪓 Customize your pickaxes
    ----------------------------------------------

    pickaxes = {
        -- The number in [brackets] is the level required to buy/craft/use this pickaxe
        -- item: is the actual pickaxe item spawn name
        -- degrade: is how much the pickaxe degrades per mining action
        -- By default, normal pickaxe can mine 100 ores before breaking
        [1] = { item = 'ls_pickaxe', degrade = 1 },
        -- The copper pickaxe can mine 133 ores before breaking
        [2] = { item = 'ls_copper_pickaxe', degrade = 0.75 },
        -- The iron pickaxe can mine 200 ores before breaking
        [3] = { item = 'ls_iron_pickaxe', degrade = 0.5 },
        -- The silver pickaxe can mine 400 ores
        [4] = { item = 'ls_silver_pickaxe', degrade = 0.25 },
        -- And the gold pickaxe can mine 1,000 ores
        [5] = { item = 'ls_gold_pickaxe', degrade = 0.1 },
        -- The number of ores mined per pickaxe is simply: 100 / X
    },

    ----------------------------------------------
    --          🛒 Setup your shops
    ----------------------------------------------

    shops = {
        -- The location to spawn the main ped at the mine
        -- Both shops are available at this main ped, but you can toggle
        -- Either shop on or off as needed
        location = vec4(2943.1362, 2747.8320, 43.3318, 252.1999),
        -- The ped model used
        -- More models: https://docs.fivem.net/docs/game-references/ped-models/
        model = 'a_m_m_farmer_01',
        -- The scenario assigned to the ped (or nil/false for no scenario)
        -- More scenarios: https://github.com/DioneB/gtav-scenarios
        scenario = 'WORLD_HUMAN_DRINKING',
        -- What hours is this shop available?
        -- By default, it's 24/7, but for example - if you wish to only
        -- Allow access during the day, set hours = { min = 6, max = 20 }
        hours = { min = 0, max = 24 },
        -- Customize the mines supply shop
        -- This shop sells items to player
        mine = {
            -- Optionally disable this shop if you wish to grant access to
            -- Mining supplies via another method
            enable = true,
            -- Use cash or bank when purchasing here?
            account = 'cash',
            -- Items available for sale in this shop
            items = {
                -- item: item spawn name
                -- price: price of item
                -- icon: icon for item
                -- metadata: optional metadata for item
                -- metadata: ⚠️ use 'durability' if using ox_inventory, otherwise use 'quality'
                -- level: optional player level requirement to purchase item
                [1] = { item = 'ls_pickaxe', price = 150, icon = 'hammer', metadata = { ['durability'] = 100 }, level = 1 },
                [2] = { item = 'ls_copper_pickaxe', price = 300, icon = 'hammer', metadata = { ['durability'] = 100 }, level = 2 },
                [3] = { item = 'ls_iron_pickaxe', price = 750, icon = 'hammer', metadata = { ['durability'] = 100 }, level = 3 },
                [4] = { item = 'ls_silver_pickaxe', price = 1500, icon = 'hammer', metadata = { ['durability'] = 100 }, level = 4 },
                [5] = { item = 'ls_gold_pickaxe', price = 3000, icon = 'hammer', metadata = { ['durability'] = 100 }, level = 5 },
                [6] = { item = 'water', price = 5, icon = 'droplet' },
                [7] = { item = 'burger', price = 5, icon = 'burger' },
                -- Add or remove items as you wish
            },
        },
        -- Customize the mines pawn shop
        -- This shop will buy items from players
        pawn = {
            enable = true,
            account = 'cash',
            items = {
                [1] = { item = 'ls_coal_ore', price = 2, icon = 'hand-holding-dollar' },
                [2] = { item = 'ls_copper_ore', price = 3, icon = 'hand-holding-dollar' },
                [3] = { item = 'ls_iron_ore', price = 5, icon = 'hand-holding-dollar' },
                [4] = { item = 'ls_silver_ore', price = 10, icon = 'hand-holding-dollar' },
                [5] = { item = 'ls_gold_ore', price = 20, icon = 'hand-holding-dollar' },
                [6] = { item = 'ls_copper_ingot', price = 35, icon = 'hand-holding-dollar' },
                [7] = { item = 'ls_iron_ingot', price = 60, icon = 'hand-holding-dollar'},
                [8] = { item = 'ls_silver_ingot', price = 100, icon = 'hand-holding-dollar' },
                [9] = { item = 'ls_gold_ingot', price = 175, icon = 'hand-holding-dollar' },
                -- Add or remove items as you wish
            }
        },
        -- Manage blip settings if desired
        blip = {
            enable = true, -- Enable or disable the blip for this shop
            sprite = 618, -- Sprite ID (https://docs.fivem.net/docs/game-references/blips/)
            color = 5, -- Color (https://docs.fivem.net/docs/game-references/blips/#blip-colors)
            scale = 0.9, -- Size/scale
            label = 'The Mines' -- Label
        }
    },

    ----------------------------------------------
    --           ⛏️ Build the mines
    ----------------------------------------------

    mining = {
        -- The center-most coords of the entire mining area
        center = vec3(2946.6995, 2792.2271, 40.5708),
        -- What hours is mining allowed to happen?
        -- By default, it's 24/7, but for example - if you wish to only
        -- Allow mining during the day, set hours = { min = 6, max = 20 }
        hours = { min = 0, max = 24 },
        -- Build individual mining areas with specific ores
        zones = {
            [1] = {
                -- The models spawned in this area
                -- You can use one or more models, it will select at random for each ore spawn
                models = { 'prop_rock_3_b', 'prop_rock_3_d', 'prop_rock_3_f' },
                -- What level must the player be to mine these?
                level = 1,
                -- How long it takes to mine these ores (in milliseconds)
                duration = { min = 2500, max = 2500 },
                -- A table containing all possible rewards from these rocks
                -- item: the item spawn name
                -- min: the minimum amount to reward
                -- max: the maximum amount to reward
                -- chance: optional percentage chance variable
                -- (if no chance is set, it will be considered 100%)
                reward = {
                    { item = 'ls_copper_ore', min = 1, max = 2 },
                    -- { item = 'example_rare_item', min = 1, max = 1, chance = 5 },
                    -- Add or remove items as desired following the format above
                },
                -- How much XP is given for each (x1) ore mined?
                xp = { min = 1, max = 3 },
                -- How long after being mined do these ores respawn (in milliseconds)
                respawn = 25000,
                -- The coordinates these ores spawn at
                ores = {
                    [1] = vec3(2949.8770, 2851.0256, 48.3509),
                    [2] = vec3(2955.0566, 2850.1597, 47.6026),
                    [3] = vec3(2959.4751, 2848.0740, 46.8103),
                    [4] = vec3(2952.2109, 2847.9136, 47.2530),
                    [5] = vec3(2956.3149, 2845.9241, 46.5613),
                    [6] = vec3(2947.4197, 2848.0171, 47.7500),
                    [7] = vec3(2961.4399, 2844.1255, 46.0608),
                }
            },
            [2] = {
                models = { 'prop_rock_3_b', 'prop_rock_3_d', 'prop_rock_3_f' },
                level = 1,
                duration = { min = 2500, max = 2500 },
                reward = {
                    { item = 'ls_coal_ore', min = 1, max = 2 },
                },
                xp = { min = 1, max = 3 },
                respawn = 25000,
                ores = {
                    [1] = vec3(2938.3345, 2808.9683, 42.1674),
                    [2] = vec3(2930.3652, 2811.0193, 43.4722),
                    [3] = vec3(2925.0359, 2807.3450, 42.9333),
                    [4] = vec3(2927.2339, 2799.7976, 41.3330),
                    [5] = vec3(2930.2278, 2794.4519, 40.6447),
                    [6] = vec3(2935.8081, 2795.5881, 40.6888),
                    [7] = vec3(2940.8623, 2800.0393, 40.9543),
                    [8] = vec3(2935.3396, 2802.2466, 41.2976),
                    [9] = vec3(2932.2173, 2806.7004, 42.2299),
                    [10] = vec3(2941.5352, 2805.1804, 41.1859),
                }
            },
            [3] = {
                models = { 'prop_rock_3_b', 'prop_rock_3_d', 'prop_rock_3_f' },
                level = 2,
                duration = { min = 7500, max = 7500 },
                reward = {
                    { item = 'ls_iron_ore', min = 1, max = 2 },
                },
                xp = { min = 2, max = 6 },
                respawn = 45000,
                ores = {
                    [1] = vec3(3027.8311, 2772.1812, 55.4793),
                    [2] = vec3(3030.8904, 2767.5234, 56.4680),
                    [3] = vec3(3028.2546, 2764.4390, 56.0667),
                    [4] = vec3(3030.5837, 2760.3337, 57.4613),
                    [5] = vec3(3025.9062, 2756.8679, 56.0076),
                    [6] = vec3(3026.0994, 2751.2605, 57.2785),
                    [7] = vec3(3020.6831, 2748.7808, 55.5372),
                }
            },
            [4] = {
                models = { 'prop_rock_3_b', 'prop_rock_3_d', 'prop_rock_3_f' },
                level = 3,
                duration = { min = 7500, max = 7500 },
                reward = {
                    { item = 'ls_silver_ore', min = 1, max = 2 },
                },
                xp = { min = 3, max = 9 },
                respawn = 75000,
                ores = {
                    [1] = vec3(2969.4246, 2697.7976, 54.5088),
                    [2] = vec3(2966.6487, 2694.4221, 54.6609),
                    [3] = vec3(2962.9324, 2697.2637, 54.6642),
                    [4] = vec3(2953.2451, 2697.2317, 55.1387),
                    [5] = vec3(2950.2148, 2700.9580, 54.8590),
                }
            },
            [5] = {
                models = { 'prop_rock_3_b', 'prop_rock_3_d', 'prop_rock_3_f' },
                level = 4,
                duration = { min = 13000, max = 13000 },
                reward = {
                    { item = 'ls_gold_ore', min = 1, max = 2 },
                },
                xp = { min = 4, max = 12 },
                respawn = 120000,
                ores = {
                    [1] = vec3(3041.3960, 2719.4390, 63.1831),
                    [2] = vec3(3047.6887, 2717.8809, 62.7571),
                    [3] = vec3(3045.9670, 2722.4072, 63.1737),
                    [4] = vec3(3052.4326, 2721.9761, 63.1375),
                    [5] = vec3(3052.2554, 2728.0950, 63.6344),
                    [6] = vec3(3058.0610, 2731.1460, 64.6821),
                    [7] = vec3(3055.9949, 2737.5295, 64.3239),
                    [8] = vec3(3060.6294, 2741.4951, 64.5270),
                    [9] = vec3(3058.5295, 2746.5312, 64.3540),
                    [10] = vec3(3060.2603, 2750.5828, 64.3339),
                }
            },
            -- You can add or remove zones as you wish
            -- Be sure to follow the same format as above
        }
    },

    ----------------------------------------------
    --           🔥 Setup smelting
    ----------------------------------------------

    smelting = {
        -- Where do you want the smelter to be?
        coords = vec3(1087.6827, -2002.1394, 31.4841),
        -- The types of ingots that can be smelted from ores
        ingots = {
            [1] = {
                -- The display name for this ingot in the menu
                name = 'Copper Ingot',
                -- The icon used
                icon = 'fas fa-fire',
                -- The player level required to smelt this
                level = 1,
                -- How long it takes to smelt x1 ingot (in milliseconds)
                duration = 10000,
                -- The maximum amount you can smelt in one session
                -- This is an optional feature to combat excessive AFK
                max = 20,
                -- How much XP to add for each ingot smelted?
                xp = { min = 3, max = 6 },
                -- Ores/items that are required to smelt this
                required = {
                    { item = 'ls_coal_ore', quantity = 5 },
                    { item = 'ls_copper_ore', quantity = 5 },
                    -- You can add or remove additional items as desired
                },
                -- Ingots/items that are added after smelting
                add = {
                    { item = 'ls_copper_ingot', quantity = 1 },
                    -- You can add or remove additional items as desired
                },
            },
            [2] = {
                name = 'Iron Ingot',
                icon = 'fas fa-fire',
                level = 2,
                duration = 15000,
                max = 15,
                xp = { min = 4, max = 8 },
                required = {
                    { item = 'ls_coal_ore', quantity = 10 },
                    { item = 'ls_iron_ore', quantity = 5 },
                },
                add = {
                    { item = 'ls_iron_ingot', quantity = 1 },
                },
            },
            [3] = {
                name = 'Silver Ingot',
                icon = 'fas fa-fire',
                level = 3,
                duration = 20000,
                max = 10,
                xp = { min = 5, max = 10 },
                required = {
                    { item = 'ls_coal_ore', quantity = 15 },
                    { item = 'ls_silver_ore', quantity = 5 },
                },
                add = {
                    { item = 'ls_silver_ingot', quantity = 1 },
                },
            },
            [4] = {
                name = 'Gold Ingot',
                icon = 'fas fa-fire',
                level = 4,
                duration = 25000,
                max = 5,
                xp = { min = 6, max = 12 },
                required = {
                    { item = 'ls_coal_ore', quantity = 20 },
                    { item = 'ls_gold_ore', quantity = 5 },
                },
                add = {
                    { item = 'ls_gold_ingot', quantity = 1 },
                },
            },
        },
        -- Manage blip settings if desired
        blip = {
            enable = true, -- Enable or disable the blip for this area
            sprite = 648, -- Sprite ID (https://docs.fivem.net/docs/game-references/blips/)
            color = 17, -- Color (https://docs.fivem.net/docs/game-references/blips/#blip-colors)
            scale = 0.9, -- Size/scale
            label = 'Smelter' -- Label
        }
    }


}