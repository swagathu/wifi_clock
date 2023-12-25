local displib = require("displib")
dofile("setup_global_vars.lua")


HEAD_SCROLL_1=0

function show_data()
    local text = "Hello World"
    if (GLOBAL_CONNECTED  ~= 0)
    then
        displib.clrscr()
        HEAD_SCROLL_1 = displib.display_scrolling(0, 3, text, 11, HEAD_SCROLL_1);
    end
end

--using i2c 0 as lcd connection.
displib.lcd_init()

dofile("exec_wifi_setup.lua")

tim_main = tmr.create()
tim_main:register(1000, tmr.ALARM_AUTO, show_data)
tim_main:start()
