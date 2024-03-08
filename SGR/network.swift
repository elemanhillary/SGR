//
//  network.swift
//  SGR
//
//  Created by eleman on 08/03/2024.
//

import Foundation
import UIKit
import CoreData

enum NetworkError: Error {
    case invalidURL
    case invalidResponse
    case noData
    case coreDataError
    case decoderError
}

struct Network {
    func request<T: Decodable>(endpoint: API_ENDPOINTS, completion: @escaping ([T]?, Error?) -> Void) {
        guard let url = URL(string: BASE_API + endpoint.rawValue) else {
            print("Invalid URL")
            completion(nil, NetworkError.invalidURL)
            return
        }

        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Error fetching data: \(error.localizedDescription)")
                completion(nil, NetworkError.invalidResponse)
                return
            }
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                print("Error: Invalid response")
                completion(nil, NetworkError.invalidResponse)
                return
            }
            guard let data = data else {
                print("Error: No data")
                completion(nil, NetworkError.noData)
                return
            }
            do {
                let decoder = JSONDecoder()
                print("data", data)
                let data = try decoder.decode([T].self, from: data)
                completion(data, nil)
            } catch {
                print("Error decoding JSON: \(error.localizedDescription)")
                completion(nil, NetworkError.decoderError)
            }
        }
        task.resume()
    }
}

