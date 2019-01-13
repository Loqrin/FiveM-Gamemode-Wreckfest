--[[
client_general_functions.lua

Provides functions and variables generally used throughout the gamemode.
]]

--#[Global Variables]#--
keys = {F5 = 166, UpArrow = 172, DownArrow = 173, LeftArrow = 174, RightArrow = 175, Enter = 176, Backspace = 177, MouseRight = 220, MouseDown = 221,
        W = 32, A = 34, S = 33, D = 35, Shift = 21, LeftCtrl = 210, MouseLeftClick = 24, MouseLeftClick2 = 106, C = 26, X = 73, Space = 22, ScrollUp = 15, ScrollDown = 14,
        ScrollUp2 = 17, ScrollDown2 = 16, Tab = 37, E = 38, R = 45, R2 = 140, R3 = 80, Q = 44, Q2 = 85, Q3 = 141, Tab = 37}

--#[Global Functions]#--
function CreateTable(data)
	return data
end

function Round(num, numDecimalPlaces)
    local mult = 10^(numDecimalPlaces or 0)
    return math.floor(num * mult + 0.5) / mult
end

function DegToRad(deg)
    return deg * math.pi / 180.0
end

function RotationToDirection(rotation)
    local rad1 = DegToRad(rotation.z)
    local rad2 = DegToRad(rotation.x)
    local num = math.abs(math.cos(rad2))

    local x = -(math.sin(rad1) * num)
    local y = math.cos(rad1) * num
    local z = math.sin(rad2)

    return x, y, z
end

function CastRay(startPos, endPos, flag, ignoreEnt)
    local raycast = StartShapeTestRay(startPos, endPos, flag, ignoreEnt, 7)
    local rayHandle, didHit, endCoords, surfaceCoords, entity = GetShapeTestResult(raycast) 

    return didHit, endCoords, surfaceCoords, entity
end

function IsNear(pos1, pos2, distMustBe)
    local diff = pos2 - pos1
	local dist = (diff.x * diff.x) + (diff.y * diff.y)

	return (dist < (distMustBe * distMustBe))
end

function GetDist(pos1, pos2)
    local diff = pos2 - pos1
    local dist = (diff.x * diff.x) + (diff.y * diff.y)
    
    return dist
end