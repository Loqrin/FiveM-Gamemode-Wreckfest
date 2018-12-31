--[[
server_map_loader.lua

Functionality to load maps from XML file and send it to the clients.
]]

--#[Local Variables]#--
local mapToLoad = "wreckfest_ls_airport_arena_v1.0.0_covered.xml"
local spawnMapName = "wreckfest_spawn_v1.0.0_covered.xml"

local mapData = {}

--#[Local Functions]#--
local function createTable(data)
	return data
end

local function readXMLFile(xml)
	local readLine = ""

    for line in io.lines(xml) do
        if string.match(line, "<MapObject") then
            line = "<MapObject>"
        elseif string.match(line, "/MapObject") then
            line = "</MapObject>"
        end

        readLine = readLine .. "\n" .. line
	end

	return readLine
end

local function loadMapData()
	print("")
	print("--#[Map Loader]#--")
	print("")
	print("#] Reading XML files...                           ")
	print("#] Parsing XML files...                           ")
	print("#] Successfully read & parsed the following:      ")
	print(" ")

    for i = 1, amountOfMaps do --variable from config file config_map.lua
        local callBack = XmlParser:ParseXmlText(readXMLFile(availableMaps[i]))

        mapData[i] = {name = availableMaps[i]}

        for k, v in pairs(callBack.Data.MapObject) do
            table.insert(mapData[i], createTable({
                x = tonumber(v.x:value()),
                y = tonumber(v.y:value()),
                z = tonumber(v.z:value()),
                rotX = tonumber(v.rotX:value()),
                rotY = tonumber(v.rotY:value()),
                rotZ = tonumber(v.rotZ:value()),
                hash = v.h:value()
            }))
        end
        
        print(i .. "] " .. mapData[i].name)
	end

    print(" ")
end

local function requestMapData(plySource, loadSpawn)
    if loadSpawn then
        for k, v in pairs(spawnPoints) do --table from config file config_map.lua
            if v.name == spawnMapName then
                local mapIndex = 1

                for i = 1, amountOfMaps do --variable from config file config_map.lua
                    if mapData[i].name == spawnMapName then
                        mapIndex = i

                        break
                    end
                end

                for m, n in pairs(mapData[mapIndex]) do 
                    if n.hash == "prop_helipad_02" then
                        table.insert(plyerPlatforms, createTable({ --table from server script server_sync_platforms.lua
                            plyer = nil,
                            x = n.x,
                            y = n.y,
                            z = n.z,
                            hash = n.hash
                        }))
                    elseif n.hash == "xm_prop_base_computer_06" then
                        table.insert(plyerTerminals, createTable({ --table from server script server_sync_platforms.lua
                            plyer = nil,
                            x = n.x,
                            y = n.y,
                            z = n.z,
                            hash = n.hash
                        }))
                    end
                end

                TriggerClientEvent("client_map_loader:receiveMapData", plySource, mapIndex, mapData[mapIndex], v.spawn)

                break
            end
        end
    end

    for k, v in pairs(spawnPoints) do --table from config file config_map.lua
        if v.name == mapToLoad then
            local mapIndex = 1

            for i = 1, amountOfMaps do --variable from config file config_map.lua
                if mapData[i].name == mapToLoad then
                    mapIndex = i

                    break
                end
            end
            
            print(mapData[mapIndex].name)
            
            TriggerClientEvent("client_map_loader:receiveMapData", plySource, mapIndex, mapData[mapIndex], v.spawn)

            break
        end
    end
end

loadMapData() -- Tell server to load map data from XML

--#[Event Handlers]#--
RegisterServerEvent("server_map_loader:requestMapData")
AddEventHandler("server_map_loader:requestMapData", function(loadSpawn)
    requestMapData(source, loadSpawn)
end)

