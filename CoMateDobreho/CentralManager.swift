//
//  CentralManager.swift
//  CoMateDobreho
//
//  Created by Roman Podymov on 03/12/2020.
//  Copyright © 2020 CoMateDobreho. All rights reserved.
//

import CoreBluetooth
import Foundation

final class CentralManager: NSObject {
    static let shared = CentralManager()

    private var centralManager: CBCentralManager!

    private static let mainServiceId = CBUUID(string: "f64642dc-22f5-450f-a2db-a0ab07c3d47f")
    private static let mainCharacteristicId = CBUUID(string: "b1faa5b2-95b1-436c-9bc5-82815228a3e1")

    public final func start() {
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
}

extension CentralManager: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOn:
            centralManager.scanForPeripherals(withServices: [Self.mainServiceId])
        default:
            ()
        }
    }

    func centralManager(
        _: CBCentralManager, didDiscover peripheral: CBPeripheral,
        advertisementData _: [String: Any], rssi _: NSNumber
    ) {
        peripheral.delegate = self
        centralManager.stopScan()
        centralManager.connect(peripheral)
    }

    func centralManager(_: CBCentralManager, didConnect peripheral: CBPeripheral) {
        peripheral.discoverServices([Self.mainServiceId])
    }
}

extension CentralManager: CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices _: Error?) {
        guard let services = peripheral.services else { return }
        for service in services {
            peripheral.discoverCharacteristics([Self.mainCharacteristicId], for: service)
        }
    }

    func peripheral(
        _ peripheral: CBPeripheral,
        didDiscoverCharacteristicsFor service: CBService,
        error _: Error?
    ) {
        guard let characteristics = service.characteristics else { return }
        for characteristic in characteristics {
            if characteristic.properties.contains(.read) {
                peripheral.readValue(for: characteristic)
            }
        }
    }

    func peripheral(
        _: CBPeripheral,
        didUpdateValueFor characteristic: CBCharacteristic,
        error _: Error?
    ) {
        switch characteristic.uuid {
        case Self.mainCharacteristicId:
            if let characteristicData = characteristic.value {
                print(String(data: characteristicData, encoding: .utf8))
            }
        default:
            ()
        }
    }
}
