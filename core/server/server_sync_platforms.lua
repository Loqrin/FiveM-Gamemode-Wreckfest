--[[
server_sync_platforms.lua

Functionality to synchronize and assign platforms to players.
]]

--#[Global Variables]#--
plyerPlatforms = {}
plyerTerminals = {}

--#[Local Functions]#--
local function IsNear(pos1, pos2, distMustBe)
    local diff = pos2 - pos1
	local dist = (diff.x * diff.x) + (diff.y * diff.y)

	return (dist < (distMustBe * distMustBe))
end

local function assignPlatform(plySource)
    local plyID = GetPlayerIdentifiers(plySource)
    local ranPlatform = math.random(1, #plyerPlatforms)
    local inc = 0

    for k, v in pairs(plyerPlatforms) do 
        inc = inc + 1

        if inc == ranPlatform then
            if v.plyer == nil then
                v.plyer = plyID[1]

                TriggerClientEvent("client_sync_platforms:assignPlatform", plySource, v.x, v.y, v.z)

                break
            end
        end
    end
end

local function assignTerminal(plySource, x, y, z)
    local plyID = GetPlayerIdentifiers(plySource)
    local plyerPlatformPos = vector3(x, y, z)

    for k, v in pairs(plyerTerminals) do
        local terminalPos = vector3(v.x, v.y, v.z)

        if IsNear(terminalPos, plyerPlatformPos, 15) then
            v.plyer = plyID[1]

            TriggerClientEvent("client_sync_platforms:assignTerminal", plySource, v.x, v.y, v.z)

            break
        end
    end
end

--#[Event Handlers]#--
RegisterServerEvent("server_sync_platforms:assignPlatform")
AddEventHandler("server_sync_platforms:assignPlatform", function()
    assignPlatform(source)
end)

RegisterServerEvent("server_sync_platforms:assignTerminal")
AddEventHandler("server_sync_platforms:assignTerminal", function(x, y, z)
    assignTerminal(source, x, y, z)
end)