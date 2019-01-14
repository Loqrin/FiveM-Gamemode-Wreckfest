--[[
client_spawn.ua

Functionality provided to spawn the player in, as well as handle the player when they first join.
]]

--#[Global Variables]#--
plyFirstJoin = false

--#[Local Variables]#--
local spawnOverview = vector3(-1890.4526367188, -1902.8321533203, 61.146965026855)

--#[Global Functions]#--
function spawnPlayer()
    local plyPed = GetPlayerPed(-1)
    local plyModelHash = GetHashKey(plyDefaultModel) --variable from client script config_client_player.lua

    RequestModel(plyModelHash)
    while not HasModelLoaded(plyModelHash) or not HasCollisionForModelLoaded(plyModelHash) do
        Citizen.Wait(1)
    end

    SetPlayerModel(PlayerId(), plyModelHash)
    SetPedRandomComponentVariation(plyPed, true)
    SetModelAsNoLongerNeeded(plyModelHash)

    plyPed = GetPlayerPed(-1)

    if isPlayerInArena then --variable from client script client_player.lua
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

        Citizen.Wait(2000)

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
                
                enableVehicleInvincibility = false --variable from client script client_player.lua
                enablePlyInvincibility = false --variable from client script client_player.lua

                break
            end
        end
    else
        displayBlackoutMenu(true) --function from client script client_ui.lua
        displayWelcomeMenu(false) --function from client script client_ui.lua

        Citizen.Wait(2000)

        SetEntityCoords(plyPed, plyerPlatformPos.x, plyerPlatformPos.y, plyerPlatformPos.z + 4.0)

        enablePlyInvincibility = true --variable from client script client_player.lua
        isPlayerInSpawn = true --variable from client script client_player.lua
    end

    FreezeEntityPosition(plyPed, false)
    SetEntityVisible(plyPed, true)

    NetworkSetFriendlyFireOption(true)
    SetCanAttackFriendly(plyPed, true, false)

    TransitionFromBlurred(500)
    displayBlackoutMenu(false)
end

--#[Local Functions]#--
local function plyerJoined()
    local plyPed = GetPlayerPed(-1)

    TriggerServerEvent("server_sync_platforms:assignPlatform")
    TriggerServerEvent("server_sync_player:loadData")
    TriggerServerEvent("server_sync_player:appendScoreboard", GetPlayerName(PlayerId()))
    TriggerServerEvent("server_sync_props:plyerJoined")

    Citizen.Wait(500)

    TriggerServerEvent("server_sync_vehicles:plyerJoined")

    Citizen.Wait(500)

    TriggerServerEvent("server_sync_attachments:plyerJoined")

    Citizen.Wait(500)

    TriggerServerEvent("server_sync_player:plyJoinedScoreboard")
    
    SetEntityCoords(plyPed, spawnOverview.x, spawnOverview.y, spawnOverview.z)

    FreezeEntityPosition(plyPed, true)
    SetEntityHeading(plyPed, 160)
    SetEntityVisible(plyPed, false)

    enablePlyInvincibility = true --variable from client script client_player.lua

    Citizen.Wait(2000)

    displayBlackoutMenu(false)
    TransitionToBlurred(500)
    displayWelcomeMenu(true)
end

--#[Event Handlers]#--
AddEventHandler("playerSpawned", function()
    if not plyFirstJoin then
        requestMap(true) --function from client script client_map_loader.lua
        plyerJoined()

        plyFirstJoin = true
    else 
        TriggerServerEvent("server_sync_player:updateScoreboard", GetPlayerName(plyID), false, true)
        spawnPlayer()

        Citizen.Wait(3000)

        displayBlackoutMenu(false) --function from client script client_ui.lua  
    end
end)

RegisterNetEvent("client_spawn:resourceRestart")
AddEventHandler("client_spawn:resourceRestart", function()
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
    end)

    cb("ok")
end)