//  Created by Rohan Thomare on 12/23/24.

import SwiftUI

struct CreateView: View {
    private let songModelGenerated: ((SongModel) -> Void)?
    @StateObject private var flowController: CreateFlowController
    
    init(requestBuilder: SongLinkRequestFactory.Type, onSongModelGenerated: ((SongModel) -> Void)? = nil) {
        _flowController = StateObject(wrappedValue: CreateFlowController(requestBuilder))
        songModelGenerated = onSongModelGenerated
    }
    
    @ViewBuilder var content: some View {
        switch _flowController.wrappedValue.state {
            case .initial: InitialView()
            case .loadingSong(link: let link, request: _):  LoadingSongView(link: link)
        case .songLoaded(song: let song, request: _):  SongLoadedView(song: song ).onTapGesture {apGesture in
            if let songModelGenerated {
                songModelGenerated(song)
                _flowController.wrappedValue.reset()
            }
        }
        case .loadError(error: let error, request: _):  ErrorView(error: error).onTapGesture {apGesture in
            _flowController.wrappedValue.reset()
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
        }
    }
}

#Preview {
    VStack(alignment: .center) {
        CreateView(requestBuilder: MockSongLinkRequestFactory.self)
    }
}
