//  Created by Rohan Thomare on 12/23/24.

import Foundation

enum RecieveState {
    case idle
    case loadingSong(link: URL, request: any SongLinkRequest)
    case songLoaded(song: Song, request: any SongLinkRequest)
    case loadError(error: Error, request: any SongLinkRequest)
}

enum RecieveActions {
    case loadSong(link: URL)
    case selectSong(song: Song, platform: PlatformIdentifier)
    case reset
}

class ReceiveController: ObservableObject, RequestController {
    @Published var state: RecieveState = .idle
    private var _songLinkRequestFactory: SongLinkRequestFactory.Type
    
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
                    self?.state = .songLoaded(song: song, request: request)
                }.onFailure { [weak self] error, request in
                    self?.state = .loadError(error: error, request: request)
                }.onLoading { [weak self] url, request in
                    self?.state = .loadingSong(link: link, request: request)
                }
                request.resume()
            case .selectSong(song: let song, platform: let platform):
                // TODO route to link
                print ("selected song \(song), platform \(platform)")
            case .reset:
                self.state = .idle
            }
        }
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
    
    func selectPlatform(song: Song, platform: PlatformIdentifier) {
        self._handleAction(.selectSong(song: song, platform: platform))
    }
    
    func reset () {
        _handleAction(.reset)
    }
}
