-- connection flag
GLOBAL_CONNECTED = 0
-- wifi data
DECODED_DATA = nil
-- weather data 
WEATHER_DATA = {
    day = "",
    temperature = "",
    condition = "",
    location = "",
    cord_lat = "",
    cord_long = "",
}

DISPLAY_DATA = {
    prev_sec = 0,
    got_time = false,
    got_weather = false,
    count_sec = 0,
    cond_scroll = 0,
    loc_scroll = 0,
    row0_clean = true,
    row1_clean = true,
    
}

WIFI_DATA = {
    conn_list_len = 0,
}
-- add displaylib
displib = require("displib")
