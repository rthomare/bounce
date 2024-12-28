//  Created by Rohan Thomare on 12/23/24.

import SwiftUI

struct CreateView: View {
    @ObservedObject var flowController: CreateFlowController
    
    var animationValue: Int {
        switch flowController.state {
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
        switch flowController.state {
            case .initializing, .loadingSong, .detecting:
                LoaderView(isLoading: true, speed: 1.5)
            case .idle: InitialView(flowController: flowController)
            case .songLoaded(song: let song, request: _):
                SongLoadedView(song: song, flowController: flowController)
            case .loadError(error: let error, request: _):
                ErrorView(flowController: flowController, error: error)
        }
    }
    
    var body: some View {
        VStack {
            Spacer()
            ZStack {
                content.transition(.blurReplace)
            }
            .animation(.easeInOut(duration: 0.25), value: animationValue).padding(.horizontal)
            Spacer()
            Text("bounce © 2024 powered by songlink")
                .font(.footnote)
                .foregroundColor(Color.secondary)
                .fontWeight(.light)
                .padding(.bottom, 4)
        }.onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                flowController.initialize()
            }
        }
    }
}

#Preview {
    let flowController = CreateFlowController(MockSongLinkRequestFactory.self)
    VStack(alignment: .center) {
        CreateView(flowController:flowController)
    }
}
