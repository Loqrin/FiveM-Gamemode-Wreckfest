--[[
config_vehicles.lua

Configuration file that sets what vehicles the player can purchase and use.
]]

--#[Vehicles]#--
--About: Table stores information regarding what vehicles player's can buy via the terminal.
--Each vehicle has its own table, and is named by its hash (note, not its name).
--In the table of the vehicle, is the name and image which is used in the terminal.
--If there is no image for the vehicle, simply set the image field to none.
--Store images in core/client/ui/html/imgs
--Remember to include the image in __resource.lua in order for it to load.
vehicles = 
{
    ["BLAZER"] = 
    {
        name = "Nagasaki Blazer",
        price = 10,
        image = "blazerVehicle.png"
    },
    ["REBEL"] = 
    {
        name = "Karin Rebel",
        price = 250,
        image = "none"
    },
    ["INSURGENT2"] = 
    {
        name = "Insurgent",
        price = 960,
        image = "none"
    },
    ["MESA3"] = 
    {
        name = "Canis Mesa",
        price = 380,
        image = "none"
    },
    ["RAPTOR"] = 
    {
        name = "BF Raptor",
        price = 300,
        image = "none"
    },
    ["OMNIS"] = 
    {
        name = "Obey Omnis",
        price = 440,
        image = "none"
    },
    ["SHEAVA"] = 
    {
        name = "Emperor ETR1",
        price = 800,
        image = "none"
    }
}