//  Created by Rohan Thomare on 12/23/24.

import SwiftUI

struct ReceieveLoadedView: View {
    @ObservedObject var controller: ReceiveController
    
    let song: Song
    
    var body: some View {
        GeometryReader { geometry in
            let expanded = geometry.size.height > 400
            VStack(spacing:0) {
                if (expanded) { Spacer () }
                SongEntityView(song: song)
                Text("choose your platform")
                    .foregroundColor(.secondary)
                    .font(expanded ? .title3 : .callout)
                    .padding(2)
                PlatformTray(song: song, expanded: expanded)
                if (expanded) { Spacer () }
            }.frame(maxWidth: .infinity)
        }
    }
}

struct PreviewReceiveLoaded: View {
    @State var song: Song? = nil
    @State var isLoading = true
    @State var speed = 1.5
    @State var request = MockSongLinkRequestFactory.build(songLink: URL(filePath: "spotify:track:0Jcij1eWd5bDMU5iPbxe2i")!)
    let controller = ReceiveController(MockSongLinkRequestFactory.self)
    
    var body: some View {
        if let song {
            ReceieveLoadedView(controller: controller, song: song).padding()
        } else {
            LoaderView(isLoading: isLoading, speed: speed).onAppear {
                request = request.onSuccess { mockedSong, _ in
                    isLoading = false
                    song = mockedSong
                }
                request.resume()
            }
        }
    }
}

#Preview {
    let expanded: Bool = true
    let createController = CreateController(MockSongLinkRequestFactory.self)
    let receiveController = ReceiveController(MockSongLinkRequestFactory.self)
    let appController = AppController(
        createController: createController,
        receiveController: receiveController)
    VStack(alignment: .center) {
        Text(expanded ? "Previewing expanded mode" : "Previewing collapsed mode").background(expanded ? Color.red : Color.blue).frame(maxWidth: .infinity, maxHeight: 25)
        Spacer()
        BounceApp(appController)
    }.onAppear {
        let song = SongAbridged(title: "", artistName: "", thumbnailUrl: URL(string: "https://example.com")!, requestPlatform: PlatformIdentifier.appleMusic, requestSongUrl: URL(string: "https://example.com")!)
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            appController.handle(action: .recievingSong(song: song))
        }
    }.frame(maxHeight: expanded ? 800 : 300)
}
