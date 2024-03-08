//
//  ViewController.swift
//  SGR
//
//  Created by eleman on 08/03/2024.
//

import UIKit
import CoreData

class ViewController: UIViewController {
    private let network = Network()
    private var stations: [Station] = []
    private var bookings: [Booking] = []
    
    @IBOutlet weak var occupany: UILabel!
    
    private let sortingOrder = [0, 2, 2, 2, 1, 0]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let retrievedOccupancyData = fetchOccupancyData()
        if !retrievedOccupancyData.isEmpty {
            occupany.text = retrievedOccupancyData
            return;
        }
        let dispatchGroup = DispatchGroup()
        dispatchGroup.enter()
        network.request(endpoint: .bookings) { [weak self] (bookings: [Booking]?, error: Error?) in
            defer { dispatchGroup.leave() }
            guard let self = self else { return }
            if let error = error {
                return
            }
            guard let bookings = bookings else { return }
            self.bookings = bookings
        }

        dispatchGroup.enter()
        network.request(endpoint: .stations) { [weak self] (stations: [Station]?, error: Error?) in
            defer { dispatchGroup.leave() }
            guard let self = self else { return }
            if let error = error {
                return
            }
            guard let stations = stations else { return }
            self.stations = stations
        }

        dispatchGroup.notify(queue: .main) {[weak self] in
            guard let self = self else { return }
            var stationOccupancy = Array(repeating: 0, count: self.stations.count)
            for booking in bookings {
                for i in Int(booking.startStation)..<Int(booking.exitStation) {
                    stationOccupancy[Int(i)] += 1
                }
            }
            
            self.occupany.text = "\(stationOccupancy)"
            saveOccupancyData(stationOccupancy)
        }
    }
    
    private func saveOccupancyData(_ occupancyData: [Int]) {
        let context = CoreDataStack.shared.viewContext
        let stationOccupancy = Occupancy(context: context)
        stationOccupancy.occupancy = "\(occupancyData)"
        do {
            try context.save()
        } catch {
            print("Error saving occupancy data: \(error)")
        }
    }

    private func fetchOccupancyData() -> String {
        let context = CoreDataStack.shared.viewContext
        let fetchRequest = Occupancy.fetchRequest()
        do {
            let stationOccupancies = try context.fetch(fetchRequest).first
            return stationOccupancies?.occupancy ?? ""
        } catch {
            print("Error fetching occupancy data: \(error)")
            return ""
        }
    }
}
