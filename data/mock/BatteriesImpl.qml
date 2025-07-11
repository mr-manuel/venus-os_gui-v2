/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

QtObject {
	id: root

	function initLynxBattery(battery) {
		const props = {
			"/Alarms/LowCellVoltage": 0,
			"/Balancing": 0,
			"/Balancer/Status": VenusOS.Battery_Balancer_Balancing,
			"/Capacity": 200,
			"/InstalledCapacity": 250,
			"/ConnectionInformation": "Generic connection info",
			"/NumberOfBmses": 1,
			"/Connected": 1,
			"/Errors/SmartLithium/Communication": 0,
			"/ConsumedAmphours": 10,
			"/CustomName": "Lynx Smart BMS HQ21302VUDQ",
			"/Dc/0/Voltage": 26.4,
			"/Dc/0/Temperature": 23.3,
			"/Dc/0/Power": 750,
			"/DeviceInstance": 1,
			"/Diagnostics/LastErrors/1/Error": 32,
			"/Diagnostics/LastErrors/1/Time": 1710467492,
			"/Diagnostics/LastErrors/2/Error": 32,
			"/Diagnostics/LastErrors/2/Time": 1710467412,
			"/Diagnostics/LastErrors/3/Error": 0,
			"/Diagnostics/LastErrors/4/Error": 0,
			"/ErrorCode": 0,
			"/Mgmt/Connection": "VE.Bus",
			"/FirmwareVersion": 66303,
			"/History/AutomaticSyncs": 10,
			"/History/CanBeCleared": 1,
			"/History/ChargeCycles": 2,
			"/History/ChargedEnergy": 11.44,
			"/History/DeepestDischarge": -25,
			"/History/DischargedEnergy": 8.5,
			"/History/FullDischarges": 0,
			"/History/MaximumVoltage": 57.16,
			"/History/MinimumVoltage": 26.07,
			"/History/TotalAhDrawn": 160.8,
			"/Info/BatteryLowVoltage": 41.6,
			"/Info/MaxChargeCurrent": 50,
			"/Info/MaxChargeVoltage": 54,
			"/Info/MaxDischargeCurrent": 600,
			"/Io/AllowToCharge": 1,
			"/Io/AllowToDischarge": 1,
			"/Mgmt/Connection": "VE.Can",
			"/Mgmt/ProcessName": "vecan-dbus",
			"/Mgmt/ProcessVersion": "2.69",
			"/Mode": 3,
			"/N2kDeviceInstance": 0,
			"/ProductId": 41957,
			"/ProductName": "Lynx Smart BMS 500",
			"/Settings/Alarm/LowSoc": 10,
			"/Settings/Alarm/LowSocClear": 20,
			"/Settings/Battery/Capacity": 50,
			"/Settings/Battery/NominalVoltage": 48,
			"/Settings/BluetoothMode": 1,
			"/Settings/DischargeFloorLinkedToRelay": 1,
			"/Settings/HasSettings": 1,
			"/Settings/HasTemperature": 1,
			"/Settings/Alarm/HighBatteryTemperatureClear": 363,
			"/Settings/Alarm/HighBatteryTemperature": 373,
			"/Settings/Alarm/HighVoltageClear": 90,
			"/Settings/Alarm/HighVoltage": 100,
			"/Settings/Alarm/HighStarterVoltageClear": 50,
			"/Settings/Alarm/HighStarterVoltage": 90,
			"/Settings/Alarm/LowBatteryTemperature": 283,
			"/Settings/Alarm/LowBatteryTemperatureClear": 293,
			"/Settings/Alarm/LowSoc": 10,
			"/Settings/Alarm/LowSocClear": 15,
			"/Settings/Alarm/LowStarterVoltage": 0,
			"/Settings/Alarm/LowStarterVoltageClear": 10,
			"/Settings/Alarm/LowVoltage": 0,
			"/Settings/Alarm/LowVoltageClear": 10,
			"/Settings/Relay/Mode": 0,
			"/Settings/Relay/FuseBlown": 1,
			"/Settings/Relay/HighBatteryTemperatureClear": 363,
			"/Settings/Relay/HighBatteryTemperature": 373,
			"/Settings/Relay/HighVoltageClear": 200,
			"/Settings/Relay/HighVoltage": 250,
			"/Settings/Relay/HighStarterVoltageClear": 200,
			"/Settings/Relay/HighStarterVoltage": 250,
			"/Settings/Relay/LowBatteryTemperature": 283,
			"/Settings/Relay/LowBatteryTemperatureClear": 293,
			"/Settings/Relay/LowSoc": 10,
			"/Settings/Relay/LowSocClear": 15,
			"/Settings/Relay/LowStarterVoltage": 0,
			"/Settings/Relay/LowStarterVoltageClear": 10,
			"/Settings/Relay/LowVoltage": 0,
			"/Settings/Relay/LowVoltageClear": 10,
			"/Settings/RestoreDefaults": 0,
			"/Soc": 95.234,
			"/SystemSwitch": 1,
			"/TimeToGo": (24 * 60 * 60) + 190 * 60, // 1d 3h 10m
			"/Settings/HasSettings": 1,
			"/Settings/Battery/PeukertExponent": 1.03999999,
			"/System/MinTemperatureCellId": 201,
			"/System/MinCellTemperature": 14.5,
			"/System/NrOfModulesBlockingCharge": 20,
			"/System/NrOfModulesBlockingDischarge": 21,
		}
		for (var propName in props) {
			Global.mockDataSimulator.setMockValue(battery.serviceUid + propName, props[propName])
		}
	}

	function updateBatteriesList() {
		const dummyBatteryServiceName = "com.victronenergy.battery/1"
		const batteryList = [
			{
				// System battery
				active_battery_service: true,
				current: dummyBattery.current,
				id: dummyBatteryServiceName,
				instance: dummyBattery.deviceInstance,
				name: dummyBattery.name,
				power: dummyBattery._power.value,
				soc: dummyBattery._stateOfCharge.value,
				temperature: dummyBattery._temperature.value,
				timetogo: dummyBattery._timeToGo.value,
				voltage: dummyBattery._voltage.value,
			},
			{
				// Starter battery, which does not have an instance number
				active_battery_service: false,
				id: dummyBatteryServiceName + ":1",
				name: "My starter battery",
				voltage: 0.029999999329447746,
				soc: 12.34,
			}
		]
		Global.mockDataSimulator.setMockValue(Global.system.serviceUid + "/Batteries", batteryList)
	}

	function updateSystemBattery(path, value) {
		Global.mockDataSimulator.setMockValue(Global.system.serviceUid + path, value)
		root.updateBatteriesList()
	}

	readonly property Device dummyBattery: Device {
		serviceUid: "mock/com.victronenergy.battery.ttyUSB1"

		// This is used as the system battery, so copy the values over when they change.
		readonly property VeQuickItem _stateOfCharge: VeQuickItem {
			uid: dummyBattery.serviceUid + "/Soc"
			onValueChanged: root.updateSystemBattery("/Dc/Battery/Soc", value)
		}
		readonly property VeQuickItem _voltage: VeQuickItem {
			uid: dummyBattery.serviceUid + "/Dc/0/Voltage"
			onValueChanged: root.updateSystemBattery("/Dc/Battery/Voltage", value)
		}
		readonly property VeQuickItem _power: VeQuickItem {
			uid: dummyBattery.serviceUid + "/Dc/0/Power"
			onValueChanged: root.updateSystemBattery("/Dc/Battery/Power", value)
		}
		readonly property VeQuickItem _current: VeQuickItem {
			uid: dummyBattery.serviceUid + "/Dc/0/Current"
			onValueChanged: root.updateSystemBattery("/Dc/Battery/Current", value)
		}

		readonly property VeQuickItem _temperature: VeQuickItem {
			uid: dummyBattery.serviceUid + "/Dc/0/Temperature"
			onValueChanged: root.updateSystemBattery("/Dc/Battery/Temperature", value)
		}

		readonly property VeQuickItem _timeToGo: VeQuickItem {
			uid: dummyBattery.serviceUid + "/TimeToGo"
			onValueChanged: root.updateSystemBattery("/Dc/Battery/TimeToGo", value)
		}

		Component.onCompleted: {
			_deviceInstance.setValue(1)
			root.initLynxBattery(dummyBattery)
			root.updateBatteriesList()
		}
	}

	property Connections batteryConn: Connections {
		target: Global.mockDataSimulator || null

		function onSetBatteryRequested(config) {
			if (config) {
				for (var propName in config) {
					dummyBattery["_" + propName].setValue(config[propName])
				}
			}
		}
	}

	// Use a Timer rather than NumberAnimations because otherwise we get
	// a heap of animated property value updates showing up in the profiler.
	property Timer chargeTimer: Timer {
		running: Global.mockDataSimulator.timersActive
		repeat: true
		interval: 1000
		property real stepSize: 1.0 // will take 100 steps to charge to 100% from 0%.
		onTriggered: {
			if (!Global.mockDataSimulator.timersActive) {
				return
			}
			var newSoc = dummyBattery._stateOfCharge.value + stepSize
			if (newSoc >= 0 && newSoc <= 100) {
				dummyBattery._stateOfCharge.setValue(newSoc)
			} else if (newSoc > 100) {
				dummyBattery._stateOfCharge.setValue(100)
				stop()
				chargeRestartTimer.start()
			} else if (newSoc < 0) {
				dummyBattery._stateOfCharge.setValue(0)
				stop()
				chargeRestartTimer.start()
			}
			dummyBattery._timeToGo.setValue(60 * 60 * 3 * (newSoc / 100))

			// Positive power when battery is charging, negative power when battery is discharging
			const randomPower = Math.round(100 + (Math.random() * 300))
			const power = stepSize > 0 ? randomPower
					: stepSize < 0 ? randomPower * -1
					: 0
			dummyBattery._power.setValue(power)
			dummyBattery._current.setValue(power * 0.1)
			root.updateBatteriesList()
		}
	}

	property Timer chargeRestartTimer: Timer {
		interval: 5000
		onTriggered: {
			chargeTimer.stepSize *= -1
			chargeTimer.start()
		}
	}
}
