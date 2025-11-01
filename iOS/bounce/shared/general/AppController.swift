//  Created by Rohan Thomare on 12/29/24.

import Foundation
import SwiftUI

enum AppSurface {
    case loading
    case home
    case create
    case recieve(song: SongAbridged)
}

enum AppAction {
    case reset
    case startCreation(forUrl: String? = nil)
    case recievingSong(song: SongAbridged)
    case openURL(url: URL)
}

class AppController : ObservableObject {
    @ObservedObject var createController: CreateController
    @ObservedObject var receiveController: ReceiveController
    @Published var surface: AppSurface = .loading
    var openURL: ((URL) -> Void)?
    
    static func defaultFactory(onSongSelected: @escaping ((Song, SongSelectionType) -> Void), openURL: @escaping ((URL) -> Void)) -> AppController {
        let ac = AppController(
            createController: CreateController(DefaultSongLinkRequestFactory.self, onSongSelected: onSongSelected),
            receiveController: ReceiveController(DefaultSongLinkRequestFactory.self, openURL: openURL),
            openURL: openURL)
        return ac;
    }
    
    init(createController: CreateController, receiveController: ReceiveController, openURL: ((URL) -> Void)? = nil) {
        self.createController = createController
        self.receiveController = receiveController
        self.openURL = openURL
    }
    
    func handle(action: AppAction) {
        switch action {
        case .reset:
            surface = .home
        case .startCreation(forUrl: let url):
            switch self.createController.state {
            case .initializing:
                self.createController.initialize(withSongUrl: url)
                break
            case .detecting, .idle, .loadError(error: _, request: _), .loadingSong(link: _, request: _), .songLoaded(song: _, request: _):
                break //no - op
            }
            self.surface = .create
        case .recievingSong(song: let song):
            surface = .recieve(song: song)
            self.receiveController.loadSong(with: song.requestSongUrl)
        case .openURL(url: let url):
            self.openURL?(url)
        }
    }
}
