//  Created by Rohan Thomare on 12/29/24.

import Foundation
import SwiftUICore

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
}

class AppController : ObservableObject {
    @ObservedObject var createController: CreateController
    @ObservedObject var receiveController: ReceiveController
    @Published var surface: AppSurface = .loading
    
    static func defaultFactory(onSongSelected: @escaping ((Song, SongSelectionType) -> Void), openURL: @escaping ((URL) -> Void)) -> AppController {
        return AppController(
            createController: CreateController(DefaultSongLinkRequestFactory.self, onSongSelected: onSongSelected),
            receiveController: ReceiveController(DefaultSongLinkRequestFactory.self))
    }
    
    init(createController: CreateController, receiveController: ReceiveController) {
        self.createController = createController
        self.receiveController = receiveController
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
        }
    }
}
