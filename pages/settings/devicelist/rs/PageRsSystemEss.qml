/*
** Copyright (C) 2024 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Page {
	id: root

	property string bindPrefix

	readonly property bool isModeOptimized: [
		VenusOS.Ess_State_OptimizedWithBatteryLife,
		VenusOS.Ess_State_OptimizedWithoutBatteryLife].includes(essMode.dataItem.value)

	VeQuickItem {
		id: dEssModeItem

		uid: Global.systemSettings.serviceUid + "/Settings/DynamicEss/Mode"
	}

	VeQuickItem {
		id: essMinSocItem
		uid: bindPrefix + "/Settings/Ess/MinimumSocLimit"
	}

	GradientListView {
		model: VisibleItemModel {
			ListRadioButtonGroup {
				id: essMode
				text: CommonWords.mode
				optionModel: Global.systemSettings.ess.stateModel
				dataItem.uid: root.bindPrefix + "/Settings/Ess/Mode"
			}

			ListButton {
				//% "Minimum SOC (unless grid fails)"
				text: qsTrId("settings_rs_ess_min_soc")
				secondaryText: Units.getCombinedDisplayText(VenusOS.Units_Percentage, essMinSocItem.value)
				preferredVisible: root.isModeOptimized
				onClicked: Global.dialogLayer.open(minSocDialogComponent)

				Component {
					id: minSocDialogComponent

					ESSMinimumSOCDialog {
						minimumStateOfCharge: essMinSocItem.value
						onAccepted: essMinSocItem.setValue(minimumStateOfCharge)
					}
				}
			}

			ListQuantity {
				//% "Active SOC limit"
				text: qsTrId("settings_rs_active_soc_limit")
				preferredVisible: essMode.dataItem.value === VenusOS.Ess_State_OptimizedWithBatteryLife
				dataItem.uid: root.bindPrefix + "/Ess/ActiveSocLimit"
				unit: VenusOS.Units_Percentage
			}

			ListNavigation {
				//% "Scheduled charge levels"
				text: qsTrId("settings_rs_scheduled_charge_levels")
				secondaryText: scheduleSoc.valid
						  //% "Active (%1)"
						? qsTrId("scheduled_charge_active").arg(Units.getCombinedDisplayText(VenusOS.Units_Percentage, scheduleSoc.value))
						  //% "Inactive"
						: qsTrId("scheduled_charge_inactive")
				preferredVisible: root.isModeOptimized
				onClicked: {
					Global.pageManager.pushPage(scheduledChargeComponent, { title: text })
				}

				VeQuickItem {
					id: scheduleSoc
					uid: Global.system.serviceUid + "/Control/ScheduledSoc"
				}

				Component {
					id: scheduledChargeComponent

					Page {
						GradientListView {
							model: 5
							delegate: ListChargeSchedule {
								scheduleNumber: modelData
							}
						}
					}
				}
			}

			ListNavigation {
				//% "Dynamic ESS"
				text: qsTrId("settings_rs_ess_dess")
				preferredVisible: dEssModeItem.value > 0 || Global.systemSettings.canAccess(VenusOS.User_AccessType_Service)
				onClicked: {
					Global.pageManager.pushPage("/pages/settings/PageSettingsDynamicEss.qml",
							{ title: text })
				}
			}
		}
	}
}
