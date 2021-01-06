//
//  OfferScreen.swift
//  CoMateDobreho
//
//  Created by Roman Podymov on 03/12/2020.
//  Copyright © 2020 CoMateDobreho. All rights reserved.
//

import CoreBluetooth
import Eureka
import Foundation
import UIKit

enum OfferScreenTag: String {
    case soup
    case firstDish
    case secondDish
    case thirdDish
}

final class OfferScreen: FormViewController {
    public var peripheral: CBPeripheral? {
        didSet {
            if let peripheral = peripheral {
                CentralManager.shared.connect(peripheral, peripheralDelegate: self)
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        form +++ Section(L10n.OfferScreen.Dishes.title)
            <<< LabelRow(OfferScreenTag.soup.rawValue) { row in
                row.title = L10n.OfferScreen.Dishes.soup
            }
            <<< LabelRow(OfferScreenTag.firstDish.rawValue) { row in
                row.title = L10n.OfferScreen.Dishes.firstDish
            }
            <<< LabelRow(OfferScreenTag.secondDish.rawValue) { row in
                row.title = L10n.OfferScreen.Dishes.secondDish
            }
            <<< LabelRow(OfferScreenTag.thirdDish.rawValue) { row in
                row.title = L10n.OfferScreen.Dishes.thirdDish
            }
    }

    override func didMove(toParent parent: UIViewController?) {
        super.didMove(toParent: parent)

        if parent == nil, let peripheral = peripheral {
            CentralManager.shared.disconnect(peripheral)
        }
    }
}

extension OfferScreen: PeripheralDelegate {
    func onDataReceived(_ data: String?, characteristicId: CharacteristicId) {
        guard let data = data,
              let rowForCharacteristicId = form.rowBy(
                  tag: characteristicId.asOfferScreenTag.rawValue
              ) as? LabelRow
        else {
            return
        }
        rowForCharacteristicId.value = data
        rowForCharacteristicId.updateCell()
    }
}
