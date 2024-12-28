//  Created by Rohan Thomare on 12/26/24.

import Foundation

class ServiceMatcher {
    private static let regexes: [PlatformIdentifier : [String]] = [
        .spotify: [
            #"https?://(music\.apple\.com/.+?/.+?/.+)"#,       // Apple Music song link (web)
            #"music://.+/song/.+"#,               // Apple Music deep link
        ],
        .appleMusic: [
            #"https?://open\.spotify\.com/.+?/[a-zA-Z0-9]+"#, // Spotify song link (web)
            #"spotify:track:[a-zA-Z0-9]+"#,       // Spotify deep link
        ],
        .youtube: [
            #"https?://(www\.)?(youtube\.com/watch\?v=|youtu\.be/)[a-zA-Z0-9_-]+"#, // YouTube video link (web)
            #"youtube://watch\?v=[a-zA-Z0-9_-]+"# // YouTube deep link
        ]
    ]
    
    static func matches(_ string: String) -> Bool {
        ServiceMatcher.regexes.keys.contains { index in ServiceMatcher.regexes[index]?.contains { pattern in
            guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else { return false }
            // Match the regex against the input string
            let range = NSRange(string.startIndex..<string.endIndex, in: string)
            let matches = regex.matches(in: string, options: [], range: range)
            // Return true if at least one match is found
            return !matches.isEmpty
        } ?? false }
    }
}
