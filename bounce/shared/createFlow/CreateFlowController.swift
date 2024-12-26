//  Created by Rohan Thomare on 12/23/24.

import Foundation
import UIKit

class ServiceMatcher {
    private static let regexes: [PlatformIdentifier : [String]] = [
        .spotify: [
            #"https?://(music\.apple\.com/.+?/song/.+)"#,       // Apple Music song link (web)
            #"music://.+/song/.+"#,               // Apple Music deep link
        ],
        .appleMusic: [
            #"https?://open\.spotify\.com/track/[a-zA-Z0-9]+"#, // Spotify song link (web)
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

protocol CreateFlowListener: AnyObject {
    func didUpdateState(state: CreateFlowState) -> Void
}

enum CreateFlowActions {
    case pasteboardUpdated(string: String)
    case didLoadSong(song: SongModel, request: any SongLinkRequest)
    case failedToLoadSong(error: Error, request: any SongLinkRequest)
    case reset
}

class CreateFlowController: ObservableObject {
    @Published var state: CreateFlowState = .initial
    private var _songLinkRequestFactory: SongLinkRequestFactory.Type
    private var _notificationCenter: NotificationCenter = .default
    
    init(_ factory: SongLinkRequestFactory.Type) {
        _songLinkRequestFactory = factory
        _notificationCenter.addObserver(self, selector: #selector(_checkPasteboard), name: UIPasteboard.changedNotification, object: nil)
        _notificationCenter.addObserver(self, selector: #selector(_checkPasteboard), name: UIPasteboard.removedNotification, object: nil)
        _checkPasteboard()
    }
    
    deinit {
        _notificationCenter.removeObserver(self, name: UIPasteboard.changedNotification, object: nil)
        _notificationCenter.removeObserver(self, name: UIPasteboard.removedNotification, object: nil)
    }
    
    // MARK: Private Methods
    
    private func _handleAction(_ action: CreateFlowActions) {
        switch action {
            case .pasteboardUpdated(string: let pasteBoardString):
                // Search if string is a service url
                if let url = ServiceMatcher.matches(pasteBoardString) ? URL(string: pasteBoardString) : nil {
                    let request = _songLinkRequestFactory.build(songLink: url)
                        .onLoading { songUrl, req  in
                            self.state = .loadingSong(link: songUrl, request: req)
                        }.onFailure { error, req in
                            self._handleAction(.failedToLoadSong(error: error, request: req))
                        }.onSuccess { songUrl, req in
                            self._handleAction(.didLoadSong(song: songUrl, request: req))
                        }
                    request.resume()
                }
            case .didLoadSong(song: let song, request: let request):
                state = .songLoaded(song: song, request: request)
            case .failedToLoadSong(error: let error, request: let request):
                state = .loadError(error: error, request: request)
            case .reset:
                state = .initial
        }
    }
    
    // check the pasteboard if it is a url is a songs link then update the state
    @objc private func _checkPasteboard() {
        let pasteboard = UIPasteboard.general.string
        if (pasteboard?.isEmpty ?? true) { return }
        _handleAction(.pasteboardUpdated(string: pasteboard!))
    }
    
    // MARK: Public Methods
    
    // trigger a fetch of the song matches
    func retry() {
        _checkPasteboard()
    }
    
    func reset () {
        _handleAction(.reset)
    }
}
