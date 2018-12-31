--[[
client_sync_platforms.lua
]]

--#[Global Variables]#--
plyerPlatformPos = vector3(0, 0, 0)
plyerTerminalPos = vector3(0, 0, 0)
plyerPlatform = nil

doesPlyerHavePlatform = false
doesPlyerHaveTerminal = false

--#[Local Functions]#--
local function assignPlatform(x, y, z)
    plyerPlatformPos = vector3(x, y, z)

    TriggerServerEvent("server_sync_platforms:assignTerminal", plyerPlatformPos.x, plyerPlatformPos.y, plyerPlatformPos.z)

    doesPlyerHavePlatform = true
end

local function assignTerminal(x, y, z)
    plyerTerminalPos = vector3(x, y, z)

    doesPlyerHaveTerminal = true
end

--#[Citizen Threads]#--
Citizen.CreateThread(function()
    while true do 
        if doesPlyerHavePlatform and not isPlyerInSpawnMenu then --variable from client script client_spawn.lua
            if plyerPlatform == nil then
                for k, v in pairs(mapPlatforms) do
                    local entPos = GetEntityCoords(v)

                    if entPos == plyerPlatformPos then
                        plyerPlatform = v

                        break
                    end
                end
            end

            if not enterArena then --variable from client script client_terminal_manager.lua
                Draw3DText(plyerPlatformPos.x, plyerPlatformPos.y, plyerPlatformPos.z + 0.5, "[~y~Assigned ~w~Platform]", 255, 255, 255, 255, 4, 0.45, true, true, true, true, 0, 0, 0, 0, 55) --function from client script ui.lua
            end
        end

        Citizen.Wait(1)
    end
end)

--#[Event Handlers]#--
RegisterNetEvent("client_sync_platforms:assignPlatform")
AddEventHandler("client_sync_platforms:assignPlatform", function(x, y, z)
    assignPlatform(x, y, z)
end)

RegisterNetEvent("client_sync_platforms:assignTerminal")
AddEventHandler("client_sync_platforms:assignTerminal", function(x, y, z)
    assignTerminal(x, y, z)
end)