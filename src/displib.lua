local displib = {}
SCREEN_WIDTH = 16
SCREEN_ROWS = 2

function displib.lookup_char(actual)
    if ((actual >= 0x30) and (actual <= 0x3F))
    then
        return bit.bor((actual - 0x30), 0x30) 
    end
    if ((actual >= 0x40) and (actual <= 0x4F))
    then
        return bit.bor((actual - 0x40), 0x40)
    end
    if ((actual >= 0x50) and (actual <= 0x5A))
    then
        return bit.bor((actual - 0x50), 0x50)
    end
    if ((actual >= 0x70) and (actual <= 0x7D))
    then
        return bit.bor((actual - 0x70), 0x70)
    end
    if ((actual >= 0x60) and (actual <= 0x6F))
    then
        return bit.bor((actual - 0x60), 0x60)
    end
    if ((actual == 0x20))
    then
        return bit.bor((actual - 0x20), 0xA0)
    end
    if ((actual >= 0x21) and (actual <= 0x2F))
    then
        return bit.bor((actual - 0x20), 0x20)
    end
end

function displib.lcd_cmd(cmd)
    local data = cmd
    local data_u = bit.band(data,0xF0)
    local data_l = bit.band(data,0x0F)
    local data_t_0 = bit.bor(data_u,0x0C)  --en=1, rs=1
    local data_t_1 = bit.bor(data_u,0x08)
    local data_t_2 = bit.bor(bit.lshift(data_l,4),0x0C)  --en=1, rs=1
    local data_t_3 = bit.bor(bit.lshift(data_l,4),0x08)
    i2c.write(0, data_t_0)
    i2c.write(0, data_t_1)
    i2c.write(0, data_t_2)
    i2c.write(0, data_t_3)
end

function displib.lcd_byte(cmd1)
    local data = cmd1
    local data_u = bit.band(data,0xF0)
    local data_l = bit.band(data,0x0F)
    local data_t_0 = bit.bor(data_u,0x0D)  --en=1, rs=1
    local data_t_1 = bit.bor(data_u,0x09)
    local data_t_2 = bit.bor(bit.lshift(data_l,4),0x0D)  --en=1, rs=1
    local data_t_3 = bit.bor(bit.lshift(data_l,4),0x09)
    i2c.write(0, data_t_0)
    i2c.write(0, data_t_1)
    i2c.write(0, data_t_2)
    i2c.write(0, data_t_3)
end

function displib.lcd_data(cmd1)
    for i = 1, #cmd1 do
        local cmd = string.byte(cmd1, i)
        local data = displib.lookup_char(cmd)
        local data_u = bit.band(data,0xF0)
        local data_l = bit.band(data,0x0F)
        local data_t_0 = bit.bor(data_u,0x0D)  --en=1, rs=1
        local data_t_1 = bit.bor(data_u,0x09)
        local data_t_2 = bit.bor(bit.lshift(data_l,4),0x0D)  --en=1, rs=1
        local data_t_3 = bit.bor(bit.lshift(data_l,4),0x09)
        i2c.write(0, data_t_0)
        i2c.write(0, data_t_1)
        i2c.write(0, data_t_2)
        i2c.write(0, data_t_3)
    end
end

function displib.cgram_init()
--sun
    displib.lcd_cmd(0x40)
    displib.lcd_byte(0x01)
    displib.lcd_byte(0x12)
    displib.lcd_byte(0x18)
    displib.lcd_byte(0x18)
    displib.lcd_byte(0x1B)
    displib.lcd_byte(0x18)
    displib.lcd_byte(0x12)
    displib.lcd_byte(0x01)
--moon
    displib.lcd_cmd(0x48)  
    displib.lcd_byte(0x00)
    displib.lcd_byte(0x00)
    displib.lcd_byte(0x10)
    displib.lcd_byte(0x19)
    displib.lcd_byte(0x1F)
    displib.lcd_byte(0x0E)
    displib.lcd_byte(0x00)
    displib.lcd_byte(0x00)
--deg cel
    displib.lcd_cmd(0x50)
    displib.lcd_byte(0x08)
    displib.lcd_byte(0x14)
    displib.lcd_byte(0x08)
    displib.lcd_byte(0x02)
    displib.lcd_byte(0x05)
    displib.lcd_byte(0x04)
    displib.lcd_byte(0x05)
    displib.lcd_byte(0x02)
end

function displib.lcd_init(void)
    i2c.setup(0,1,2, i2c.SLOW)
    i2c.start(0)
    i2c.address(0, 0x27, i2c.TRANSMITTER)
    
    -- 4 bit initialisation
    tmr.delay(50 *1000)  -- wait for >40ms
    displib.lcd_cmd (0x30)
    tmr.delay(5 * 1000)  -- wait for >4.1ms
    displib.lcd_cmd (0x30)
    tmr.delay(5 * 1000)  -- wait for >100us
    displib.lcd_cmd (0x30)
    tmr.delay(1000)
    displib.lcd_cmd (0x20)  -- 4bit mode
    displib.lcd_cmd(0x01)
    tmr.delay(5*1000)
    displib.lcd_cmd(0x28)
    displib.lcd_cmd(0x0C)
    displib.lcd_cmd(0x06)
    displib.lcd_cmd(0x80)
    displib.cgram_init()
end

function displib.lcd_loc( row, pos)
    if (row == 0)
    then
        row = 0
    else
        row = 0x40
    end
    row = bit.bor(row, pos)
    row = bit.bor(0x80, row)
    displib.lcd_cmd(row)
    displib.lcd_cmd(row)
end

function displib.monthlist(cmd)
    local mlist = {"Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"}
    return mlist[cmd]
end

-----------------------------------
CONDITION_SCROLL = 0
LOC_SCROLL = 0
PREV_COND  = ""
PREV_LOC   = ""
-----------------------------------
function displib.shift_n_times(cmd,n)
    if (n == 0)
    then
        return cmd
    end
    local len = string.len(cmd)
    for i =1, n, 1
    do
        local x = cmd
        local y = cmd
        cmd = string.sub(x, 2, len)..string.sub(y, 1, 1)
    end
    return cmd
end

function displib.cutstrndisp(str_in, req_len)
    return string.sub(str_in,1,req_len)
end

-- this function increments and return head value if disp_len < text len
-- head need to be kept track of in function calling side.
function displib.display_scrolling(row, col, text, disp_len, head)
    displib.lcd_loc(row, col)
    local ret = ""
    text = text.." "
    local text_len = string.len(text)
    -- print(row, col, text, disp_len, head)
    if (string.len(text) > (disp_len + 1))
    then
        local shift_text = displib.shift_n_times(text, head);
        ret = string.sub(shift_text, 0, disp_len)
        head = head + 1
        if (head > (text_len -1))
        then
            head = 0
        end
    else
        ret = text
    end
    -- print(ret)
    displib.lcd_data(ret)
    return head
end

function displib.clrrow(row)
    displib.lcd_loc(row, 0)
    displib.lcd_data("                ")
end

function displib.clrscr()
    displib.clrrow(0)
    displib.clrrow(1)
end

function displib.lcddisp(text, row, col)
    local head_tmp = 0
    head_tmp = displib.display_scrolling(row, col, text, SCREEN_WIDTH - col, head_tmp)
end

return displib
