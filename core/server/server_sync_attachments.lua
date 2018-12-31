--[[
server_sync_attachments.lua

Functionality to sync attachments between players.
]]

--#[Global Variables]#--
attachedProps = {}

--#[Local Functions]#--
local function CreateTable(data)
	return data
end

local function updatePlyers(plySource, state, serverID, vehicleServerID, pos, rotZ)
    local allPlyers = GetPlayers()

    for k, v in pairs(allPlyers) do
        if tonumber(v) ~= plySource then
            if state then
                TriggerClientEvent("client_sync_attachments:updatePlyers", v, true, plySource, serverID, vehicleServerID, pos.x, pos.y, pos.z, rotZ)
            else
                TriggerClientEvent("client_sync_attachments:updatePlyers", v, false, v, serverID)
            end
        end
    end

    if state then
        TriggerClientEvent("client_sync_attachments:updatePlySource", plySource, true, serverID, vehicleServerID, pos.x, pos.y, pos.z, rotZ)
    else
        TriggerClientEvent("client_sync_attachments:updatePlySource", plySource, false, serverID)
    end
end

local function syncAttachment(plySource, prop, vehicleServerID, pos, rotZ)
    local plyID = GetPlayerIdentifiers(plySource)

    for k, v in pairs(spawnedProps["" .. plyID[1]]) do --table from server script server_sync_props.lua
        if spawnedProps["" .. plyID[1]][k].localID == prop then
            if attachedProps["" .. plyID[1]] == nil then
                attachedProps["" .. plyID[1]] = {}
            end
        
            table.insert(attachedProps["" .. plyID[1]], CreateTable({serverID = spawnedProps["" .. plyID[1]][k].serverID, localID = prop, model = spawnedProps["" .. plyID[1]][k].model, vehicleServerID = vehicleServerID, x = pos.x, y = pos.y, z = pos.z, rotZ = rotZ}))
        
            print("[Wreckfest DEBUG] Attachment Synced: " .. spawnedProps["" .. plyID[1]][k].serverID .. " | " .. vehicleServerID)
        
            updatePlyers(plySource, true, spawnedProps["" .. plyID[1]][k].serverID, vehicleServerID, pos, rotZ)

            break
        end
    end
end

local function unsyncAttachment(plySource, serverID)
    local plyID = GetPlayerIdentifiers(plySource)

    for k, v in pairs(attachedProps["" .. plyID[1]]) do
        if attachedProps["" .. plyID[1]][k].serverID == serverID then
            print("[Wreckfest DEBUG] Attachment Unsynced: " .. serverID .. " | " .. attachedProps["" .. plyID[1]][k].vehicleServerID)
            
            table.remove(attachedProps["" .. plyID[1]], k)

            break
        end
    end

    updatePlyers(plySource, false, serverID)
end

local function plyerJoined(plySource)
    local plyID = GetPlayerIdentifiers(plySource)
    local allPlyers = GetPlayers()

    for k, v in pairs(allPlyers) do
        local id = GetPlayerIdentifiers(v)

        if tonumber(v) ~= plySource then
            if attachedProps["" .. id[1]] ~= nil then
                for m, n in pairs(attachedProps["" .. id[1]]) do
                    TriggerClientEvent("client_sync_attachments:updatePlyers", plySource, true, v, n.serverID, n.vehicleServerID, n.pos.x, n.pos.y, n.pos.z, n.rotZ)
                end
            end
        end
    end

    print('[Wreckfest DEBUG] Player joined, synching attachments')

end

--#[Event Handlers]#--
RegisterServerEvent("server_sync_attachments:syncAttachment")
AddEventHandler("server_sync_attachments:syncAttachment", function(prop, vehicleServerID, x, y, z, rotZ)
    local pos = vector3(x, y, z)
    syncAttachment(source, prop, vehicleServerID, pos, rotZ)
end)

RegisterServerEvent("server_sync_attachments:unsyncAttachment")
AddEventHandler("server_sync_attachments:unsyncAttachment", function(serverID)
    unsyncAttachment(source, serverID)
end)

RegisterServerEvent("server_sync_attachments:plyerJoined")
AddEventHandler("server_sync_attachments:plyerJoined", function()
    plyerJoined(source)
end)