//  Created by Rohan Thomare on 12/25/24.

import Foundation
import Messages

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
    
    func to<T: Decodable>(type: T.Type) throws -> T {
        guard let components = URLComponents(url: self, resolvingAgainstBaseURL: false),
            let queryItems = components.queryItems else {
            throw NSError(domain: "InvalidURL", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to parse URL components"])
        }
        
        let queryDict = Dictionary(uniqueKeysWithValues: queryItems.compactMap { item in
            item.value.map { (item.name, $0) }
        })
        
        let jsonData = try JSONSerialization.data(withJSONObject: queryDict, options: [])
        return try JSONDecoder().decode(type, from: jsonData)
    }
}

class MessageFactory {
    static func buildSongMessage(_ song: Song) -> MSMessage? {
        // Make an abridged version of the song
        guard let messageURL = URL.from(baseURL: "https://songs.rohanthomare.com", parameters: song.abridged()) else {
            print("Failed to create message URL")
            return nil
        }

        // Create a new MSMessage
        let message = MSMessage()
        message.url = messageURL

        // Add a layout for a nice preview in iMessage
        let layout = MSMessageTemplateLayout()
        // UIImage from url
        layout.image = song.thumbnail
        layout.caption = song.title
        layout.subcaption = "By \(song.artistName)"
        layout.trailingSubcaption = "Tap to listen"
        message.layout = layout

        // Send the message
        return message;
    }
    
    static func universalLink(for song: Song) -> URL? {
        guard let messageURL = URL.from(baseURL: "https://bounce.io", parameters: song.abridged()) else {
            print("Failed to create message URL")
            return nil
        }
        return messageURL
    }
    
    static func getSongFromMessage(_ message: MSMessage) -> SongAbridged? {
        let url = message.url
        do {
            return try url?.to(type: SongAbridged.self)
        } catch {
            print("Failed to parse song from message: \(error)")
            return nil
        }
    }
}
