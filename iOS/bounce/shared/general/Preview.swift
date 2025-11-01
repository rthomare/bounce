//  Created by Rohan Thomare on 1/1/25.

import SwiftUI

struct PreviewBounce: View {
    @State var show: Bool = true
    
    let appController = AppController(
        createController: CreateController(MockSongLinkRequestFactory.self),
        receiveController: ReceiveController(MockSongLinkRequestFactory.self, openURL: { _ in }))
    
    var body: some View {
        let content = BounceApp(appController).onAppear {
            let song = SongAbridged(title: "", artistName: "", thumbnailUrl: URL(string: "https://example.com")!, requestPlatform: PlatformIdentifier.appleMusic, requestSongUrl: URL(string: "https://example.com")!)
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                appController.handle(action: .recievingSong(song: song))
            }
        }
        
        ZStack{}.sheet(isPresented: $show , onDismiss: {}) {
            GeometryReader{ geometry in
                content.frame(maxWidth: .infinity, maxHeight: geometry.size.height)
                    .padding(EdgeInsets(top: 20, leading: 5, bottom: 10, trailing: 5))
            }.presentationDetents([.height(500), .medium, .large]) // snap points
                .presentationDragIndicator(.visible)
        }.background(Color.black)
    }
}

#Preview {
    PreviewBounce()
}
