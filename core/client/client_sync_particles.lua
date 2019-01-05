--[[
client_sync_particles.lua

Functionality to synchronize particles between players.
]]

--#[Local Variables]#--
local isParticlePlaying = {destroy = false}

--#[Local Functions]#--
local function syncParticleEffect(state, particleEffect, pos)
    Citizen.CreateThread(function()
        if not isParticlePlaying.destroy then
            isParticlePlaying.destroy = true

            if particleEffect == "destroy" then
                while not HasNamedPtfxAssetLoaded("scr_rcbarry2") do
                    RequestNamedPtfxAsset("scr_rcbarry2")

                    Citizen.Wait(1)
                end

                UseParticleFxAssetNextCall("scr_rcbarry2")

                if state then
                    StartParticleFxNonLoopedAtCoord("scr_clown_appears", pos.x + 0.0, pos.y + 0.0, pos.z + 0.3, 0.0, 0.0, 0.0, 1.0, false, false, false)
                    PlaySoundFromCoord(-1, "MAIN_EXPLOSION_CHEAP", pos.x + 0.0, pos.y + 0.0, pos.z, 0, 0, 0, 0);
                else
                    StartParticleFxNonLoopedAtCoord("scr_clown_appears", pos.x + 0.0, pos.y + 0.0, pos.z + 0.3, 0.0, 0.0, 0.0, 1.0, false, false, false)
                    PlaySoundFromCoord(-1, "MAIN_EXPLOSION_CHEAP", pos.x + 0.0, pos.y + 0.0, pos.z, 0, 0, 0, 0);
                end
            end
        end
    end)
end

--#[Citizen Threads]#--
Citizen.CreateThread(function()
    while true do
        if isParticlePlaying.destroy then
            Citizen.Wait(1)

            isParticlePlaying.destroy = false
        end

        Citizen.Wait(1)
    end
end)

--#[Event Handlers]#--
RegisterNetEvent("client_sync_particles:syncParticleEffect")
AddEventHandler("client_sync_particles:syncParticleEffect", function(state, particleEffect, x, y, z)
    local pos = vector3(x, y, z)
    syncParticleEffect(state, particleEffect, pos)
end)