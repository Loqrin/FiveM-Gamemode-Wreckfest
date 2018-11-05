--[[
███╗   ██╗███████╗██╗   ██╗███████╗██████╗     ██╗    ██╗ █████╗ ███╗   ██╗████████╗███████╗██████╗ 
████╗  ██║██╔════╝██║   ██║██╔════╝██╔══██╗    ██║    ██║██╔══██╗████╗  ██║╚══██╔══╝██╔════╝██╔══██╗
██╔██╗ ██║█████╗  ██║   ██║█████╗  ██████╔╝    ██║ █╗ ██║███████║██╔██╗ ██║   ██║   █████╗  ██║  ██║
██║╚██╗██║██╔══╝  ╚██╗ ██╔╝██╔══╝  ██╔══██╗    ██║███╗██║██╔══██║██║╚██╗██║   ██║   ██╔══╝  ██║  ██║
██║ ╚████║███████╗ ╚████╔╝ ███████╗██║  ██║    ╚███╔███╔╝██║  ██║██║ ╚████║   ██║   ███████╗██████╔╝
╚═╝  ╚═══╝╚══════╝  ╚═══╝  ╚══════╝╚═╝  ╚═╝     ╚══╝╚══╝ ╚═╝  ╚═╝╚═╝  ╚═══╝   ╚═╝   ╚══════╝╚═════╝ 

Simple module to make the player never receive a wanted level.
]]

--#[Local Functions]#--
local function neverWanted(playerID)
    if GetPlayerWantedLevel(playerID) ~= 0 then
        SetPlayerWantedLevel(playerID, 0, false)
        SetPlayerWantedLevelNow(playerID, false)
    end
end

--#[Citizen Threads]#--
Citizen.CreateThread(function()
    if neverWantedModule then
        while true do 
            local playerID = PlayerId()

            neverWanted(playerID)

            Citizen.Wait(1)
        end
    end
end)