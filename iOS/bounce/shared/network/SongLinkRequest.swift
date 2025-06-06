//  Created by Rohan Thomare on 12/24/24.

import UIKit

protocol SongLinkRequest {
    var songLink: URL { get }
    func onLoading(_ callback: @escaping (URL, any SongLinkRequest) -> Void) -> any SongLinkRequest
    func onSuccess(_ callback: @escaping (Song, any SongLinkRequest) -> Void) -> any SongLinkRequest
    func onFailure(_ callback: @escaping (Error, any SongLinkRequest) -> Void) -> any SongLinkRequest
    func resume()
    func cancel()
}

protocol SongLinkRequestFactory {
    static func build(songLink: URL) -> any SongLinkRequest
}

func loadSong(request: SongLinkRequest, response: SongResponse, completion: @escaping (Song?, Error?) -> Void) {
        guard let entity = response.entitiesByUniqueId[response.entityUniqueId] else {
            completion(nil, nil)
            return
        }
        // Download the image
        URLSession.shared.dataTask(with: entity.thumbnailUrl) { data, _, _ in
            let image = data != nil ? UIImage(data: data!) : nil
            let song = Song(
                title: entity.title,
                artistName: entity.artistName,
                thumbnail: image,
                thumbnailUrl: entity.thumbnailUrl,
                thumbnailWidth: entity.thumbnailWidth,
                thumbnailHeight: entity.thumbnailHeight,
                platform: entity.platforms[0],
                platformEntityUrl: request.songLink,
                rawData: response
            )
            completion(song, nil)
        }.resume()
}

struct MockSongLinkRequestFactory: SongLinkRequestFactory {
    static func build(songLink: URL) -> any SongLinkRequest {
        MockSongLinkRequest(songLink)
    }
}

class MockSongLinkRequest: SongLinkRequest {
    private var _loadingCallback: ((URL, SongLinkRequest) -> Void)?
    private var _successCallback: ((Song, SongLinkRequest) -> Void)?
    private var _failureCallback: ((Error, SongLinkRequest) -> Void)?
    let songLink: URL
    
    init(_ songLink: URL) {
        self.songLink = songLink
    }
    
    static func mockSong() throws -> SongResponse?  {
        guard let url = Bundle.main.url(forResource: "sampleResponse", withExtension: "json") else {
            throw URLError(.badURL)
        }
        
        do {
            // Read the data from the file
            let data = try Data(contentsOf: url)
            // Decode the JSON into the SongResponse model
            let decoder = JSONDecoder()
            return try decoder.decode(SongResponse.self, from: data)
        } catch {
            throw error
        }
    }
    
    func resume() {
        // wait some time and then set the state to cached success
        self._loadingCallback?(songLink, self)
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
            do {
                let response = try MockSongLinkRequest.mockSong()!
                loadSong(request: self, response: response) { song, error in
                    guard let song else {
                        self._failureCallback?(error ?? URLError(.badServerResponse), self)
                        return
                    }
                    self._successCallback?(song, self)
                }
            } catch {
               self._failureCallback?(error, self)
            }
        }
    }
    
    func cancel() {
        // no op
    }
    
    func onLoading(_ callback: @escaping (URL, SongLinkRequest) -> Void) -> any SongLinkRequest {
        _loadingCallback = callback
        return self
    }
    
    func onSuccess(_ callback: @escaping (Song, SongLinkRequest) -> Void) -> any SongLinkRequest {
        _successCallback = callback
        return self
    }
    
    func onFailure(_ callback: @escaping (Error, SongLinkRequest) -> Void) -> any SongLinkRequest {
        _failureCallback = callback
        return self
    }
}

struct DefaultSongLinkRequestFactory: SongLinkRequestFactory {
    static func build(songLink: URL) -> any SongLinkRequest {
        DefaultSongLinkRequest(songLink)
    }
}

class DefaultSongLinkRequest: SongLinkRequest {
    private var _loadingCallback: ((URL, SongLinkRequest) -> Void)?
    private var _successCallback: ((Song, SongLinkRequest) -> Void)?
    private var _failureCallback: ((Error, SongLinkRequest) -> Void)?
    private var _task: URLSessionDataTask?
    private let _session: URLSession
    private let _cache: URLCache
    internal let songLink: URL
    
    init(_ songLink: URL) {
        // Configure URLCache with disk persistence
        _cache = URLCache(memoryCapacity: 10 * 1024 * 1024, // 10 MB in memory
                             diskCapacity: 50 * 1024 * 1024,  // 50 MB on disk
                             diskPath: "urlCache")

        let config = URLSessionConfiguration.default
        config.urlCache = _cache
        config.requestCachePolicy = .returnCacheDataElseLoad
        _session = URLSession(configuration: config)
        self.songLink = songLink
    }
    
    // Fetch JSON data using URLSessionDataTask
    private func _fetchData(fetchURL: URL, maxCacheAge: TimeInterval = 3600, completion: @escaping (Result<Song, Error>) -> Void) -> URLSessionDataTask {
        let request = URLRequest(url: fetchURL)
        let cache = _cache
        
        // Clear if cached for too long (default 1 hour)
        if let cachedResponse = cache.cachedResponse(for: request) {
            if let cachedDate = cachedResponse.userInfo?["bounce-cached-date"] as? Date {
                let expirationDate = cachedDate.addingTimeInterval(maxCacheAge)
                if Date() > expirationDate {
                    // Cache is expired
                    URLCache.shared.removeCachedResponse(for: request)
                }
            } else {
                URLCache.shared.removeCachedResponse(for: request)
            }
        }
        
        let handle: (Data?, URLResponse?, Error?) -> Void = { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data, let response = response as? HTTPURLResponse else {
                completion(.failure(URLError(.badServerResponse)))
                return
            }

            // Update the last fetch date
            let decoder = JSONDecoder()
            do {
                let songResponse = try decoder.decode(SongResponse.self, from: data)
                // Cache the response with a custom timestamp
                let cachedResponse = CachedURLResponse(response: response, data: data, userInfo: ["bounce-cached-date": Date()], storagePolicy: .allowed)
                cache.storeCachedResponse(cachedResponse, for: request)
                loadSong(request: self, response: songResponse) { song, error in
                    guard let song else {
                        completion(.failure(error ?? URLError(.badServerResponse)))
                        return
                    }
                    completion(.success(song))
                }
            } catch {
                completion(.failure(error))
            }
        }
        let task = _session.dataTask(with: request, completionHandler: handle)
        return task
    }
    
    func resume() {
        _loadingCallback?(songLink, self)
        let encodedSongLink = songLink.absoluteString.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
        let url = URL(string: "https://api.song.link/v1-alpha.1/links?url=\(encodedSongLink)&userCountry=US&songIfSingle=true")
        let req = self
        DispatchQueue.global().async { [weak self] in
            guard let self = self else {
                // Self was deallocated before background task completed
                return
            }
            self._task = _fetchData(fetchURL: url!) { [weak self] result in
                guard let self = self else {
                    // Self was deallocated before background task completed
                    return
                }
                DispatchQueue.main.async { [weak self] in
                    switch result {
                    case .success(let Song):
                        self?._successCallback?(Song, req)
                    case .failure(let error):
                        self?._failureCallback?(error, req)
                    }
                }
                self._task = nil
            }
            self._task?.resume()
        }
    }
    
    func cancel() {
        _task?.cancel()
    }
    
    func onLoading(_ callback: @escaping (URL, SongLinkRequest) -> Void) -> any SongLinkRequest {
        _loadingCallback = callback
        return self
    }
    
    func onSuccess(_ callback: @escaping (Song, SongLinkRequest) -> Void) -> any SongLinkRequest {
        _successCallback = callback
        return self
    }
    
    func onFailure(_ callback: @escaping (Error, SongLinkRequest) -> Void) -> any SongLinkRequest {
        _failureCallback = callback
        return self
    }
}
