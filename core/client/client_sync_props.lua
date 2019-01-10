--[[
client_sync_props.lua

Provides functionality to synchronize props between players.
]]

--#[Global Variables]#--
ownProps = {}
plyersProps = {}
ownLastSpawnedProp = nil

numOwnProps = 0

local basePropHealth = 100

--#[Global Functions]#--
function syncProp(prop, model, pos, rot, health, dmgMultiplier)
    TriggerServerEvent("server_sync_props:syncProp", prop, model, pos.x, pos.y, pos.z, rot.x, rot.y, rot.z, health, dmgMultiplier)
end

function unsyncProp(serverID)
    TriggerServerEvent("server_sync_props:unsyncProp", serverID)
end

function spawnProp(mustSync, forceSelect, model, pos, rot, collision, dmgMultiplier, mustAttach, mustSyncAttachment, relativePos)
    local hash = ""

    if tonumber(model) ~= nil then
        hash = tonumber(model)
    else
        hash = GetHashKey(model)
    end

    if IsModelValid(hash) then 
        local prop = CreateObjectNoOffset(hash, pos, false, false, false)

        SetEntityRotation(prop, rot, 2, true)
        SetEntityAsMissionEntity(prop, true, true)
        FreezeEntityPosition(prop, true)
        SetEntityCollision(prop, collision, true)
        SetEntityCanBeDamaged(prop, true)
        SetEntityLodDist(prop, 10000)
        SetEntityHealth(prop, basePropHealth * dmgMultiplier)

        ownLastSpawnedProp = prop
        
        if mustSync then
            syncProp(prop, model, pos, rot, GetEntityHealth(prop), dmgMultiplier)
        end

        if forceSelect then
            forceSelectedProp(prop, model) --function from client script client_build_vehicle.lua
        end

        Citizen.Wait(250)

        if mustAttach then
            --currentVehicle variable from client script client_sync_vehicles.lua
            AttachEntityToEntity(prop, currentVehicle, -1, relativePos.x, relativePos.y, relativePos.z, 0.0, 0.0, (rot.z - GetEntityRotation(currentVehicle, 2).z), false, false, false, false, 2, true)
            SetEntityCollision(prop, true, true)

            if mustSyncAttachment then
                --currentVehicleServerID variable from client script client_sync_vehicles.lua
                syncAttachment(prop, currentVehicleServerID, relativePos, rot.z) --function from client script client_sync_attachments.lua
            end
        end
    end
end

function despawnProp(serverID)
    DeleteObject(ownProps["" .. serverID].localID)

    unsyncProp(serverID)
end

--#[Local Functions]#--
local function roundNum(num, numDecimalPlaces)
    return tonumber(string.format("%." .. (numDecimalPlaces or 0) .. "f", num))
end

local function calculatePropAlpha(dmgMultiplier, health)
    return ((255 * ((health / (basePropHealth * dmgMultiplier)) * 100)) / 100)
end

local function spawnSync(plySource, serverID, model, pos, rot, health, dmgMultiplier)
    Citizen.CreateThread(function()
        local hash = ""

        if tonumber(model) ~= nil then
            hash = tonumber(model)
        else
            hash = GetHashKey(model)
        end

        if IsModelValid(hash) then
            local prop = CreateObjectNoOffset(hash, pos, false, false, false)

            SetEntityRotation(prop, rot, 2, true)
            FreezeEntityPosition(prop, true)
            SetEntityHealth(prop, health)
            SetEntityCollision(prop, false, true)
            SetEntityCanBeDamaged(prop, false)
            SetEntityLodDist(prop, 10000)

            if plyersProps["" .. serverID] == nil then
                plyersProps["" .. serverID] = {}

                plyersProps["" .. serverID] = 
                {
                    plySource = plySource,
                    serverID = serverID,
                    localID = prop, 
                    model = model,
                    pos = pos, 
                    rot = rot,
                    health = health,
                    dmgMultiplier = dmgMultiplier
                }
            end
        end
    end)
end

local function despawnSync(serverID)
    Citizen.CreateThread(function()
        if plyersProps["" .. serverID].localID ~= nil then
            DeleteObject(plyersProps["" .. serverID].localID)

            plyersProps["" .. serverID] = nil
        end
    end)
end

local function syncHealth(state, serverID, health)
    Citizen.CreateThread(function()
        local prop = nil
        local propAlpha = 255

        if state then
            prop = plyersProps["" .. serverID].localID
            plyersProps["" .. serverID].health = health
            
            propAlpha = calculatePropAlpha(plyersProps["" .. serverID].dmgMultiplier, health)
        else
            prop = ownProps["" .. serverID].localID
            ownProps["" .. serverID].health = health
            
            propAlpha = calculatePropAlpha(ownProps["" .. serverID].dmgMultiplier, health)
        end

        SetEntityHealth(prop, health)

        if GetEntityAlpha(prop) > 100.0 then
            SetEntityAlpha(prop, roundNum(propAlpha)) --function from client script client_general_functions.lua
        end

        if health < 5 then
            

            if state then
                local causeFuckTimeouts = serverID

                SetTimeout(100, function()
                    --unsyncProp(causeFuckTimeouts)
                end)
            else
                local causeFuckTimeouts = serverID
                local pos = GetEntityCoords(ownProps["" .. serverID].localID)

                TriggerServerEvent("server_sync_particles:syncParticleEffect", "destroy", pos.x, pos.y, pos.z)

                SetTimeout(100, function()
                    unsyncProp(causeFuckTimeouts)

                    DeleteObject(prop)
                end)
            end
        end
    end)
end

local function plyerRejoined(serverID, model, x, y, z, rotX, rotY, rotZ, health, dmgMultiplier)
    Citizen.CreateThread(function()
        local hash = ""

        if tonumber(model) ~= nil then
            hash = tonumber(model)
        else
            hash = GetHashKey(model)
        end

        if IsModelValid(hash) then
            local pos = vector3(x, y, z)
            local rot = vector3(rotX, rotY, rotZ)
            local prop = CreateObjectNoOffset(hash, pos, false, false, false)

            SetEntityRotation(prop, rot, 2, true)
            FreezeEntityPosition(prop, true)
            SetEntityHealth(prop, health)
            SetEntityCollision(prop, false, true)
            SetEntityCanBeDamaged(prop, false)
            SetEntityLodDist(prop, 10000)

            if ownProps["" .. serverID] == nil then
                ownProps["" .. serverID] = {}

                ownProps["" .. serverID] = 
                {
                    serverID = serverID,
                    localID = prop,
                    model = model,
                    pos = pos,
                    rot = rot,
                    health = health,
                    dmgMultiplier = dmgMultiplier
                }

                numOwnProps = 0

                for k, v in pairs(ownProps) do 
                    numOwnProps = numOwnProps + 1
                end
            end

            TriggerServerEvent("server_sync_props:updateProps", serverID, prop)
        end
    end)
end

local function updateProps(serverID, plySource)
    for k, v in pairs(plyersProps) do
        if v.serverID == serverID then
            v.plySource = plySource

            break
        end
    end
end

--#[Event Handlers]#--
RegisterNetEvent("client_sync_props:updatePlyers")
AddEventHandler("client_sync_props:updatePlyers", function(state, plySource, serverID, model, x, y, z, rotX, rotY, rotZ, health, dmgMultiplier)
    if state then
        local pos = vector3(x, y, z)
        local rot = vector3(rotX, rotY, rotZ)

        spawnSync(plySource, serverID, model, pos, rot, health, dmgMultiplier)
    else
        despawnSync(serverID)
    end
end)

RegisterNetEvent("client_sync_props:updatePlySource")
AddEventHandler("client_sync_props:updatePlySource", function(state, serverID, localID, model, x, y, z, rotX, rotY, rotZ, health, dmgMultiplier)
    if state then
        local pos = vector3(x, y, z)
        local rot = vector3(rotX, rotY, rotZ)

        if ownProps["" .. serverID] == nil then
            ownProps["" .. serverID] = {}

            ownProps["" .. serverID] = 
            {
                serverID = serverID,
                localID = localID,
                model = model,
                pos = pos,
                rot = rot,
                health = health,
                dmgMultiplier = dmgMultiplier
            }

            numOwnProps = 0

            for k, v in pairs(ownProps) do 
                numOwnProps = numOwnProps + 1
            end
        end
    else
        numOwnProps = numOwnProps - 1

        ownProps["" .. serverID] = nil
    end
end)

RegisterNetEvent("client_sync_props:updateHealth")
AddEventHandler("client_sync_props:updateHealth", function(state, serverID, health)
    syncHealth(state, serverID, health)
end)

RegisterNetEvent("client_sync_props:plyerRejoined")
AddEventHandler("client_sync_props:plyerRejoined", function(serverID, model, x, y, z, rotX, rotY, rotZ, health, dmgMultiplier)
    plyerRejoined(serverID, model, x, y, z, rotX, rotY, rotZ, health, dmgMultiplier)
end)

RegisterNetEvent("client_sync_props:updateProps")
AddEventHandler("client_sync_props:updateProps", function(serverID, plySource)
    updateProps(serverID, plySource)
end)