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
                                    enableVehicleInvincibility = false --variable from client script client_player.lua
                                    enablePlyInvincibility = false --variable from client script client_player.lua

                                    break
                                end
                            end

                            displayUserMenu(false) --function from client script client_ui.lua
                            displayScaleform(false) --function from client script client_ui.lua

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
            local plyPed = GetPlayerPed(-1)

            SetVehicleDoorsLocked(currentVehicle, 2)
            SetVehicleDoorsLocked(currentVehicle, 4)

            if not isRoundTimerActive then --variable from client script client_player.lua
                enterArena = false

                SetEntityCoords(currentVehicle, plyerPlatformPos.x, plyerPlatformPos.y, plyerPlatformPos.z + 4.0)
                SetEntityHeading(currentVehicle, 272.64904785156)
                TaskLeaveVehicle(plyPed, currentVehicle, 16)

                if numOwnProps > 0 then --variable from client script client_sync_props.lua
                    displayUserMenu(true) --function from client script client_ui.lua
                    displayScaleform(true) --function from client script client_ui.lua
                end

                isPlayerInSpawn = true --variable from client script client_player.lua
                isPlayerInArena = false
                isPlayerInSpawn = true
            end
        end

        Citizen.Wait(1)
    end
end)