/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Templates as CT
import QtQuick.Controls as C
import QtQuick.Controls.impl as CP
import Victron.VenusOS

CT.Button {
	id: root

	property color color: !showEnabled ? Theme.color_font_disabled
			: down ? Theme.color_button_down_text
			: Theme.color_font_primary
	property color backgroundColor: !showEnabled ? Theme.color_background_disabled
			: down ? downColor
			: flat ? "transparent"
			: Theme.color_darkOk
	property color downColor: flat ? "transparent"
			: Theme.color_ok
	property alias border: backgroundRect.border
	property alias radius: backgroundRect.radius
	property bool showEnabled: enabled

	onPressed: if (pressEffect.active) pressEffect.item.start(pressX/width, pressY/height)
	onReleased: if (pressEffect.active) pressEffect.item.stop()
	onCanceled: if (pressEffect.active) pressEffect.item.stop()

	down: pressed || checked
	spacing: Theme.geometry_button_spacing
	topPadding: 0
	bottomPadding: 0
	leftPadding: 0
	rightPadding: 0

	implicitWidth: contentItem.implicitWidth + root.leftPadding + root.rightPadding
	implicitHeight: contentItem.implicitHeight + root.topPadding + root.bottomPadding

	icon.color: root.color

	font.family: Global.fontFamily
	font.pixelSize: Theme.font_size_body1
	flat: true

	background: Rectangle {
		id: backgroundRect

		color: root.backgroundColor
		border.width: root.flat ? 0 : Theme.geometry_button_border_width
		border.color: root.showEnabled ? Theme.color_ok : Theme.color_font_disabled
		radius: Theme.geometry_button_radius

		Loader {
			id: pressEffect
			anchors.fill: parent
			active: Qt.platform.os === "wasm"
			source: "qrc:/qt/qml/Victron/VenusOS/components/controls/PressEffect.qml"
			onItemChanged: {
				if (item) {
					item.radius = Qt.binding(function() { return backgroundRect.radius })
				}
			}
		}
	}

	contentItem: CP.IconLabel {
		anchors.fill: parent
		spacing: root.spacing
		display: root.display
		icon: root.icon
		text: root.text
		font: root.font
		color: root.color
	}

	KeyNavigationHighlight.active: root.activeFocus
}
