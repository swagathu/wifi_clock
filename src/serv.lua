-- Start the HTTP server
srv = net.createServer(net.TTCP)
srv:listen(80, function(conn)
    conn:on("receive", function(sck, payload)
        print("Payload received:", payload)

        -- Attempt to decode the JSON payload
        local success, request = pcall(sjson.decode, payload)

        -- Check if JSON decoding was successful
        if success and request.query and request.payload then
            -- Handle different queries
            if request.query == "get_config" then
                -- Try opening the file
                if file.open("network_data.json", "r") then
                    local json_data = file.read()
                    file.close()

                    -- Check if data was successfully read
                    if json_data then
                        print("Sending JSON data:", json_data)
                        sck:send(json_data)
                    else
                        print("Error: No data in file")
                        sck:send("Error: No data in file")
                    end
                else
                    print("Error: File not found")
                    sck:send("Error: File not found")
                end

            elseif request.query == "set_config" then
                -- Try decoding the outer payload JSON
                local success, outerPayload = pcall(sjson.decode, request.payload)

                if success and outerPayload then
                    -- Try opening the file to write
                    local file_success = file.open("network_data.json", "w+")
                    if file_success then
                        -- Write the JSON data to the file
                        file.write(sjson.encode(outerPayload))
                        file.close()
                        print("Success: Configuration updated")
                        sck:send("Success: Configuration updated")
                        node.restart()
                    else
                        print("Error: Could not open file for writing")
                        sck:send("Error: Could not open file for writing")
                    end
                else
                    print("Error: Invalid outer payload JSON")
                    sck:send("Error: Invalid payload JSON")
                end

            else
                print("Error: Unknown query", request.query)
                sck:send("Error: Unknown query")
            end
        else
            -- Handle JSON decoding errors or missing keys
            print("Error: Invalid JSON format or missing 'query'/'payload'")
            sck:send("Error: Invalid JSON format or missing keys")
        end
    end)

    conn:on("sent", function(sck) sck:close() end)
end)
