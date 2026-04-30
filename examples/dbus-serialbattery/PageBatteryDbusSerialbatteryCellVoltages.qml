/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Layouts
import Victron.VenusOS

DeviceListPluginPage {
	id: root

	//% "dbus-serialbattery - Cell Voltages"
	title: qsTrId("dbus_serialbattery_cell_voltages_title")

	readonly property string bindPrefix: root.device.serviceUid

	// Measures the widest possible cell row label ("Cells 29-32") without needing access to a delegate
	Text {
		id: cellLabelMeasure
		visible: false
		font: cellOverviewItem.font
		//% "Cells %1-%2"
		text: qsTrId("dbus_serialbattery_cell_voltages_cells").arg(29).arg(32)
	}

	readonly property real overviewLabelWidth: Math.max(
		overviewTitleLabel.implicitWidth,
		cellLabelMeasure.implicitWidth
	)

	readonly property int overviewColumnCount: {
		if (contentRowOverview.width <= 0) return 5
		const colWidth5 = (contentRowOverview.width - Theme.geometry_listItem_content_spacing * 4) / 5
		return colWidth5 >= 80 ? 5 : 2
	}
	readonly property real overviewColumnWidth: contentRowOverview.width > 0
		? (contentRowOverview.width - Theme.geometry_listItem_content_spacing * (overviewColumnCount - 1)) / overviewColumnCount
		: 0

	readonly property int cellColumnCount: {
		if (contentRowOverview.width <= 0) return 4
		const colWidth4 = (contentRowOverview.width - Theme.geometry_listItem_content_spacing * 3) / 4
		return colWidth4 >= 80 ? 4 : 2
	}
	readonly property real cellColumnWidth: contentRowOverview.width > 0
		? (contentRowOverview.width - Theme.geometry_listItem_content_spacing * (cellColumnCount - 1)) / cellColumnCount
		: 0

	property real cellVoltagesMean: NaN
	readonly property int cellCount: 32
	readonly property real cellVoltageDiffThreshold: isNaN(cellVoltagesMean) ? NaN : cellVoltagesMean * 0.05 // 5% of mean voltage

	// Arrays to hold references to VeQuickItems
	property var cellVoltageItems: []
	property var cellBalanceItems: []

	function getCellTextColor(cell) {
		if (cell < 1 || cell > cellCount) {
			return Theme.color_font_primary;
		}
		var voltageCellItem = cellVoltageItems[cell - 1];
		var balanceCellItem = cellBalanceItems[cell - 1];
		if (!voltageCellItem || !balanceCellItem) {
			return Theme.color_font_primary;
		}
		if (cellVoltageMin.valid && cellVoltageMax.valid && voltageCellItem.valid && balanceCellItem.valid && balanceCellItem.value == "1") {
			return (cellVoltageMin.value == voltageCellItem.value) ? Theme.color_blue
				: (cellVoltageMax.value == voltageCellItem.value) ? Theme.color_red
				: Theme.color_orange;
		} else {
			return Theme.color_font_primary;
		}
	}

	// Get mean cell voltage by adding all cell voltages and dividing by number of cells
	// since the battery voltage is not accurate enough
	function updateCellVoltagesMean() {
		var sum = 0;
		var count = 0;
		for (var cell = 1; cell <= cellCount; cell++) {
			var cellItem = cellVoltageItems[cell - 1];
			if (cellItem && cellItem.valid && cellItem.value != 0) {
				sum += cellItem.value;
				count += 1;
			}
		}
		cellVoltagesMean = (count > 0) ? (sum / count) : NaN;
	}

	// Use Repeaters to create VeQuickItems for voltages and balances
	Repeater {
		id: voltageRepeater
		model: root.cellCount
		delegate: Item {
			property int cellIndex: index
			VeQuickItem {
				id: voltageItem
				uid: root.bindPrefix + "/Voltages/Cell" + (cellIndex + 1)
				onValidChanged: root.updateCellVoltagesMean()
				onValueChanged: root.updateCellVoltagesMean()
				Component.onCompleted: {
					root.cellVoltageItems[cellIndex] = voltageItem;
					// Trigger a slice to notify that the array has changed
					if (cellIndex === root.cellCount - 1) {
						root.cellVoltageItems = root.cellVoltageItems.slice(0);
					}
				}
			}
		}
	}
	Repeater {
		id: balanceRepeater
		model: root.cellCount
		delegate: Item {
			property int cellIndex: index
			VeQuickItem {
				id: balanceItem
				uid: root.bindPrefix + "/Balances/Cell" + (cellIndex + 1)
				Component.onCompleted: {
					root.cellBalanceItems[cellIndex] = balanceItem;
					// Trigger a slice to notify that the array has changed
					if (cellIndex === root.cellCount - 1) {
						root.cellBalanceItems = root.cellBalanceItems.slice(0);
					}
				}
			}
		}
	}

	VeQuickItem {
		id: cellVoltageSum
		uid: root.bindPrefix + "/Voltages/Sum"
	}
	VeQuickItem {
		id: cellVoltageDiff
		uid: root.bindPrefix + "/Voltages/Diff"
	}
	VeQuickItem {
		id: cellVoltageMin
		uid: root.bindPrefix + "/System/MinCellVoltage"
	}
	VeQuickItem {
		id: cellVoltageMax
		uid: root.bindPrefix + "/System/MaxCellVoltage"
	}

	GradientListView {
		model: VisibleItemModel {

			ListItem {
				id: cellOverviewItem
				topPadding: Theme.geometry_listItem_content_verticalMargin / 2
				bottomPadding: Theme.geometry_listItem_content_verticalMargin / 2

				contentItem: RowLayout {
					Label {
						id: overviewTitleLabel
						//% "Overview"
						text: qsTrId("dbus_serialbattery_overview")
						font: cellOverviewItem.font
						Layout.minimumWidth: root.overviewLabelWidth
					}

					Flow {
						id: contentRowOverview
						Layout.fillWidth: true
						spacing: Theme.geometry_listItem_content_spacing

						ColumnLayout {
							width: root.overviewColumnWidth
							spacing: 0

							QuantityLabel {
								Layout.fillWidth: true
								value: cellVoltageSum.value ?? NaN
								unit: VenusOS.Units_Volt_DC
								decimals: 2
								font.pixelSize: 22
							}

							Label {
								Layout.fillWidth: true
								horizontalAlignment: Text.AlignHCenter
								//: Sum of all cell voltages
								//% "Sum"
								text: qsTrId("dbus_serialbattery_cell_voltages_sum")
								color: Theme.color_font_secondary
								font.pixelSize: Theme.font_size_caption
							}
						}
						ColumnLayout {
							width: root.overviewColumnWidth
							spacing: 0

							QuantityLabel {
								Layout.fillWidth: true
								value: cellVoltagesMean ?? NaN
								unit: VenusOS.Units_Volt_DC
								decimals: 3
								font.pixelSize: 22
							}

							Label {
								Layout.fillWidth: true
								horizontalAlignment: Text.AlignHCenter
								//: Average of all cell voltages
								//% "Mean"
								text: "Ø " + qsTrId("dbus_serialbattery_cell_voltages_mean")
								color: Theme.color_font_secondary
								font.pixelSize: Theme.font_size_caption
							}
						}
						ColumnLayout {
							width: root.overviewColumnWidth
							spacing: 0

							QuantityLabel {
								Layout.fillWidth: true
								value: cellVoltageMin.value ?? NaN
								unit: VenusOS.Units_Volt_DC
								decimals: 3
								font.pixelSize: 22
							}

							Label {
								Layout.fillWidth: true
								horizontalAlignment: Text.AlignHCenter
								//: Minimum cell voltage
								//% "Min"
								text: qsTrId("dbus_serialbattery_cell_voltages_min")
								color: Theme.color_font_secondary
								font.pixelSize: Theme.font_size_caption
							}
						}
						ColumnLayout {
							width: root.overviewColumnWidth
							spacing: 0

							QuantityLabel {
								Layout.fillWidth: true
								value: cellVoltageMax.value ?? NaN
								unit: VenusOS.Units_Volt_DC
								decimals: 3
								font.pixelSize: 22
							}

							Label {
								Layout.fillWidth: true
								horizontalAlignment: Text.AlignHCenter
								//: Maximum cell voltage
								//% "Max"
								text: qsTrId("dbus_serialbattery_cell_voltages_max")
								color: Theme.color_font_secondary
								font.pixelSize: Theme.font_size_caption
							}
						}
						ColumnLayout {
							width: root.overviewColumnWidth
							spacing: 0

							QuantityLabel {
								Layout.fillWidth: true
								value: cellVoltageDiff.value ?? NaN
								unit: VenusOS.Units_Volt_DC
								decimals: 3
								font.pixelSize: 22
							}

							Label {
								Layout.fillWidth: true
								horizontalAlignment: Text.AlignHCenter
								//: Difference between maximum and minimum cell voltage
								//% "Diff"
								text: qsTrId("dbus_serialbattery_cell_voltages_diff")
								color: Theme.color_font_secondary
								font.pixelSize: Theme.font_size_caption
							}
						}
					}
				}
			}

			ColumnLayout {
				width: parent ? parent.width : 0
				spacing: Theme.geometry_gradientList_spacing

				Repeater {
					id: cellRowRepeater
					model: 8
					delegate: ListItem {
						id: cellListItem

						property int outerIndex: model.index

						preferredVisible: (
							root.cellVoltageItems[outerIndex * 4 + 0] && root.cellVoltageItems[outerIndex * 4 + 0].valid
						) || (
							root.cellVoltageItems[outerIndex * 4 + 1] && root.cellVoltageItems[outerIndex * 4 + 1].valid
						) || (
							root.cellVoltageItems[outerIndex * 4 + 2] && root.cellVoltageItems[outerIndex * 4 + 2].valid
						) || (
							root.cellVoltageItems[outerIndex * 4 + 3] && root.cellVoltageItems[outerIndex * 4 + 3].valid
						)
						topPadding: Theme.geometry_listItem_content_verticalMargin / 2
						bottomPadding: Theme.geometry_listItem_content_verticalMargin / 2

						contentItem: RowLayout {
							implicitHeight: contentRowCell.height

							Label {
								id: cellDetailsTitleLabel
								//% "Cells %1-%2"
								text: qsTrId("dbus_serialbattery_cell_voltages_cells").arg(model.index * 4 + 1).arg(model.index * 4 + 4)
								font: cellOverviewItem.font
								Layout.minimumWidth: root.overviewLabelWidth
							}

							Flow {
								id: contentRowCell
								Layout.fillWidth: true
								spacing: Theme.geometry_listItem_content_spacing

								Repeater {
									id: cellRepeater
									model: 4
									delegate: ColumnLayout {
										width: root.cellColumnWidth
										spacing: 0

										readonly property var cellVoltageRef: root.cellVoltageItems[outerIndex * 4 + model.index]
										readonly property real cellVoltageMeanDiff: cellVoltageRef && cellVoltageRef.valid ? (cellVoltageRef.value - cellVoltagesMean) : NaN

										QuantityLabel {
											Layout.fillWidth: true
											value: cellVoltageRef && cellVoltageRef.valid ? cellVoltageRef.value : NaN
											unit: VenusOS.Units_Volt_DC
											decimals: 3
											font.pixelSize: 22
											valueColor: getCellTextColor(outerIndex * 4 + model.index + 1)
											visible: cellVoltageRef && cellVoltageRef.valid
										}

										Label {
											Layout.fillWidth: true
											horizontalAlignment: Text.AlignHCenter
											text: isNaN(cellVoltageMeanDiff) ? "" : "Ø " + (cellVoltageMeanDiff > 0 ? "+" : "") + cellVoltageMeanDiff.toFixed(3) + " V"
											color: isNaN(cellVoltageMeanDiff)
												? Theme.color_font_secondary
												: (cellVoltageMeanDiff > cellVoltageDiffThreshold ? Theme.color_red
													: cellVoltageMeanDiff < -cellVoltageDiffThreshold ? Theme.color_blue
													: Theme.color_font_secondary)
											font.pixelSize: Theme.font_size_caption
											visible: cellVoltageRef && cellVoltageRef.valid
										}
									}
								}
							}
						}
					}
				}
			}
		}
	}
}
