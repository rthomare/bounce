//  Created by Rohan Thomare on 12/23/24.

import SwiftUI

struct CreateView: View {
    @ObservedObject var controller: CreateController
    
    var animationValue: Int {
        switch controller.state {
        case .initializing, .loadingSong, .detecting:
            return 1
        case .idle:
            return 2
        case .songLoaded(song: _, request: _):
            return 3
        case .loadError(error: _, request: _):
            return 4
        }
    }
    
    @ViewBuilder var content: some View {
        switch controller.state {
            case .initializing, .loadingSong, .detecting:
                LoaderView(isLoading: true, speed: 1.5)
            case .idle: InitialView(controller: controller)
            case .songLoaded(song: let song, request: _):
                CreateSongLoadedView(song: song, controller: controller)
            case .loadError(error: let error, request: _):
                ErrorView(requestController: controller, error: error)
        }
    }
    
    var body: some View {
        VStack {
            Spacer()
            ZStack {
                content.transition(.blurReplace)
                        .animation(.easeInOut(duration: 0.25), value: animationValue)
            }
            .padding(.horizontal)
            Spacer()
            Text("bounce © 2024 powered by songlink")
                .font(.footnote)
                .foregroundColor(Color.secondary)
                .fontWeight(.light)
                .padding(.bottom, 4)
        }
    }
}

#Preview {
    let controller = CreateController(MockSongLinkRequestFactory.self)
    VStack(alignment: .center) {
        CreateView(controller:controller)
    }.onAppear {
        controller.initialize()
    }
}
