//
//  RestaurantsScreen.swift
//  CoMateDobreho
//
//  Created by Roman Podymov on 02/01/2021.
//  Copyright © 2021 CoMateDobreho. All rights reserved.
//

import CoreBluetooth
import UIKit

final class RestaurantsScreen: UITableViewController {
    private var peripheralsList: [CBPeripheral] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        CentralManager.shared.start(peripheralsListDelegate: self)
    }

    override func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        peripheralsList.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = peripheralsList[indexPath.row].name
        return cell
    }

    override func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
        let controller = OfferScreen()
        navigationController?.pushViewController(controller, animated: true)
        controller.peripheral = peripheralsList[indexPath.row]
    }
}

extension RestaurantsScreen: PeripheralsListDelegate {
    func onPeripheralsListReceived(_ peripheralsList: [CBPeripheral]) {
        self.peripheralsList = peripheralsList
        tableView.reloadData()
    }
}
