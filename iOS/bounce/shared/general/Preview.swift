//  Created by Rohan Thomare on 1/1/25.

import SwiftUI

struct PreviewBounce: View {
    @State var expanded: Bool = true
    let appController = AppController(
        createController: CreateController(MockSongLinkRequestFactory.self),
        receiveController: ReceiveController(MockSongLinkRequestFactory.self))
    
    var body: some View {
        Text(expanded ? "Previewing expanded mode" : "Previewing collapsed mode")
            .background(expanded ? Color.red : Color.blue)
            .frame(maxWidth: .infinity, maxHeight: 25)
            .onTapGesture {
                expanded.toggle()
            }
        Rectangle()
            .frame(maxWidth: .infinity, maxHeight: expanded ? .zero : .infinity)
            .border(Color.black, width: 1)
            .transition(.scale)
            .animation(.easeInOut, value: expanded)
        BounceApp(appController).onAppear {
            let song = SongAbridged(title: "", artistName: "", thumbnailUrl: URL(string: "https://example.com")!, requestPlatform: PlatformIdentifier.appleMusic, requestSongUrl: URL(string: "https://example.com")!)
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                appController.handle(action: .recievingSong(song: song))
            }
        }
         .frame(maxWidth: .infinity, maxHeight: expanded ? .infinity : 300)
         .transition(.scale)
         .animation(.easeInOut, value: expanded)
    }
}

#Preview {
    PreviewBounce()
}
