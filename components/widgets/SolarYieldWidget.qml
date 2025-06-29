/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

OverviewWidget {
	id: root

	onClicked: {
		const singleDeviceOnly = (Global.solarInputs.devices.count + Global.solarInputs.pvInverterDevices.count) === 1
		if (singleDeviceOnly && Global.solarInputs.devices.count === 1) {
			Global.pageManager.pushPage("/pages/solar/SolarDevicePage.qml",
					{ "solarDevice": Global.solarInputs.devices.firstObject })
		} else if (singleDeviceOnly && Global.solarInputs.pvInverterDevices === 1) {
			Global.pageManager.pushPage("/pages/solar/PvInverterPage.qml",
					{ "pvInverter": Global.solarInputs.pvInverterDevices.deviceAt(0) })
		} else {
			Global.pageManager.pushPage("/pages/solar/SolarInputListPage.qml", { "title": root.title })
		}
	}

	//% "Solar yield"
	title: qsTrId("overview_widget_solaryield_title")
	icon.source: "qrc:/images/solaryield.svg"
	type: VenusOS.OverviewWidget_Type_Solar
	enabled: true
	quantityLabel.dataObject: Global.system.solar
	preferredSize: extraContentLoader.status !== Loader.Null
			? VenusOS.OverviewWidget_PreferredSize_PreferLarge
			: VenusOS.OverviewWidget_PreferredSize_Any

	// Solar yield history is only available for PV chargers, and phase data is only available for
	// PV inverters. So, if there are only solar chargers, show the solar history; otherwise if
	// there is a single PV inverter, show its phase data.
	extraContentChildren: [
		Loader {
			id: extraContentLoader

			readonly property int margin: sourceComponent === historyComponent
				  ? Theme.geometry_overviewPage_widget_solar_graph_margins
				  : root.verticalMargin

			anchors {
				left: parent.left
				leftMargin: margin
				right: parent.right
				rightMargin: margin
				bottom: parent.bottom
				bottomMargin: margin
			}
			active: root.size >= VenusOS.OverviewWidget_Size_L
			sourceComponent: {
				if (Global.solarInputs.pvInverterDevices.count === 1 && Global.solarInputs.devices.count === 0) {
					return phaseComponent
				} else if (Global.solarInputs.pvInverterDevices.count === 0) {
					return historyComponent
				}
				// If there are both chargers and inverters, do not show the history (as inverters
				// do not have history) and also do not show phase data (as we cannot combine the
				// phase data from inverters and chargers together).
				return null
			}
		}
	]

	Component {
		id: phaseComponent

		ThreePhaseDisplay {
			model: Global.solarInputs.pvInverterDevices.deviceAt(0).phases
			visible: model.count > 1
			widgetSize: root.size
		}
	}

	Component {
		id: historyComponent

		SolarYieldGraph {
			height: root.extraContent.height - (2 * Theme.geometry_overviewPage_widget_solar_graph_margins)
		}
	}
}
