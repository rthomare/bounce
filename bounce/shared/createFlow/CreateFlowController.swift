//  Created by Rohan Thomare on 12/23/24.

import Foundation
import MediaPlayer
import MusicKit
import UIKit

protocol CreateFlowListener: AnyObject {
    func didUpdateState(state: CreateFlowState) -> Void
}

enum CreateFlowState {
    case initializing
    case idle
    case detecting
    case loadingSong(link: URL, request: any SongLinkRequest)
    case songLoaded(song: Song, request: any SongLinkRequest)
    case loadError(error: Error, request: any SongLinkRequest)
}

enum CreateFlowActions {
    case startDetection
    case dectectedSongUrl(songUrl: URL)
    case didLoadSong(song: Song, request: any SongLinkRequest)
    case failedToLoadSong(error: Error, request: any SongLinkRequest)
    case reset
}

class CreateFlowController: ObservableObject {
    @Published var state: CreateFlowState = .initializing
    private var _songLinkRequestFactory: SongLinkRequestFactory.Type
    private let _notificationCenter: NotificationCenter = .default
    private let _musicPlayer = MPMusicPlayerController.systemMusicPlayer
    private let _hasMusicPermission: Bool = false
    
    init(_ factory: SongLinkRequestFactory.Type) {
        _songLinkRequestFactory = factory
    }
    
    deinit {
        _notificationCenter.removeObserver(self, name: UIPasteboard.changedNotification, object: nil)
        _notificationCenter.removeObserver(self, name: UIPasteboard.removedNotification, object: nil)
        _notificationCenter.removeObserver(
            self,
            name: .MPMusicPlayerControllerNowPlayingItemDidChange,
            object: _musicPlayer
        )
        _notificationCenter.removeObserver(
            self,
            name: .MPMusicPlayerControllerPlaybackStateDidChange,
            object: _musicPlayer
        )
    }
    
    // MARK: Private Methods
    
    private func _handleAction(_ action: CreateFlowActions) {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            switch action {
                case .startDetection:
                    self.state = .detecting
                    _detectSong()
                case .dectectedSongUrl(songUrl: let url):
                    // Search if string is a service url
                    let request = _songLinkRequestFactory.build(songLink: url)
                        .onLoading { songUrl, req  in
                            self.state = .loadingSong(link: songUrl, request: req)
                        }.onFailure { error, req in
                            self._handleAction(.failedToLoadSong(error: error, request: req))
                        }.onSuccess { songUrl, req in
                            self._handleAction(.didLoadSong(song: songUrl, request: req))
                        }
                    request.resume()
                case .didLoadSong(song: let song, request: let request):
                    state = .songLoaded(song: song, request: request)
                case .failedToLoadSong(error: let error, request: let request):
                    state = .loadError(error: error, request: request)
                case .reset:
                    state = .idle
            }
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
                let title = nowPlayingItem.title!
                let artist = nowPlayingItem.artist!
                let album = nowPlayingItem.albumTitle!
                do {
                    // Create a search request
                    let searchRequest = MusicCatalogSearchRequest(term: "\(title) \(artist) \(album)", types: [MusicKit.Song.self])
                    // Perform the search
                    let searchResponse = try await searchRequest.response()
                        // Access results
                        let song = searchResponse.songs.first
                        if let song, song.url != nil {
                            completion(.success(song.url!)) // Pass the result in the completion handler
                        }
                    }
            } catch {
                completion(.failure(error)) // Pass the error in the completion handler
            }
        }
    }
    
    // check the pasteboard if it is a url is a songs link then update the state
    private func _detectSong() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: { [weak self] in
            guard let self else { return }
            if let pasteboard = UIPasteboard.general.string {
                if let url = ServiceMatcher.matches(pasteboard) ? URL(string: pasteboard) : nil {
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
            self.reset()
        })
    }
    
    private func _start(hasMusicPermission: Bool) {
        if (hasMusicPermission) {
            _musicPlayer.beginGeneratingPlaybackNotifications()
            // Start observing notifications
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(detectSong),
                name: .MPMusicPlayerControllerNowPlayingItemDidChange,
                object: _musicPlayer
            )
            
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(detectSong),
                name: .MPMusicPlayerControllerPlaybackStateDidChange,
                object: _musicPlayer
            )
        }
        
        _notificationCenter.addObserver(self, selector: #selector(detectSong), name: UIPasteboard.changedNotification, object: nil)
        _notificationCenter.addObserver(self, selector: #selector(detectSong), name: UIPasteboard.removedNotification, object: nil)
        _handleAction(.startDetection)
    }
    
    // MARK: Public Methods
    
    func initialize() {
        MPMediaLibrary.requestAuthorization { [weak self] status in
            switch status {
            case .authorized:
                self?._start(hasMusicPermission: true)
            case .denied, .restricted, .notDetermined:
                self?._start(hasMusicPermission: false)
            @unknown default:
                self?._start(hasMusicPermission: false)
                break
            }
        }
    }
    
    @objc func detectSong() {
        self._handleAction(.startDetection)
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
    
    func reset () {
        _handleAction(.reset)
    }
}
