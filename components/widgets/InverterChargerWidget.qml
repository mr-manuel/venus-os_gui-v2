/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

OverviewWidget {
	id: root

	// read values from the system service
	// slower but less code
	readonly property string efficiency: calculateEfficiency()

	function calculateEfficiency() {
		const dcPower = Math.abs(
			(alternatorPower.value ?? 0) +
			(chargerPower.value ?? 0) +
			(fuelCellPower.value ?? 0) +
			(pvPower.value ?? 0) -
			(batteryPower.value ?? 0)
		)
		if (dcPower === 0 || Math.abs(dcPower) < 30){
			// console.log("dcPower is zero or too low:", dcPower)
			return ""
		}

		const acPower = Math.abs(inverterChargerPower.value ?? 0)
		if (acPower === 0 || Math.abs(acPower) < 30) {
			// console.log("acPower is zero or too low:", acPower)
			return ""
		}

		// Calculate efficiency as a percentage
		let efficiency
		if (acPower < dcPower) {
			efficiency = acPower / dcPower * 100
		} else {
			efficiency = dcPower / acPower * 100
		}
		return "Efficiency (AC ↔ DC): " + efficiency.toFixed(1) + "%"
	}

	VeQuickItem {
		id: alternatorPower
		uid: Global.system.serviceUid + "/Dc/Alternator/Power"
	}
	VeQuickItem {
		id: batteryPower
		uid: Global.system.serviceUid + "/Dc/Battery/Power"
	}
	VeQuickItem {
		id: chargerPower
		uid: Global.system.serviceUid + "/Dc/Charger/Power"
	}
	VeQuickItem {
		id: fuelCellPower
		uid: Global.system.serviceUid + "/Dc/FuelCell/Power"
	}
	VeQuickItem {
		id: inverterChargerPower
		uid: Global.system.serviceUid + "/Dc/InverterCharger/Power"
	}
	VeQuickItem {
		id: pvPower
		uid: Global.system.serviceUid + "/Dc/Pv/Power"
	}
	VeQuickItem {
		id: showInverterChargerEfficiency
		uid: Global.systemSettings.serviceUid + "/Settings/Gui2/ShowInverterChargerEfficiency"
		// Manually execute via SSH this command to add this setting:
		// dbus -y com.victronenergy.settings /Settings AddSetting Gui2 ShowInverterChargerEfficiency 1 i 0 1
	}



	onClicked: {
		if (Global.inverterChargers.deviceCount > 1) {
			Global.pageManager.pushPage("/pages/invertercharger/InverterChargerListPage.qml")
		} else {
			// Show page for chargers
			chargerModelLoader.active = true
			if (chargerModelLoader.item.count > 0) {
				const charger = chargerModelLoader.item.firstObject
				Global.pageManager.pushPage("/pages/settings/devicelist/PageAcCharger.qml",
						{ "bindPrefix": charger.serviceUid })
			} else {
				// Show page for inverter, vebus and acsystem services
				const device = Global.inverterChargers.firstObject
				Global.pageManager.pushPage("/pages/invertercharger/OverviewInverterChargerPage.qml",
						{ "serviceUid": device.serviceUid })
			}
		}
	}

	//% "Inverter / Charger"
	title: qsTrId("overview_widget_inverter_title")
	icon.source: "qrc:/images/inverter_charger.svg"
	type: VenusOS.OverviewWidget_Type_VeBusDevice
	enabled: !!Global.inverterChargers.firstObject
	quantityLabel.visible: false
	rightPadding: Theme.geometry_overviewPage_widget_sideGauge_margins
	extraContentChildren: [
		Label {
			anchors {
				top: parent.top
				left: parent.left
				leftMargin: Theme.geometry_overviewPage_widget_content_horizontalMargin
				right: parent.right
				rightMargin: Theme.geometry_overviewPage_widget_content_horizontalMargin
				bottom: systemReasonText.top
			}
			text: Global.system.systemStateToText(Global.system.state)
			font.pixelSize: Theme.font_overviewPage_widget_quantityLabel_maximumSize
			minimumPixelSize: Theme.font_overviewPage_widget_quantityLabel_minimumSize
			fontSizeMode: Text.Fit
			wrapMode: Text.WordWrap
			maximumLineCount: 4
			elide: Text.ElideRight
		},
		Label {
			id: systemReasonText

			anchors {
				left: parent.left
				leftMargin: Theme.geometry_overviewPage_widget_content_horizontalMargin
				right: parent.right
				rightMargin: Theme.geometry_overviewPage_widget_content_horizontalMargin
				bottom: efficiencyText.top
			}
			text: systemReason.text
			wrapMode: Text.WordWrap
			color: Theme.color_font_secondary
			SystemReason {
				id: systemReason
			}
		},
		Label {
			id: efficiencyText

			anchors {
				left: parent.left
				leftMargin: Theme.geometry_overviewPage_widget_content_horizontalMargin
				right: parent.right
				rightMargin: Theme.geometry_overviewPage_widget_content_horizontalMargin
				bottom: parent.bottom
				bottomMargin: Theme.geometry_overviewPage_widget_content_verticalMargin
			}
			text: showInverterChargerEfficiency.valid && showInverterChargerEfficiency.value === 1 ? efficiency : ""
			wrapMode: Text.WordWrap
			color: Theme.color_font_secondary
		}
	]

	Loader {
		id: sideGaugeLoader

		anchors {
			top: parent.top
			bottom: parent.bottom
			right: parent.right
			margins: Theme.geometry_overviewPage_widget_sideGauge_margins
		}
		sourceComponent: ThreePhaseBarGauge {
			valueType: VenusOS.Gauges_ValueType_RisingPercentage
			phaseModel: Global.system.load.ac.phases
			maximumValue: Global.system.load.maximumAcCurrent
			animationEnabled: root.animationEnabled
			inOverviewWidget: true
		}
	}

	Loader {
		id: chargerModelLoader
		active: false
		sourceComponent: FilteredDeviceModel {
			serviceTypes: ["charger"]
			sorting: FilteredDeviceModel.DeviceInstance
		}
	}
}
