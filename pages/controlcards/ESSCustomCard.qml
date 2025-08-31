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

	icon.source: "qrc:/images/ess.svg"
	title.text: "dbus-serialbattery - ESS"

    VeQuickItem {
        id: essMode
        uid: Global.systemSettings.serviceUid + "/Settings/CGwacs/Hub4Mode"
    }

    VeQuickItem {
        id: batteryLifeState
        uid: Global.systemSettings.serviceUid + "/Settings/CGwacs/BatteryLife/State"
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

		ListSpinBox {
			id: gridSetpoint

			//% "Grid setpoint"
			text: qsTrId("settings_ess_grid_setpoint")
			flat: true
			preferredVisible: essMode.value !== VenusOS.Ess_Hub4ModeState_Disabled
			dataItem.uid: Global.systemSettings.serviceUid + "/Settings/CGwacs/AcPowerSetPoint"
			suffix: Units.defaultUnitString(VenusOS.Units_Watt)
			stepSize: 10
			presets: [ -500, -250, -100, 0, 100, 250, 500 ].map(function(v) { return { value: v } })
		}

		FlatListItemSeparator { visible: gridSetpoint.visible }

		ListSwitch {
			id: maxInverterPowerSwitch

			//% "Limit inverter power"
			text: qsTrId("settings_ess_limit_inverter_power")
			flat: true
			checked: maxDischargePower.dataItem.value >= 0
			preferredVisible: essMode.value !== VenusOS.Ess_Hub4ModeState_Disabled
				&& batteryLifeState.value !== VenusOS.Ess_BatteryLifeState_KeepCharged

			onClicked: {
				if (maxDischargePower.dataItem.value < 0) {
					maxDischargePower.dataItem.setValue(1000)
				} else if (maxDischargePower.dataItem.value >= 0) {
					maxDischargePower.dataItem.setValue(-1)
				}
			}
		}

		FlatListItemSeparator { visible: maxInverterPowerSwitch.visible }

		ListSpinBox {
			id: maxDischargePower

			//% "Maximum inverter power"
			text: qsTrId("settings_ess_max_inverter_power")
			flat: true
			preferredVisible: maxInverterPowerSwitch.visible && maxInverterPowerSwitch.checked
			dataItem.uid: Global.systemSettings.serviceUid + "/Settings/CGwacs/MaxDischargePower"
			suffix: Units.defaultUnitString(VenusOS.Units_Watt)
			from: 0
			to: 300000
			stepSize: 50
		}

		FlatListItemSeparator { visible: maxDischargePower.visible }

        ListSwitch {
            id: acFeedin

            //% "AC-coupled PV - feed in excess"
            text: qsTrId("settings_ess_ac_coupled_pv")
			flat: true
            dataItem.uid: Global.systemSettings.serviceUid + "/Settings/CGwacs/PreventFeedback"
            preferredVisible: essMode.value !== VenusOS.Ess_Hub4ModeState_Disabled
            invertSourceValue: true
        }

		FlatListItemSeparator { visible: acFeedin.visible }


        ListSwitch {
            id: feedInDc

            //% "DC-coupled PV - feed in excess"
            text: qsTrId("settings_ess_dc_coupled_pv")
			flat: true
            dataItem.uid: Global.systemSettings.serviceUid + "/Settings/CGwacs/OvervoltageFeedIn"
            preferredVisible: essMode.value !== VenusOS.Ess_Hub4ModeState_Disabled
                && doNotFeedInvOvervoltage.valid

            VeQuickItem {
                id: doNotFeedInvOvervoltage
                uid: Global.system.veBus.serviceUid ? Global.system.veBus.serviceUid + "/Hub4/DoNotFeedInOvervoltage" : ""
            }
        }

		FlatListItemSeparator { visible: feedInDc.visible }


        ListSwitch {
            id: restrictFeedIn

            //% "Limit system feed-in"
            text: qsTrId("settings_ess_limit_system_feed_in")
			flat: true
            preferredVisible: acFeedin.checked || feedInDc.checked
            checked: maxFeedInPower.dataItem.value >= 0
            onClicked: {
                if (maxFeedInPower.dataItem.value < 0) {
                    maxFeedInPower.dataItem.setValue(1000)
                } else if (maxFeedInPower.dataItem.value >= 0) {
                    maxFeedInPower.dataItem.setValue(-1)
                }
            }
        }

		FlatListItemSeparator { visible: restrictFeedIn.visible }


        ListSpinBox {
            id: maxFeedInPower

            //% "Maximum feed-in"
            text: qsTrId("settings_ess_max_feed_in")
			flat: true
            preferredVisible: restrictFeedIn.visible && restrictFeedIn.checked
            dataItem.uid: Global.systemSettings.serviceUid + "/Settings/CGwacs/MaxFeedInPower"
            suffix: Units.defaultUnitString(VenusOS.Units_Watt)
            from: 0
            to: 300000
            stepSize: 100
        }

		FlatListItemSeparator { visible: maxFeedInPower.visible }


        ListText {
            id: feedInLimitingActive
            //% "Feed-in limiting active"
            text: qsTrId("settings_ess_feed_in_limiting_active")
			flat: true
            preferredVisible: essMode.value !== VenusOS.Ess_Hub4ModeState_Disabled
                && dataItem.valid
            dataItem.uid: BackendConnection.serviceUidForType("hub4") +"/PvPowerLimiterActive"
            secondaryText: CommonWords.yesOrNo(feedInLimitingActive.dataItem.value)
        }

		FlatListItemSeparator { visible: feedInLimitingActive.visible }

	}
}
