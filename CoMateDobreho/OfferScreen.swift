//
//  OfferScreen.swift
//  CoMateDobreho
//
//  Created by Roman Podymov on 03/12/2020.
//  Copyright © 2020 CoMateDobreho. All rights reserved.
//

import Eureka
import Foundation

enum OfferScreenTag: String {
    case soup
    case firstMeal
    case secondMeal
    case thirdMeal
}

final class OfferScreen: FormViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        form +++ Section(NSLocalizedString("offer_screen.title", comment: ""))
            <<< LabelRow(OfferScreenTag.soup.rawValue) { row in
                row.title = NSLocalizedString("offer_screen.soup", comment: "")
            }
            <<< LabelRow(OfferScreenTag.firstMeal.rawValue) { row in
                row.title = NSLocalizedString("offer_screen.first_meal", comment: "")
            }
            <<< LabelRow(OfferScreenTag.secondMeal.rawValue) { row in
                row.title = NSLocalizedString("offer_screen.second_meal", comment: "")
            }
            <<< LabelRow(OfferScreenTag.thirdMeal.rawValue) { row in
                row.title = NSLocalizedString("offer_screen.third_meal", comment: "")
            }

        CentralManager.shared.start(with: self)
    }
}

extension OfferScreen: CentralManagerDelegate {
    func onDataReceived(_ data: String?, characteristicId: CharacteristicId) {
        guard let data = data, let rowForCharacteristicId = form.rowBy(tag: characteristicId.asOfferScreenTag.rawValue) as? LabelRow else {
            return
        }
        rowForCharacteristicId.value = data
        rowForCharacteristicId.updateCell()
    }
}
