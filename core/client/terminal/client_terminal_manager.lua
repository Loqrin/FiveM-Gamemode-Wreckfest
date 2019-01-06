--[[
client_terminal_manager.lua

Functionality to manage the user terminal and the different menus/modes.
]]

--#[Global Variables]#--
isPlyerInTerminal = false

enterArena = false
enableGarageTerminal = false
enableBuyVehicleTerminal = false
enableBuyPropsTerminal = false
enableBuyWeaponsTerminal = false

--#[Global Functions]#--
function setupUserTerminalMenu()
    clearUserTerminalNavList()
    clearUserTerminalContentImages()

    updateUserTerminalTitle("User Terminal")
    updateUserTerminalNavHeading("Navigate")

    appendUserTerminalNavList("enterArena", "Enter Arena", false)
    appendUserTerminalNavList("garage", "Garage", false)
    appendUserTerminalNavList("buyVehicle", "Buy Vehicle", false)
    appendUserTerminalNavList("buyProps", "Buy Props", false)
    appendUserTerminalNavList("buyWeapons", "Buy Weapons", false)

    updateUserTerminalContentHeading("Welcome " .. GetPlayerName(PlayerId()))
    updateUserTerminalContentText("This is your terminal. <br> Here you can access your garage, purchase any vehicle that you desire, buy props to fortify your vehicle and buy weapons to obliterate your opponents!")
    detectUserTerminalMouseClick()
end

--#[Citizen Threads]#--
Citizen.CreateThread(function()
    while true do 
        local plyPed = GetPlayerPed(-1)
        local plyPos = GetEntityCoords(plyPed)

        if doesPlyerHavePlatform and doesPlyerHaveTerminal and not isPlyerInSpawnMenu then --variables from client script client_sync_platforms.lua
            if IsNear(plyPos, plyerTerminalPos, 2.0) then --function from client script client_general_functions.lua
                DisableControlAction(1, keys.E, true)

                --plyerTerminalPos variable from client script client_sync_platforms.lua
                Draw3DText(plyerTerminalPos.x, plyerTerminalPos.y, plyerTerminalPos.z + 0.5, "[Press ~y~" .. ConvertInstructBtnText(GetControlInstructionalButton(1, keys.E, 1)) .. "~w~ - Access Terminal]", 255, 255, 255, 255, 4, 0.45, true, true, true, true, 0, 0, 0, 0, 55) --function from client script ui.lua
            
                if IsDisabledControlJustReleased(1, keys.E) then
                    if not isPlyerInTerminal then
                        setupUserTerminalMenu()
                        displayUserTerminal(true)

                        isPlyerInTerminal = true
                    end
                end
            else
                if not enterArena then --variable from client script client_terminal_manager.lua
                    Draw3DText(plyerTerminalPos.x, plyerTerminalPos.y, plyerTerminalPos.z + 0.5, "[Approach the ~y~Terminal~w~]", 255, 255, 255, 255, 4, 0.45, true, true, true, true, 0, 0, 0, 0, 55) --function from client script ui.lua
                end
            end
        end

        Citizen.Wait(1)
    end
end)

--#[NUI Callbacks]#--
RegisterNUICallback("userTerminalNavClick", function(data, cb)
    if data.key == "enterArena" then
        enterArena = true

        if currentVehicleServerID ~= nil then
            TriggerServerEvent("server_sync_player:saveVehicle", currentVehicleModel, currentVehicleServerID)
        end

        displayUserTerminal(false)

        isPlyerInTerminal = false --variable from client script client_terminal_manager.lua
    elseif data.key == "garage" then
        enableGarageTerminal = true
    elseif data.key == "buyVehicle" then
        enableBuyVehicleTerminal = true
    elseif data.key == "buyProps" then
        enableBuyPropsTerminal = true
    elseif data.key == "buyWeapons" then
        enableBuyWeaponsTerminal = true
    end
end)