local displib = require("displib")
dofile("exec_setup_global_vars.lua")

local function time_recv_callback(s, ms, serv, info)
    print("Got time\n")
    DISPLAY_DATA.got_time = true
end

local function get_meridien_time(hour)
    local meridien = ""
    if (hour > 0)
    then
        meridien = "am"
    end
    if (hour > 12)
    then
        hour = hour - 12
        meridien = "pm"
    end
    if (hour == 12)
    then
        meridien = "pm"
    end
    if (hour == 0)
    then
        hour = 12
        meridien = "am"
    end
    return hour, meridien
end

-- main function for displaying data, we want this to run every 500ms.
local function display_weather()
    if (GLOBAL_CONNECTED  <= 0)
    then
        return
    end
    -- initialize flags etc..
    local one_sec = 0
    local sec,x,y = rtctime.get()
    if (DISPLAY_DATA.prev_sec ~= sec)
    then
        one_sec = 1
        DISPLAY_DATA.prev_sec = sec
    end
    -- check if we have new date
    if(sec == 0)
    then
        displib.clrrow(0)
        displib.lcddisp("WaitForTime...", 1, 0)
        DISPLAY_DATA.row0_clean = true
        DISPLAY_DATA.row1_clean = false
        return
    end
    if (DISPLAY_DATA.row0_clean == false or DISPLAY_DATA.row1_clean == false)
    then
        displib.clrscr()
        DISPLAY_DATA.row0_clean = true
        DISPLAY_DATA.row1_clean = true
        dofile("exec_get_weather.lua")
    end
    sec = sec + 19800 --IST correction
    local time = rtctime.epoch2cal(sec)
    if (one_sec == 1)
    then
        local hour = time["hour"]
        local meridien = ""
        hour, meridien = get_meridien_time(hour)
        -- displib.clrrow(0)
        if (DISPLAY_DATA.count_sec == 0)
        then
            displib.lcddisp(""..string.format("%02d",hour)..":"..string.format("%02d",time["min"])..":"..string.format("%02d",time["sec"])..meridien.." "..displib.monthlist(time["mon"])..string.format("%02d",time["day"]).." ", 0, 0)
            DISPLAY_DATA.count_sec = DISPLAY_DATA.count_sec + 1
        else
            displib.lcddisp(""..string.format("%02d",hour).." "..string.format("%02d",time["min"]).." "..string.format("%02d",time["sec"])..meridien.." "..displib.monthlist(time["mon"])..string.format("%02d",time["day"]).." ", 0, 0)
            DISPLAY_DATA.count_sec = 0
        end
        one_sec = 0
    end

    -- displib.clrrow(1)
    if (DISPLAY_DATA.got_weather)
    then
        displib.lcd_loc( 1, 0)
        if (WEATHER_DATA.day == 1)
        then
            -- sun
            displib.lcd_byte(0x00)
        else
            -- moon
            displib.lcd_byte(0x01)
        end
            displib.lcddisp(""..WEATHER_DATA.temperature.."", 1, 1)
            displib.lcd_loc(1, 3)
            displib.lcd_byte(0x02)
            displib.lcddisp(" ", 1, 4)
            DISPLAY_DATA.cond_scroll = displib.display_scrolling(1, 5, WEATHER_DATA.condition, 5, DISPLAY_DATA.cond_scroll)
            displib.lcddisp(" ", 1, 11)
            DISPLAY_DATA.loc_scroll = displib.display_scrolling(1, 12   , WEATHER_DATA.location, 4, DISPLAY_DATA.loc_scroll)
    end

end

--using i2c 0 as lcd connection.
displib.lcd_init()

dofile("exec_wifi_setup.lua")

sntp.sync(nil, time_recv_callback, nil, 1)

local tim_main = tmr.create()
tim_main:register(500, tmr.ALARM_AUTO, display_weather)
tim_main:start()

-- each 10 min data refreshed.
local tim_sec = tmr.create()
tim_sec:register((10 * 60 *1000), tmr.ALARM_AUTO, 
function()
    dofile("exec_get_weather.lua")
end
)
tim_sec:start()

