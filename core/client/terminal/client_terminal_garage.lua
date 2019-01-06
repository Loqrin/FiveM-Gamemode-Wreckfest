--[[
client_terminal_garage.lua

Functionality to allow players to store/save/retrieve their vehicles from thier garage.
]]

--#[Global Variables]#--
currentVehicleData = {}

--#[Local Variables]#--
local isMenuSetup = false
local isRetrievalMenuSetup = false

--#[Local Functions]#--
local function setupGarageMenu()
    clearUserTerminalNavList()
    clearUserTerminalContentImages()

    appendUserTerminalNavList("back", "Back", false)
    appendUserTerminalNavList("storeVehicle", "Store Vehicle", false)
    appendUserTerminalNavList("saveVehicle", "Save Vehicle", false)
    appendUserTerminalNavList("sellAllProps", "Sell All Current Props/Weapons", false)

    for k, v in pairs(plyerData.vehicles) do --table from config file config_vehicles.lua
        for m, n in pairs(vehicles) do
            if m == v.vehicle then
                appendUserTerminalNavList(v.id, n.name, true)

                break
            end
        end
    end

    updateUserTerminalContentHeading("Garage")
    updateUserTerminalContentText("Here is your private stash of vehicles. <br> Feel free to pull out any of your vehicles to either build up or send out to the arena and obliterate opponents.")
    detectUserTerminalMouseClick()
end

local function setupRetrievalMenu(hash, name, image)
    clearUserTerminalNavList()
    clearUserTerminalContentImages()

    appendUserTerminalNavList("cancelRetrieve", "Cancel", false)
    appendUserTerminalNavList(hash, "Retrieve", false)

    updateUserTerminalContentHeading(name)

    if image ~= "none" then
        appendUserTerminalContentImage(image)
    end

    updateUserTerminalContentText("More information coming soon!")

    detectUserTerminalMouseClick()

    isRetrievalMenuSetup = true
end

local function retrievalComplete(vehicleData)
    local pos = vector3(plyerPlatformPos.x, plyerPlatformPos.y, plyerPlatformPos.z + 4.0)

    spawnVehicle(true, vehicleData.vehicle, pos, 272.0, vehicleData.id) --function from client script client_sync_vehicles.lua

    if vehicleData.props ~= nil then
        for k, v in pairs(vehicleData.props) do
            local relativePos = vector3(tonumber(v.x), tonumber(v.y), tonumber(v.z))
            local rot = vector3(0, 0, tonumber(v.rotZ))
            local dmgMultiplier = 5
            local attachmentEntity = currentVehicle --variable from client script client_sync_vehicles.lua

            for m, n in pairs(props) do --table from config file config_props.lua
                if model == m then
                    dmgMultiplier = n.dmgMultiplier
    
                    break
                end
            end

            spawnProp(true, false, v.model, plyerPlatformPos, rot, false, dmgMultiplier, true, true, relativePos) --function from client script client_sync_props.lua

            if weapons[v.model] == nil then
                currentVehicleWeight = currentVehicleWeight + props[v.model].weight --table from config file config_props.lua
            else
                local weap = weapons[v.model].weapon
                local weapModel = weapons[v.model].hash
                local weapType = weapons[v.model].type
                local weapRange = weapons[v.model].range
                local weapBulletDrop = weapons[v.model].bulletDrop
                local weapCooldownTime = weapons[v.model].cooldownTime

                currentVehicleWeight = currentVehicleWeight + weapons[v.model].weight --table from config file config_weapons.lua

                spawnWeapon(false, ownLastSpawnedProp, weap, weapModel, weapType, weapRange, weapBulletDrop, weapCooldownTime)
            end
        end

        updatePropMenu() --function from client script client_build_vehicle.lua
    end

    currentVehicleData = vehicleData
end

local function storeVehicle()
    if numOwnProps > 0 then
        for k, v in pairs(ownProps) do
            unsyncAttachment(ownProps["" .. k].serverID)
            despawnProp(ownProps["" .. k].serverID) --function from client script client_sync_props.lua
        end
    end

    if #ownWeapons > 0 then
        ownWeapons = {}
    end

    currentVehicleWeight = 0

    despawnVehicle() --function from client script client_sync_vehicles.lua

    updatePropMenu() --function from client script client_build_vehicle.lua
    displayUserMenu(false) --function from client script client_ui.lua
    displayScaleform(false) --function from client script client_ui.lua
end

local function saveVehicle()
    TriggerServerEvent("server_sync_player:saveVehicle", currentVehicleModel, currentVehicleServerID)
end

local function sellProp()
    for k, v in pairs(ownProps) do
        TriggerServerEvent("server_sync_player:sellProp", ownProps[k].localID, ownProps[k].model)

        if ownAttachedProps[ownProps[k].serverID] ~= nil then
            unsyncAttachment(ownProps[k].serverID)
        end
        
        despawnProp(ownProps[k].serverID) --function from client script client_sync_props.lua

        Citizen.Wait(500)
    end
end

--#[Citizen Threads]#--
Citizen.CreateThread(function()
    while true do
        if enableGarageTerminal then --variable from client script client_terminal_manager.lua
            if not isMenuSetup then
                setupGarageMenu()

                isMenuSetup = true
            end
        end

        Citizen.Wait(1)
    end
end)

--#[Event Handlers]#--
RegisterNetEvent("client_terminal_garage:retrievalComplete")
AddEventHandler("client_terminal_garage:retrievalComplete", function(vehicleData)
    retrievalComplete(vehicleData)

    DrawNotificationMinimap("Retrieval ~g~successful!~w~", "[User Terminal]")
end)

RegisterNetEvent("client_terminal_garage:retrievalFailed")
AddEventHandler("client_terminal_garage:retrievalFailed", function()
    DrawNotificationMinimap("Retrieval ~r~failed!~w~", "[User Terminal]")
end)

--#[NUI Callbacks]#--
RegisterNUICallback("userTerminalNavClick", function(data, cb)
    if enableGarageTerminal then
        if not isRetrievalMenuSetup then
            if data.key == "back" then
                setupUserTerminalMenu() --function from client script client_terminal_manager.lua
                
                isMenuSetup = false
                enableGarageTerminal = false
            end

            if data.key == "storeVehicle" then
                if currentVehicle ~= nil then
                    storeVehicle()

                    DrawNotificationMinimap("Vehicle ~g~stored!", "[User Terminal]")
                else
                    DrawNotificationMinimap("~r~No vehicle ~w~to store!", "[User Terminal]")
                end
            end

            if data.key == "saveVehicle" then
                if currentVehicle ~= nil then
                    if numOwnProps > 0 then --variable from client script client_sync_props
                        saveVehicle()

                        DrawNotificationMinimap("~g~Vehicle successfully saved!", "[User Terminal]")
                    else
                        DrawNotificationMinimap("~r~Unable to save~w~ vehicle without attachments!", "[User Terminal]")
                    end
                else
                    DrawNotificationMinimap("~r~No vehicle ~w~to save!", "[User Terminal]")
                end
            end

            if data.key == "sellAllProps" then
                if numOwnProps > 0 then
                    sellProp()
                else
                    DrawNotificationMinimap("~r~No props/weapons ~w~to sell!", "[User Terminal]")
                end
            end

            for k, v in pairs(plyerData.vehicles) do
                if tonumber(data.key) == v.id then
                    for m, n in pairs(vehicles) do
                        if m == v.vehicle then
                            setupRetrievalMenu(v.id, n.name, n.image)

                            break
                        end
                    end
                end
            end
        else
            if data.key == "cancelRetrieve" then
                setupGarageMenu()

                isRetrievalMenuSetup = false
            end

            if currentVehicle == nil then
                for k, v in pairs(plyerData.vehicles) do
                    if tonumber(data.key) == v.id then
                        TriggerServerEvent("server_sync_player:retrieveVehicle", v.id)

                        displayUserTerminal(false) --function from client script client_ui.lua

                        isPlyerInTerminal = false --variable from client script client_terminal_manager.lua
                        isMenuSetup = false
                        isRetrievalMenuSetup = false
                        enableGarageTerminal = false

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
    if enableGarageTerminal then
        isMenuSetup = false
        isRetrievalMenuSetup = false
        enableGarageTerminal = false
    end
end)