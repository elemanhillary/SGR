//
//  models.swift
//  SGR
//
//  Created by eleman on 08/03/2024.
//

import Foundation

struct Station: Codable {
    var stationId: UInt
    var stationName: String
    
    enum CodingKeys: String, CodingKey {
        case stationId = "id"
        case stationName
    }
}

struct Booking: Decodable {
    var passengerName: String
    var startStation: UInt
    var exitStation: UInt
}
