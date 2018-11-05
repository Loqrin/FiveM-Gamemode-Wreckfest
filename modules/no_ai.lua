--[[
███╗   ██╗ ██████╗      █████╗ ██╗
████╗  ██║██╔═══██╗    ██╔══██╗██║
██╔██╗ ██║██║   ██║    ███████║██║
██║╚██╗██║██║   ██║    ██╔══██║██║
██║ ╚████║╚██████╔╝    ██║  ██║██║
╚═╝  ╚═══╝ ╚═════╝     ╚═╝  ╚═╝╚═╝

Simple script to disable the AI in-game. AI relates to the peds. Disables vehicles and dispatch services, too.
]]

--#[Local Functions]#--
local function removeAI(playerPed, playerPos)
    SetVehicleDensityMultiplierThisFrame(0.0)
    SetPedDensityMultiplierThisFrame(0.0)
    SetRandomVehicleDensityMultiplierThisFrame(0.0)
    SetParkedVehicleDensityMultiplierThisFrame(0.0)
    SetScenarioPedDensityMultiplierThisFrame(0.0, 0.0)

    RemoveVehiclesFromGeneratorsInArea(playerPos.x - 500.0, playerPos.y - 500.0, playerPos.z - 500.0, playerPos.x + 500.0, playerPos.y + 500.0, playerPos.z + 500.0);
    
    SetGarbageTrucks(0)
    SetRandomBoats(0)
    
    for i = 1, 15 do
        EnableDispatchService(i, false)
    end
end

--#[Citizen Threads]#--
Citizen.CreateThread(function()
    if noAIModule then
        while true do
            local playerPed = GetPlayerPed(-1)
            local playerPos = GetEntityCoords(playerPed)

            removeAI(playerPed, playerPos)

            Citizen.Wait(1)
        end
    end
end)