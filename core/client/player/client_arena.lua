--[[
client_arena.lua

Functionality to handle the player while they are in the arena.
]]

--#[Citizen Threads]#--
Citizen.CreateThread(function()
    while true do 
        if enterArena then --variable from client script client_terminal_manager.lua
            if not isBuildTimerActive then --variable from client script client_player.lua
                if currentVehicle ~= nil then --variable from client script client_sync_vehicles.lua
                    if isPlayerInSpawn then --variable from client script client_player.lua
                        if not isPlayerInArena then --variable from client script client_player.lua
                            local ranSpawn = math.random(1, #mapSpawnPoints["2"]) --table from clinet script client_map_loader.lua
                            local inc = 0

                            for k, v in pairs(mapSpawnPoints["2"]) do
                                inc = inc + 1

                                if inc == ranSpawn then
                                    TaskWarpPedIntoVehicle(GetPlayerPed(-1), currentVehicle, -1)
                                    
                                    SetEntityCoords(currentVehicle, tonumber(v.x), tonumber(v.y), tonumber(v.z))
                                    SetEntityHeading(currentVehicle, tonumber(v.heading))
                                    FreezeEntityPosition(currentVehicle, false)
                                    SetEntityInvincible(currentVehicle, false)

                                    break
                                end
                            end

                            isPlayerInArena = true
                        end

                        isPlayerInSpawn = false
                    end
                else
                    DrawNotificationMinimap("~r~Can't enter the Arena with no vehicle!", "[User Terminal]") --function from client script client_ui.lua

                    enterArena = false
                end
            else
                DrawNotificationMinimap("~r~The arena is closed!~w~ Please wait until the arena opens.", "[User Terminal]") --function from client script client_ui.lua
            
                enterArena = false
            end
        end

        if isPlayerInArena then
            if not isRoundTimerActive then --variable from client script client_player.lua
                local plyPed = GetPlayerPed(-1)

                enterArena = false

                SetEntityCoords(currentVehicle, plyerPlatformPos.x, plyerPlatformPos.y, plyerPlatformPos.z + 4.0)
                SetEntityHeading(currentVehicle, 272.64904785156)
                TaskLeaveVehicle(plyPed, currentVehicle, 16)

                isPlayerInSpawn = true --variable from client script client_player.lua
                isPlayerInArena = false
                isPlayerInSpawn = true
            end
        end

        Citizen.Wait(1)
    end
end)