--[[
client_spawn.ua

Functionality provided to spawn the player in, as well as handle the player when they first join.
]]

--#[Global Variables]#--
plyFirstJoin = false
isPlyerInSpawnMenu = false

--#[Local Variables]#--
local spawnOverview = vector3(-1890.4526367188, -1902.8321533203, 61.146965026855)

--#[Global Functions]#--
function spawnPlayer()
    local plyPed = GetPlayerPed(-1)
    local plyModelHash = GetHashKey(plyDefaultModel) --variable from client script config_client_player.lua

    DoScreenFadeOut(500)
    displayWelcomeMenu(false) --function from client script client_ui.lua

    Citizen.Wait(3000)

    RequestModel(plyModelHash)
    while not HasModelLoaded(plyModelHash) or not HasCollisionForModelLoaded(plyModelHash) do
        Citizen.Wait(1)
    end

    SetPlayerModel(PlayerId(), plyModelHash)
    SetPedRandomComponentVariation(plyPed, true)
    SetModelAsNoLongerNeeded(plyModelHash)

    plyPed = GetPlayerPed(-1)

    if enterArena then --variable from client script client_terminal_manager.lua
        local pos = vector3(plyerPlatformPos.x, plyerPlatformPos.y, plyerPlatformPos.z + 4.0)
        local ranSpawn = math.random(1, #mapSpawnPoints["2"]) --table from clinet script client_map_loader.lua
        local inc = 0

        if numOwnProps > 0 then
            for k, v in pairs(ownProps) do
                unsyncAttachment(ownProps["" .. k].serverID)
                despawnProp(ownProps["" .. k].serverID) --function from client script client_sync_props.lua
            end
        end
    
        if #ownWeapons > 0 then
            ownWeapons = {}
        end
    
        unsyncVehicle(currentVehicleServerID) --function from client script client_sync_vehicles.lua

        DeleteVehicle(currentVehicle)

        Citizen.Wait(100)

        --variable currentVehicleData from client script client_terminal_garage.lua
        spawnVehicle(true, currentVehicleData.vehicle, pos, 272.64904785156, currentVehicleData.id) --function from client script client_sync_vehicles.lua

        Citizen.Wait(1000)

        if currentVehicleData.props ~= nil then
            for k, v in pairs(currentVehicleData.props) do
                local relativePos = vector3(tonumber(v.x), tonumber(v.y), tonumber(v.z))
                local rot = vector3(0, 0, tonumber(v.rotZ))
                local dmgMultiplier = 5
                local attachmentEntity = currentVehicle --variable from client script client_sync_vehicles.lua
    
                for m, n in pairs(props) do --table from config file config_props.lua
                    if model == m then
                        dmgMultiplier = n.dmgMultiplier
        
                        break
                    end
                end
    
                spawnProp(true, false, v.model, plyerPlatformPos, rot, false, dmgMultiplier, true, true, relativePos) --function from client script client_sync_props.lua
            
                for m, n in pairs(weapons) do --table from config file config_weapons.lua
                    if v.model == n.hash then
                        spawnWeapon(false, ownLastSpawnedProp, n.weapon, n.hash, n.type, n.range, n.bulletDrop, n.cooldownTime)
    
                        break
                    end
                end
            end
        end

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
    else
        SetEntityCoords(plyPed, plyerPlatformPos.x, plyerPlatformPos.y, plyerPlatformPos.z + 4.0)
    end

    FreezeEntityPosition(plyPed, false)
    SetEntityVisible(plyPed, true)
    SetEntityInvincible(plyPed, false)

    isPlayerInSpawn = true --variable from client script client_player.lua

    TransitionFromBlurred(500)
    DoScreenFadeIn(500)

    Citizen.Wait(1000)
end

--#[Local Functions]#--
local function plyerJoined()
    local plyPed = GetPlayerPed(-1)

    isPlyerInSpawnMenu = true

    TriggerServerEvent("server_sync_platforms:assignPlatform")
    TriggerServerEvent("server_sync_player:loadData")
    TriggerServerEvent("server_sync_player:appendScoreboard", GetPlayerName(PlayerId()))
    TriggerServerEvent("server_sync_player:plyJoinedScoreboard")
    
    Citizen.CreateThread(function()
        TriggerServerEvent("server_sync_props:plyerJoined")

        Citizen.Wait(2000)

        TriggerServerEvent("server_sync_vehicles:plyerJoined")

        Citizen.Wait(500)

        TriggerServerEvent("server_sync_attachments:plyerJoined")
    end)

    Citizen.Wait(1000)
    
    SetEntityCoords(plyPed, spawnOverview.x, spawnOverview.y, spawnOverview.z)

    FreezeEntityPosition(plyPed, true)
    SetEntityVisible(plyPed, false)
    SetEntityInvincible(plyPed, true)

    Citizen.Wait(3000)

    DoScreenFadeIn(500)
    TransitionToBlurred(500)

    displayWelcomeMenu(true)

    while isPlyerInSpawnMenu do
        SetEntityHeading(plyPed, 160)

        Citizen.Wait(1)
    end
end

--#[Citizen Threads]#--
Citizen.CreateThread(function()
    Citizen.Wait(500)

    DoScreenFadeOut(1)
    
    Citizen.Wait(2000)

    if not plyFirstJoin then
        requestMap(true) --function from client script client_map_loader.lua
        plyerJoined()

        plyFirstJoin = true
    end
end)

--#[NUI Callbacks]#--
RegisterNUICallback("spawnPlayer", function(data, cb)
    Citizen.CreateThread(function()
        spawnPlayer()

        isPlyerInSpawnMenu = false
    end)

    cb("ok")
end)