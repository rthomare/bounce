//  Created by Rohan Thomare on 12/25/24.

import Foundation
import Messages

class MessageFactory {
    static func buildSongMessage(_ song: Song) -> MSMessage? {
        // Create a message URL with the song link data
        let queryItems = [
            URLQueryItem(name: "title", value: song.title),
            URLQueryItem(name: "artist", value: song.artistName),
            URLQueryItem(name: "url", value: "https://espn.com")
        ]
        
        var components = URLComponents()
        components.queryItems = queryItems

        guard let messageURL = components.url else {
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
}

