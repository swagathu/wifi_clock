local station_cfg = {}
station_cfg.ssid = "default"
station_cfg.pwd = "default"
station_cfg.save = false

-- Set Wi-Fi mode and configure it
wifi.setmode(wifi.STATION)
wifi.sta.config(station_cfg)

-- Register an event when the device gets an IP address
wifi.eventmon.register(wifi.eventmon.STA_GOT_IP, function()
    print("WiFi connected")
    print("IP address:", wifi.sta.getip())

    -- Start the HTTP server
    srv = net.createServer(net.TCP)
    srv:listen(80, function(conn)
        conn:on("receive", function(sck, payload)
            print("Payload received:", payload)

            -- Attempt to decode the JSON payload
            local success, request = pcall(sjson.decode, payload)

            -- Check if JSON decoding was successful
            if success and request.query and request.payload then
                -- Handle different queries
                if request.query == "get_config" then
                    -- Open the file
                    if file.open("network_data.json", "r") then
                        local json_data = file.read()
                        file.close()

                        -- Check if data is available and send it
                        if json_data then
                            print(json_data)
                            sck:send(json_data)
                        else
                            sck:send("Error: No data in file")
                        end
                    else
                        sck:send("Error: File not found")
                    end

                elseif request.query == "set_config" then
                    -- Decode the outer JSON payload
                    local success, outerPayload = pcall(sjson.decode, request.payload)
                
                    -- Check if the outer JSON was decoded successfully
                    if success and outerPayload then
                        -- Open the file to save the JSON payload
                        local file = file.open("network_data.json", "w+")
                        if file then
                            -- Write the decoded outer payload as a JSON string to the file
                            file.write(sjson.encode(outerPayload))
                            file.close()
                            sck:send("Success: Configuration updated")
                        else
                            sck:send("Error: Could not open file for writing")
                        end
                    else
                        sck:send("Error: Invalid payload JSON")
                    end
                else
                    sck:send("Error: Unknown query")
                end
            else
                -- Respond with an error if JSON format is incorrect or missing keys
                sck:send("Error: Invalid JSON format or missing keys")
            end
        end)
        
        conn:on("sent", function(sck) sck:close() end)
    end)
end)

-- Enable auto-connect to Wi-Fi
wifi.sta.autoconnect(1)
wifi.sta.connect()
