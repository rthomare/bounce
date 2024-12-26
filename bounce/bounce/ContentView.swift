//  Created by Rohan Thomare on 12/23/24.

import SwiftUI

struct ContentView: View {
    @State var text = "Ready to copy"

    var body: some View {
        VStack(alignment: .center) {
            CreateView(requestBuilder: DefaultSongLinkRequestFactory.self)
        }
    }
}

#Preview {
    CreateView(requestBuilder: MockSongLinkRequestFactory.self)
}
