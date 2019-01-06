--[[
server_sync_props.lua

Provides functionality to synchronize props between players.
]]

--#[Global Variables]#--
spawnedProps = {}
joinedPlyers = {}

--#[Local Variables]#--
local propID = 0

--#[Local Functions]#--
local function CreateTable(data)
	return data
end

local function updatePlyers(plySource, state, serverID, prop, model, x, y, z, rotX, rotY, rotZ, health, dmgMultiplier)
    local allPlyers = GetPlayers()

    for k, v in pairs(allPlyers) do
        if tonumber(v) ~= plySource then
            if state then
                TriggerClientEvent("client_sync_props:updatePlyers", v, true, plySource, serverID, model, x, y, z, rotX, rotY, rotZ, health, dmgMultiplier)
            else
                TriggerClientEvent("client_sync_props:updatePlyers", v, false, v, serverID)
            end
        end
    end

    if state then
        TriggerClientEvent("client_sync_props:updatePlySource", plySource, true, serverID, prop, model, x, y, z, rotX, rotY, rotZ, health, dmgMultiplier)
    else
        TriggerClientEvent("client_sync_props:updatePlySource", plySource, false, serverID)
    end
end

local function syncProp(plySource, prop, model, x, y, z, rotX, rotY, rotZ, health, dmgMultiplier)
    local plyID = GetPlayerIdentifiers(plySource)

    propID = propID + 1

    if spawnedProps["" .. plyID[1]] == nil then
        spawnedProps["" .. plyID[1]] = {}
    end

    table.insert(spawnedProps["" .. plyID[1]], CreateTable({serverID = propID, localID = prop, model = model, x = x, y = y, z = z, rotX = rotX, rotY = rotY, rotZ = rotZ, health = health, dmgMultiplier = dmgMultiplier}))

    print("[Wreckfest DEBUG] Prop Synced: " .. propID .. " | " .. model)

    updatePlyers(plySource, true, propID, prop, model, x, y, z, rotX, rotY, rotZ, health, dmgMultiplier)
end

local function unsyncProp(plySource, serverID)
    local plyID = GetPlayerIdentifiers(plySource)

    for k, v in pairs(spawnedProps["" .. plyID[1]]) do
        if spawnedProps["" .. plyID[1]][k].serverID == serverID then
            print("[Wreckfest DEBUG] Prop Unsynced: " .. serverID .. " | " .. spawnedProps["" .. plyID[1]][k].model)

            table.remove(spawnedProps["" .. plyID[1]], k)

            break
        end
    end

    updatePlyers(plySource, false, serverID)
end

local function checkHealth(plySource, serverID, health, weapon, ownerSource)
    local state = false
    local weapIndex = nil

    for k, v in pairs(weapons) do --table from config file config_weapon_stats.lua
        if weapon ~= weapons["" .. k].weaponHash then
            weapIndex = k
            state = false
        else
            state = true

            break
        end
    end

    if state then
        local allPlyers = GetPlayers()
        local newHealth = health

        if weapons["" .. weapIndex] ~= nil then
            newHealth = newHealth - (weapons["" .. weapIndex].weaponDamage * 10) --table from config file config_weapon_stats.lua
        else
            newhealth = newHealth - 30

            print("[Wreckfest Log] The following weapon hash is invalid (update the config file config_weapon_stats.lua):" .. weapon)
        end

        --print("[Wreckfest DEBUG] New health calculated with weapon hash " .. weapon .. ": " .. newHealth)

        if ownerSource ~= nil then
            local ownerID = GetPlayerIdentifiers(ownerSource)
    
            for k, v in pairs(spawnedProps["" .. ownerID[1]]) do
                if spawnedProps["" .. plyID[1]][k].serverID == serverID then
                    spawnedProps["" .. plyID[1]][k].health = newHealth
        
                    break
                end
            end
    
            for k, v in pairs(allPlyers) do
                local plyID = GetPlayerIdentifiers(v)
    
                if plyID[1] ~= ownerID[1] then
                    TriggerClientEvent("client_sync_props:updateHealth", v, true, serverID, newHealth)
                end
            end
    
            TriggerClientEvent("client_sync_props:updateHealth", ownerSource, false, serverID, newHealth)
        else
            local plyID = GetPlayerIdentifiers(plySource)
    
            for k, v in pairs(spawnedProps["" .. plyID[1]]) do
                if spawnedProps["" .. plyID[1]][k].serverID == serverID then
                    spawnedProps["" .. plyID[1]][k].health = newHealth
        
                    break
                end
            end
    
            for k, v in pairs(allPlyers) do 
                if tonumber(v) ~= plySource then
                    TriggerClientEvent("client_sync_props:updateHealth", v, true, serverID, newHealth)
                end
            end
    
            TriggerClientEvent("client_sync_props:updateHealth", plySource, false, serverID, newHealth)
        end
    end
end

local function plyerRejoined(plySource)
    local plyID = GetPlayerIdentifiers(plySource)

    local allPlyers = GetPlayers()

    for k, v in pairs(allPlyers) do
        local id = GetPlayerIdentifiers(v)

        if tonumber(v) ~= plySource then
            if spawnedProps["" .. id[1]] ~= nil then
                for m, n in pairs(spawnedProps["" .. id[1]]) do
                    TriggerClientEvent("client_sync_props:updatePlyers", plySource, true, v, n.serverID, n.model, n.x, n.y, n.z, n.rotX, n.rotY, n.rotZ, n.health, n.dmgMultiplier)
                end
            end
        end
    end

    if spawnedProps["" .. plyID[1]] ~= nil then
        for k, v in pairs(spawnedProps["" .. plyID[1]]) do
            TriggerClientEvent("client_sync_props:plyerRejoined", plySource, v.serverID, v.model, v.x, v.y, v.z, v.rotX, v.rotY, v.rotZ, v.health, v.dmgMultiplier)
        end
    end
end

local function plyerJoined(plySource)
    local plyID = GetPlayerIdentifiers(plySource)

    if joinedPlyers["" .. plyID[1]] == nil then
        joinedPlyers["" .. plyID[1]] = {joined = true, disconnected = false}

        if #spawnedProps > 0 then
            local allPlyers = GetPlayers()

            for k, v in pairs(allPlyers) do
                local id = GetPlayerIdentifiers(v)

                if spawnedProps["" .. id[1]] ~= nil then
                    for m, n in pairs(spawnedProps["" .. id[1]]) do
                        TriggerClientEvent("client_sync_props:updatePlyers", plySource, true, v, n.serverID, n.model, n.x, n.y, n.z, n.rotX, n.rotY, n.rotZ, n.health, n.dmgMultiplier)
                    end
                end
            end
        end
    else
        if joinedPlyers["" .. plyID[1]].disconnected then
            joinedPlyers["" .. plyID[1]].joined = true
            joinedPlyers["" .. plyID[1]].disconnected = false

            plyerRejoined(plySource)

            print("[Wreckfest Log] Player Rejoined: " .. plyID[1] .. " | " .. plyID[3])
        end
    end
end

local function updateProps(plySource, serverID, localID)
    local allPlyers = GetPlayers()
    local plyID = GetPlayerIdentifiers(plySource)
    
    for k, v in pairs(spawnedProps["" .. plyID[1]]) do
        if tonumber(v.serverID) == tonumber(serverID) then
            v.localID = localID

            print("[Wreckfest DEBUG] Prop Updated - Server ID: " .. serverID .. " | Local ID: " .. localID)
        end
    end

    for k, v in pairs(allPlyers) do
        if tonumber(v) ~= plySource then
            TriggerClientEvent("client_sync_props:updateProps", v, serverID, plySource)
        end
    end
end

local function clearDisconnectedProps(plyID, plySource)
    local allPlyers = GetPlayers()

    if spawnedProps["" .. plyID] ~= nil then
        for i = 1, #spawnedProps["" .. plyID] do
            updatePlyers(plySource, false, "" .. spawnedProps["" .. plyID][i].serverID)

            print("[Wreckfest DEBUG] Prop Unsynced: " .. spawnedProps["" .. plyID][i].serverID .. " | " .. spawnedProps["" .. plyID][i].model)
        end

        spawnedProps["" .. plyID] = nil
    end
end

--#[Event Handlers]#--
RegisterServerEvent("server_sync_props:syncProp")
AddEventHandler("server_sync_props:syncProp", function(prop, model, x, y, z, rotX, rotY, rotZ, health, dmgMultiplier)
    syncProp(source, prop, model, x, y, z, rotX, rotY, rotZ, health, dmgMultiplier)
end)

RegisterServerEvent("server_sync_props:unsyncProp")
AddEventHandler("server_sync_props:unsyncProp", function(serverID)
    unsyncProp(source, serverID)
end)

RegisterServerEvent("server_sync_props:checkPropHealth")
AddEventHandler("server_sync_props:checkPropHealth", function(serverID, health, weapon, ownerSource)
    checkHealth(source, serverID, health, weapon, ownerSource)
end)

RegisterServerEvent("server_sync_props:plyerJoined")
AddEventHandler("server_sync_props:plyerJoined", function()
    plyerJoined(source)
end)

RegisterServerEvent("server_sync_props:updateProps")
AddEventHandler("server_sync_props:updateProps", function(serverID, localID)
    updateProps(source, serverID, localID)
end)

AddEventHandler("playerDropped", function(reason)
    local plyID = GetPlayerIdentifiers(source)
    local plySource = source

    joinedPlyers["" .. plyID[1]].disconnected = true
    joinedPlyers["" .. plyID[1]].joined = false

    clearDisconnectedProps(plyID[1], plySource)

    print("[Wreckfest Log] Player Disconnected: " .. plyID[1] .. " | " ..plyID[3] .. " | Reason: " .. reason)
end)