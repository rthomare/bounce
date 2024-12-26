//  Created by Rohan Thomare on 12/23/24.

import SwiftUI

struct LoadingSongView: View {
    var link: URL
    @State var fetching: Bool = false
    @State var speed: Double = 1.0
    
    var body: some View {
        VStack {
            LoaderView(isLoading: $fetching, speed: $speed)
        } .onAppear {
            fetching = true
            speed = 2.0
        }
        
    }
}
#Preview {
    LoadingSongView(link: URL(string:"https://music.apple.com/us/album/hello-miss-johnson/1780429542?i=1780429748")!)
}
