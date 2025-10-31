//  Created by Rohan Thomare on 12/30/24.

import SwiftUI

struct BounceApp: View {
    @ObservedObject var appController: AppController
    @ObservedObject var createController: CreateController
    @ObservedObject var receiveController: ReceiveController
    
    init(_ _appController: AppController) {
        appController = _appController
        createController = _appController.createController
        receiveController = _appController.receiveController
    }
    
    var showLoading: Bool {
        switch appController.surface {
            case .loading: return true
            case .create:
                switch createController.state {
                    case .initializing: return true
                    case .detecting, .idle, .loadError(error: _, request: _), .loadingSong(link: _, request: _), .songLoaded(song: _, request: _):
                    return false
                }
            case .recieve(song: _):
                switch receiveController.state {
                case .idle:
                    return true
                case .loadingSong(link: _, request: _):
                    return true
                case .songLoaded(song: _, request: _):
                    return false
                case .loadError(error: _, request: _):
                    return false
                }
            case .home: return false
        }
    }

    var animationValue: Int {
        switch appController.surface {
            case .loading: 0
            case .home: 1
            case .create: 2
            case .recieve(song: _): 3
        }
    }
    
    @ViewBuilder var content: some View {
        if showLoading {
            LoaderView(isLoading: true, speed: 1.5)
        } else {
            switch appController.surface {
                case .loading:
                    LoaderView(isLoading: true, speed: 1.5)
                case .recieve(song: _):
                    ReceiveView(controller: appController.receiveController)
                case .create, .home:
                    CreateView(controller: appController.createController)
            }
        }
    }
    
    var body: some View {
        VStack {
            content
                .transition(.blurReplace)
                .animation(.easeInOut(duration: 0.25), value: animationValue).padding(.horizontal)
        }
    }
}

#Preview {
    PreviewBounce()
}
