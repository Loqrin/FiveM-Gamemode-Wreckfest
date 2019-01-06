--[[
server_sync_player.lua

Functionality to sync player data. i.e load and save data such as player money, vehicles, etc.
]]

--#[Global Variables]#--
vehicleServerID = 0

--#[Local Variables]#--
local saveDirectory = "wreckfest_playerData"
local plyersData = {}
local plyersScoreboard = {}

local xmlIgnore = {
    ["___name"] = {name = "___name"}, 
    ["name"] = {name = "name"}, 
    ["setName"] = {name = "setName"}, 
    ["value"] = {name = "value"}, 
    ["setValue"] = {name = "setValue"}, 
    ["___children"] = {name = "___children"}, 
    ["children"] = {name = "children"}, 
    ["addChild"] = {name = "addChild"}, 
    ["numChildren"] = {name = "numChildren"}, 
    ["___props"] = {name = "___props"}, 
    ["properties"] = {name = "properties"}, 
    ["addProperty"] = {name = "addProperty"}, 
    ["numProperties"] = {name = "numProperties"}
} --doing this prevents having to iterate through the entire table; instead the key can just be called and checked.

local roundTime = 0
local isRoundTimerOn = false

local buildTime = 0
local isBuildTimerOn = false

--local maxRoundTime = 600 --5min
--local maxBuildTime = 180 --3min

local maxRoundTime = 600
local maxBuildTime = 5

--#[Local Functions]#--
local function createTable(data)
	return data
end

local function splitString(string, seperator)
    local tbl = {}
    local increment = 1

    if seperator == nil then
        seperator = "%s"
    end
    
    for splitString in string.gmatch(string, "([^"..seperator.."]+)") do
        tbl[increment] = splitString
        increment = increment + 1
    end

    return tbl
end

local function readXMLFile(xml)
	local readLine = ""

	for line in io.lines(xml) do
		readLine = readLine .. "\n" .. line
	end

	return readLine
end

local function doesSaveDirectoryExist()
    local response = os.execute("cd " .. saveDirectory)

    if response then
        return true
    else
        return false
    end
end

local function doesUserDataFileExist(fileName)
    local response = io.open(saveDirectory .. "/" .. fileName .. ".xml", "r")

    if response ~= nil then
        io.close(response)

        return true
    else
        return false
    end
end

local function createSaveDirectory()
    os.execute("mkdir " .. saveDirectory)

    print("[Wreckfest Log] Successfully created directory: " .. saveDirectory)
end

local function createUserDataFile(fileName, plyID)
    --startingMoney variable from config file config_server_player.lua
    local plyerData = {Data = {steamID = plyID, money = startingMoney, vehicles = {}}}
    
    TableToXML(plyerData, saveDirectory .. "/" .. fileName .. ".xml") --function from libs xml_serializer.lua
end

local function loadUserDataFile(fileName, plyID)
    local callBack = XmlParser:ParseXmlText(readXMLFile(saveDirectory .. "/" .. fileName .. ".xml")) --function from libs xml_parser.lua
    local vehicles = {}

    for k, v in pairs(callBack.Data["vehicles"]) do 
        if xmlIgnore[k] == nil then
            local veh = callBack.Data["vehicles"][k].vehicle:value()
            local props = {}

            for m, n in pairs(callBack.Data["vehicles"][k].props) do
                if xmlIgnore[m] == nil then
                    local model = callBack.Data["vehicles"][k].props[m].model:value()
                    local x = callBack.Data["vehicles"][k].props[m].x:value()
                    local y = callBack.Data["vehicles"][k].props[m].y:value()
                    local z = callBack.Data["vehicles"][k].props[m].z:value()
                    local rotZ = callBack.Data["vehicles"][k].props[m].rotZ:value()

                    props[m] = {model = model, x = x, y = y, z = z, rotZ = rotZ}
                end
            end

            vehicleServerID = vehicleServerID + 1

            vehicles["" .. veh .. "_" .. vehicleServerID] = {}
            vehicles["" .. veh .. "_" .. vehicleServerID] = {vehicle = veh, id = vehicleServerID, props = props}
        end
    end

    plyersData["" .. plyID] = {}
    plyersData["" .. plyID] = {money = callBack.Data["money"]:value(), vehicles = vehicles}


    print("[Wreckfest Log] Successfully fetched data for player: " .. plyID)
end

local function loadData(plySource)
    local plyID = GetPlayerIdentifiers(plySource)
    local fileName = splitString(plyID[1], ":")
    fileName = fileName[1] .. "_" .. fileName[2]

    if not doesSaveDirectoryExist() then
        createSaveDirectory()
    end

    if doesSaveDirectoryExist() then
        print("[Wreckfest Log] Player joined: " .. plyID[1] .. " - " .. plyID[3])
        print("[Wreckfest Log] Attempting to fetch their data...")

        if doesUserDataFileExist(fileName) then
            loadUserDataFile(fileName, plyID[1])
            
            TriggerClientEvent("client_player:loadData", plySource, plyersData["" .. plyID[1]].money, plyersData["" .. plyID[1]].vehicles)
        else
            createUserDataFile(fileName, plyID[1])
            loadUserDataFile(fileName, plyID[1])

            TriggerClientEvent("client_player:loadData", plySource, plyersData["" .. plyID[1]].money, plyersData["" .. plyID[1]].vehicles)
        end
    end
end

local function saveUserData(plySource)
    local plyID = GetPlayerIdentifiers(plySource)
    local plyerData = {Data = {steamID = plyID[1], money = plyersData["" .. plyID[1]].money, vehicles = plyersData["" .. plyID[1]].vehicles}}
    local fileName = splitString(plyID[1], ":")
    fileName = fileName[1] .. "_" .. fileName[2]

    TableToXML(plyerData, saveDirectory .. "/" .. fileName .. ".xml") --function from libs xml_serializer.lua

    print("[Wreckfest Log] Successfully updated data for player: " .. plyID[1])
end

local function purchaseVehicle(plySource, hash)
    local plyID = GetPlayerIdentifiers(plySource)
    local charge = 0

    for k, v in pairs(vehicles) do --table from config file config_vehicles.lua
        if k == hash then
            if tonumber(plyersData["" .. plyID[1]].money) >= tonumber(v.price) then
                vehicleServerID = vehicleServerID + 1

                charge = tonumber(plyersData["" .. plyID[1]].money) - tonumber(v.price)

                plyersData["" .. plyID[1]].money = charge
                plyersData["" .. plyID[1]].vehicles["" .. hash .. "_" .. vehicleServerID] = {}
                plyersData["" .. plyID[1]].vehicles["" .. hash .. "_" .. vehicleServerID] = {id = vehicleServerID, vehicle = hash, props = {}}

                TriggerClientEvent("client_player:loadData", plySource, plyersData["" .. plyID[1]].money, plyersData["" .. plyID[1]].vehicles)
                TriggerClientEvent("client_terminal_buyvehicles:purchaseComplete", plySource, charge, hash, vehicleServerID)

                saveUserData(plySource)
            else
                charge = tonumber(v.price) - tonumber(plyersData["" .. plyID[1]].money)

                TriggerClientEvent("client_terminal_buyvehicles:purchaseFailed", plySource, charge)
            end

            break
        end
    end
end

local function retrieveVehicle(plySource, id)
    local plyID = GetPlayerIdentifiers(plySource)
    local isSuccessful = false
    
    for k, v in pairs(plyersData["" .. plyID[1]].vehicles) do
        if plyersData["" .. plyID[1]].vehicles[k].id == id then
            TriggerClientEvent("client_terminal_garage:retrievalComplete", plySource, plyersData["" .. plyID[1]].vehicles[k])

            isSuccessful = true

            break
        else
            isSuccessful = false
        end
    end

    if not isSuccessful then
        TriggerClientEvent("client_terminal_garage:retrievalFailed", plySource)
    end
end

local function purchaseProp(plySource, hash)
    local plyID = GetPlayerIdentifiers(plySource)
    local charge = 0

    for k, v in pairs(props) do --table from config file config_vehicles.lua
        if k == hash then
            if tonumber(plyersData["" .. plyID[1]].money) >= tonumber(v.price) then
                charge = tonumber(plyersData["" .. plyID[1]].money) - tonumber(v.price)

                plyersData["" .. plyID[1]].money = charge

                TriggerClientEvent("client_player:loadData", plySource, plyersData["" .. plyID[1]].money, plyersData["" .. plyID[1]].vehicles)
                TriggerClientEvent("client_terminal_buyprops:purchaseComplete", plySource, charge, hash, v.dmgMultiplier)

                saveUserData(plySource)
            else
                charge = tonumber(v.price) - tonumber(plyersData["" .. plyID[1]].money)

                TriggerClientEvent("client_terminal_buyprops:purchaseFailed", plySource, charge)
            end

            break
        end
    end
end

local function sellProp(plySource, prop, model)
    local plyID = GetPlayerIdentifiers(plySource)
    local sellAmount = 0

    for k, v in pairs(spawnedProps["" .. plyID[1]]) do
        local sellPrice = 0

        if weapons[model] ~= nil then
            sellPrice = weapons[model].price
        else
            sellPrice = props[model].price
        end

        if spawnedProps["" .. plyID[1]][k].localID == prop then
            sellAmount =  plyersData["" .. plyID[1]].money + (sellPrice * 0.4)

            plyersData["" .. plyID[1]].money = sellAmount

            TriggerClientEvent("client_player:loadData", plySource, plyersData["" .. plyID[1]].money, plyersData["" .. plyID[1]].vehicles)
            TriggerClientEvent("client_build_vehicle:sellComplete", plySource, (sellPrice * 0.4))

            saveUserData(plySource)

            break
        end
    end
end

local function saveVehicle(plySource, hash, vehicleID)
    local plyID = GetPlayerIdentifiers(plySource)

    print("[Wreckfest DEBUG] Attempting to save vehicle " .. hash .. " with the ID of " .. vehicleID .. " for player: " .. plyID[1])

    for k, v in pairs(vehicles) do --table from config file config_vehicles.lua
        if k == hash then
            if plyersData["" .. plyID[1]].vehicles["" .. hash .. "_" .. vehicleID] ~= nil then
                plyersData["" .. plyID[1]].vehicles["" .. hash .. "_" .. vehicleID].props = {}

                if attachedProps["" .. plyID[1]] ~= nil then
                    for k, v in pairs(attachedProps["" .. plyID[1]]) do --table from server script server_sync_attachments.lua
                        plyersData["" .. plyID[1]].vehicles["" .. hash .. "_" .. vehicleID].props["" .. attachedProps["" .. plyID[1]][k].serverID] = {}
                        plyersData["" .. plyID[1]].vehicles["" .. hash .. "_" .. vehicleID].props["" .. attachedProps["" .. plyID[1]][k].serverID] = 
                        {
                            model = attachedProps["" .. plyID[1]][k].model,
                            x = attachedProps["" .. plyID[1]][k].x,
                            y = attachedProps["" .. plyID[1]][k].y,
                            z = attachedProps["" .. plyID[1]][k].z,
                            rotZ = attachedProps["" .. plyID[1]][k].rotZ
                        }
                    end
                end

                print("[Wreckfest DEBUG] Successfully saved vehicle " .. hash .. " with the ID of " .. vehicleID)

                TriggerClientEvent("client_player:loadData", plySource, plyersData["" .. plyID[1]].money, plyersData["" .. plyID[1]].vehicles)

                saveUserData(plySource)
            end

            break
        end
    end
end

local function purchaseWeapon(plySource, hash)
    local plyID = GetPlayerIdentifiers(plySource)
    local charge = 0

    for k, v in pairs(weapons) do --table from config file config_weapons.lua
        if k == hash then
            if tonumber(plyersData["" .. plyID[1]].money) >= tonumber(v.price) then
                charge = tonumber(plyersData["" .. plyID[1]].money) - tonumber(v.price)

                plyersData["" .. plyID[1]].money = charge

                TriggerClientEvent("client_player:loadData", plySource, plyersData["" .. plyID[1]].money, plyersData["" .. plyID[1]].vehicles)
                TriggerClientEvent("client_terminal_buyweapons:purchaseComplete", plySource, charge, hash, v.weapon, v.type, v.range, v.bulletDrop, v.cooldownTime, v.dmgMultiplier)

                saveUserData(plySource)
            else
                charge = tonumber(v.price) - tonumber(plyersData["" .. plyID[1]].money)

                TriggerClientEvent("client_terminal_buyweapons:purchaseFailed", plySource, charge)
            end
        end
    end
end

local function appendScoreboard(plySource, plyName)
    local plyID = GetPlayerIdentifiers(plySource)
    local allPlyers = GetPlayers()

    if plyersScoreboard["" .. plyID[1]] == nil then
        plyersScoreboard["" .. plyID[1]] = {name = plyName, kills = 0, deaths = 0}

        for k, v in pairs(allPlyers) do
            TriggerClientEvent("client_player:appendScoreboard", v, plyID[1], plyName, 0, 0)
        end
    end
end

local function updateScoreboard(plySource, plyName, addKill, addDeath)
    local plyID = GetPlayerIdentifiers(plySource)
    local allPlyers = GetPlayers()

    if addKill then
        plyersScoreboard["" .. plyID[1]].kills = plyersScoreboard["" .. plyID[1]].kills + 1
    elseif addDeath then
        plyersScoreboard["" .. plyID[1]].deaths = plyersScoreboard["" .. plyID[1]].deaths + 1
    end

    for k, v in pairs(allPlyers) do
        TriggerClientEvent("client_player:updateScoreboard", v, plyID[1], plyName, plyersScoreboard["" .. plyID[1]].kills, plyersScoreboard["" .. plyID[1]].deaths)
    end
end

function roundTimer(state)
    local allPlyers = GetPlayers()

    if state then
        roundTime = maxRoundTime
        
        for k, v in pairs(allPlyers) do
            local id = GetPlayerIdentifiers(v)

            plyersScoreboard["" .. id[1]].kills = 0
            plyersScoreboard["" .. id[1]].deaths = 0

            TriggerClientEvent("client_player:RoundTimerStarting", v, id[1], roundTime)
        end

        print("[Wreckfest Log] Round Starting...")
    else
        roundTime = roundTime - 1
    end

    if not isRoundTimerOn then
        if roundTime <= 0 then
            isBuildTimerOn = false
            isRoundTimerOn = true

            for k, v in pairs(allPlyers) do
                TriggerClientEvent("client_player:RoundTimerEnding", v)
            end

            print("[Wreckfest Log] Round Ending...")

            buildTimer(true)
        else
            SetTimeout(1000, function()
                roundTimer(false)
            end)
        end
    end
end

function buildTimer(state)
    local allPlyers = GetPlayers()

    if state then
        buildTime = maxBuildTime

        for k, v in pairs(allPlyers) do
            TriggerClientEvent("client_player:BuildTimerStarting", v, buildTime)
        end

        print("[Wreckfest Log] Build Time Starting...")
    else
        buildTime = buildTime - 1
    end

    if not isBuildTimerOn then
        if buildTime <= 0 then
            isRoundTimerOn = false
            isBuildTimerOn = true

            for k, v in pairs(allPlyers) do
                TriggerClientEvent("client_player:BuildTimerEnding", v)
            end

            print("[Wreckfest Log] Build Time Over...")

            roundTimer(true)
        else
            SetTimeout(1000, function()
                buildTimer(false)
            end)
        end
    end
end

local function plyJoinedScoreboard(plySource)
    local allPlyers = GetPlayers()

    for k, v in pairs(allPlyers) do
        local id = GetPlayerIdentifiers(v)

        if plyersScoreboard["" .. id[1]] ~= nil and v ~= plySource then
            TriggerClientEvent("client_player:appendScoreboard", plySource, id[1], plyersScoreboard["" .. id[1]].name, plyersScoreboard["" .. id[1]].kills, plyersScoreboard["" .. id[1]].deaths)
        end
    end

    if not isBuildTimerOn then
        TriggerClientEvent("client_player:updateScoreboardTimer", plySource, false, buildTime)
    elseif not isRoundTimerOn then
        TriggerClientEvent("client_player:updateScoreboardTimer", plySource, true, buildTime)
    end
end

local function clearScoreboard()
    local allPlyers = GetPlayers()

    plyersScoreboard = {}

    for k, v in pairs(allPlyers) do
        TriggerClientEvent("client_player:clearScoreboard", v)
    end
end

local function plyPayment(plySource)
    local plyID = GetPlayerIdentifiers(plySource)

    plyersData["" .. plyID[1]].money = plyersData["" .. plyID[1]].money + paymentMoney --variable from config file config_server_player.lua

    TriggerClientEvent("client_player:loadData", plySource, plyersData["" .. plyID[1]].money, plyersData["" .. plyID[1]].vehicles)
    TriggerClientEvent("client_player:paymentComplete", plySource, paymentMoney)

    saveUserData(plySource)
end

buildTimer(true)

--#[Event Handlers]#--
RegisterServerEvent("server_sync_player:loadData")
AddEventHandler("server_sync_player:loadData", function()
    loadData(source)
end)

RegisterServerEvent("server_sync_player:purchaseVehicle")
AddEventHandler("server_sync_player:purchaseVehicle", function(hash)
    purchaseVehicle(source, hash)
end)

RegisterServerEvent("server_sync_player:retrieveVehicle")
AddEventHandler("server_sync_player:retrieveVehicle", function(id)
    retrieveVehicle(source, id)
end)

RegisterServerEvent("server_sync_player:purchaseProp")
AddEventHandler("server_sync_player:purchaseProp", function(hash)
    purchaseProp(source, hash)
end)

RegisterServerEvent("server_sync_player:saveVehicle")
AddEventHandler("server_sync_player:saveVehicle", function(hash, vehicleID)
    saveVehicle(source, hash, vehicleID)
end)

RegisterServerEvent("server_sync_player:purchaseWeapon")
AddEventHandler("server_sync_player:purchaseWeapon", function(hash)
    purchaseWeapon(source, hash)
end)

RegisterServerEvent("server_sync_player:sellProp")
AddEventHandler("server_sync_player:sellProp", function(prop, model)
    sellProp(source, prop, model)
end)

RegisterServerEvent("server_sync_player:appendScoreboard")
AddEventHandler("server_sync_player:appendScoreboard", function(plyName)
    appendScoreboard(source, plyName)
end)

RegisterServerEvent("server_sync_player:updateScoreboard")
AddEventHandler("server_sync_player:updateScoreboard", function(plyName, addKill, addDeath)
    updateScoreboard(source, plyName, addKill, addDeath)
end)

RegisterServerEvent("server_sync_player:plyJoinedScoreboard")
AddEventHandler("server_sync_player:plyJoinedScoreboard", function()
    plyJoinedScoreboard(source)
end)

RegisterServerEvent("server_sync_player:clearScoreboard")
AddEventHandler("server_sync_player:clearScoreboard", function()
    clearScoreboard()
end)

RegisterServerEvent("server_sync_player:payment")
AddEventHandler("server_sync_player:payment", function()
    plyPayment(source)
end)

RegisterServerEvent("server_sync_player:sellAllProps")
AddEventHandler("server_sync_player:sellAllProps", function()
    sellAllProps(source)
end)