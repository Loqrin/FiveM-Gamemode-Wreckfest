--[[
client_ui.lua

Provides functionality for the UI: native UI and HTML UI.
]]

--#[Local Variables]#--
local instructionalBtn = 
{
    ["Mouse Wheel Up/Down"] = "b_117", ["Mouse Wheel Down"] = "b_116", ["Mouse Wheel Up"] = "b_115", ["Left Alt"] = "b_1015", ["Space"] = "b_2000",
    ["Left Ctrl"] = "b_1013", ["Tab"] = "b_1002", ["Left Shift"] = "b_1000", ["Right Ctrl"] = "b_1014", ["Caps"] = "b_1012", ["Backspace"] = "b_1004",
    ["Esc"] = "b_199", ["Enter"] = "b_1003", ["Up Arrow"] = "b_194", ["Down Arrow"] = "b_195", ["Left Arrow"] = "b_196", ["Right Arrow"] = "b_197", 
    ["Delete"] = "b_198", ["Left Mouse Btn"] = "b_100",
    ["A"] = "t_A", ["B"] = "t_B", ["C"] = "t_C", ["D"] = "t_D", ["E"] = "t_E", ["F"] = "t_F", ["G"] = "t_G", ["H"] = "t_H", ["I"] = "t_I",
    ["J"] = "t_J", ["K"] = "t_K", ["L"] = "t_L", ["M"] = "t_M", ["N"] = "t_N", ["O"] = "t_O", ["P"] = "t_P", ["Q"] = "t_Q", ["R"] = "t_R",
    ["S"] = "t_S", ["T"] = "t_T", ["U"] = "t_U", ["V"] = "t_V", ["W"] = "t_W", ["X"] = "t_X", ["Y"] = "t_Y", ["Z"] = "t_Z"
}

local scaleform = nil
local showScaleform = false

--#[Global Functions]#--
function displayWelcomeMenu(state)
    if state then
        SetNuiFocus(true, true)

        SendNUIMessage({
            showWelcomeMenu = true
        })
    else
        SetNuiFocus(false, false)

        SendNUIMessage({
            hideWelcomeMenu = true
        })
    end
end

function displayBlackoutMenu(state)
    if state then
        SendNUIMessage({
            showBlackoutMenu = true
        })
    else
        SendNUIMessage({
            hideBlackoutMenu = true
        })
    end
end

function displayUserTerminal(state)
    if state then
        SetNuiFocus(true, true)

        SendNUIMessage({
            showUserTerminal = true
        })
    else
        SetNuiFocus(false, false)

        SendNUIMessage({
            hideUserTerminal = true
        })
    end
end

function updateUserTerminalTitle(text)
    SendNUIMessage({
        updateUserTerminalTitlebar = true,
        titleText = text
    })
end

function updateUserTerminalNavHeading(text)
    SendNUIMessage({
        updateUserTerminalNavHeading = true,
        navHeading = text
    })
end

function appendUserTerminalNavList(key, item, sort)
    SendNUIMessage({
        appendUserTerminalNavList = true,
        key = key,
        item = item,
        sort = sort
    })
end

function updateUserTerminalContentHeading(text)
    SendNUIMessage({
        updateUserTerminalContentHeading = true,
        contentHeading = text
    })
end

function appendUserTerminalContentImage(image)
    SendNUIMessage({
        appendUserTerminalContentImage = true,
        image = image
    })
end

function updateUserTerminalContentText(text)
    SendNUIMessage({
        updateUserTerminalContentText = true,
        contentText = text
    })
end

function clearUserTerminalNavList()
    SendNUIMessage({
        clearUserTerminalNavList = true
    })
end

function clearUserTerminalContentImages()
    SendNUIMessage({
        clearUserTerminalContentImages = true
    })
end

function detectUserTerminalMouseClick()
    SendNUIMessage({
        detectUserTerminalMouseClick = true
    })
end

function displayUserMenu(state)
    if state then
        SendNUIMessage({
            showUserMenu = true
        })
    else
        SendNUIMessage({
            hideUserMenu = true
        })
    end
end

function userMenuScrollFunctionality()
    DisableControlAction(1, keys.UpArrow, true)
    DisableControlAction(1, keys.DownArrow, true)

    if IsDisabledControlJustReleased(1, keys.UpArrow) then
        SendNUIMessage({
            scrollUserMenuUp = true
        })
    end

    if IsDisabledControlJustReleased(1, keys.DownArrow) then
        SendNUIMessage({
            scrollUserMenuDown = true
        })
    end
end

function updateUserMenu(title, items)
    SendNUIMessage({
        clearUserMenuList = true
    })

    SendNUIMessage({
        updateUserMenuTitle = true,
        titleText = title
    })

    for k, v in ipairs(items) do
        SendNUIMessage({
            appendUserMenuItem = true,
            key = items[k].key,
            item1 = items[k].item1,
            item2 = items[k].item2
        })
    end

    SendNUIMessage({
        finishUserMenuAppending = true
    })
end

function updateUserMenuItem(key, text)
    SendNUIMessage({
        updateUserMenuItem = true,
        key = key,
        itemText = text
    })
end

function displayScoreboard(state)
    if state then
        SendNUIMessage({
            showScoreboard = true
        })
    else
        SendNUIMessage({
            hideScoreboard = true
        })
    end
end

function scoreboardAddPlyer(plyID, plyName, kills, deaths)
    SendNUIMessage({
        scoreboardAddPlyer = true,
        plyerID = plyID,
        plyerName = plyName,
        plyerKills = kills,
        plyerDeaths = deaths
    })
end

function scoreboardUpdatePlyer(plyID, plyName, kills, deaths)
    SendNUIMessage({
        scoreboardUpdatePlyer = true,
        plyerID = plyID,
        plyerName = plyName,
        plyerKills = kills,
        plyerDeaths = deaths
    })
end

function scoreboardUpdateTimer(duration, text)
    SendNUIMessage({
        scoreboardUpdateTimer = true,
        duration = duration,
        timerText = text
    })
end

function scoreboardClear()
    SendNUIMessage({
        scoreboardClear = true
    })
end

function Draw3DText(x, y, z, str, r, g, b, a, font, scaleSize, enableProportional, enableCentre, enableOutline, enableShadow, sDist, sR, sG, sB, sA)
    local onScreen, worldX, worldY = World3dToScreen2d(x, y, z)
    local gameplayCamX, gameplayCamY, gameplayCamZ = table.unpack(GetGameplayCamCoords())
    
    if onScreen then
        SetTextScale(1.0, scaleSize)
        SetTextFont(font)
        SetTextColour(r, g, b, a)
        SetTextEdge(2, 0, 0, 0, 150)

        if enableProportional then
            SetTextProportional(1)
        end

        if enableOutline then
            SetTextOutline()
        end

        if enableShadow then
            SetTextDropshadow(sDist, sR, sG, sB, sA)
            SetTextDropShadow()
        end

        if enableCentre then
            SetTextCentre(1)
        end
        
        SetTextEntry("STRING")
        AddTextComponentString(str)
        DrawText(worldX, worldY)
    end
end

function DrawNotificationMinimap(text, heading)
	SetNotificationTextEntry("STRING")
	AddTextComponentString(text)
	SetNotificationMessage("CHAR_MULTIPLAYER", "CHAR_MULTIPLAYER", true, 4, heading, "")
	DrawNotification(false, true)
end

function DrawNotifcationNormal(text)
    SetNotificationTextEntry("STRING")
    AddTextComponentString(text)
    DrawNotification(false, false)
end

function ConvertInstructBtnText(btn)
    local convertedText = "Unknown Btn"

    for k, v in pairs(instructionalBtn) do
        if btn == v then
            convertedText = k

            break
        end
    end

    return convertedText
end

function SetupScaleform(items, type)
    scaleform = RequestScaleformMovie(type)
    local inc = 0

    while not HasScaleformMovieLoaded(scaleform) do
        Citizen.Wait(1)
    end

    PushScaleformMovieFunction(scaleform, "CLEAR_ALL")
    PopScaleformMovieFunctionVoid()

    PushScaleformMovieFunction(scaleform, "SET_CLEAR_SPACE")
    PushScaleformMovieFunctionParameterInt(200)
    PopScaleformMovieFunctionVoid()

    for k, v in pairs(items) do
        PushScaleformMovieFunction(scaleform, "SET_DATA_SLOT")
        PushScaleformMovieFunctionParameterInt(inc)
        N_0xe83a3e3557a56640(GetControlInstructionalButton(1, items[k].button, true)) --AddScaleformMovieMethodParameterButtonName(button)
        BeginTextCommandScaleformString("STRING")
        AddTextComponentScaleform(items[k].text)
        EndTextCommandScaleformString()
        PopScaleformMovieFunctionVoid()

        inc = inc + 1
    end

    PushScaleformMovieFunction(scaleform, "DRAW_INSTRUCTIONAL_BUTTONS")
    PopScaleformMovieFunctionVoid()

    PushScaleformMovieFunction(scaleform, "SET_BACKGROUND_COLOUR")
    PushScaleformMovieFunctionParameterInt(0)
    PushScaleformMovieFunctionParameterInt(0)
    PushScaleformMovieFunctionParameterInt(0)
    PushScaleformMovieFunctionParameterInt(80)
    PopScaleformMovieFunctionVoid()
end

function displayScaleform(state)
    if state then
        showScaleform = true
    else
        showScaleform = false
    end
end

--#[Citizen Threads]#--
Citizen.CreateThread(function()
    while true do 
        if showScaleform then
            if scaleform ~= nil then
                DrawScaleformMovieFullscreen(scaleform, 255, 255, 255, 255, 0)
            end
        end

        Citizen.Wait(1)
    end
end)

--#[NUI Callbacks]#--
RegisterNUICallback("closeUserTerminal", function(data, cb)
    displayUserTerminal(false)

    isPlyerInTerminal = false --variable from client script client_terminal_manager.lua
end)