//  Created by Rohan Thomare on 12/23/24.

import SwiftUI

struct ReceiveView: View {
    @ObservedObject var controller: ReceiveController
    
    var animationValue: Int {
        switch controller.state {
        case .idle:
            return 1
        case .loadingSong:
            return 1
        case .songLoaded:
            return 2
        case .loadError:
            return 3
        }
    }
    
    @ViewBuilder var content: some View {
        switch controller.state {
            case .idle, .loadingSong:
                // TODO: Loader view for state to show abridged song
                LoaderView(isLoading: true, speed: 1.5)
            case .songLoaded(song: let song, request: _):
                ReceieveLoadedView(controller: controller, song: song)
            case .loadError(error: let error, request: _):
                ErrorView(requestController: controller, error: error)
        }
    }
    
    var body: some View {
        VStack(alignment: .center) {
            Spacer()
            content
                .transition(.blurReplace)
                .animation(.easeInOut(duration: 0.25), value: animationValue)
                .padding(.horizontal)
            Spacer()
            Text("bounce © 2024 powered by songlink")
                .font(.footnote)
                .foregroundColor(Color.secondary)
                .fontWeight(.light)
                .padding(.bottom, 4)
        }.onAppear {
            print(controller.state)
        }
    }
}

#Preview {
    let controller = ReceiveController(MockSongLinkRequestFactory.self)
    VStack(alignment: .center) {
        ReceiveView(controller: controller)
    }.onAppear {
        controller.loadSong(with: URL(string:"https://songlink.io/song/123456789")!)
    }
}
