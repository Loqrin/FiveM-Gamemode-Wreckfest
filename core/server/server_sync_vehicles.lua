--[[
server_sync_vehicles.lua

Functionality to sync vehicles between players.
]]

--#[Local Variables]#--
local vehicleID = 0
local spawnedVehicles = {}

--#[Local Functions]#--
local function updatePlyers(plySource, state, serverID, pos, pos2)
    local allPlyers = GetPlayers()

    for k, v in pairs(allPlyers) do
        if tonumber(v) ~= plySource then
            if state then
                TriggerClientEvent("client_sync_vehicles:updatePlyers", v, true, plySource, serverID, pos.x, pos.y, pos.z, pos2.x, pos2.y, pos2.z)
            else
                TriggerClientEvent("client_sync_vehicles:updatePlyers", v, false, v, serverID)
            end
        end
    end

    if state then
        TriggerClientEvent("client_sync_vehicles:updatePlySource", plySource, true, serverID)
    else
        TriggerClientEvent("client_sync_vehicles:updatePlySource", plySource, false, serverID)
    end
end

local function syncVehicle(plySource, vehicleServerID, vehicle, pos, pos2)
    local plyID = GetPlayerIdentifiers(plySource)

    if spawnedVehicles["" .. plyID[1]] == nil then
        spawnedVehicles["" .. plyID[1]] = {}
    end

    spawnedVehicles["" .. plyID[1]] = {serverID = vehicleServerID, localID = vehicle, pos = pos, pos2 = pos2} 

    print("[Wreckfest DEBUG] Vehicle Synced: " .. vehicleServerID .. " | " .. vehicle)

    updatePlyers(plySource, true, vehicleServerID, pos, pos2)
end

local function unsyncVehicle(plySource, serverID)
    local plyID = GetPlayerIdentifiers(plySource)

    if spawnedVehicles["" .. plyID[1]].serverID == serverID then
        print("[Wreckfest DEBUG] Vehicle Unsynced: " .. serverID .. " | " .. spawnedVehicles["" .. plyID[1]].localID)

        spawnedVehicles["" .. plyID[1]] = nil
    end

    updatePlyers(plySource, false, serverID)
end

local function plyerJoined(plySource)
    local plyID = GetPlayerIdentifiers(plySource)
    local allPlyers = GetPlayers()

    for k, v in pairs(allPlyers) do
        local id = GetPlayerIdentifiers(v)

        if tonumber(v) ~= plySource then
            if spawnedVehicles["" .. id[1]] ~= nil then
                local pos = vector3(spawnedVehicles["" .. id[1]].pos.x, spawnedVehicles["" .. id[1]].pos.y, spawnedVehicles["" .. id[1]].pos.z)
                local pos2 = vector3(spawnedVehicles["" .. id[1]].pos2.x, spawnedVehicles["" .. id[1]].pos2.y, spawnedVehicles["" .. id[1]].pos2.z)

                TriggerClientEvent("client_sync_vehicles:plyerJoined", plySource, v, spawnedVehicles["" .. id[1]].serverID, pos.x, pos.y, pos.z, pos2.x, pos2.y, pos2.z)
            end
        end
    end
end

local function clearDisconnectedVehicles(plyID, plySource)
    local allPlyers = GetPlayers()

    if spawnedVehicles["" .. plyID] ~= nil then
        updatePlyers(plySource, false, "" .. spawnedVehicles["" .. plyID].serverID)

        print("[Wreckfest DEBUG] Vehicle Unsynced: " .. spawnedVehicles["" .. plyID].serverID)

        spawnedVehicles["" .. plyID] = nil
    end
end

--#[Event Handlers]#--
RegisterServerEvent("server_sync_vehicles:syncVehicle")
AddEventHandler("server_sync_vehicles:syncVehicle", function(vehicleServerID, vehicle, x, y, z, x2, y2, z2)
    local pos = vector3(x, y, z)
    local pos2 = vector3(x2, y2, z2)

    syncVehicle(source, vehicleServerID, vehicle, pos, pos2)
end)

RegisterServerEvent("server_sync_vehicles:unsyncVehicle")
AddEventHandler("server_sync_vehicles:unsyncVehicle", function(serverID)
    unsyncVehicle(source, serverID)
end)

RegisterServerEvent("server_sync_vehicles:plyerJoined")
AddEventHandler("server_sync_vehicles:plyerJoined", function()
    plyerJoined(source)
end)

AddEventHandler("playerDropped", function(reason)
    local plyID = GetPlayerIdentifiers(source)
    local plySource = source

    clearDisconnectedVehicles(plyID[1], plySource)
end)