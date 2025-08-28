1) Run the following in a terminal which has sourced the Venus OS SDK environment:

python3 ../../tools/customisationcompiler.py \
    --name DeviceListExample \
    --minrequiredversion v1.2.7 \
    --devicelist 0x106 DeviceListExample_CellVoltages.qml devicelistexample_cellvoltages_title_cell_voltages \
    --devicelist 0x106 DeviceListExample_CellTemperatures.qml 'Cell Temperatures' \
    --devicelist 0x106 DeviceListExample_ComponentError.qml 'Invalid Customisation'

python3 ../../tools/customisationcompiler.py \
    --name dbus-serialbattery \
    --minrequiredversion v1.2.7 \
    --devicelist 0xBA77 PageBatteryDbusSerialbattery.qml dbus-serialbattery_general_title \
    --devicelist 0XBA77 PageBatteryDbusSerialbatteryCellVoltages.qml dbus-serialbattery_cell_voltages_title \
    --devicelist 0xba77 PageBatteryDbusSerialbatterySettings.qml dbus-serialbattery_settings_title \
    --devicelist 0xba77 PageBatteryDbusSerialbatteryTimeToSoc.qml dbus-serialbattery_time_to_soc_title

2) Copy the output file `DeviceListExample.json` to /tmp/venus-gui-v2/customisations/ on device
3) Run gui-v2 in mock mode, e.g. `/opt/victronenergy/venus-gui-v2 --mock --no-mock-timers`
4) Navigate to Settings -> Integrations -> UI Customisations and enable the DeviceListExample customisation
5) Navigate to Settings -> Device List -> Skylla-i 24/100 and find the customisation entries there
