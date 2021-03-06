--[[
config_weapons.lua

Configuration of weapons that the player can spawn.
]]

--#[Weapons]#--
--About: Table stores weapons that the players can spawn, as well as their statistics.
weapons = 
{
    ["prop_minigun_01"] = 
    {
        name = "Turret",
        weapon = "VEHICLE_WEAPON_TURRET_TECHNICAL",
        weaponHash = 2144528907,
        hash = "prop_minigun_01",
        image = "none",
        type = "bullet",
        price = 60,
        range = 25,
        bulletDrop = 0.5,
        weaponDamage = 10,
        dmgMultiplier = 5,
        cooldownTime = 0.2,
        weight = 100
    },
    ["w_ar_railgun"] = 
    {
        name = "Rail Gun",
        weapon = "WEAPON_RAILGUN",
        weaponHash = 1834241177,
        hash = "w_ar_railgun",
        image = "none",
        type = "explosive",
        price = 300,
        range = 25,
        bulletDrop = 2.0,
        weaponDamage = 50,
        dmgMultiplier = 5,
        cooldownTime = 3,
        weight = 150
    },
    ["w_lr_rpg"] = 
    {
        name = "Rocket Launcher",
        weapon = "WEAPON_RPG",
        weaponHash = -1312131151,
        hash = "w_lr_rpg",
        image = "none",
        type = "explosive",
        price = 200,
        range = 25,
        bulletDrop = 0.8,
        weaponDamage = 25,
        dmgMultiplier = 5,
        cooldownTime = 3,
        weight = 120
    },
    ["w_mg_combatmg"] = 
    {
        name = "Combat Machine Gun",
        weapon = "WEAPON_MICROSMG",
        weaponHash = 324215364,
        hash = "w_mg_combatmg",
        image = "none",
        type = "bullet",
        price = 150,
        range = 25,
        bulletDrop = 1.0,
        weaponDamage = 12,
        dmgMultiplier = 5,
        cooldownTime = 0.5,
        weight = 50
    },
    ["w_lr_homing"] = 
    {
        name = "Cannon",
        weapon = "VEHICLE_WEAPON_TANK",
        weaponHash = 1945616459,
        hash = "w_lr_homing",
        image = "none",
        type = "explosive",
        price = 450,
        range = 25,
        bulletDrop = 1.0,
        weaponDamage = 70,
        dmgMultiplier = 5,
        cooldownTime = 5,
        weight = 180
    }
}