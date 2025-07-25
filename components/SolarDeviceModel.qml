/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

DeviceModel {
	id: root

	modelId: "solarDevices"

	readonly property Instantiator _serviceObjects: Instantiator {
		model: ["solarcharger", "multi", "inverter"]
		delegate: Instantiator {
			id: serviceInstantiator

			required property string modelData

			model: ServiceModel { serviceTypes: [modelData] }
			delegate: SolarDevice {
				id: solarDevice

				// solarcharger devices are always included in the model.
				// For multi and inverter devices, only include them if /NrOfTrackers > 0.
				readonly property bool hasSolarData: valid
						&& (serviceInstantiator.modelData === "solarcharger"
							|| (_nrOfTrackers.valid && _nrOfTrackers.value > 0))

				serviceUid: model.uid

				onHasSolarDataChanged: {
					if (hasSolarData) {
						root.addDevice(solarDevice)
					} else {
						root.removeDevice(solarDevice.serviceUid)
					}
				}

				readonly property VeQuickItem _nrOfTrackers: VeQuickItem {
					uid: solarDevice.serviceUid + "/NrOfTrackers"
				}
			}
		}
	}
}
