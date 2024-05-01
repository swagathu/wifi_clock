ESPTOOL="./nodemcu-firmware/tools/toolchains/esptool.py"
BAUDRATE=115200
ESPPORT="/dev/ttyUSB0"
FLASHOPTIONS="-fm dio -fs 4MB -ff 40m"
FIRMWAREDIR="./nodemcu-firmware/bin"
python3 $(ESPTOOL) --port $(ESPPORT) --baud $(BAUDRATE) write_flash $(FLASHOPTIONS) 0x00000 $(FIRMWAREDIR)0x00000.bin 0x10000 $(FIRMWAREDIR)0x10000.bin
