local file_check = file.open("network_data.json", "r")
if not file_check then
    print("File does not exist. Creating with default values.")
    local def_ssid = "default"
    local def_pass = "default"
    -- Create a file with default values
    local default_data = {
        ["lastConnected"] = {
            ssid = def_ssid,
            password = def_pass
        },
        ["networks"] = {
            { ssid = def_ssid, password = def_pass },
            { ssid = "default", password = "default"},
            { ssid = "default", password = "default"}
            -- Add more default networks as needed
        }
    }

    -- Encode the default data table to JSON
    local default_json = sjson.encode(default_data)

    -- Create and write the default JSON data to the file
    local file = file.open("network_data.json", "w+")
    if file then
        file.write(default_json)
        file.close()
        print("Default file created.")
    else
        print("Error creating default file.")
    end

    -- Set DECODED_DATA to default_data for further processing
    DECODED_DATA = default_data
else
    -- Read data from the existing file
    file_check.close()
end
local file_exists = file.open("network_data.json", "r")
local json_data = file_exists.read()
file_exists.close()

DECODED_DATA = sjson.decode(json_data)

-- Decode JSON data to Lua table
local max_networks = 20
-- limit length of array.
WIFI_DATA.conn_list_len = 0
print("\nList of networks:")
for i, network in pairs(DECODED_DATA.networks) do
    print("Network " .. i .. ":")
    print("SSID: " .. network.ssid)
    print("Password: " .. network.password)
    WIFI_DATA.conn_list_len = WIFI_DATA.conn_list_len + 1
end

if WIFI_DATA.conn_list_len > max_networks then
    while WIFI_DATA.conn_list_len > max_networks do
        table.remove(DECODED_DATA.networks)
        WIFI_DATA.conn_list_len = WIFI_DATA.conn_list_len - 1
    end
    local updated_json = sjson.encode(DECODED_DATA)

    -- Save the updated JSON back to the file
    local file = file.open("network_data.json", "w+")
    if file then
        file.write(updated_json)
        file.close()
        print("File updated successfully.")
    else
        print("Error updating file.")
    end
end
-- Access and print the lastConnected details
print("Last connected:")
print("SSID: " .. DECODED_DATA.lastConnected.ssid)
print("Password: " .. DECODED_DATA.lastConnected.password)
print("no. of nets:" .. WIFI_DATA.conn_list_len .. "")
