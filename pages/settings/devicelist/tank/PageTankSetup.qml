/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS
import Victron.Gauges

Page {
	id: root

	property string bindPrefix

	GradientListView {
		model: VisibleItemModel {
			ListSpinBox {
				//% "Capacity"
				text: qsTrId("devicelist_tanksetup_capacity")
				dataItem.uid: root.bindPrefix + "/Capacity"
				dataItem.sourceUnit: Units.unitToVeUnit(VenusOS.Units_Volume_CubicMetre)
				dataItem.displayUnit: Units.unitToVeUnit(Global.systemSettings.volumeUnit)
				suffix: Units.defaultUnitString(Global.systemSettings.volumeUnit)
				stepSize: Global.systemSettings.volumeUnit === VenusOS.Units_Volume_CubicMetre
						  ? 0.005
						  : 1   // Litres, Gallons
				decimals: Units.defaultUnitPrecision(Global.systemSettings.volumeUnit)
			}

			ListRadioButtonGroup {
				//% "Sensor type"
				text: qsTrId("devicelist_tanksetup_sensor_type")
				dataItem.uid: root.bindPrefix + "/SenseType"
				preferredVisible: dataItem.valid
				optionModel: [
					{ display: CommonWords.voltage, value: 1 },
					{ display: CommonWords.current_amps, value: 2 },
				]
			}

			ListRadioButtonGroup {
				id: standard

				//% "Standard"
				text: qsTrId("devicelist_tanksetup_standard")
				dataItem.uid: root.bindPrefix + "/Standard"
				preferredVisible: dataItem.valid
				optionModel: [
					//% "European (0 to 180 Ohm)"
					{ display: qsTrId("devicelist_tanksetup_european_(0_to_180_ohm)"), value: 0 },
					//% "US (240 to 30 Ohm)"
					{ display: qsTrId("devicelist_tanksetup_us_(240_to_30_ohm)"), value: 1 },
					//% "Custom"
					{ display: qsTrId("devicelist_tanksetup_custom"), value: 2 },
				]
			}

			ListSpinBox {
				//% "Sensor value when empty"
				text: qsTrId("devicelist_tanksetup_sensor_value_when_empty")
				preferredVisible: dataItem.seen && (!standard.dataItem.valid || standard.currentValue === 2)
				dataItem.uid: root.bindPrefix + "/RawValueEmpty"
				suffix: rawUnit.value || ""
				decimals: rawUnit.displayDecimals
				stepSize: rawUnit.stepSize
			}

			ListSpinBox {
				//% "Sensor value when full"
				text: qsTrId("devicelist_tanksetup_sensor_value_when_full")
				preferredVisible: dataItem.seen && (!standard.dataItem.valid || standard.currentValue === 2)
				dataItem.uid: root.bindPrefix + "/RawValueFull"
				suffix: rawUnit.value || ""
				decimals: rawUnit.displayDecimals
				stepSize: rawUnit.stepSize
			}

			ListRadioButtonGroup {
				//% "Fluid type"
				text: qsTrId("devicelist_tanksetup_fluid_type")
				dataItem.uid: root.bindPrefix + "/FluidType"
				optionModel: Global.tanks.tankTypes.map(function(tankType) {
					return { display: Gauges.tankProperties(tankType).name || "", value: tankType }
				})
			}

			ListSpinBox {
				//% "Butane ratio"
				text: qsTrId("devicelist_tanksetup_butane_ratio")
				preferredVisible: dataItem.valid
				dataItem.uid: root.bindPrefix + "/ButaneRatio"
				suffix: "%"
			}

			ListVolumeUnitRadioButtonGroup {}

			ListNavigation {
				//% "Custom shape"
				text: qsTrId("devicelist_tanksetup_custom_shape")
				preferredVisible: shape.seen

				onClicked: {
					Global.pageManager.pushPage("/pages/settings/devicelist/tank/PageTankShape.qml",
							{ "title": text, "bindPrefix": root.bindPrefix })
				}

				VeQuickItem {
					id: shape
					uid: root.bindPrefix + "/Shape"
				}
			}

			ListSpinBox {
				//% "Averaging time"
				text: qsTrId("devicelist_tanksetup_averaging_time")
				dataItem.uid: root.bindPrefix + "/FilterLength"
				preferredVisible: dataItem.valid
				suffix: "s"
			}

			ListText {
				//% "Sensor value"
				text: qsTrId("devicelist_tanksetup_sensor_value")
				dataItem.uid: root.bindPrefix + "/RawValue"
				preferredVisible: dataItem.valid
				secondaryText: dataItem.valid ? Units.formatNumber(dataItem.value, rawUnit.displayDecimals) + (rawUnit.value || "") : "--"
			}

			ListNavigation {
				text: CommonWords.low_level_alarm
				preferredVisible: low.seen

				onClicked: {
					Global.pageManager.pushPage("/pages/settings/devicelist/tank/PageTankAlarm.qml",
							{ "title": text, "bindPrefix": root.bindPrefix + "/Alarms/Low" })
				}

				VeQuickItem {
					id: low
					uid: root.bindPrefix + "/Alarms/Low/Enable"
				}
			}

			ListNavigation {
				text: CommonWords.high_level_alarm
				preferredVisible: high.seen

				onClicked: {
					Global.pageManager.pushPage("/pages/settings/devicelist/tank/PageTankAlarm.qml",
							{ "title": text, "bindPrefix": root.bindPrefix + "/Alarms/High" })
				}

				VeQuickItem {
					id: high
					uid: root.bindPrefix + "/Alarms/High/Enable"
				}
			}
		}
	}

	VeQuickItem {
		id: rawUnit

		// The possible values here are not well defined. The doco says: "can be V, and probably also mA and R or O."
		// At least one installation uses "cm".
		readonly property int displayDecimals: {
			switch (value) {
			case "cm":
				return 1
			default:
				return 3
			}
		}

		readonly property real stepSize: {
			switch (value) {
			case "cm":
				return 0.1
			default:
				return 0.005
			}
		}

		uid: root.bindPrefix + "/RawUnit"
	}
}
