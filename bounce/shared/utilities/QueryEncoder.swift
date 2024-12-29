//  Created by Rohan Thomare on 12/29/24.

import Foundation

extension URL {
    static func from<T: Encodable>(baseURL: String, parameters: T) -> URL? {
        var components = URLComponents(string: baseURL)
        var queryItems: [URLQueryItem] = []

        // Convert the struct into a dictionary
        do {
            let data = try JSONEncoder().encode(parameters)
            if let dictionary = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                for (key, value) in dictionary {
                    if let value = value as? String {
                        queryItems.append(URLQueryItem(name: key, value: value))
                    } else if let value = value as? CustomStringConvertible {
                        queryItems.append(URLQueryItem(name: key, value: value.description))
                    }
                }
            }
        } catch {
            print("Failed to encode parameters: \(error)")
            return nil
        }

        components?.queryItems = queryItems
        return components?.url
    }
}



