--[[
client_sync_weapons.lua

Functionality to sync weapons and weapon audio amongst players.
]]

--#[Global Variables]#--
ownWeapons = {}

--#[Global Functions]#--
function spawnWeapon(syncAudio, prop, weapon, model, type, range, bulletDrop, cooldownTime)
    if syncAudio then

    else
        table.insert(ownWeapons, CreateTable({
            prop = prop,
            weapon = weapon, 
            model = model,
            type = type,
            range = range,
            bulletDrop = bulletDrop,
            cooldownTime = cooldownTime,
            cooldownActive = false
        }))
    end
end

--#[Citizen Threads]#--
Citizen.CreateThread(function()
    while true do 
        local plyPed = GetPlayerPed(-1)

        if #ownWeapons > 0 then
            for k, v in pairs(ownWeapons) do
                if IsPedInAnyVehicle(plyPed, false) then
                    local veh = GetVehiclePedIsIn(plyPed, false)
                    local vehOffset = GetOffsetFromEntityInWorldCoords(veh, 0.0, 20.0, 2.0)
                    local weaponPos = GetEntityCoords(ownWeapons[k].prop)
                    local startPos = GetOffsetFromEntityInWorldCoords(ownWeapons[k].prop, 1.0, 0.0, 0.0)
                    local endPos = GetOffsetFromEntityInWorldCoords(ownWeapons[k].prop, tonumber(v.range) + 0.0, 0.0, tonumber(v.bulletDrop) * -1.0)

                    weapHash = GetHashKey(v.weapon)

                    if not HasWeaponAssetLoaded(weapHash) then
                        RequestWeaponAsset("WEAPON_VEHICLE_ROCKET", 31, 0) --some weapons don't seem to load until this hash loads, eg: VEHICLE_TANK
                        RequestWeaponAsset(weapHash, 31, 0)

                        print("[Wreckfest DEBUG] Request weapon hash: " .. weapHash)

                        while not HasWeaponAssetLoaded(weapHash) do
                            Citizen.Wait(0)
                        end
                    end

                    --DrawLine(startPos.x, startPos.y, startPos.z, endPos.x, endPos.y, endPos.z, 255, 0, 0, 255)

                    Draw3DText(vehOffset.x, vehOffset.y, vehOffset.z, ".", 255, 255, 255, 255, 4, 0.75, true, true, true, true, 0, 0, 0, 0, 55) --function from client script ui.lua

                    DisableControlAction(1, keys.MouseLeftClick, true)
                    DisableControlAction(1, keys.MouseLeftClick2, true)

                    if string.lower(v.type) == "bullet" then
                        if IsDisabledControlPressed(1, keys.MouseLeftClick) then --key: Left Mouse Button
                            if not v.cooldownActive then
                                ShootSingleBulletBetweenCoords(startPos, endPos, 1.0, 1, weapHash, plyPed, true, false, -1.0)
                            
                                v.cooldownActive = true

                                if v.cooldownTime ~= 0 then
                                    SetTimeout(v.cooldownTime * 1000, function()
                                        v.cooldownActive = false
                                    end)
                                else
                                    v.cooldownActive = false
                                end
                            end
                        end
                    elseif string.lower(v.type) == "explosive" then
                        if IsDisabledControlJustReleased(1, keys.MouseLeftClick) then --key: Left Mouse Button
                            if not v.cooldownActive then
                                ShootSingleBulletBetweenCoords(startPos, endPos, 1.0, 1, weapHash, plyPed, true, false, -1.0)
                            
                                v.cooldownActive = true

                                if v.cooldownTime ~= 0 then
                                    SetTimeout(v.cooldownTime * 1000, function()
                                        v.cooldownActive = false
                                    end)
                                else
                                    v.cooldownActive = false
                                end
                            end
                        end
                    end
                end
            end
        end

        Citizen.Wait(1)
    end
end)
