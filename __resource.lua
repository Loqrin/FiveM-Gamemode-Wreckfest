resource_manifest_version "44febabe-d386-4d18-afbe-5e627f4af937"

ui_page "core/client/ui/html/ui.html"

files
{
    "core/client/ui/html/ui.html",
    "core/client/ui/html/fonts/ChaletLondonNineteenSixty.ttf",
    "core/client/ui/html/css/welcome_menu_css.css",
    "core/client/ui/html/css/user_terminal_css.css",
    "core/client/ui/html/css/user_menu_css.css",
    "core/client/ui/html/css/scoreboard_css.css",
    "core/client/ui/html/js/ui_js.js",
    --Add Vehicle Images Below Here--
    "core/client/ui/html/imgs/blazerVehicle.png"
}

client_scripts
{
    "_configs/config_modules.lua",
    "_configs/config_client_player.lua",
    "_configs/config_vehicles.lua",
    "_configs/config_props.lua",
    "_configs/config_weapons.lua",
    "modules/no_ai.lua",
    "modules/never_wanted.lua",
    "modules/weather_and_time.lua",
    "core/client/client_general_functions.lua",
    "core/client/client_map_loader.lua",
    "core/client/client_sync_platforms.lua",
    "core/client/client_sync_props.lua",
    "core/client/client_sync_attachments.lua",
    "core/client/client_sync_vehicles.lua",
    "core/client/client_sync_weapons.lua",
    "core/client/player/client_player.lua",
    "core/client/player/client_spawn.lua",
    "core/client/player/client_build_vehicle.lua",
    "core/client/player/client_arena.lua",
    "core/client/ui/client_ui.lua",
    "core/client/terminal/client_terminal_manager.lua",
    "core/client/terminal/client_terminal_buyvehicles.lua",
    "core/client/terminal/client_terminal_garage.lua",
    "core/client/terminal/client_terminal_buyprops.lua",
    "core/client/terminal/client_terminal_buyweapons.lua"
}

server_scripts
{
    "server_initialization.lua",
    "_configs/config_map.lua",
    "_configs/config_server_player.lua",
    "_configs/config_vehicles.lua",
    "_configs/config_props.lua",
    "_configs/config_weapons.lua",
    "core/libs/xml_parser.lua",
    "core/libs/xml_serializer.lua",
    "core/server/server_map_loader.lua",
    "core/server/server_sync_platforms.lua",
    "core/server/server_sync_player.lua",
    "core/server/server_sync_props.lua",
    "core/server/server_sync_attachments.lua",
    "core/server/server_sync_vehicles.lua"
}