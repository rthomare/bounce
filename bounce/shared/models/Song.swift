//  Created by Rohan Thomare on 12/23/24.

import UIKit

enum PlatformIdentifier: String, Codable {
    case appleMusic = "appleMusic"
    case youtube = "youtube"
    case spotify = "spotify"
}

struct SongEntity: Codable {
    let id: String
    let type: String
    let title: String
    let artistName: String
    let thumbnailUrl: String
    let thumbnailWidth: Int
    let thumbnailHeight: Int
    let apiProvider: String
    let platforms: [String] // Updated to use PlatformIdentifier
}

struct PlatformLink: Codable {
    let country: String
    let url: String
    let nativeAppUriMobile: String?
    let nativeAppUriDesktop: String?
    let entityUniqueId: String
}

struct SongResponse: Codable {
    let entityUniqueId: String
    let userCountry: String
    let pageUrl: String
    let entitiesByUniqueId: [String: SongEntity]
    let linksByPlatform: [String: PlatformLink]
    
    init() {
        entityUniqueId = ""
        userCountry = ""
        pageUrl = ""
        entitiesByUniqueId = [:]
        linksByPlatform = [:]
    }
    
    static func from(jsonString: String) throws -> SongResponse {
        return try JSONDecoder().decode(SongResponse.self, from: jsonString.data(using: .utf8)!)
    }
    
    static func from(json: Data) throws -> SongResponse {
        return try JSONDecoder().decode(SongResponse.self, from: json)
    }
}

struct Song {
    let title: String
    let artistName: String
    let thumbnail: UIImage?
    let thumbnailUrl: String
    let thumbnailWidth: Int
    let thumbnailHeight: Int
    let platform: String
    let rawData: SongResponse
}

struct SongAbridged {
    let title: String
    let artistName: String
    let thumbnailUrl: String
    let linkByPlatform: [PlatformIdentifier: String]
}
