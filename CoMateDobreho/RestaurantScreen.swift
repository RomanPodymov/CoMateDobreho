//
//  RestaurantScreen.swift
//  CoMateDobreho
//
//  Created by Roman Podymov on 03/12/2020.
//  Copyright © 2020 CoMateDobreho. All rights reserved.
//

import UIKit

final class RestaurantScreen: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        CentralManager.shared.start()
    }
}
