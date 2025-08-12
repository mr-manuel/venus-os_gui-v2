/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS
import QtQuick.Controls as C
import QtQuick.Controls.impl as CP

ControlCard {
	id: root

	icon.source: "qrc:/images/settings.svg"
    icon.height: 17
    icon.width: 17
	title.text: "dbus-serialbattery - DVCC"

    VeQuickItem {
        id: essMode
        uid: Global.systemSettings.serviceUid + "/Settings/CGwacs/Hub4Mode"
    }

	SettingsColumn {
		anchors {
			top: root.title.bottom
			topMargin: Theme.geometry_controlCard_status_bottomMargin
		}
		width: parent.width

		C.ButtonGroup {
			id: stateRadioButtonGroup
		}

        ListSwitchForced {
            id: dvccSwitch

            //% "DVCC"
            text: qsTrId("settings_dvcc_dvcc")
			flat: true
            dataItem.uid: Global.systemSettings.serviceUid + "/Settings/Services/Bol"

            onCheckedChanged: {
                if (dataItem.valid && !checked && nrVebusDevices.valid && nrVebusDevices.value >= 1) {
                    //% "Make sure to also reset the VE.Bus system after disabling DVCC"
                    Global.showToastNotification(VenusOS.Notification_Info, qsTrId("settings_dvcc_switch_reset_vebus_after_disabling_dvcc"))
                }
            }

            VeQuickItem {
                id: nrVebusDevices
                uid: Global.system.serviceUid + "/Devices/NumberOfVebusDevices"
            }
        }

		FlatListItemSeparator { visible: dvccSwitch.visible }

        ListSwitch {
            id: maxChargeCurrentSwitch

            //% "Limit charge current"
            text: qsTrId("settings_dvcc_limit_charge_current")
			flat: true
            checked: maxChargeCurrent.dataItem.valid && maxChargeCurrent.dataItem.value >= 0
            preferredVisible: dvccSwitch.checked
            onClicked: {
                maxChargeCurrent.dataItem.setValue(maxChargeCurrent.dataItem.value < 0 ? 50 : -1)
            }
        }

		FlatListItemSeparator { visible: maxChargeCurrentSwitch.visible }

        ListSpinBox {
            id: maxChargeCurrent

            //% "Maximum charge current"
            text: qsTrId("settings_dvcc_max_charge_current")
			flat: true
            preferredVisible: maxChargeCurrentSwitch.visible && maxChargeCurrentSwitch.checked
            dataItem.uid: Global.systemSettings.serviceUid + "/Settings/SystemSetup/MaxChargeCurrent"
            suffix: Units.defaultUnitString(VenusOS.Units_Amp)
            from: 0
        }

		FlatListItemSeparator { visible: maxChargeCurrent.visible }

        ListSwitch {
            id: maxChargeVoltageSwitch

            //% "Limit managed battery charge voltage"
            text: qsTrId("settings_dvcc_limit_managed_battery_charge_voltage")
			flat: true
            checked: maxChargeVoltage.dataItem.valid && maxChargeVoltage.dataItem.value > 0
            preferredVisible: dvccSwitch.checked
            onClicked: {
                maxChargeVoltage.dataItem.setValue(maxChargeVoltage.dataItem.value === 0.0 ? 55.0 : 0.0)
            }
        }

		FlatListItemSeparator { visible: maxChargeVoltageSwitch.visible }

        ListSpinBox {
            id: maxChargeVoltage

            //% "Maximum charge voltage"
            text: qsTrId("settings_dvcc_max_charge_voltage")
			flat: true
            preferredVisible: maxChargeVoltageSwitch.visible && maxChargeVoltageSwitch.checked
            dataItem.uid: Global.systemSettings.serviceUid + "/Settings/SystemSetup/MaxChargeVoltage"
            suffix: "V"
            decimals: 1
            stepSize: 0.1
        }

		FlatListItemSeparator { visible: maxChargeVoltage.visible }

	}
}
