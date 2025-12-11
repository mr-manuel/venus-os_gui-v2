/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

DeviceListPluginPage {
	id: root

	//% "dbus-serialbattery - Time to SoC"
	title: qsTrId("dbus_serialbattery_time_to_soc_title")

	readonly property string bindPrefix: root.device.serviceUid

	property int visibleTimeToSocCount: 0

	function getTimeToSocText(dataItem) {
		if (dataItem.valid && Number.isInteger(Number(dataItem.value)) && dataItem.value > 0) {
			return Utils.secondsToString(dataItem.value);
		} else if (dataItem.valid && dataItem.value !== "") {
			return dataItem.value;
		} else {
			return "--";
		}
	}

	function updateVisibleTimeToSocCount() {
		var count = 0;
		for (var i = 0; i < timeToSocModel.count; ++i) {
			var item = timeToSocModel.get(i);
			if (item.preferredVisible) {
				count++;
			}
		}
		return count;
	}

	// Call this function whenever your model changes, e.g. onCompleted or on model update
	// Component.onCompleted: updateVisibleTimeToSocCount()
	// timeToSocModel.onCountChanged: updateVisibleTimeToSocCount()

	GradientListView {
		// if timeToSocModel is empty, show the noticeModel instead
		id: settingsListView
		model: updateVisibleTimeToSocCount() > 0 ? timeToSocModel : noticeModel

		VisibleItemModel {
			id: noticeModel

			ListItem {
				//% "No Time-to-Soc was enabled in the config file."
				text: qsTrId("dbus_serialbattery_time_to_soc_not_available")
			}
		}



		VisibleItemModel {
			id: timeToSocModel

			ListText {
				//% "Time-to-SoC %1%"
				text: qsTrId("dbus_serialbattery_time_to_soc").arg("0")
				preferredVisible: dataItem.seen
				dataItem.uid: root.bindPrefix + "/TimeToSoC/0"
				secondaryText: getTimeToSocText(dataItem)
			}
			ListText {
				//% "Time-to-SoC %1%"
				text: qsTrId("dbus_serialbattery_time_to_soc").arg("5")
				preferredVisible: dataItem.seen
				dataItem.uid: root.bindPrefix + "/TimeToSoC/5"
				secondaryText: getTimeToSocText(dataItem)
			}
			ListText {
				//% "Time-to-SoC %1%"
				text: qsTrId("dbus_serialbattery_time_to_soc").arg("10")
				preferredVisible: dataItem.seen
				dataItem.uid: root.bindPrefix + "/TimeToSoC/10"
				secondaryText: getTimeToSocText(dataItem)
			}
			ListText {
				//% "Time-to-SoC %1%"
				text: qsTrId("dbus_serialbattery_time_to_soc").arg("15")
				preferredVisible: dataItem.seen
				dataItem.uid: root.bindPrefix + "/TimeToSoC/15"
				secondaryText: getTimeToSocText(dataItem)
			}
			ListText {
				//% "Time-to-SoC %1%"
				text: qsTrId("dbus_serialbattery_time_to_soc").arg("20")
				preferredVisible: dataItem.seen
				dataItem.uid: root.bindPrefix + "/TimeToSoC/20"
				secondaryText: getTimeToSocText(dataItem)
			}
			ListText {
				//% "Time-to-SoC %1%"
				text: qsTrId("dbus_serialbattery_time_to_soc").arg("25")
				preferredVisible: dataItem.seen
				dataItem.uid: root.bindPrefix + "/TimeToSoC/25"
				secondaryText: getTimeToSocText(dataItem)
			}
			ListText {
				//% "Time-to-SoC %1%"
				text: qsTrId("dbus_serialbattery_time_to_soc").arg("30")
				preferredVisible: dataItem.seen
				dataItem.uid: root.bindPrefix + "/TimeToSoC/30"
				secondaryText: getTimeToSocText(dataItem)
			}
			ListText {
				//% "Time-to-SoC %1%"
				text: qsTrId("dbus_serialbattery_time_to_soc").arg("35")
				preferredVisible: dataItem.seen
				dataItem.uid: root.bindPrefix + "/TimeToSoC/35"
				secondaryText: getTimeToSocText(dataItem)
			}
			ListText {
				//% "Time-to-SoC %1%"
				text: qsTrId("dbus_serialbattery_time_to_soc").arg("40")
				preferredVisible: dataItem.seen
				dataItem.uid: root.bindPrefix + "/TimeToSoC/40"
				secondaryText: getTimeToSocText(dataItem)
			}
			ListText {
				//% "Time-to-SoC %1%"
				text: qsTrId("dbus_serialbattery_time_to_soc").arg("45")
				preferredVisible: dataItem.seen
				dataItem.uid: root.bindPrefix + "/TimeToSoC/45"
				secondaryText: getTimeToSocText(dataItem)
			}
			ListText {
				//% "Time-to-SoC %1%"
				text: qsTrId("dbus_serialbattery_time_to_soc").arg("50")
				preferredVisible: dataItem.seen
				dataItem.uid: root.bindPrefix + "/TimeToSoC/50"
				secondaryText: getTimeToSocText(dataItem)
			}
			ListText {
				//% "Time-to-SoC %1%"
				text: qsTrId("dbus_serialbattery_time_to_soc").arg("55")
				preferredVisible: dataItem.seen
				dataItem.uid: root.bindPrefix + "/TimeToSoC/55"
				secondaryText: getTimeToSocText(dataItem)
			}
			ListText {
				//% "Time-to-SoC %1%"
				text: qsTrId("dbus_serialbattery_time_to_soc").arg("60")
				preferredVisible: dataItem.seen
				dataItem.uid: root.bindPrefix + "/TimeToSoC/60"
				secondaryText: getTimeToSocText(dataItem)
			}
			ListText {
				//% "Time-to-SoC %1%"
				text: qsTrId("dbus_serialbattery_time_to_soc").arg("65")
				preferredVisible: dataItem.seen
				dataItem.uid: root.bindPrefix + "/TimeToSoC/65"
				secondaryText: getTimeToSocText(dataItem)
			}
			ListText {
				//% "Time-to-SoC %1%"
				text: qsTrId("dbus_serialbattery_time_to_soc").arg("70")
				preferredVisible: dataItem.seen
				dataItem.uid: root.bindPrefix + "/TimeToSoC/70"
				secondaryText: getTimeToSocText(dataItem)
			}
			ListText {
				//% "Time-to-SoC %1%"
				text: qsTrId("dbus_serialbattery_time_to_soc").arg("75")
				preferredVisible: dataItem.seen
				dataItem.uid: root.bindPrefix + "/TimeToSoC/75"
				secondaryText: getTimeToSocText(dataItem)
			}
			ListText {
				//% "Time-to-SoC %1%"
				text: qsTrId("dbus_serialbattery_time_to_soc").arg("80")
				preferredVisible: dataItem.seen
				dataItem.uid: root.bindPrefix + "/TimeToSoC/80"
				secondaryText: getTimeToSocText(dataItem)
			}
			ListText {
				//% "Time-to-SoC %1%"
				text: qsTrId("dbus_serialbattery_time_to_soc").arg("85")
				preferredVisible: dataItem.seen
				dataItem.uid: root.bindPrefix + "/TimeToSoC/85"
				secondaryText: getTimeToSocText(dataItem)
			}
			ListText {
				//% "Time-to-SoC %1%"
				text: qsTrId("dbus_serialbattery_time_to_soc").arg("90")
				preferredVisible: dataItem.seen
				dataItem.uid: root.bindPrefix + "/TimeToSoC/90"
				secondaryText: getTimeToSocText(dataItem)
			}
			ListText {
				//% "Time-to-SoC %1%"
				text: qsTrId("dbus_serialbattery_time_to_soc").arg("95")
				preferredVisible: dataItem.seen
				dataItem.uid: root.bindPrefix + "/TimeToSoC/95"
				secondaryText: getTimeToSocText(dataItem)
			}
			ListText {
				//% "Time-to-SoC %1%"
				text: qsTrId("dbus_serialbattery_time_to_soc").arg("100")
				preferredVisible: dataItem.seen
				dataItem.uid: root.bindPrefix + "/TimeToSoC/100"
				secondaryText: getTimeToSocText(dataItem)
			}
		}
	}
}
