--[[
client_map_loader.lua

Provides functionality to load maps from XML files.
]]

--#[Global Variables]#--
mapSpawnPoints = {}
mapData = {}
mapPlatforms = {}

--#[Local Variables]#--
local borderProps = {"stt_prop_stunt_bblock_huge_05"}

--#[Global Functions]#--
function requestMap(loadSpawn)
    TriggerServerEvent("server_map_loader:requestMapData", loadSpawn)
end

--#[Local Functions]#--
local function loadMap(mapIndex, data, spawnPoints)
    mapSpawnPoints["" .. mapIndex] = {}
    mapSpawnPoints["" .. mapIndex] = spawnPoints

    for k, v in pairs(data) do
        local hash = ""

        if tonumber(v.hash) ~= nil then
            hash = tonumber(v.hash)
        else
            hash = GetHashKey(v.hash)
        end

        if IsModelValid(hash) then
            local propPos = vector3(v.x, v.y, v.z)
            local propRot = vector3(v.rotX, v.rotY, v.rotZ)

            local prop = CreateObjectNoOffset(hash, propPos, false, false, false)

            SetEntityAsMissionEntity(prop, true, true)
            SetEntityRotation(prop, propRot, 2, true)
            FreezeEntityPosition(prop, true)
            SetEntityCollision(prop, true, true)
            SetEntityCanBeDamaged(prop, false)
            SetEntityLodDist(prop, 10000)

            for j, l in ipairs(borderProps) do --table from config file config_map.lua
                if GetHashKey(l) == hash then
                    SetEntityAlpha(prop, 0)
                end
            end

            mapData["" .. mapIndex] = {}
            mapData["" .. mapIndex] = data

            if v.hash == "prop_helipad_02" then
                table.insert(mapPlatforms, prop)
            end
        end
    end
end

--#[Event Handlers]#--
RegisterNetEvent("client_map_loader:receiveMapData")
AddEventHandler("client_map_loader:receiveMapData", function(mapIndex, data, spawnPoints)
    Citizen.CreateThread(function()
        loadMap(mapIndex, data, spawnPoints)
    end)
end)