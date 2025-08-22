/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Item {
	id: gauges

	property alias value: arc.value
	property alias startAngle: arc.startAngle
	property alias endAngle: arc.endAngle
	property int status
	property alias animationEnabled: arc.animationEnabled
	property alias shineAnimationEnabled: arc.shineAnimationEnabled



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
		let backgroundColor, foregroundColor

		if (errorCode.valid && errorCode.value !== 0) {
			backgroundColor = Theme.color_darkRed
			foregroundColor = Theme.color_red
		} else if (allowToCharge.valid && allowToCharge.value === 0 && allowToDischarge.valid && allowToDischarge.value === 0) {
			backgroundColor = Theme.color_darkRed
			foregroundColor = Theme.color_red
		} else if (allowToCharge.valid && allowToCharge.value === 0) {
			backgroundColor = Theme.color_red
			foregroundColor = Theme.color_darkGreen
		} else if (allowToDischarge.valid && allowToDischarge.value === 0) {
			backgroundColor = Theme.color_overviewPage_widget_background
			foregroundColor = Theme.color_red
		} else {
			backgroundColor = batteryCurrent.value > 0 ? Theme.color_darkGreen : Theme.statusColorValue(gauges.status, true)
			foregroundColor = batteryCurrent.value > 0 ? Theme.color_green : Theme.statusColorValue(gauges.status)
			// batteryMode = VenusOS.battery_modeToText(batteryData.mode)
		}

		if (type === "background") return backgroundColor
		if (type === "foreground") return foregroundColor

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
		id: batteryCurrent
		uid: Global.system.serviceUid + "/Dc/Battery/Current"
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

	Item {
		id: antialiased
		anchors.fill: parent

		// Antialiasing without requiring multisample framebuffers.
		layer.enabled: !BackendConnection.msaaEnabled
		layer.smooth: true
		layer.textureSize: Qt.size(antialiased.width*2, antialiased.height*2)

		// The single circular gauge is always the battery gauge :. shiny.
		ShinyProgressArc {
			id: arc

			width: gauges.width
			height: width
			anchors.centerIn: parent
			radius: width/2
			startAngle: 0
			endAngle: 359 // "Note that a single PathArc cannot be used to specify a circle."
			progressColor: Theme.color_darkOk,getBatteryProperty("foreground")
			remainderColor: Theme.color_darkOk,getBatteryProperty("background")
			strokeWidth: Theme.geometry_circularSingularGauge_strokeWidth
		}
	}
}
