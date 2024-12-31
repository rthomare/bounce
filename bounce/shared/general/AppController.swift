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
    case startCreation
    case recievingSong(song: SongAbridged)
}

class AppController : ObservableObject {
    @ObservedObject var createController: CreateController
    @ObservedObject var receiveController: ReceiveController
    @Published var surface: AppSurface = .loading
    
    init(createController: CreateController, receiveController: ReceiveController) {
        self.createController = createController
        self.receiveController = receiveController
    }
    
    func handle(action: AppAction) {
        switch action {
        case .reset:
            surface = .home
        case .startCreation:
            switch self.createController.state {
            case .initializing:
                self.createController.initialize()
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
