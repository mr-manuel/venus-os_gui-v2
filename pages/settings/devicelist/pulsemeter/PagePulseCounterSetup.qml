/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Page {
	id: root

	property string bindPrefix
	property int inputNumber

	GradientListView {
		model: VisibleItemModel {
			ListVolumeUnitRadioButtonGroup {}

			ListSwitch {
				//% "Inverted"
				text: qsTrId("pulsecounter_setup_inverted")
				dataItem.uid: root.bindPrefix + "/Settings/InvertTranslation"
			}

			ListSpinBox {
				//% "Multiplier"
				text: qsTrId("pulsecounter_setup_multiplier")
				dataItem.uid: root.bindPrefix + "/Settings/Multiplier"
				decimals: 6
				stepSize: Math.pow(10, -decimals)
			}

			ListButton {
				//% "Reset counter"
				text: qsTrId("pulsecounter_setup_reset_counter")
				secondaryText: itemCount.value || 0
				onClicked: itemCount.setValue(0)
				interactive: itemCount.valid

				VeQuickItem {
					id: itemCount
					uid: root.bindPrefix + "/Count"
				}
			}
		}
	}
}
