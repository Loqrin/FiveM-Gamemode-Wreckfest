--[[
client_terminal_buyprops.lua

Functionality to allow the player to purchase props to place on their vehicle.
]]

--#[Local Variables]#--
local isMenuSetup = false
local isPropMenuSetup = false

local baseHealth = 100
local amountBoughtProps = 0

--#[Local Functions]#--
local function setupBuyPropMenu()
    clearUserTerminalNavList()
    clearUserTerminalContentImages()

    appendUserTerminalNavList("back", "Back", false)

    for k, v in pairs(props) do --table from config file config_props.lua
        appendUserTerminalNavList(k, v.name, true)
    end

    updateUserTerminalContentHeading("Purchase Props")
    updateUserTerminalContentText("The strongest, the highest of quality, the most refined props are available to be purchsed.<br>Right here, right now.<br>Purchase any prop and have it protect your previous vehicle!")
    detectUserTerminalMouseClick()
end

local function setupPropMenu(hash, name, price, image)
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

    isPropMenuSetup = true
end

local function purchaseComplete(charge, model, dmgMultiplier)
    plyerData.money = charge

    local ranLeftRight = math.random(-6, 6)
    local ranForwardBackward = math.random(1, 2)
    local pos = vector3(0, 0, 0)
    local rot = vector3(0, 0, 272.0)

    if ranForwardBackward == 1 then
        pos = GetOffsetFromEntityInWorldCoords(plyerPlatform, ranLeftRight + 0.0, -8.0, 2.3) --variable from client script client_sync_platforms.lua
    elseif ranForwardBackward == 2 then
        pos = GetOffsetFromEntityInWorldCoords(plyerPlatform, ranLeftRight + 0.0, 8.0, 2.3)
    end

    spawnProp(true, false, model, pos, rot, true, dmgMultiplier) --function from client script client_sync_props.lua

    amountBoughtProps = amountBoughtProps + 1

    updatePropMenu() --function from client script client_build_vehicle.lua
end

--#[Citizen Threads]#--
Citizen.CreateThread(function()
    while true do
        if enableBuyPropsTerminal then --variable from client script client_terminal_manager.lua
            if not isMenuSetup then
                setupBuyPropMenu()

                isMenuSetup = true
            end
        end

        Citizen.Wait(1)
    end
end)

--#[Event Handlers]#--
RegisterNetEvent("client_terminal_buyprops:purchaseComplete")
AddEventHandler("client_terminal_buyprops:purchaseComplete", function(charge, hash, dmgMultiplier)
    purchaseComplete(charge, hash, dmgMultiplier)

    DrawNotificationMinimap("Purchase ~g~successful!~w~", "[User Terminal]")
end)

RegisterNetEvent("client_terminal_buyprops:purchaseFailed", function(charge)
    DrawNotificationMinimap("Purchase ~r~failed!~w~~n~You do not have sufficient funds to pay ~y~$" .. charge, "[User Terminal]")
end)

--#[NUI Callbacks]#--
RegisterNUICallback("userTerminalNavClick", function(data, cb)
    if enableBuyPropsTerminal then
        if not isPropMenuSetup then
            if data.key == "back" then
                setupUserTerminalMenu() --function from client script client_terminal_manager.lua
                
                isMenuSetup = false
                enableBuyPropsTerminal = false
            end

            for k, v in pairs(props) do
                if data.key == k then
                    setupPropMenu(k, v.name, v.price, v.image)

                    break
                end
            end
        else
            if data.key == "cancelPurchase" then
                setupBuyPropMenu()

                isPropMenuSetup = false
            end

            if amountBoughtProps <= 10 then
                for k, v in pairs(props) do
                    if data.key == k then
                        TriggerServerEvent("server_sync_player:purchaseProp", k, v.dmgMultiplier)

                        break
                    end
                end
            else
                DrawNotificationMinimap("Please ~y~sell~w~ or ~y~attach~w~ previous bought props!", "[User Terminal]")
            end
        end
    end
end)

RegisterNUICallback("closeUserTerminal", function(data, cb)
    if enableBuyPropsTerminal then
        isMenuSetup = false
        isPropMenuSetup = false
        enableBuyPropsTerminal = false
    end
end)
