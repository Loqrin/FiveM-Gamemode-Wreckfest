--[[
client_terminal_buyvehicles.lua

Functionality to allow the player to purchase vehicles from the terminal.
]]

--#[Local Variables]#--
local isMenuSetup = false
local isVehicleMenuSetup = false

--#[Local Functions]#--
local function setupBuyVehicleMenu()
    clearUserTerminalNavList()
    clearUserTerminalContentImages()

    appendUserTerminalNavList("back", "Back", false)

    for k, v in pairs(vehicles) do --table from config file config_vehicles.lua
        appendUserTerminalNavList(k, v.name, true)
    end

    updateUserTerminalContentHeading("Purchase Vehicles")
    updateUserTerminalContentText("Only the finest vehicles and strongest vehicles can be purchased and used in Wreckfest. <br> To simply purchase a vehicle, select one from the list to the left.")
    detectUserTerminalMouseClick()
end

local function setupVehicleMenu(hash, name, price, image)
    clearUserTerminalNavList()
    clearUserTerminalContentImages()

    appendUserTerminalNavList("cancelPurchase", "Cancel", false)
    appendUserTerminalNavList(hash, "Purchase", false)

    updateUserTerminalContentHeading(name)

    if image ~= "none" then
        appendUserTerminalContentImage(image)
    end

    updateUserTerminalContentText("Price: $" .. price .. " <br><br> More information coming soon!")

    detectUserTerminalMouseClick()

    isVehicleMenuSetup = true
end

local function purchaseComplete(charge, model, serverID)
    plyerData.money = charge

    spawnVehicle(true, model, plyerPlatformPos, 272.0, serverID) --function from client script client_sync_vehicles.lua
end

--#[Citizen Threads]#--
Citizen.CreateThread(function()
    while true do
        if enableBuyVehicleTerminal then --variable from client script client_terminal_manager.lua
            if not isMenuSetup then
                setupBuyVehicleMenu()

                isMenuSetup = true
            end
        end

        Citizen.Wait(1)
    end
end)

--#[Event Handlers]#--
RegisterNetEvent("client_terminal_buyvehicles:purchaseComplete")
AddEventHandler("client_terminal_buyvehicles:purchaseComplete", function(charge, hash, serverID)
    purchaseComplete(charge, hash, serverID)

    DrawNotificationMinimap("Purchase ~g~successful!~w~", "[User Terminal]")
end)

RegisterNetEvent("client_terminal_buyvehicles:purchaseFailed", function(charge)
    DrawNotificationMinimap("Purchase ~r~failed!~w~~n~You do not have sufficient funds to pay ~y~$" .. charge, "[User Terminal]")
end)

--#[NUI Callbacks]#--
RegisterNUICallback("userTerminalNavClick", function(data, cb)
    if enableBuyVehicleTerminal then
        if not isVehicleMenuSetup then
            if data.key == "back" then
                setupUserTerminalMenu() --function from client script client_terminal_manager.lua
                
                isMenuSetup = false
                enableBuyVehicleTerminal = false
            end

            for k, v in pairs(vehicles) do
                if data.key == k then
                    setupVehicleMenu(k, v.name, v.price, v.image)

                    break
                end
            end
        else
            if data.key == "cancelPurchase" then
                setupBuyVehicleMenu()

                isVehicleMenuSetup = false
            end

            if currentVehicle == nil then
                for k, v in pairs(vehicles) do
                    if data.key == k then
                        TriggerServerEvent("server_sync_player:purchaseVehicle", k)

                        displayUserTerminal(false) --function from client script client_ui.lua

                        isPlyerInTerminal = false --variable from client script client_terminal_manager.lua
                        isMenuSetup = false
                        isVehicleMenuSetup = false
                        enableBuyVehicleTerminal = false

                        break
                    end
                end
            else
                DrawNotificationMinimap("There is already a ~y~vehicle~w~ on the platform!", "[User Terminal]")
            end
        end
    end
end)

RegisterNUICallback("closeUserTerminal", function(data, cb)
    if enableBuyVehicleTerminal then
        isMenuSetup = false
        isVehicleMenuSetup = false
        enableBuyVehicleTerminal = false
    end
end)
