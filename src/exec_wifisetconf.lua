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
