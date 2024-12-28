//  Created by Rohan Thomare on 12/23/24.

import SwiftUI

struct CreateView: View {
    @ObservedObject var flowController: CreateFlowController
    var songGenerated: ((Song) -> Void)? = nil
    
    @ViewBuilder var content: some View {
        switch flowController.state {
            case .initializing, .loadingSong:
                    LoaderView(isLoading: true, speed: 1.5)
        case .idle: InitialView(flowController: flowController)
            case .songLoaded(song: let song, request: _):  SongLoadedView(song: song ).onTapGesture {_ in
                if let songGenerated {
                    songGenerated(song)
                    flowController.reset()
                }
            }
        case .loadError(error: let error, request: _):  ErrorView(flowController: flowController, error: error).onTapGesture {apGesture in
                flowController.reset()
            }
        }
    }
    
    var body: some View {
        VStack {
            Spacer()
            content.padding(.horizontal)
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
