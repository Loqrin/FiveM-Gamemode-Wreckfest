--[[
██╗    ██╗███████╗ █████╗ ████████╗██╗  ██╗███████╗██████╗      █████╗ ███╗   ██╗██████╗     ████████╗██╗███╗   ███╗███████╗
██║    ██║██╔════╝██╔══██╗╚══██╔══╝██║  ██║██╔════╝██╔══██╗    ██╔══██╗████╗  ██║██╔══██╗    ╚══██╔══╝██║████╗ ████║██╔════╝
██║ █╗ ██║█████╗  ███████║   ██║   ███████║█████╗  ██████╔╝    ███████║██╔██╗ ██║██║  ██║       ██║   ██║██╔████╔██║█████╗  
██║███╗██║██╔══╝  ██╔══██║   ██║   ██╔══██║██╔══╝  ██╔══██╗    ██╔══██║██║╚██╗██║██║  ██║       ██║   ██║██║╚██╔╝██║██╔══╝  
╚███╔███╔╝███████╗██║  ██║   ██║   ██║  ██║███████╗██║  ██║    ██║  ██║██║ ╚████║██████╔╝       ██║   ██║██║ ╚═╝ ██║███████╗
 ╚══╝╚══╝ ╚══════╝╚═╝  ╚═╝   ╚═╝   ╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝    ╚═╝  ╚═╝╚═╝  ╚═══╝╚═════╝        ╚═╝   ╚═╝╚═╝     ╚═╝╚══════╝

 Simple script to modify the weather and time.
]]

--#[Local Functions]#--
local function freezeWeather(weatherType)
    ClearWeatherTypePersist()
    SetWeatherTypePersist(weatherType)
    SetWeatherTypeNowPersist(weatherType)
    SetWeatherTypeNow(weatherType)
    SetOverrideWeather(weatherType)
end

local function freezeTime(hour, minute, second)
    NetworkOverrideClockTime(hour, minute, second)
end

--#[Citizen Threads]#--
Citizen.CreateThread(function()
    if weatherAndTimeModule then
        while true do
            freezeWeather("EXTRASUNNY")
            freezeTime(12, 0, 0)

            Citizen.Wait(1)
        end
    end
end)