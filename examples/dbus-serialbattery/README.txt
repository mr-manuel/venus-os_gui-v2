1) Compile this plugin for gui-v2 using the gui-v2-plugin-compiler

# Either: run the following in a terminal which has sourced the Venus OS SDK environment:

cd examples/dbus-serialbattery/

. /opt/venus/current/environment-setup-cortexa8hf-neon-ve-linux-gnueabi

python3 ../../tools/gui-v2-plugin-compiler.py --filter-empty-sources \
    --name dbus-serialbattery \
    --min-required-version v1.2.18 \
    --devicelist 0xba77 PageBatteryDbusSerialbattery.qml 'dbus_serialbattery_general_title' \
    --devicelist 0xba77 PageBatteryDbusSerialbatteryCellVoltages.qml 'dbus_serialbattery_cell_voltages_title' \
    --devicelist 0xba77 PageBatteryDbusSerialbatterySettings.qml 'dbus_serialbattery_settings_title' \
    --devicelist 0xba77 PageBatteryDbusSerialbatteryTimeToSoc.qml 'dbus_serialbattery_time_to_soc_title'

Copy the json to

# Create setting on dbus
dbus -y com.victronenergy.settings /Settings AddSettings '%[{"path": "/Gui2/Plugins", "default": "[]"}]'

# Set to empty list/reset
dbus -y com.victronenergy.settings /Settings/Gui2/Plugins SetValue "[]"

# Set to dbus-serialbattery json
dbus -y com.victronenergy.settings /Settings/Gui2/Plugins SetValue "[$(cat /data/apps/enabled/dbus-serialbattery/gui-v2/dbus-serialbattery.json)]"

# Remove setting on dbus
dbus -y com.victronenergy.settings /Settings RemoveSettings '%["System/Gui2/Plugins"]'



# Alternatively: copy the contents of this directory to the device, ssh in, and compile it on device:

rsync -avc . root@gx.device.ip.address:/tmp/DeviceList/
ssh root@gx.device.ip.address
cd /tmp/DeviceList/
python3 /opt/victronenergy/gui-v2/gui-v2-plugin-compiler.py \
    --name dbus-serialbattery \
    --min-required-version v1.2.18 \
    --devicelist 0xba77 PageBatteryDbusSerialbattery.qml 'dbus_serialbattery_general_title' \
    --devicelist 0xba77 PageBatteryDbusSerialbatteryCellVoltages.qml 'dbus_serialbattery_cell_voltages_title' \
    --devicelist 0xba77 PageBatteryDbusSerialbatterySettings.qml 'dbus_serialbattery_settings_title' \
    --devicelist 0xba77 PageBatteryDbusSerialbatteryTimeToSoc.qml 'dbus_serialbattery_time_to_soc_title'

cp -f dbus-serialbattery.json /data/apps/enabled/dbus-serialbattery/gui-v2/

2) Copy the output file `DeviceListExample.json` to /data/apps/available/DeviceListExample/gui-v2/DeviceListExample.json on device
3) Symlink the `DeviceListExample` directory as follows: `ln -s /data/apps/available/DeviceListExample /data/apps/enabled/DeviceListExample` on device
4) Run gui-v2 in mock mode, e.g. `/opt/victronenergy/venus-gui-v2 --mock --no-mock-timers`
5) Navigate to Settings -> Integrations -> UI Plugins and confirm the DeviceListExample plugin exists
6) Navigate to Settings -> Device List -> Skylla-i 24/100 and find the plugin-provided entries there

Note that the custom entries provided by the DeviceListExample plugin will only be displayed in the Device List page for "Skylla-i 24/100" devices which have product id "0x106".
