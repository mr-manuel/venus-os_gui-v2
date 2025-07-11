/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

SettingsColumn {
	id: root

	property int relayNumber
	property string sensorId
	property bool relayActivateOnTemperature
	property bool hasInvalidRelayTempConfig

	readonly property string tempRelayPrefix: BackendConnection.serviceUidForType("temprelay") + "/Sensor/" + sensorId
	readonly property string settingsBindPrefix: Global.systemSettings.serviceUid + "/Settings/TempSensorRelay/" + sensorId
	readonly property bool relayValue: cRelay.currentValue

	function showEqualValuesWarningToast() {
		//% "Warning: Activation and deactivation temperatures are set to the same value. This will lead the condition to be ignored."
		Global.showToastNotification(VenusOS.Notification_Warning, qsTrId("settings_relay_equal_values_warning"))
	}

	width: parent ? parent.width : 0

	VeQuickItem {
		id: relay1Item
		uid: Global.system.serviceUid + "/Relay/1/State"
	}

	ListText {
		//% "Condition %1"
		text: qsTrId("settings_relay_condition").arg(root.relayNumber + 1)
		secondaryText: root.relayActivateOnTemperature
			? dataItem.value
				? CommonWords.active_status
				: CommonWords.inactive_status
			  //% "Function disabled"
			: qsTrId("settings_relay_function_disabled")
		dataItem.uid: "%1/%2/State".arg(root.tempRelayPrefix).arg(root.relayNumber)
	}

	ListRadioButtonGroup {
		id: cRelay

		text: CommonWords.relay
		dataItem.uid: "%1/%2/Relay".arg(root.settingsBindPrefix).arg(root.relayNumber)
		optionModel: [
			//% "None (Disable)"
			{ display: qsTrId("settings_relay_none"), value: -1 },
			//% "Relay 1"
			{ display: qsTrId("settings_relay1"), value: 0 },
			//% "Relay 2"
			{ display: qsTrId("settings_relay2"), value: 1, readOnly: !relay1Item.valid },
		]

		//% "Warning: The above selected relay is not configured for temperature, this condition will be ignored."
		caption: root.hasInvalidRelayTempConfig ? qsTrId("settings_relay_invalid_temp_config_warning") : ""
	}

	ListSpinBox {
		id: cSet

		//% "Activation value"
		text: qsTrId("settings_relay_activation_value")
		dataItem.uid: "%1/%2/SetValue".arg(root.settingsBindPrefix).arg(root.relayNumber)
		dataItem.sourceUnit: Units.unitToVeUnit(VenusOS.Units_Temperature_Celsius)
		dataItem.displayUnit: Units.unitToVeUnit(Global.systemSettings.temperatureUnit)
		from: Units.convert(-50, VenusOS.Units_Temperature_Celsius, Global.systemSettings.temperatureUnit)
		to: Units.convert(100, VenusOS.Units_Temperature_Celsius, Global.systemSettings.temperatureUnit)
		suffix: Global.systemSettings.temperatureUnitSuffix

		onValueChanged: {
			if (value === cClear.value) {
				showEqualValuesWarningToast()
			}
		}
	}

	ListSpinBox {
		id: cClear

		//% "Deactivation value"
		text: qsTrId("settings_relay_deactivation_value")
		dataItem.uid: "%1/%2/ClearValue".arg(root.settingsBindPrefix).arg(root.relayNumber)
		dataItem.sourceUnit: Units.unitToVeUnit(VenusOS.Units_Temperature_Celsius)
		dataItem.displayUnit: Units.unitToVeUnit(Global.systemSettings.temperatureUnit)
		from: cSet.from
		to: cSet.to
		suffix: cSet.suffix

		onValueChanged: {
			if (value === cSet.value) {
				showEqualValuesWarningToast()
			}
		}
	}
}
