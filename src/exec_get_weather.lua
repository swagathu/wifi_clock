local function decode_weather(status, body, headers)
    if ( status ~= 200 )
    then
        DISPLAY_DATA.got_weather = false
        return
    end
    local t = sjson.decode(body)
    WEATHER_DATA.day = t["current"]["is_day"]
    WEATHER_DATA.temperature = tostring(t["current"]["temp_c"])
    WEATHER_DATA.condition = t["current"]["condition"]["text"].." "
    WEATHER_DATA.location = t["location"]["name"]
    DISPLAY_DATA.got_weather = true
end

local function display_weather_internal()
    local key = "add your api key"
    if (WEATHER_DATA.cord_lat == "")
    then
        WEATHER_DATA.cord_lat = "10"
        WEATHER_DATA.cord_long = "10"
    end
    http.request("http://api.weatherapi.com/v1/current.json?key="..key.."&q="..WEATHER_DATA.cord_lat..","..WEATHER_DATA.cord_long.."&aqi=no", "GET", nil, nil, decode_weather)
end

display_weather_internal()

return
