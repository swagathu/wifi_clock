local displib = require("displib")

-- assume lcd inited in main lua

-- display a connecting print
local function show_conn_in_progress(text, type)
    if (type == 0)
    then
        displib.clrrow(0)
        displib.display_scrolling(0,0,text, 16, 0)
    else
        displib.clrrow(1)
        displib.display_scrolling(1,0,text, 16, 0)
    end
    tmr.delay(1000000)
end

show_conn_in_progress("Connecting...", 0)

-- limit the time spend for connecting.
local conn_fail = 0
-- -- 2 minute timer. limit connection tris to stop after 2 minutes.
local connintr_timer = tmr.create()
connintr_timer:register(1000 * 60 * 2, tmr.ALARM_SINGLE, function ()
    conn_fail = 1
end)
connintr_timer:start()

-- get the config from flash
local decoded_data = dofile("exec_wifigetconf.lua")

local station_cfg={}
station_cfg.ssid = decoded_data.lastConnected.ssid
station_cfg.pwd = decoded_data.lastConnected.password
station_cfg.save = false

-- Connect to the last connected network
wifi.setmode(wifi.STATION)
wifi.sta.config(station_cfg)
wifi.sta.autoconnect(1)

-- Check if already connected
if wifi.sta.getip() then
    print("Connected to last connected network:", decoded_data.lastConnected.ssid)
    show_conn_in_progress("prev conn ok", 1)
    GLOBAL_CONNECTED = 1
else
    print("Failed to connect to last connected network. Trying other networks...")
    show_conn_in_progress("prev net fail", 1)
    -- Try connecting to other networks from the list
    for _, network in ipairs(decoded_data.networks) do
        station_cfg.ssid = network.ssid
        station_cfg.pwd = network.password
        station_cfg.save = false
        wifi.sta.config(station_cfg)
        wifi.sta.connect()

        -- Wait for connection
        tmr.create():alarm(10000, tmr.ALARM_SINGLE, function()
            if wifi.sta.getip() then
                print("Connected to network:", network.ssid)
                show_conn_in_progress("Connected", 1)
                GLOBAL_CONNECTED = 1
            else
                print("Failed to connect to network:", network.ssid)
                show_conn_in_progress("Try diff net", 1)
            end
        end)
        if (conn_fail == 1)
        then
            GLOBAL_CONNECTED =-1
            break
        end
    end
end

connintr_timer:stop()
