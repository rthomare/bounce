//  Created by Rohan Thomare on 12/23/24.

import Foundation
import SwiftUICore

enum RecieveState {
    case idle
    case loadingSong(link: URL, request: any SongLinkRequest)
    case songLoaded(song: Song, request: any SongLinkRequest)
    case loadError(error: Error, request: any SongLinkRequest)
}

enum RecieveActions {
    case loadSong(link: URL)
    case selectSong(song: Song, platform: PlatformIdentifier, preferred: Bool)
    case reset
}

let PLATFORM_PREFERENCE_KEY = "platform_perference"

class ReceiveController: ObservableObject, RequestController {
    @Published var state: RecieveState = .idle
    let sharedDefaults = UserDefaults(suiteName: "com.roti.bounce.shared")
    
    private var _songLinkRequestFactory: SongLinkRequestFactory.Type
    var openURL: OpenURLAction?
    
    init(_ factory: SongLinkRequestFactory.Type) {
        _songLinkRequestFactory = factory
    }
    
    // MARK: Private Methods
    
    private func _handleAction(_ action: RecieveActions) {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            switch action {
            case .loadSong(link: let link):
                let request = self._songLinkRequestFactory.build(songLink: link).onSuccess { [weak self] song, request in
                    guard let self else { return }
                    if let pref = PlatformIdentifier(rawValue: self.sharedDefaults?.string(forKey: PLATFORM_PREFERENCE_KEY) ?? "") {
                        self.selectPlatform(song: song, platform: pref, preferred: false)
                    } else {
                        self.state = .songLoaded(song: song, request: request)
                    }
                }.onFailure { [weak self] error, request in
                    self?.state = .loadError(error: error, request: request)
                }.onLoading { [weak self] url, request in
                    self?.state = .loadingSong(link: link, request: request)
                }
                request.resume()
            case .selectSong(song: let song, platform: let platform, preferred: let preferred):
                if let item = song.rawData.linksByPlatform.first(where: {
                    $0.key == platform.rawValue
                }), let url = URL(string: item.value.nativeAppUriMobile ?? item.value.url) {
                    if preferred {
                        _storePreference(platform: platform)
                    }
                    openURL?(url)
                }
                print ("selected song \(song), platform \(platform)")
            case .reset:
                self.state = .idle
            }
        }
    }
    
    private func _storePreference(platform: PlatformIdentifier) {
        sharedDefaults?.set(platform.rawValue, forKey: PLATFORM_PREFERENCE_KEY)
        sharedDefaults?.synchronize() // Ensure changes are written immediately
    }
    
    // MARK: Public Methods
    
    func loadSong(with songLink: URL) {
        self._handleAction(.loadSong(link: songLink))
    }
    
    // trigger a fetch of the song matches
    func retry() {
        switch state {
        case .idle, .songLoaded, .loadingSong:
            // no need to retry in these states
            break
        case .loadError(error: _, request: let req):
            self._handleAction(.loadSong(link: req.songLink))
            break
        }
    }
    
    func selectPlatform(song: Song, platform: PlatformIdentifier, preferred: Bool) {
        self._handleAction(.selectSong(song: song, platform: platform, preferred: preferred))
    }
    
    func reset () {
        _handleAction(.reset)
    }
}
