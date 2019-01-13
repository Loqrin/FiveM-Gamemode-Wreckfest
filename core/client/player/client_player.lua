--[[
client_player.lua

Functionality provided for the player.
]]

--#[Global Variables]#--
plyerData = {money = 0, vehicles = {}}

isPlayerInSpawn = false
isPlayerInArena = false

isBuildTimerActive = false
isRoundTimerActive = false

enableVehicleInvincibility = false
enablePlyInvincibility = false

--#[Local Variables]#--
local scoreboardPlyers = {}
local isScoreboardDisplaying = false

local deadPlyers = {}

--#[Local Functions]#--
local function appendScoreboard(plyID, plyName, kills, deaths)
    if scoreboardPlyers["" .. plyID] == nil then
        scoreboardPlyers["" .. plyID] = {plyID = plyID}

        scoreboardAddPlyer(plyID, plyName, kills, deaths) --function from client script client_ui.lua
    end
end

local function updateScoreboard(plyID, plyName, kills, deaths)
    scoreboardUpdatePlyer(plyID, plyName, kills, deaths) --function from client script client_ui.lua
end

local function plyerDeath(otherID, otherPed)
    local plyID = PlayerId()
    local entity, weapon = NetworkGetEntityKillerOfPlayer(otherID)
    local otherName = GetPlayerName(otherID)
    local deathMsg = "~y~" .. otherName .. " ~w~died."
    
    if IsPedAPlayer(entity) then
        local killer = NetworkGetPlayerIndexFromPed(entity)
        local killerName = GetPlayerName(killer)

        if killerName == otherName then
            deathMsg = "~y~" .. otherName .. " ~w~commited suicide."
        elseif killerName == GetPlayerName(plyID) then
            deathMsg = "~y~You ~w~obliterated ~y~" .. otherName .. "~w~."

            TriggerServerEvent("server_sync_player:updateScoreboard", GetPlayerName(plyID), true, false)
            TriggerServerEvent("server_sync_player:payment")
        else
            deathMsg = "~y~" .. killerName .. " ~w~obliterated ~y~" .. otherName .. "~w~."
        end
    end

    DrawNotifcationNormal(deathMsg) --function from client script client_ui.lua
end

--#[Citizen Threads]#--
Citizen.CreateThread(function()
    while true do
        local plyPed = GetPlayerPed(-1)
        local plyID = PlayerId()
        local numPlyers = NetworkGetNumConnectedPlayers()

        for i = 0, numPlyers, 1 do
            if NetworkIsPlayerConnected(i) then
                local otherPed = GetPlayerPed(i)

                if DoesEntityExist(otherPed) and IsEntityDead(otherPed) then
                    if deadPlyers[i] == nil then
                        plyerDeath(i, otherPed)

                        if i == plyID then
                            displayBlackoutMenu(true) --function from client script client_ui.lua                            
                        end

                        deadPlyers[i] = true
                    end
                else
                    if deadPlyers[i] ~= nil then
                        deadPlyers[i] = nil
                    end
                end
            end
        end

        if isPlayerInSpawn then
            DisableControlAction(1, keys.MouseLeftClick, true)
            DisableControlAction(1, keys.ScrollUp, true)
            DisableControlAction(1, keys.ScrollUp2, true)
            DisableControlAction(1, keys.ScrollDown, true)
            DisableControlAction(1, keys.ScrollDown2, true)
            DisableControlAction(1, keys.Space, true)

            if currentVehicle ~= nil then
                SetVehicleDoorsLocked(currentVehicle, 2)
                FreezeEntityPosition(currentVehicle, true)
            end
        end

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

        Citizen.Wait(1)
    end
end)

Citizen.CreateThread(function()
    while true do 
        local plyPed = GetPlayerPed(-1)

        for k, v in pairs(ownProps) do --table from client script client_sync_props.lua
            for m, n in pairs(weapons) do --table from config file config_weapons.lua
                if HasEntityBeenDamagedByWeapon(tonumber(v.localID), GetHashKey(weapons[m].weapon), 0) and tonumber(v.health) > 0 then
                    TriggerServerEvent("server_sync_props:checkPropHealth", v.serverID, v.health, GetHashKey(weapons[m].weapon), nil)

                    ClearEntityLastDamageEntity(tonumber(v.localID))
                end
            end
        end

        for k, v in pairs(plyersProps) do --table from client script client_sync_props.lua
            for m, n in pairs(weapons) do --table from config file config_weapons.lua
                if HasEntityBeenDamagedByWeapon(tonumber(v.localID), GetHashKey(weapons[m].weapon), 0) and tonumber(v.health) > 0 then
                    TriggerServerEvent("server_sync_props:checkPropHealth", v.serverID, GetEntityHealth(v.localID), GetHashKey(weapons[m].weapon), tonumber(v.plySource))

                    ClearEntityLastDamageEntity(tonumber(v.localID))
                end
            end
        end

        Citizen.Wait(100)
    end
end)

Citizen.CreateThread(function()
    while true do 
        local plyPed = GetPlayerPed(-1)

        SetEntityInvincible(currentVehicle, enableVehicleInvincibility)
        SetEntityInvincible(plyPed, enablePlyInvincibility)

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
AddEventHandler("client_player:RoundTimerStarting", function(time)
    isRoundTimerActive = true

    scoreboardPlyers = {}
    scoreboardClear()
    TriggerServerEvent("server_sync_player:appendScoreboard", GetPlayerName(PlayerId()))

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
        scoreboardUpdateTimer(time, "Build Time")
    else
        scoreboardUpdateTimer(time, "Round Time")
    end
end)

RegisterNetEvent("client_player:paymentComplete")
AddEventHandler("client_player:paymentComplete", function(paymentMoney)
    DrawNotificationMinimap("Payment for killing: ~g~" .. paymentMoney, "[User Terminal]")
end)