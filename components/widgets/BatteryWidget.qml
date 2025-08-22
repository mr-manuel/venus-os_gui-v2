/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS
import QtQuick.Controls.impl as CP

OverviewWidget {
	id: root

	readonly property bool preferRenewable: preferRenewableEnergy.valid
	readonly property bool preferRenewableOverride: preferRenewableEnergy.value === 0 || preferRenewableEnergy.value === 2
	readonly property bool preferRenewableOverrideGenset: remoteGeneratorSelected.value === 1 || Global.acInputs.activeInSource === VenusOS.AcInputs_InputSource_Generator

	onClicked: {
		// If com.victronenergy.system/Batteries has only one battery, then show the device
		// settings for that battery; otherwise, show the full battery list using BatteryListPage.
		if (batteries.value.length === 1) {
			const batteryUids = batteries.value.map((info) => BackendConnection.serviceUidFromName(info.id, info.instance))

			// Show the vebus page if the battery is from a vebus service.
			if (BackendConnection.serviceTypeFromUid(batteryUids[0]) === "vebus") {
				Global.pageManager.pushPage("/pages/vebusdevice/PageVeBus.qml", {
					"bindPrefix": batteryUids[0],
				})
			} else {
				// Assume this is a battery service
				Global.pageManager.pushPage("/pages/settings/devicelist/battery/PageBattery.qml", {
					"bindPrefix": batteryUids[0]
				})
			}
		} else {
			Global.pageManager.pushPage("/pages/battery/BatteryListPage.qml")
		}
	}

	readonly property var batteryData: Global.system.battery

	readonly property int _normalizedStateOfCharge: Math.round(batteryData.stateOfCharge || 0)
	readonly property bool _animationReady: animationEnabled && !isNaN(batteryData.stateOfCharge)

	// Calculate whether voltage, current and power quantities fit on the footer together, if not use smaller font.
	// Discharging battery has negative amperes and its not unusual for the watts to be in the 1k+ range.
	readonly property bool _useSmallFont: !quantityLabelFits(batteryVoltageDisplay) || !quantityLabelFits(batteryPowerDisplay)

	function quantityLabelFits(label) {
		return root.width/2 - 2*Theme.geometry_overviewPage_widget_content_horizontalMargin
			> quantityLabelWidth(batteryCurrentDisplay.valueText, batteryCurrentDisplay.unitText)/2
			+ quantityLabelWidth(label.valueText, label.unitText)
	}

	function quantityLabelWidth(valueText, unitText){
		const valueTextRect = quantityLabelFont.tightBoundingRect(valueText)
		return quantityLabelFont.font, (valueTextRect.x + valueTextRect.width
										+ Theme.geometry_quantityLabel_spacing
										+ quantityLabelFont.advanceWidth(unitText))
	}



	function selectedBatteryMonitorServiceUid() {
		if (!systemActiveBatteryService.value || systemActiveBatteryService.value === "") {
			return ""
		}

		const serviceUid = systemActiveBatteryService.value
		if (typeof serviceUid !== "string" || serviceUid.indexOf("/") === -1) {
			return ""
		}

		// Split the serviceUid into parts and return the serviceUid from the name and instance.
		// Example: "com.victronenergy.battery/ActiveBatteryService/0
		const parts = serviceUid.split("/")
		//console.log("part 0:", batteryService.value, "part 1:", parts[1])

		const name = BackendConnection.serviceUidFromName(batteryService.value, parts[1])
		//console.log("name:", name)
		return name
	}

	function getBatteryProperty(type) {
		let borderColor, backgroundColor, foregroundColor, batteryMode

		if (errorCode.valid && errorCode.value !== 0) {
			borderColor = Theme.color_red
			backgroundColor = Theme.color_darkRed
			foregroundColor = Theme.color_red
			batteryMode = "Error %1".arg(BmsError.description(errorCode.value))
		} else if (allowToCharge.valid && allowToCharge.value === 0 && allowToDischarge.valid && allowToDischarge.value === 0) {
			borderColor = Theme.color_red
			backgroundColor = Theme.color_darkRed
			foregroundColor = Theme.color_red
			batteryMode = "Charging/Discharging not allowed"
		} else if (allowToCharge.valid && allowToCharge.value === 0) {
			borderColor = Theme.color_green
			backgroundColor = Theme.color_red
			foregroundColor = Theme.color_darkGreen
			batteryMode = "Charging not allowed"
		} else if (allowToDischarge.valid && allowToDischarge.value === 0) {
			borderColor = Theme.color_overviewPage_widget_border
			backgroundColor = Theme.color_overviewPage_widget_background
			foregroundColor = Theme.color_red
			batteryMode = "Discharging not allowed"
		} else {
			borderColor = batteryData.current > 0 ? Theme.color_green : Theme.color_overviewPage_widget_border
			backgroundColor = batteryData.current > 0 ? Theme.color_darkGreen : Theme.color_overviewPage_widget_background
			foregroundColor = batteryData.current > 0 ? Theme.color_green : Theme.color_overviewPage_widget_battery_background
			batteryMode = VenusOS.battery_modeToText(batteryData.mode)
		}

		if (type === "border") return borderColor
		if (type === "background") return backgroundColor
		if (type === "foreground") return foregroundColor
		if (type === "mode") return batteryMode

		return null
	}

	VeQuickItem {
		id: systemActiveBatteryService
		uid: Global.system.serviceUid + "/ActiveBatteryService"
	}
	VeQuickItem {
		id: batteryService
		uid: Global.system.serviceUid + "/Dc/Battery/BatteryService"
	}
	VeQuickItem {
		id: allowToCharge
		uid: selectedBatteryMonitorServiceUid() !== "" ? selectedBatteryMonitorServiceUid() + "/Io/AllowToCharge" : ""
	}
	VeQuickItem {
		id: allowToDischarge
		uid: selectedBatteryMonitorServiceUid() !== "" ? selectedBatteryMonitorServiceUid() + "/Io/AllowToDischarge" : ""
	}
	VeQuickItem {
		id: errorCode
		uid: selectedBatteryMonitorServiceUid() !== "" ? selectedBatteryMonitorServiceUid() + "/ErrorCode" : ""
	}



	FontMetrics {
		id: quantityLabelFont
		font.pixelSize: Theme.font_size_body2
		font.family: Global.quantityFontFamily
	}

	VeQuickItem {
		id: batteries
		uid: Global.system.serviceUid + "/Batteries"
	}

	VeQuickItem {
		id: preferRenewableEnergy

		uid: Global.system.veBus.serviceUid ? Global.system.veBus.serviceUid + "/Dc/0/PreferRenewableEnergy" : ""
	}

	VeQuickItem {
		id: remoteGeneratorSelected

		uid: Global.system.veBus.serviceUid ? Global.system.veBus.serviceUid + "/Ac/State/RemoteGeneratorSelected" : ""
	}

	title: CommonWords.battery
	icon.source: batteryData.icon
	type: VenusOS.OverviewWidget_Type_Battery
	enabled: batteries.valid

	quantityLabel.value: batteryData.stateOfCharge
	quantityLabel.unit: VenusOS.Units_Percentage
	quantityLabel.unitColor: Theme.color_overviewPage_widget_battery_font_secondary

	color: "transparent"

	borderColor: getBatteryProperty("border")
	backgroundColor: Theme.color_overviewPage_widget_background

	BarGauge {
		id: animationRect
		z: -1

		anchors {
			fill: parent
			margins: root.border.width
		}

		animationEnabled: root.animationEnabled // Note: don't use _animationReady here.
		value: _normalizedStateOfCharge/100
		backgroundColor: getBatteryProperty("background")
		foregroundColor: getBatteryProperty("foreground")
		radius: Theme.geometry_overviewPage_widget_battery_background_radius

		Item {
			id: animationClip

			width: parent.width
			height: parent.height * (animationRect.value)
			anchors.bottom: parent.bottom
			visible: batteryData.mode === VenusOS.Battery_Mode_Charging && root._animationReady
			clip: true
			z: 6 // greater than the explicit z-order specified in BarGauge.

			SequentialAnimation {
				property bool startAnimation: root._animationReady
				onStartAnimationChanged: if (startAnimation) start()
				onStopped: if (startAnimation) start()

				YAnimator {
					target: gradient
					from: animationClip.height
					to: -gradient.height
					duration: Theme.animation_overviewPage_widget_battery_animation_duration
					easing.type: Easing.OutQuad
				}

				PauseAnimation {
					duration: Theme.animation_overviewPage_widget_battery_animation_pause_duration
				}
			}

			Rectangle {
				id: gradient
				width: parent.width
				height: Theme.geometry_overviewPage_widget_battery_gradient_height
				gradient: Gradient {
					GradientStop {
						position: 0.0
						color: Qt.rgba(1,1,1,0.3)
					}
					GradientStop {
						position: 0.3
						color: Qt.rgba(1,1,1,0.15)
					}
					GradientStop {
						position: 1.0
						color: Qt.rgba(1,1,1,0.0)
					}
				}
			}
		}
	}

	QuantityLabel {
		id: batteryTempDisplay

		anchors {
			top: parent.top
			topMargin: root.verticalMargin
			right: parent.right
			rightMargin: Theme.geometry_overviewPage_widget_content_horizontalMargin
		}

		value: batteryData.temperature
		unit: Global.systemSettings.temperatureUnit
		unitColor: Theme.color_overviewPage_widget_battery_font_secondary
		font.pixelSize: Theme.font_size_body2
		alignment: Qt.AlignRight
		visible: !isNaN(batteryData.temperature)
	}

	extraContentChildren: [
		Column {
			anchors {
				top: parent.top
				left: parent.left
				leftMargin: Theme.geometry_overviewPage_widget_content_horizontalMargin
				right: parent.right
				rightMargin: Theme.geometry_overviewPage_widget_content_horizontalMargin
			}
			Label {
				text: getBatteryProperty("mode")
				font.pixelSize: Theme.font_size_body1
				width: parent.width
				elide: Text.ElideRight
				color: Theme.color_overviewPage_widget_battery_font_secondary
			}
			Label {
				text: Global.system.battery.timeToGo == 0 ? "" : Utils.secondsToString(Global.system.battery.timeToGo)
				visible: Global.system.battery.timeToGo
				color: Theme.color_font_primary
				width: parent.width
				elide: Text.ElideRight
				font.pixelSize: Theme.font_overviewPage_battery_timeToGo_pixelSize
			}
		},

		CP.ColorImage {
			anchors {
				left: parent.left
				leftMargin: Theme.geometry_overviewPage_widget_content_horizontalMargin
				bottom: batteryVoltageDisplay.top
				bottomMargin: Theme.geometry_overviewPage_widget_battery_bottomRow_bottomMargin
			}
			fillMode: Image.PreserveAspectFit
			color: Theme.color_font_primary
			visible: root.preferRenewableOverride
			source: root.preferRenewableOverrideGenset
					? "qrc:/images/icon_charging_generator.svg"
					: Global.acInputs.activeInSource === VenusOS.AcInputs_InputSource_Shore
					  ? "qrc:/images/icon_charging_shore.svg"
					  : "qrc:/images/icon_charging_grid.svg"
		},

		QuantityLabel {
			id: batteryVoltageDisplay

			anchors {
				left: parent.left
				leftMargin: Theme.geometry_overviewPage_widget_content_horizontalMargin
				bottom: parent.bottom
				bottomMargin: Theme.geometry_overviewPage_widget_battery_bottomRow_bottomMargin
			}

			value: batteryData.voltage
			unit: VenusOS.Units_Volt_DC
			unitColor: Theme.color_overviewPage_widget_battery_font_secondary
			font.pixelSize: root._useSmallFont ? Theme.font_size_body1 : Theme.font_size_body2
			alignment: Qt.AlignLeft
		},

		QuantityLabel {
			id: batteryCurrentDisplay

			anchors {
				horizontalCenter: parent.horizontalCenter
				bottom: parent.bottom
				bottomMargin: Theme.geometry_overviewPage_widget_battery_bottomRow_bottomMargin
			}
			value: batteryData.current
			unit: VenusOS.Units_Amp
			unitColor: Theme.color_overviewPage_widget_battery_font_secondary
			font.pixelSize: root._useSmallFont ? Theme.font_size_body1 : Theme.font_size_body2
		},

		CP.ColorImage {
			anchors {
				bottom: batteryPowerDisplay.top
				bottomMargin: Theme.geometry_overviewPage_batterywidget_renewable_icon_bottom_margin
				right: parent.right
				rightMargin: Theme.geometry_overviewPage_batterywidget_renewable_icon_right_margin
			}

			fillMode: Image.PreserveAspectFit
			color: Theme.color_font_primary
			visible: root.preferRenewable
			source: "qrc:/images/icon_charging_renewables.svg"
		},

		QuantityLabel {
			id: batteryPowerDisplay

			anchors {
				right: parent.right
				rightMargin: Theme.geometry_overviewPage_widget_content_horizontalMargin
				bottom: parent.bottom
				bottomMargin: Theme.geometry_overviewPage_widget_battery_bottomRow_bottomMargin
			}
			value: batteryData.power
			unit: VenusOS.Units_Watt
			unitColor: Theme.color_overviewPage_widget_battery_font_secondary
			font.pixelSize: root._useSmallFont ? Theme.font_size_body1 : Theme.font_size_body2
			alignment: Qt.AlignRight
		}
	]
}
