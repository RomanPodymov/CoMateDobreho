//
//  CentralManager.swift
//  CoMateDobreho
//
//  Created by Roman Podymov on 03/12/2020.
//  Copyright © 2020 CoMateDobreho. All rights reserved.
//

import CoreBluetooth

protocol CentralManagerDelegate: AnyObject {
    func onDataReceived(_: String?, characteristicId: CharacteristicId)
}

public enum CharacteristicId: String, CaseIterable {
    case soup = "b1faa5b2-95b1-436c-9bc5-82815228a3e1"
    case firstMeal = "b1faa5b2-95b1-436c-9bc5-82815228a3e2"
    case secondMeal = "b1faa5b2-95b1-436c-9bc5-82815228a3e3"
    case thirdMeal = "b1faa5b2-95b1-436c-9bc5-82815228a3e4"

    var asOfferScreenTag: OfferScreenTag {
        switch self {
        case .soup:
            return .soup
        case .firstMeal:
            return .firstMeal
        case .secondMeal:
            return .secondMeal
        case .thirdMeal:
            return .thirdMeal
        }
    }
}

final class CentralManager: NSObject {
    static let shared = CentralManager()

    private var centralManager: CBCentralManager!
    private weak var delegate: CentralManagerDelegate?
    private var currentPeripheral: CBPeripheral?

    private static let mainServiceId = CBUUID(string: "f64642dc-22f5-450f-a2db-a0ab07c3d47f")

    public final func start(with delegate: CentralManagerDelegate?) {
        self.delegate = delegate
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
        currentPeripheral = peripheral
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
            peripheral.discoverCharacteristics(nil, for: service)
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
        guard let characteristicId = CharacteristicId(
            rawValue: characteristic.uuid.uuidString.lowercased()
        ), let characteristicData = characteristic.value else {
            return
        }

        delegate?.onDataReceived(
            String(data: characteristicData, encoding: .utf8),
            characteristicId: characteristicId
        )
    }
}
