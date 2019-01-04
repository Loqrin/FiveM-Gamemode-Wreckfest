--[[
client_player.lua

Functionality provided for the player.
]]

--#[Global Variables]#--
plyDead = false
plyerData = {money = 0, vehicles = {}}

isPlayerInSpawn = false
isPlayerInArena = false

isBuildTimerActive = false
isRoundTimerActive = false

--#[Local Variables]#--
local isScoreboardDisplaying = false

--#[Local Functions]#--
local function appendScoreboard(plyID, plyName, kills, deaths)
    scoreboardAddPlyer(plyID, plyName, kills, deaths) --function from client script client_ui.lua
end

local function updateScoreboard(plyID, plyName, kills, deaths)
    scoreboardUpdatePlyer(plyID, plyName, kills, deaths) --function from client script client_ui.lua
end

--#[Citizen Threads]#--
Citizen.CreateThread(function()
    while true do
        local plyPed = GetPlayerPed(-1)

        if IsPedDeadOrDying(plyPed, 1) and not plyDead then
            plyDead = true

            displayBlackoutMenu(true) --function from client script client_ui.lua

            Citizen.Wait(3000)

            TriggerServerEvent("server_sync_player:updateScoreboard", GetPlayerName(PlayerId()), false, true)

            spawnPlayer() --function from client script client_spawn.lua

            Citizen.Wait(1000)

            displayBlackoutMenu(false)

            plyDead = false
        end

        if isPlayerInSpawn then
            DisableControlAction(1, keys.MouseLeftClick, true)
            DisableControlAction(1, keys.ScrollUp, true)
            DisableControlAction(1, keys.ScrollUp2, true)
            DisableControlAction(1, keys.ScrollDown, true)
            DisableControlAction(1, keys.ScrollDown2, true)
            DisableControlAction(1, keys.Space, true)

            SetEntityInvincible(plyPed, true)

            if currentVehicle ~= nil then
                SetEntityInvincible(currentVehicle, true)
                SetVehicleDoorsLocked(currentVehicle, 2)
                FreezeEntityPosition(currentVehicle, true)
            end
        end

        Citizen.Wait(1)
    end
end)

Citizen.CreateThread(function()
    while true do 
        local plyPed = GetPlayerPed(-1)

        for k, v in pairs(ownProps) do --table from client script client_sync_props.lua
            if HasEntityBeenDamagedByWeapon(tonumber(v.localID), 0, 2) and tonumber(v.health) > 0 then
                TriggerServerEvent("server_sync_props:checkPropHealth", v.serverID, v.health, GetSelectedPedWeapon(plyPed), nil)

                ClearEntityLastDamageEntity(tonumber(v.localID))
            end
        end

        for k, v in pairs(plyersProps) do --table from client script client_sync_props.lua
            if HasEntityBeenDamagedByWeapon(tonumber(v.localID), 0, 2) and tonumber(v.health) > 0 then
                TriggerServerEvent("server_sync_props:checkPropHealth", v.serverID, GetEntityHealth(v.localID), GetSelectedPedWeapon(plyPed), nil)

                ClearEntityLastDamageEntity(tonumber(v.localID))
            end
        end

        Citizen.Wait(100)
    end
end)

Citizen.CreateThread(function()
    local deadPeds = {}

    while true do
        local plyPed = GetPlayerPed(-1)
        local aiming, target = GetEntityPlayerIsFreeAimingAt(PlayerId())

        DisableControlAction(1, keys.Tab, true)

        if not IsPedDeadOrDying(plyPed) then --variable from client script player.lua
            if IsDisabledControlPressed(1, keys.Tab) then
                if not isScoreboardDisplaying then
                    isScoreboardDisplaying = true

                    displayScoreboard(true) --function from client script client_ui.lua
                end
            end
            
            if IsDisabledControlJustReleased(1, keys.Tab) then
                if isScoreboardDisplaying then
                    isScoreboardDisplaying = false

                    displayScoreboard(false)
                end
            end
        end

        for k, v in pairs(plyersVehicles) do --table from client script client_sync_vehicles.lua
            local veh = plyersVehicles["" .. k].localID

            if IsEntityAVehicle(veh) and not plyersVehicles["" .. k].destroyed then
                if HasEntityBeenDamagedByWeapon(veh, 0, 2) then
                    if GetVehicleEngineHealth(veh) <= 0 then
                        plyersVehicles["" .. k].destroyed = true
                        
                        TriggerServerEvent("server_sync_player:updateScoreboard", GetPlayerName(PlayerId()), true, false)
                        TriggerServerEvent("server_sync_player:payment")

                        break
                    end

                    ClearEntityLastDamageEntity(veh)
                end
            end
        end

        Citizen.Wait(1)
    end
end)


--#[Event Handlers]#--
RegisterNetEvent("client_player:loadData")
AddEventHandler("client_player:loadData", function(money, vehicles)
    plyerData.money = money
    plyerData.vehicles = vehicles
end)

RegisterNetEvent("client_player:appendScoreboard")
AddEventHandler("client_player:appendScoreboard", function(plyID, plyName, kills, deaths)
    appendScoreboard(plyID, plyName, kills, deaths)
end)

RegisterNetEvent("client_player:updateScoreboard")
AddEventHandler("client_player:updateScoreboard", function(plyID, plyName, kills, deaths)
    updateScoreboard(plyID, plyName, kills, deaths)
end)

RegisterNetEvent("client_player:BuildTimerStarting")
AddEventHandler("client_player:BuildTimerStarting", function(time)
    isBuildTimerActive = true

    scoreboardUpdateTimer(time, "Build Time") --function from client script client_ui.lua
    DrawNotificationMinimap("The arena is now ~r~closed!", "[User Terminal]")
end)

RegisterNetEvent("client_player:BuildTimerEnding")
AddEventHandler("client_player:BuildTimerEnding", function()
    isBuildTimerActive = false
end)

RegisterNetEvent("client_player:RoundTimerStarting")
AddEventHandler("client_player:RoundTimerStarting", function(plyID, time)
    isRoundTimerActive = true

    TriggerServerEvent("server_sync_player:clearScoreboard", GetPlayerName(PlayerId()))
    scoreboardUpdateTimer(time, "Round Time") --function from client script client_ui.lua
    DrawNotificationMinimap("The arena is now ~g~open!", "[User Terminal]")    
end)

RegisterNetEvent("client_player:RoundTimerEnding")
AddEventHandler("client_player:RoundTimerEnding", function()
    isRoundTimerActive = false
end)

RegisterNetEvent("client_player:updateScoreboardTimer")
AddEventHandler("client_player:updateScoreboardTimer", function(state, time)
    if state then
        scoreboardUpdateTimer(time, "Round Time")
    else
        scoreboardUpdateTimer(time, "Build Time")
    end
end)

RegisterNetEvent("client_player:clearScoreboard")
AddEventHandler("client_player:clearScoreboard", function()
    scoreboardClear()
    TriggerServerEvent("server_sync_player:appendScoreboard", GetPlayerName(PlayerId()))
end)

RegisterNetEvent("client_player:paymentComplete")
AddEventHandler("client_player:paymentComplete", function(paymentMoney)
    DrawNotificationMinimap("Payment for killing: ~g~" .. paymentMoney, "[User Terminal]")
end)