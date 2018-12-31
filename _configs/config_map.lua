--[[
config_map.lua

Configuration for maps.
]]

--#[Amount of Maps]#--
--Default: 1
--About: Sets the amount of maps that are available. Corresponds to the config "availableMaps".
amountOfMaps = 2

--#[Available Maps]#--
--Default: None
--About: Sets the path to load maps. Place the XML files in the same folder as the server config is.
availableMaps = {"wreckfest_spawn_v1.0.0_covered.xml", "wreckfest_ls_airport_arena_v1.0.0_covered.xml"}

--#[Spawn Points]#--
--About: Table that stores spawn points for the map.
spawnPoints = {
    map1 = 
    {
        name = "wreckfest_spawn_v1.0.0_covered.xml",
        spawn = 
        {
            {
                x = -1943.6870117188,
                y = -1748.6483154297,
                z = 12.547177314758,
                heading = 312.54504394531
            }
        }
    },
    map2 = 
    {
        name = "wreckfest_ls_airport_arena_v1.0.0_covered.xml",
        spawn = 
        {
            {
                x = -1346.8918457031,
                y = -2230.4304199219,
                z = 13.944833755493,
                heading = 147.17723083496
            },
            {
                x = -1740.8040771484,
                y = -2910.7253417969,
                z = 13.944264411926,
                heading = 279.08349609375
            },
            {
                x = -1099.6586914063,
                y = -3412.8044433594,
                z = 13.945055961609,
                heading = 25.713531494141
            },
            {
                x = -1342.3044433594,
                y = -2708.30078125,
                z = 13.944927215576,
                heading = 144.86895751953
            }
        }
    }
}