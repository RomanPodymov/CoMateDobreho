//
//  CentralManager.swift
//  CoMateDobreho
//
//  Created by Roman Podymov on 03/12/2020.
//  Copyright © 2020 CoMateDobreho. All rights reserved.
//

import CoreBluetooth

protocol PeripheralsListDelegate: AnyObject {
    func onPeripheralsListReceived(_: [CBPeripheral])
}

protocol PeripheralDelegate: AnyObject {
    func onDataReceived(_: String?, characteristicId: CharacteristicId)
}

public enum CharacteristicId: String, CaseIterable {
    case soup = "b1faa5b2-95b1-436c-9bc5-82815228a3e1"
    case firstDish = "b1faa5b2-95b1-436c-9bc5-82815228a3e2"
    case secondDish = "b1faa5b2-95b1-436c-9bc5-82815228a3e3"
    case thirdDish = "b1faa5b2-95b1-436c-9bc5-82815228a3e4"

    var asOfferScreenTag: OfferScreenTag {
        switch self {
        case .soup:
            return .soup
        case .firstDish:
            return .firstDish
        case .secondDish:
            return .secondDish
        case .thirdDish:
            return .thirdDish
        }
    }
}

final class CentralManager: NSObject {
    static let shared = CentralManager()

    private var centralManager: CBCentralManager!
    private weak var peripheralsListDelegate: PeripheralsListDelegate?
    private weak var peripheralDelegate: PeripheralDelegate?
    private var peripheralsList: [CBPeripheral] = [] {
        didSet {
            peripheralsListDelegate?.onPeripheralsListReceived(peripheralsList)
        }
    }

    private static let mainServiceId = CBUUID(string: "f64642dc-22f5-450f-a2db-a0ab07c3d47f")

    public final func start(
        peripheralsListDelegate: PeripheralsListDelegate?
    ) {
        self.peripheralsListDelegate = peripheralsListDelegate
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }

    public final func connect(
        _ peripheral: CBPeripheral,
        peripheralDelegate: PeripheralDelegate?
    ) {
        self.peripheralDelegate = peripheralDelegate
        centralManager.connect(peripheral)
    }

    public final func disconnect(_ peripheral: CBPeripheral) {
        centralManager.cancelPeripheralConnection(peripheral)
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
        peripheralsList += [peripheral]
        peripheral.delegate = self
    }

    func centralManager(_: CBCentralManager, didConnect peripheral: CBPeripheral) {
        peripheral.discoverServices([Self.mainServiceId])
    }
}

extension CentralManager: CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices _: Error?) {
        guard let services = peripheral.services else { return }
        services.forEach { service in
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }

    func peripheral(
        _ peripheral: CBPeripheral,
        didDiscoverCharacteristicsFor service: CBService,
        error _: Error?
    ) {
        guard let characteristics = service.characteristics else { return }
        let knownCharacteristics = characteristics.filter { CharacteristicId(
            rawValue: $0.uuid.uuidString.lowercased()
        ) != nil }
        knownCharacteristics.forEach { characteristic in
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

        peripheralDelegate?.onDataReceived(
            String(data: characteristicData, encoding: .utf8),
            characteristicId: characteristicId
        )
    }
}
