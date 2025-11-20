/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

DeviceListPluginPage {
	id: root

	//% "dbus-serialbattery - Settings"
	title: qsTrId("dbus_serialbattery_settings_title")

	readonly property string bindPrefix: root.device.serviceUid

	GradientListView {
		model: VisibleItemModel {

			SettingsListHeader {
				//% "IO"
				text: qsTrId("dbus_serialbattery_settings_io")
			}

			ListText {
				text: CommonWords.allow_to_charge
				dataItem.uid: root.bindPrefix + "/Io/AllowToCharge"
				preferredVisible: dataItem.valid
				secondaryText: CommonWords.yesOrNo(dataItem.value)
			}

			ListText {
				text: CommonWords.allow_to_discharge
				dataItem.uid: root.bindPrefix + "/Io/AllowToDischarge"
				preferredVisible: dataItem.valid
				secondaryText: CommonWords.yesOrNo(dataItem.value)
			}

			ListText {
				//% "Allow to balance"
				text: qsTrId("dbus_serialbattery_settings_allow_to_balance")
				dataItem.uid: root.bindPrefix + "/Io/AllowToBalance"
				preferredVisible: dataItem.valid
				secondaryText: CommonWords.yesOrNo(dataItem.value)
			}

			ListSwitch {
				//% "Force charging off"
				text: qsTrId("dbus_serialbattery_settings_force_charging_off")
				dataItem.uid: root.bindPrefix + "/Io/ForceChargingOff"
				preferredVisible: dataItem.valid
			}

			ListSwitch {
				//% "Force discharging off"
				text: qsTrId("dbus_serialbattery_settings_force_discharging_off")
				dataItem.uid: root.bindPrefix + "/Io/ForceDischargingOff"
				preferredVisible: dataItem.valid
			}

			ListSwitch {
				//% "Turn balancing off"
				text: qsTrId("dbus_serialbattery_settings_turn_balancing_off")
				dataItem.uid: root.bindPrefix + "/Io/TurnBalancingOff"
				preferredVisible: dataItem.valid
			}

			SettingsListHeader {
				//% "Settings"
				text: qsTrId("dbus_serialbattery_settings_settings")
				preferredVisible: resetSocSpinBoxItem.visible
			}

			ListSpinBox {
				id: resetSocSpinBoxItem
				//% "Reset SoC to"
				text: qsTrId("dbus_serialbattery_settings_reset_soc_to")
				dataItem.uid: root.bindPrefix + "/Settings/ResetSoc"
				preferredVisible: dataItem.valid
				suffix: "%"
				from: 0
				to: 100
				stepSize: 1
			}
		}
	}
}
