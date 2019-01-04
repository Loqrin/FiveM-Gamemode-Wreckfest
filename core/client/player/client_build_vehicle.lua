--[[
client_build_vehicle.lua

Functionality to allow the player to build their vehicle with props.
]]

--#[Local Variables]#--
local selectedProp = nil
local selectedPropModel = nil
local selectedPropSensitivity = 1
local isPropSelected = false

local raycastDistance = 5.0

local toggleRotation = false

local zoomAmount = 5.0
local maxZoomAmount = 10.0
local minZoomAmount = 1.0
local incrementZoomAmount = 0.2

local currentItem = ""
local currentKey = ""

local canAttach = false
local attachmentPos = vector3(0, 0, 0)

local isForcedSelected = false

--#[Global Functions]#--
function forceSelectedProp(prop)
    selectedProp = prop

    isForcedSelected = true
end

--#[Local Functions]#--
local function editSelectedSensitivity(state)
    if state then
        if selectedPropSensitivity == 0.0001 then
            selectedPropSensitivity = 0.001
        elseif selectedPropSensitivity == 0.001 then
            selectedPropSensitivity = 0.01
        elseif selectedPropSensitivity == 0.01 then
            selectedPropSensitivity = 0.1
        elseif selectedPropSensitivity == 0.1 then
            selectedPropSensitivity = 1
        elseif selectedPropSensitivity == 1 then
            selectedPropSensitivity = 10
        elseif selectedPropSensitivity == 10 then
            selectedPropSensitivity = 100
        end
    else
        if selectedPropSensitivity == 100 then
            selectedPropSensitivity = 10
        elseif selectedPropSensitivity == 10 then
            selectedPropSensitivity = 1
        elseif selectedPropSensitivity == 1 then
            selectedPropSensitivity = 0.1
        elseif selectedPropSensitivity == 0.1 then
            selectedPropSensitivity = 0.01
        elseif selectedPropSensitivity == 0.01 then
            selectedPropSensitivity = 0.001
        elseif selectedPropSensitivity == 0.001 then
            selectedPropSensitivity = 0.0001
        end
    end
end

local function editSelectedYaw(state)
    if state then
        local propRot = vector3(GetEntityPitch(selectedProp), GetEntityRotation(selectedProp, 2).y, Round((GetEntityRotation(selectedProp, 2).z + selectedPropSensitivity), 4))

        SetEntityRotation(selectedProp, propRot, 2, true)
    else
        local propRot = vector3(GetEntityPitch(selectedProp), GetEntityRotation(selectedProp, 2).y, Round((GetEntityRotation(selectedProp, 2).z - selectedPropSensitivity), 4))

        SetEntityRotation(selectedProp, propRot, 2, true)
    end
end

local function zoomControl()
    DisableControlAction(1, keys.ScrollDown, true)
    DisableControlAction(1, keys.ScrollUp, true)
    DisableControlAction(1, keys.ScrollDown2, true)
    DisableControlAction(1, keys.ScrollUp2, true)

    if IsDisabledControlJustReleased(1, keys.ScrollDown) then
        if zoomAmount > minZoomAmount then
            zoomAmount = zoomAmount - incrementZoomAmount
        end
    end

    if IsDisabledControlJustReleased(1, keys.ScrollUp) then
        if zoomAmount < maxZoomAmount then
            zoomAmount = zoomAmount + incrementZoomAmount
        end
    end
end

local function attachProp()
    if canAttach then
        local rot = vector3(GetEntityRotation(selectedProp, 2).x, GetEntityRotation(selectedProp, 2).y, GetEntityRotation(selectedProp, 2).z)
        local relativePos = GetOffsetFromEntityGivenWorldCoords(currentVehicle, attachmentPos)

        AttachEntityToEntity(selectedProp, currentVehicle, -1, relativePos.x, relativePos.y, relativePos.z, 0.0, 0.0, (rot.z - GetEntityRotation(currentVehicle, 2).z), false, false, false, false, 2, true)
        SetEntityCollision(selectedProp, true, true)

        syncAttachment(selectedProp, currentVehicleServerID, relativePos, rot.z) --function from client script client_sync_attachments.lua

        displayUserMenu(false)
        displayScaleform(false)

        isPropSelected = false
        toggleRotation = false
        selectedProp = nil

        DrawNotificationMinimap("Attachment ~g~successful!~w~", "[User Terminal]")
    else
        DrawNotificationMinimap("~r~Nothing to attach to!", "[User Terminal]")
    end
end

local function sellProp()
    for k, v in pairs(ownProps) do
        if ownProps[k].localID == selectedProp then
            TriggerServerEvent("server_sync_player:sellProp", selectedProp, selectedPropModel)

            unsyncProp(ownProps[k].serverID)

            DeleteObject(selectedProp)

            displayUserMenu(false)
            displayScaleform(false)

            isPropSelected = false
            toggleRotation = false
            selectedProp = nil
            selectedPropModel = nil

            break
        end
    end
end

local function sellComplete(sellAmount)
    if #ownProps > 0 then
        TriggerServerEvent("server_sync_player:saveVehicle", currentVehicleModel, currentVehicleServerID)
    end
    
    DrawNotificationMinimap("~g~Successfully sold prop for: ~y~$" .. sellAmount, "[User Terminal]")
end

local function userMenuFunctionality()
    DisableControlAction(1, keys.Enter, true)
    DisableControlAction(1, keys.LeftArrow, true)
    DisableControlAction(1, keys.RightArrow, true)

    if IsDisabledControlJustReleased(1, keys.Enter) then
        if currentKey == "toggleRotation" then
            if toggleRotation then
                toggleRotation = false

                updateUserMenuItem("rotateYaw", "Yaw:" .. 0)
                updateUserMenuItem("sensitivity", "Sensitivity:" .. 0)
            else
                toggleRotation = true

                updateUserMenuItem("rotateYaw", "[Rot Toggled] Yaw:" .. 0)
                updateUserMenuItem("sensitivity", "[Rot Toggled] Sensitivity:" .. 0)
            end
        elseif currentKey == "attachProp" then
            attachProp()
        elseif currentKey == "sellProp" then
            sellProp()
        end
    end

    if not toggleRotation then
        if currentKey == "sensitivity" then
            if IsDisabledControlJustReleased(1, keys.LeftArrow) then
                editSelectedSensitivity(true)

                updateUserMenuItem(currentKey, "Sensitivity:" .. Round(selectedPropSensitivity, 4))
            end

            if IsDisabledControlJustReleased(1, keys.RightArrow) then
                editSelectedSensitivity(false)

                updateUserMenuItem(currentKey, "Sensitivity:" .. Round(selectedPropSensitivity, 4))
            end
        end

        if currentKey == "rotateYaw" then
            if IsDisabledControlJustReleased(1, keys.LeftArrow) then
                editSelectedYaw(true)

                updateUserMenuItem(currentKey, "Yaw:" .. Round(GetEntityRotation(selectedProp, 2).z, 4))
            end

            if IsDisabledControlJustReleased(1, keys.RightArrow) then
                editSelectedYaw(false)

                updateUserMenuItem(currentKey, "Yaw:" .. Round(GetEntityRotation(selectedProp, 2).z, 4))
            end
        end
    end
end

--#[Citizen Threads]#--
Citizen.CreateThread(function()
    while true do 
        local plyPed = GetPlayerPed(-1)
        local plyPos = GetEntityCoords(plyPed)
        local camDirX, camDirY, camDirZ = RotationToDirection(GetGameplayCamRot(2)) --function from client script client_general_functions.lua 

        if numOwnProps > 0 and not enterArena then --variable from client script client_sync_props.lua and client_terminal_manager.lua
            local distancePos = vector3((plyPos.x + raycastDistance * camDirX), (plyPos.y + raycastDistance * camDirY), (plyPos.z + raycastDistance * camDirZ + 1.2))
            local didHit, endCoords, surfaceCoords, entity

            if selectedProp == nil then
                didHit, endCoords, surfaceCoords, entity = CastRay(plyPos, distancePos, -1, plyPed) --function from client script client_general_functions.lua

                if didHit then
                    local foundProp = nil
                    local foundAttachment = nil
                    local foundModel = nil
                    local attachmentServerID = 0
    
                    for k, v in pairs(ownProps) do --table from client script client_sync_props.lua
                        if tonumber(v.localID) == tonumber(entity) then
                            if ownAttachedProps["" .. v.serverID] == nil then
                                foundProp = tonumber(v.localID)
                                foundModel = v.model
        
                                break
                            else
                                foundAttachment = tonumber(v.localID)
                                attachmentServerID = v.serverID
                                foundModel = v.model

                                break
                            end
                        end
                    end
    
                    if foundProp ~= nil then
                        DisableControlAction(1, keys.E, true)
    
                        Draw3DText(endCoords.x, endCoords.y, endCoords.z, "[Press ~y~" .. ConvertInstructBtnText(GetControlInstructionalButton(1, keys.E, 1)) .. "~w~ - Select Prop]", 255, 255, 255, 255, 4, 0.45, true, true, true, true, 0, 0, 0, 0, 55) --function from client script ui.lua
                    
                        if IsDisabledControlJustReleased(1, keys.E) then
                            if selectedProp == nil then
                                selectedProp = entity
                                selectedPropModel = foundModel
                            end
                        end
                    end

                    if foundAttachment ~= nil then
                        DisableControlAction(1, keys.E, true)
    
                        Draw3DText(endCoords.x, endCoords.y, endCoords.z, "[Press ~y~" .. ConvertInstructBtnText(GetControlInstructionalButton(1, keys.E, 1)) .. "~w~ - Detach Prop]", 255, 255, 255, 255, 4, 0.45, true, true, true, true, 0, 0, 0, 0, 55) --function from client script ui.lua
                        
                        if IsDisabledControlJustReleased(1, keys.E) then
                            if selectedProp == nil then
                                DetachEntity(entity, false, false)
                                unsyncAttachment(attachmentServerID) --function from client script client_sync_attachments.lua

                                selectedProp = entity
                                selectedPropModel = foundModel
                            end
                        end
                    end
                end
            else
                local propPos = GetEntityCoords(selectedProp)
                local propRot = vector3(GetEntityPitch(selectedProp), GetEntityRotation(selectedProp, 2).y, GetEntityRotation(selectedProp, 2).z)
                local distancePos = vector3((plyPos.x + zoomAmount * camDirX), (plyPos.y + zoomAmount * camDirY), (plyPos.z + zoomAmount * camDirZ + 1.2))
                local didHit, endCoords, surfaceCoords, entity = CastRay(plyPos, distancePos, -1, plyPed)

                if not isPropSelected then
                    local menuItems = 
                    {
                        {key = "attachProp", item1 = "Attach Prop", item2 = "none"},
                        {key = "toggleRotation", item1 = "Toggle Rotation", item2 = "none"},
                        {key = "sensitivity", item1 = "Sensitivity:", item2 = selectedPropSensitivity},
                        {key = "rotateYaw", item1 = "Yaw:", item2 = 0.0},
                        {key = "sellProp", item1 = "Sell Prop", item2 = "none"}
                    }

                    local scaleformItems = 
                    {
                        {button = keys.UpArrow, text = "Navigate Up"},
                        {button = keys.DownArrow, text = "Navigate Down"},
                        {button = keys.LeftArrow, text = "Alter Value"},
                        {button = keys.RightArrow, text = "Alter Value"},
                        {button = keys.Enter, text = "Execute"}
                    }

                    updateUserMenu("Prop Selected", menuItems) --function from client script client_ui.lua
                    displayUserMenu(true) --function from client script client_ui.lua

                    SetupScaleform(scaleformItems, "instructional_buttons") --function from client script client_ui.lua
                    displayScaleform(true) --function from client script client_ui.lua

                    SetEntityCollision(selectedProp, false, true)

                    isPropSelected = true
                end

                userMenuScrollFunctionality() --function from client script client_ui.lua
                userMenuFunctionality()

                zoomControl()
                
                if IsNear(plyPos, plyerPlatformPos, 10) then --function from client script client_general_functions.lua
                    if entity == currentVehicle then
                        SetEntityCoords(selectedProp, endCoords)

                        Draw3DText(propPos.x, propPos.y, propPos.z + 1.0, "[~g~Prop Selected - ~g~Can Attach Prop~w~]~n~[Press ~y~" .. ConvertInstructBtnText(GetControlInstructionalButton(1, keys.Backspace, 1)) .. "~w~ - Deselect Prop]", 255, 255, 255, 255, 4, 0.45, true, true, true, true, 0, 0, 0, 0, 55) --function from client script ui.lua

                        attachmentPos = endCoords
                        canAttach = true
                    else
                        if endCoords.z == 0.0 then
                            SetEntityCoords(selectedProp, (plyPos.x + zoomAmount * camDirX), (plyPos.y + zoomAmount * camDirY), (plyPos.z + zoomAmount * camDirZ))
                        
                            attachmentPos = GetEntityCoords(selectedProp)
                        else
                            SetEntityCoords(selectedProp, endCoords)

                            attachmentPos = endCoords
                        end

                        Draw3DText(propPos.x, propPos.y, propPos.z + 1.0, "[~g~Prop Selected - ~r~Can't Attach Prop~w~]~n~[Press ~y~" .. ConvertInstructBtnText(GetControlInstructionalButton(1, keys.Backspace, 1)) .. "~w~ - Deselect Prop]", 255, 255, 255, 255, 4, 0.45, true, true, true, true, 0, 0, 0, 0, 55) --function from client script ui.lua

                        canAttach = false
                    end

                    if toggleRotation then
                        SetEntityHeading(selectedProp, GetGameplayCamRot(2).z)
                    else
                        --SetEntityRotation(selectedProp, propRot, 2, true)
                    end
                
                    DisableControlAction(1, keys.Backspace, true)

                    if IsDisabledControlJustReleased(1, keys.Backspace) then
                        if selectedProp ~= nil then
                            displayUserMenu(false)
                            displayScaleform(false)

                            SetEntityCollision(selectedProp, true, true)

                            isPropSelected = false
                            toggleRotation = false
                            selectedProp = nil
                        end
                    end
                else
                    Draw3DText(propPos.x, propPos.y, propPos.z + 1.0, "[~g~Prop Selected - ~r~Out of range!~w~]", 255, 255, 255, 255, 4, 0.45, true, true, true, true, 0, 0, 0, 0, 55) --function from client script ui.lua
                end
            end
        end

        Citizen.Wait(1)
    end
end)

--#[Event Handlers]#--
RegisterNetEvent("client_build_vehicle:sellComplete")
AddEventHandler("client_build_vehicle:sellComplete", function(sellAmount)
    sellComplete(sellAmount)
end)

--#[NUI Callbacks]#--
RegisterNUICallback("userMenuSelectedItem", function(data, cb)
    currentItem = data.item
    currentKey = data.key

    cb("ok")
end)