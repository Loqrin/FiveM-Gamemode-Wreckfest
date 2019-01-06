--[[
client_terminal_buyprops.lua

Functionality to allow the player to purchase props to place on their vehicle.
]]

--#[Local Variables]#--
local isMenuSetup = false
local isWeaponMenuSetup = false

local baseHealth = 100
local amountWeaponProps = 0

--#[Local Functions]#--
local function setupBuyWeaponMenu()
    clearUserTerminalNavList()
    clearUserTerminalContentImages()

    appendUserTerminalNavList("back", "Back", false)

    for k, v in pairs(weapons) do --table from config file config_weapons.lua
        appendUserTerminalNavList(k, v.name, true)
    end

    updateUserTerminalContentHeading("Purchase Weapons")
    updateUserTerminalContentText("The most powerful, badass and obliterating weapons are here to be purchased.<br>Purchase any weapon and attach it to your vehicle. Enter the Arena and show off your fire power!")
    detectUserTerminalMouseClick()
end

local function setupWeaponMenu(hash, name, price, image, damage, cooldownTime, range, bulletDrop)
    clearUserTerminalNavList()
    clearUserTerminalContentImages()

    appendUserTerminalNavList("cancelPurchase", "Cancel", false)
    appendUserTerminalNavList(hash, "Purchase", false)

    updateUserTerminalContentHeading(name)

    if image ~= "none" then
        appendUserTerminalContentImage(image)
    end

    updateUserTerminalContentText("Price: $" .. price .. " <br><br> Damage: " .. damage .. " <br> Cooldown Time (seconds): " .. cooldownTime .. " <br> Range: " .. range .. " <br> Bullet Drop: " .. bulletDrop)

    detectUserTerminalMouseClick()

    isWeaponMenuSetup = true
end

local function purchaseComplete(charge, model, weapon, type, range, bulletDrop, cooldownTime, dmgMultiplier)
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

    spawnProp(true, true, model, pos, rot, true, dmgMultiplier) --function from client script client_sync_props.lua
    spawnWeapon(false, ownLastSpawnedProp, weapon, model, type, range, bulletDrop, cooldownTime)

    amountWeaponProps = amountWeaponProps + 1
end

--#[Citizen Threads]#--
Citizen.CreateThread(function()
    while true do
        if enableBuyWeaponsTerminal then --variable from client script client_terminal_manager.lua
            if not isMenuSetup then
                setupBuyWeaponMenu()

                isMenuSetup = true
            end
        end

        Citizen.Wait(1)
    end
end)

--#[Event Handlers]#--
RegisterNetEvent("client_terminal_buyweapons:purchaseComplete")
AddEventHandler("client_terminal_buyweapons:purchaseComplete", function(charge, hash, weapon, type, range, bulletDrop, cooldownTime, dmgMultiplier)
    purchaseComplete(charge, hash, weapon, type, range, bulletDrop, cooldownTime, dmgMultiplier)

    DrawNotificationMinimap("Purchase ~g~successful!~w~", "[User Terminal]")
end)

RegisterNetEvent("client_terminal_buyweapons:purchaseFailed", function(charge)
    DrawNotificationMinimap("Purchase ~r~failed!~w~~n~You do not have sufficient funds to pay ~y~$" .. charge, "[User Terminal]")
end)

--#[NUI Callbacks]#--
RegisterNUICallback("userTerminalNavClick", function(data, cb)
    if enableBuyWeaponsTerminal then
        if not isWeaponMenuSetup then
            if data.key == "back" then
                setupUserTerminalMenu() --function from client script client_terminal_manager.lua
                
                isMenuSetup = false
                enableBuyWeaponsTerminal = false
            end

            for k, v in pairs(weapons) do
                if data.key == k then
                    setupWeaponMenu(k, v.name, v.price, v.image, v.weaponDamage, v.cooldownTime, v.range, v.bulletDrop)

                    break
                end
            end
        else
            if data.key == "cancelPurchase" then
                setupBuyWeaponMenu()

                isWeaponMenuSetup = false
            end

            if amountWeaponProps <= 4 then
                for k, v in pairs(weapons) do
                    if data.key == k then
                        TriggerServerEvent("server_sync_player:purchaseWeapon", k)

                        break
                    end
                end
            else
                DrawNotificationMinimap("Please ~y~sell~w~ or ~y~attach~w~ previous bought weapons!", "[User Terminal]")
            end
        end
    end
end)

RegisterNUICallback("closeUserTerminal", function(data, cb)
    if enableBuyWeaponsTerminal then
        isMenuSetup = false
        isWeaponMenuSetup = false
        enableBuyWeaponsTerminal = false
    end
end)
