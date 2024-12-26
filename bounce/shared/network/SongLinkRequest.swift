//  Created by Rohan Thomare on 12/24/24.

import UIKit

protocol SongLinkRequest {
    func onLoading(_ callback: @escaping (URL, any SongLinkRequest) -> Void) -> any SongLinkRequest
    func onSuccess(_ callback: @escaping (SongModel, any SongLinkRequest) -> Void) -> any SongLinkRequest
    func onFailure(_ callback: @escaping (Error, any SongLinkRequest) -> Void) -> any SongLinkRequest
    func resume()
    func cancel()
}

protocol SongLinkRequestFactory {
    static func build(songLink: URL) -> any SongLinkRequest
}

func loadImage(urlString: String, completion: @escaping (UIImage?) -> Void) {
    guard let url = URL(string: urlString) else {
            completion(nil) // Invalid URL
            return
        }
        
        // Download the image
        URLSession.shared.dataTask(with: url) { data, _, _ in
            guard let data = data, let image = UIImage(data: data) else {
                completion(nil) // Image download failed
                return
            }
            completion(image)
        }.resume()
}

struct MockSongLinkRequestFactory: SongLinkRequestFactory {
    static func build(songLink: URL) -> any SongLinkRequest {
        MockSongLinkRequest(songLink)
    }
}

class MockSongLinkRequest: SongLinkRequest {
    private var _loadingCallback: ((URL, SongLinkRequest) -> Void)?
    private var _successCallback: ((SongModel, SongLinkRequest) -> Void)?
    private var _failureCallback: ((Error, SongLinkRequest) -> Void)?
    let _songLink: URL
    
    init(_ songLink: URL) {
        _songLink = songLink
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
        self._loadingCallback?(_songLink, self)
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(5)) {
            do {
                let response = try MockSongLinkRequest.mockSong()!
                let entity = response.entitiesByUniqueId[response.entityUniqueId]!
                
                // Get image from thumnail url
                loadImage(urlString: entity.thumbnailUrl) { image in
                    let song = SongModel(
                        title: entity.title,
                        artistName: entity.artistName,
                        thumbnail: image,
                        thumbnailUrl: entity.thumbnailUrl,
                        thumbnailWidth: entity.thumbnailWidth,
                        thumbnailHeight: entity.thumbnailHeight,
                        platform: entity.platforms[0],
                        rawData: response
                    )
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
    
    func onSuccess(_ callback: @escaping (SongModel, SongLinkRequest) -> Void) -> any SongLinkRequest {
        _successCallback = callback
        return self
    }
    
    func onFailure(_ callback: @escaping (Error, SongLinkRequest) -> Void) -> any SongLinkRequest {
        _failureCallback = callback
        return self
    }
}

//class SongLinkRequest: SongLinkRequestProtocol {
//    @Published var state: SongLinkRequestState = .idle
//    private let _dataTask: URLSessionDataTask
//    init (songLink: URL) {
//        // Example of setting the URL in a URLRequest
//        let escapedString: String = songLink.absoluteString.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
//        if let apiURL = URL(string:"https://api.song.link/v1-alpha.1/links?url=\(escapedString)&userCountry=US&songIfSingle=true") {
//            var request = URLRequest(url: apiURL)
//            request.httpMethod = "GET"
//            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//            
//            // URLSession configuration
//            let config = URLSessionConfiguration.default
//            let session = URLSession(configuration: config)
//            
//            // Create the task to fetch the data
//            let task = session.dataTask(with: request) { (data, response, error) in
//                    //Process the data
//                    //...
//            }
//            
//            return task
//        }
//    }
//    
//    func cancel() {
//        _dataTask.cancel()
//    }
//    
//    func resume() {
//        _dataTask.resume()
//    }
//}
