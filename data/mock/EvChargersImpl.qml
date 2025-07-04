/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

QtObject {
	id: root

	property int mockDeviceCount

	function populate() {
		for (let i = 0; i < 3; ++i) {
			const charger = createCharger({
				position: i % 2 === 0 ? VenusOS.AcPosition_AcInput : VenusOS.AcPosition_AcOutput,
				status: Math.floor(Math.random() * VenusOS.Evcs_Status_Charged),
				mode: Math.floor(Math.random() * VenusOS.Evcs_Mode_Scheduled),
			})
			charger.phaseCount = i + 1
		}
		createEnergyMeter()
	}

	function createCharger(config) {
		const deviceInstanceNum = mockDeviceCount++
		const charger = chargerComponent.createObject(root, {
			serviceUid: "mock/com.victronenergy.evcharger.ttyUSB" + deviceInstanceNum,
			deviceInstance: deviceInstanceNum,
		})
		for (const configProperty in config) {
			const configValue = config[configProperty]
			charger["_" + configProperty].setValue(configValue)
		 }
		_createdObjects.push(charger)
		return charger
	}

	function createEnergyMeter() {
		const deviceInstanceNum = mockDeviceCount++
		const charger = energyMeterComponent.createObject(root, {
			serviceUid: "mock/com.victronenergy.evcharger.ttyUSB" + deviceInstanceNum,
			deviceInstance: deviceInstanceNum,
			phaseCount: 4,
		})
		_createdObjects.push(charger)
	}

	property Connections mockConn: Connections {
		target: Global.mockDataSimulator || null

		function onSetEvChargersRequested(config) {
			while (_createdObjects.length > 0) {
				const evCharger = _createdObjects.pop()
				Global.mockDataSimulator.setMockValue(evCharger.serviceUid + "/DeviceInstance", -1)
				evCharger.destroy()
			}

			if (config && config.chargers) {
				for (let i = 0; i < config.chargers.length; ++i) {
					createCharger(config.chargers[i])
				}
			}
		}
	}

	property Component chargerComponent: Component {
		EvCharger {
			id: evCharger

			property int phaseCount

			property Timer _dummyValues: Timer {
				running: Global.mockDataSimulator.timersActive
				repeat: true
				interval: 1000

				onTriggered: {
					const zeroPower = Math.random() < 0.2
					let totalPower = 0
					for (let i = 0; i < evCharger.phaseCount; ++i) {
						const phasePower = zeroPower ? 0 : 100 + Math.random() * 50
						Global.mockDataSimulator.setMockValue(`${evCharger.serviceUid}/Ac/L${i+1}/Power`, phasePower)
						totalPower += phasePower
					}

					Global.mockDataSimulator.setMockValue(evCharger.serviceUid + "/Ac/Energy/Forward", 1 + Math.random() * 10)
					Global.mockDataSimulator.setMockValue(evCharger.serviceUid + "/Current", 1 + Math.random() * 20)
					Global.mockDataSimulator.setMockValue(evCharger.serviceUid + "/Ac/Power", totalPower)
					Global.mockDataSimulator.setMockValue(evCharger.serviceUid + "/ChargingTime", chargingTime + 60)
				}
			}

			property Timer _statusChange: Timer {
				running: Global.mockDataSimulator.timersActive
				repeat: true
				interval: 3000

				onTriggered: {
					evCharger._status.setValue(Math.floor(Math.random() * VenusOS.Evcs_Status_OverheatingDetected))
				}
			}

			Component.onCompleted: {
				_deviceInstance.setValue(deviceInstance)

				// Set default values
				_maxCurrent.setValue(30)
				_customName.setValue("EV Charger " + deviceInstance)
				_productId.setValue(0xC025)
				_status.setValue(Math.floor(Math.random() * VenusOS.Evcs_Status_Charged))
				_mode.setValue(Math.floor(Math.random() * VenusOS.Evcs_Mode_Auto))
				_chargingTime.setValue(100000)
				_position.setValue(1)

				Global.mockDataSimulator.setMockValue(serviceUid + "/StartStop", 1)
				Global.mockDataSimulator.setMockValue(serviceUid + "/AutoStart", 1)
				Global.mockDataSimulator.setMockValue(serviceUid + "/EnableDisplay", 1)
				Global.mockDataSimulator.setMockValue(serviceUid + "/SetCurrent", 16)

				// Device info
				Global.mockDataSimulator.setMockValue(serviceUid + "/Mgmt/Connection", serviceUid)
				Global.mockDataSimulator.setMockValue(serviceUid + "/Connected", 1)

				// Immediately queue an update so that the Brief/Overview pages update sooner for
				// UI testing.
				Qt.callLater(Global.evChargers._doUpdateTotals)
			}
		}
	}

	property Component energyMeterComponent: Component {
		Device {
			id: energyMeter

			readonly property int status: Math.floor(Math.random() * VenusOS.Evcs_Status_ChargingLimit)
			readonly property real energy: _energy.valid ? _energy.value : NaN
			readonly property real power: _power.valid ? _power.value : NaN
			readonly property real current: NaN
			readonly property real maxCurrent: NaN
			property int phaseCount

			function updateTotals() {
				let totalPower = 0
				for (let i = 0; i < _phases.count; ++i) {
					totalPower += _phases.objectAt(i).power
				}
				_power.setValue(totalPower)
				_energy.setValue(Math.random() * 100)
			}

			readonly property VeQuickItem _energy: VeQuickItem {
				uid: energyMeter.serviceUid + "/Ac/Energy/Forward"
			}

			readonly property VeQuickItem _power: VeQuickItem {
				uid: energyMeter.serviceUid + "/Ac/Power"
			}

			readonly property VeQuickItem _role: VeQuickItem {
				uid: energyMeter.serviceUid + "/Role"
				Component.onCompleted: setValue("evcharger")
			}

			readonly property VeQuickItem _allowedRoles: VeQuickItem {
				uid: energyMeter.serviceUid + "/AllowedRoles"
				Component.onCompleted: setValue(["evcharger"])
			}

			readonly property Instantiator _phases: Instantiator {
				model: energyMeter.phaseCount
				delegate: QtObject {
					required property int index
					readonly property string phaseUid: energyMeter.serviceUid + "/Ac/L" + (index + 1)
					readonly property string name: "L" + (index + 1)
					readonly property real power: _power.valid ? _power.value : NaN

					readonly property VeQuickItem _power: VeQuickItem {
						uid: phaseUid + "/Power"
					}
					property Timer _dummyValues: Timer {
						running: Global.mockDataSimulator.timersActive
						repeat: true
						interval: 2000
						onTriggered: {
							_power.setValue(100 + (Math.random() * 100))
							Qt.callLater(energyMeter.updateTotals)
						}
					}
				}
			}

			Component.onCompleted: {
				_deviceInstance.setValue(deviceInstance)
				_productName.setValue("Energy Meter")
			}
		}
	}

	property var _createdObjects: []

	Component.onCompleted: {
		populate()
	}
}
