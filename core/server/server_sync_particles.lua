--[[
server_sync_particles.lua

Functionality to synchronize particle effects between players.
]]

--#[Local Functions]#--
local function syncParticleEffects(plySource, particleEffect, pos)
    local allPlyers = GetPlayers()

    for k, v in pairs(allPlyers) do
        if tonumber(v) ~= plySource then
            TriggerClientEvent("client_sync_particles:syncParticleEffect", v, false, particleEffect, pos.x, pos.y, pos.z)
        end
    end

    TriggerClientEvent("client_sync_particles:syncParticleEffect", plySource, true, particleEffect, pos.x, pos.y, pos.z)
end

--#[Event Handlers]#--
RegisterServerEvent("server_sync_particles:syncParticleEffect")
AddEventHandler("server_sync_particles:syncParticleEffect", function(particleEffect, x, y, z)
    local pos = vector3(x, y, z)
    syncParticleEffects(source, particleEffect, pos)
end)