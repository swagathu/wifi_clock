-- local displib = require("displib")
local timeoutTimer = tmr.create()
local TIMEOUT_DURATION = 15000         -- Adjust timeout duration as needed (in milliseconds)
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

-- get the config from flash
dofile("exec_wifigetconf.lua")

-- limit the time spend for connecting.
-- -- 2 minute timer. limit connection tries to stop after 2 minutes.
local connintr_timer = tmr.create()
connintr_timer:register(1000 * 60 * 3, tmr.ALARM_SINGLE, function ()
    show_conn_in_progress("conn timeout", 1)
    timeoutTimer:stop()
    GLOBAL_CONNECTED = -1
    dofile("exec_wifi_setup.lua")
end)
connintr_timer:start()

local num_of_conns = 1
local curSSID = ""
local curPWD = ""

local function onConnection()
    show_conn_in_progress("Connected", 1)
    timeoutTimer:stop()
end

local function onDisconnect()
    wifi.eventmon.unregister(wifi.eventmon.STA_DISCONNECTED)
    dofile("exec_wifi_setup.lua")
end

local function onIPGot()
    if wifi.sta.getip()
    then
        show_conn_in_progress("Got IP", 1)
        DECODED_DATA.lastConnected.ssid = curSSID
        DECODED_DATA.lastConnected.password = curPWD
        -- write to config.
        dofile("exec_wifisetconf.lua")
        show_conn_in_progress("start serv:", 0)
        show_conn_in_progress(wifi.sta.getip(), 1)
        dofile("serv.lua")
        GLOBAL_CONNECTED = 1
        wifi.sta.autoconnect(1)
        wifi.eventmon.register(wifi.eventmon.STA_DISCONNECTED, onDisconnect)
        -- get weather
        connintr_timer:stop()
        return
    end
end

local function onConnectionTimeout()
    if wifi.sta.getip()
    then
        return
    else
        show_conn_in_progress("conn timeout", 1)
        print("Failed to connect to network:", curSSID)
        show_conn_in_progress("Try diff net", 1)
    end
end

local station_cfg={}
-- function to set next network
local function try_conn()
    print(WIFI_DATA.conn_list_len)
    print(num_of_conns)
    if ((num_of_conns <= WIFI_DATA.conn_list_len))
    then
        if (GLOBAL_CONNECTED == -1 or GLOBAL_CONNECTED == 1)
        then
            return
        end
        print(sjson.encode(DECODED_DATA))
        print("value", num_of_conns)
        curSSID = DECODED_DATA.networks[num_of_conns].ssid
        curPWD = DECODED_DATA.networks[num_of_conns].password
        station_cfg.ssid = curSSID
        station_cfg.pwd = curPWD
        station_cfg.save = false
        print("Try "..curSSID.."")
        show_conn_in_progress("Try "..curSSID.."",1)
        wifi.sta.config(station_cfg)
        wifi.sta.connect()

        timeoutTimer:alarm(TIMEOUT_DURATION, tmr.ALARM_SINGLE, function()
            onConnectionTimeout()
            try_conn()
        end)
        timeoutTimer:start()
        num_of_conns = num_of_conns + 1
    else
        GLOBAL_CONNECTED = -1
    end
end

-- set wifi callbacks
wifi.eventmon.register(wifi.eventmon.STA_CONNECTED, onConnection)
wifi.eventmon.register(wifi.eventmon.STA_GOT_IP, onIPGot)


station_cfg.ssid = DECODED_DATA.lastConnected.ssid
station_cfg.pwd = DECODED_DATA.lastConnected.password
station_cfg.save = false

ap_cfg = {}
ap_cfg.ssid = "wificlock"
ap_cfg.auth = wifi.OPEN

curSSID = DECODED_DATA.lastConnected.ssid
curPWD = DECODED_DATA.lastConnected.password

-- Connect to the last connected network
wifi.setmode(wifi.STATION)
wifi.sta.config(station_cfg)
wifi.ap.config(ap_cfg)
-- enable auto connect once a connection is done.
wifi.sta.autoconnect(0)
wifi.sta.connect()

timeoutTimer:stop()

timeoutTimer:alarm(TIMEOUT_DURATION, tmr.ALARM_SINGLE, function()
    onConnectionTimeout()
    try_conn()
end)

timeoutTimer:start()
