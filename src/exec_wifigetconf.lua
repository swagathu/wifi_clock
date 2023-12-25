local decoded_data = nil
local file_exists = file.open("network_data.json", "r")
if not file_exists then
    print("File does not exist. Creating with default values.")
    local def_ssid = "default"
    local def_pass = "default"
    -- Create a file with default values
    local default_data = {
        lastConnected = {
            ssid = def_ssid,
            password = def_pass
        },
        networks = {
            { ssid = def_ssid, password = def_pass }
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

    -- Set decoded_data to default_data for further processing
    decoded_data = default_data
else
    -- Read data from the existing file
    local json_data = file.read()
    file.close()

    -- Decode JSON data to Lua table
    decoded_data = sjson.decode(json_data)
    local max_networks = 20
    -- limit length of array.
    if #decoded_data.networks > max_networks then
        while #decoded_data.networks > max_networks do
            table.remove(decoded_data.networks)
        end
        local updated_json = sjson.encode(decoded_data)

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
    print("SSID:", decoded_data.lastConnected.ssid)
    print("Password:", decoded_data.lastConnected.password)

    -- Access and print the list of networks and passwords
    print("\nList of networks:")
    for i, network in ipairs(decoded_data.networks) do
        print("Network " .. i .. ":")
        print("SSID:", network.ssid)
        print("Password:", network.password)
    end
end

return decoded_data
