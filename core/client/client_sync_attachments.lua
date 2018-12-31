--[[
client_sync_attachments.lua

Provides functionality to synchronize attachments of props between players.
]]

--#[Global Variables]#--
ownAttachedProps = {}
plyersAttachedProps = {}

--#[Global Functions]#--
function syncAttachment(prop, serverID, pos, rotZ)
    TriggerServerEvent("server_sync_attachments:syncAttachment", prop, serverID, pos.x, pos.y, pos.z, rotZ)
end

function unsyncAttachment(serverID)
    TriggerServerEvent("server_sync_attachments:unsyncAttachment", serverID)
end

--#[Local Functions]#--
local function attachSync(plySource, serverID, vehicleServerID, pos, rotZ)
    if plyersProps["" .. serverID] ~= nil then --table from client script client_sync_props.lua
        local prop = plyersProps["" .. serverID].localID
        local entity = plyersVehicles["" .. vehicleServerID].localID

        AttachEntityToEntity(prop, entity, -1, pos.x, pos.y, pos.z, 0.0, 0.0, (rotZ - GetEntityRotation(entity, 2).z), false, false, false, false, 2, true)

        plyersAttachedProps["" .. serverID] = {}

        plyersAttachedProps["" .. serverID] = 
        {
            plySource = plySource,
            serverID = serverID,
            localID = prop,
            vehicleServerID = vehicleServerID,
            pos = pos,
            rotZ = rotZ
        }
    end
end

local function detachSync(serverID)
    if plyersAttachedProps["" .. serverID].localID ~= nil then
        DetachEntity(plyersAttachedProps["" .. serverID].localID, false, false)

        plyersAttachedProps["" .. serverID] = nil
    end
end

--#[Event Handlers]#--
RegisterNetEvent("client_sync_attachments:updatePlyers")
AddEventHandler("client_sync_attachments:updatePlyers", function(state, plySource, serverID, vehicleServerID, x, y, z, rotZ)
    if state then
        local pos = vector3(x, y, z)
        attachSync(plySource, serverID, vehicleServerID, pos, rotZ)
    else
        detachSync(serverID)
    end
end)

RegisterNetEvent("client_sync_attachments:updatePlySource")
AddEventHandler("client_sync_attachments:updatePlySource", function(state, serverID, vehicleServerID, x, y, z, rotZ)
    if state then
        local pos = vector3(x, y, z)

        if ownAttachedProps["" .. serverID] == nil then
            ownAttachedProps["" .. serverID] = {}

            ownAttachedProps["" .. serverID] = 
            {
                serverID = serverID,
                localID = ownProps["" .. serverID].localID,
                vehicleServerID = vehicleServerID,
                pos = pos,
                rotZ = rotZ
            }
        end
    else
        ownAttachedProps["" .. serverID] = nil
    end
end)