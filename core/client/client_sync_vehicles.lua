--[[
client_sync_vehicles.lua

Functionality to sync vehicles between players.
]]

--#[Global Variables]#--
currentVehicle = nil
currentVehicleServerID = nil
currentVehicleModel = nil
currentVehicleWeight = 0
currentVehicleMaxWeight = nil

plyersVehicles = {}

--#[Global Functions]#--
function syncVehicle(serverID, vehicle, pos, pos2)
    TriggerServerEvent("server_sync_vehicles:syncVehicle", serverID, vehicle, pos.x, pos.y, pos.z, pos2.x, pos2.y, pos2.z)
end

function unsyncVehicle(serverID)
    TriggerServerEvent("server_sync_vehicles:unsyncVehicle", serverID)
end

function spawnVehicle(mustSync, model, pos, heading, serverID)
    local hash = ""

    if tonumber(model) ~= nil then
        hash = tonumber(model)
    else
        hash = GetHashKey(model)
    end

    if IsModelValid(hash) then
        RequestModel(hash)
        while not HasModelLoaded(hash) do
            Citizen.Wait(1)
        end

        currentVehicle = CreateVehicle(hash, pos.x, pos.y, pos.z, heading, true, true)
        currentVehicleModel = model

        SetVehicleOnGroundProperly(currentVehicle)

        if vehicles[model] ~= nil then --table from config file config_vehicles.lua
            currentVehicleMaxWeight = vehicles[model].maxWeight
        end

        --SetEntityAsMissionEntity(currentVehicle)

        if mustSync then
            syncVehicle(serverID, currentVehicle, GetEntityCoords(currentVehicle), plyerTerminalPos) --variable from client script client_sync_platforms.lua
        end
    end
end

function despawnVehicle()
    unsyncVehicle(currentVehicleServerID)

    DeleteVehicle(currentVehicle)

    currentVehicle = nil
    currentVehicleModel = nil
end

--#[Local Functions]#--
local function vehicleSync(plySource, serverID, pos, pos2)
    while plyersVehicles["" .. serverID] == nil do
        local distancePos = vector3(pos.x, pos.y, pos.z + 0.5)
        local didHit, endCoords, surfaceCoords, entity = CastRay(pos2, distancePos, 2, GetPlayerPed(-1)) --function from client script client_general_functions.lua

        DrawLine(pos2, distancePos, 255, 0, 0, 255)

        if didHit then
            if IsEntityAVehicle(entity) then
                plyersVehicles["" .. serverID] = {}

                plyersVehicles["" .. serverID] = 
                {
                    plySource = plySource,
                    serverID = serverID,
                    localID = entity,
                    destroyed = false
                }

                local plyPed = GetPlayerPed(GetPlayerFromServerId(plySource))
                print("[Wreckfest DEBUG] Managed to obtain vehicle: " .. entity .. " from player source: " .. plySource)
            end
        end

        Citizen.Wait(1)
    end
end

local function vehicleUnsyc(serverID)
    if DoesEntityExist(plyersVehicles["" .. serverID].localID) then
        DeleteVehicle(plyersVehicles["" .. serverID].localID)
    end

    plyersVehicles["" .. serverID] = nil
end

local function plyerJoined(plySource, serverID, pos, pos2)
    local allPlyers = GetNumberOfPlayers()
    local plyPed = nil

    for i = 0, allPlyers do
        local plyServerID = GetPlayerServerId(NetworkGetPlayerIndexFromPed(GetPlayerPed(i)))

        if plyServerID == tonumber(plySource) then
            plyPed = GetPlayerPed(i)

            break
        end
    end

    if IsPedInAnyVehicle(plyPed, false) then
        local plyVehicle = GetVehiclePedIsIn(plyPed, false)

        plyersVehicles["" .. serverID] = {}

        plyersVehicles["" .. serverID] = 
        {
            plySource = plySource,
            serverID = serverID,
            localID = plyVehicle,
            destroyed = false
        }

        print("[Wreckfest DEBUG] Player is in vehicle, still managed to obtain vehicle: " .. plyVehicle .. " from player source: " .. plySource)
    else
        while plyersVehicles["" .. serverID] == nil do
            local distancePos = vector3(pos.x, pos.y, pos.z + 0.5)
            local didHit, endCoords, surfaceCoords, entity = CastRay(pos2, distancePos, 2, GetPlayerPed(-1)) --function from client script client_general_functions.lua
    
            DrawLine(pos2, distancePos, 255, 0, 0, 255)
    
            if didHit then
                if IsEntityAVehicle(entity) then
                    plyersVehicles["" .. serverID] = {}
    
                    plyersVehicles["" .. serverID] = 
                    {
                        plySource = plySource,
                        serverID = serverID,
                        localID = entity,
                        destroyed = false
                    }

                    print("[Wreckfest DEBUG] Managed to obtain vehicle: " .. entity .. " from player source: " .. plySource)
                end
            end
    
            Citizen.Wait(1)
        end
    end
end

--#[Event Handlers]#--
RegisterNetEvent("client_sync_vehicles:updatePlyers")
AddEventHandler("client_sync_vehicles:updatePlyers", function(state, plySource, serverID, x, y, z, x2, y2, z2)
    if state then
        local pos = vector3(x, y, z)
        local pos2 = vector3(x2, y2, z2)
        vehicleSync(plySource, serverID, pos, pos2)
    else
        vehicleUnsyc(serverID)
    end
end)

RegisterNetEvent("client_sync_vehicles:updatePlySource")
AddEventHandler("client_sync_vehicles:updatePlySource", function(state, serverID)
    if state then
        currentVehicleServerID = serverID
    else
        currentVehicleServerID = nil
    end
end)

RegisterNetEvent("client_sync_vehicles:plyerJoined")
AddEventHandler("client_sync_vehicles:plyerJoined", function(plySource, serverID, x, y, z, x2, y2, z2)
    local pos = vector3(x, y, z)
    local pos2 = vector3(x2, y2, z2)

    plyerJoined(plySource, serverID, pos, pos2)
end)

RegisterNetEvent("client_sync_vehicles:resourceRestart")
AddEventHandler("client_sync_vehicles:resourceRestart", function()
    local handle, vehicle = FindFirstVehicle()
    local foundVehicle

    repeat
        if DoesEntityExist(vehicle) then
            DeleteVehicle(vehicle)
        end

        foundVehicle, vehicle = FindNextVehicle(handle)
    until not foundVehicle

    EndFindVehicle(handle)
end)