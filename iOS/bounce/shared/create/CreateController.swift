//  Created by Rohan Thomare on 12/23/24.

import Foundation
import MediaPlayer
import MusicKit
import UIKit

enum CreateFlowState {
    case initializing
    case idle
    case detecting
    case loadingSong(link: URL, request: any SongLinkRequest)
    case songLoaded(song: Song, request: any SongLinkRequest)
    case loadError(error: Error, request: any SongLinkRequest)
}

enum SongSelectionType {
    case tapped
    case shake
}

enum CreateFlowActions {
    case startDetection(withSongUrl: String? = nil)
    case emptyDetection
    case dectectedSongUrl(songUrl: URL)
    case didLoadSong(song: Song, request: any SongLinkRequest)
    case failedToLoadSong(error: Error, request: any SongLinkRequest)
    case selectSong(song: Song, selectionType: SongSelectionType)
    case reset
}

class CreateController: ObservableObject, RequestController {
    @Published var state: CreateFlowState = .initializing
    private let _onSongSelected: ((Song, SongSelectionType) -> Void)?
    private var _songLinkRequestFactory: SongLinkRequestFactory.Type
    private let _notificationCenter: NotificationCenter = .default
    private let _musicPlayer = MPMusicPlayerController.systemMusicPlayer
    private let _hasMusicPermission: Bool = false
    
    init(_ factory: SongLinkRequestFactory.Type, onSongSelected: ((Song, SongSelectionType) -> Void)? = nil) {
        _songLinkRequestFactory = factory
        _onSongSelected = onSongSelected
    }
    
    deinit {
        _notificationCenter.removeObserver(self, name: UIPasteboard.changedNotification, object: nil)
        _notificationCenter.removeObserver(
            self,
            name: .MPMusicPlayerControllerNowPlayingItemDidChange,
            object: _musicPlayer
        )
    }
    
    // MARK: Private Methods
    
    private func _setState(_ state: CreateFlowState) {
        DispatchQueue.main.async {
            self.state = state
        }
    }
    
    private func _handleAction(_ action: CreateFlowActions) {
        switch action {
            case .startDetection(withSongUrl: let url):
                _setState(.detecting)
                _detectSong(overrideString: url)
            case .emptyDetection:
                _setState(.idle)
            case .dectectedSongUrl(songUrl: let url):
                // Search if string is a service url
                let request = _songLinkRequestFactory.build(songLink: url)
                    .onLoading { songUrl, req  in
                        self._setState(.loadingSong(link: songUrl, request: req))
                    }.onFailure { error, req in
                        self._handleAction(.failedToLoadSong(error: error, request: req))
                    }.onSuccess { songUrl, req in
                        self._handleAction(.didLoadSong(song: songUrl, request: req))
                    }
                request.resume()
            case .didLoadSong(song: let song, request: let request):
                _setState(.songLoaded(song: song, request: request))
            case .failedToLoadSong(error: let error, request: let request):
                _setState(.loadError(error: error, request: request))
            case .selectSong(song: let song, selectionType: let selectionType):
                self._onSongSelected?(song, selectionType)
            case .reset:
                _setState(.idle)
        }
    }
    
    private func _checkNowPlaying() -> URL?{
        // Access the now-playing info center
        guard let nowPlayingInfo = MPNowPlayingInfoCenter.default().nowPlayingInfo else {
            return nil
        }
        
        // Retrieve the media URL
        if let assetURL = nowPlayingInfo[MPMediaItemPropertyAssetURL] as? URL {
            return assetURL
        } else {
            return nil
        }
    }
    
    func _fetchMusic(nowPlayingItem: MPMediaItem, completion: @escaping (Result<URL, Error>) -> Void) {
        Task {
            do {
                guard let title = nowPlayingItem.title, let artist = nowPlayingItem.artist, let album = nowPlayingItem.albumTitle else {
                    completion(.failure(URLError(.unknown)))
                    return
                }
                // Create a search request
                let searchRequest = MusicCatalogSearchRequest(term: "\(title) \(artist) \(album)", types: [MusicKit.Song.self])
                // Perform the search
                let searchResponse = try await searchRequest.response()
                // Access results
                let song = searchResponse.songs.first
                if let song, song.url != nil {
                    completion(.success(song.url!)) // Pass the result in the completion handler
                }
            } catch {
                completion(.failure(error)) // Pass the error in the completion handler
            }
        }
    }
    
    // check the pasteboard if it is a url is a songs link then update the state
    @objc private func _detectSong(overrideString: String? = nil) {
        if let songString = overrideString ?? UIPasteboard.general.string {
            if let url = ServiceMatcher.matches(songString) ? URL(string: songString) : nil {
                self._handleAction(.dectectedSongUrl(songUrl: url))
                return
            }
        }
        
        if let nowPlayingItem = self._musicPlayer.nowPlayingItem {
            self._fetchMusic(nowPlayingItem: nowPlayingItem) { [weak self] result in
                guard let self else { return }
                switch result {
                case .success(let url):
                    self._handleAction(.dectectedSongUrl(songUrl: url))
                    return
                case .failure:
                    break
                }
            }
        }
        self._handleAction(.emptyDetection)
    }
    
    private func _start(hasMusicPermission: Bool, songUrl: String?) {
        if (hasMusicPermission) {
            _musicPlayer.beginGeneratingPlaybackNotifications()
            // Start observing notifications
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(_detectSong),
                name: .MPMusicPlayerControllerNowPlayingItemDidChange,
                object: _musicPlayer
            )
        }
        
        _notificationCenter.addObserver(self, selector: #selector(_detectSong), name: UIPasteboard.changedNotification, object: nil)
        _handleAction(.startDetection(withSongUrl: songUrl))
    }
    
    // MARK: Public Methods
    
    func initialize(withSongUrl: String? = nil) {
        MPMediaLibrary.requestAuthorization { [weak self] status in
            switch status {
            case .authorized:
                self?._start(hasMusicPermission: true, songUrl: withSongUrl)
            case .denied, .restricted, .notDetermined:
                self?._start(hasMusicPermission: false, songUrl: withSongUrl)
            @unknown default:
                self?._start(hasMusicPermission: false, songUrl: withSongUrl)
                break
            }
        }
    }
    
    @objc func detectSong(with songUrl: String? = nil) {
        self._handleAction(.startDetection(withSongUrl: songUrl))
        self.reset()
    }
    
    func rotateRandomSong() {
        // Select a random string from the array
        let rotatedURL = URL(string: songRotation.randomElement()!)!
        self._handleAction(.dectectedSongUrl(songUrl: rotatedURL))
    }
    
    // trigger a fetch of the song matches
    func retry() {
        switch state {
        case .initializing, .idle, .detecting, .loadingSong(link: _, request: _), .songLoaded(song: _, request: _):
            // no need to retry in these states
            break
        case .loadError(error: _, request: let req):
            self._handleAction(.dectectedSongUrl(songUrl: req.songLink))
            break
        }
    }
    
    func selectSong(_ song: Song, selectionType: SongSelectionType = SongSelectionType.tapped) {
        self._handleAction(.selectSong(song: song, selectionType: selectionType))
    }
    
    func reset () {
        _handleAction(.reset)
    }
}
