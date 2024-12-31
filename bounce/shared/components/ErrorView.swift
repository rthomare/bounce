//  Created by Rohan Thomare on 12/23/24.

import SwiftUI

struct ErrorView: View {
    var requestController: RequestController
    var error: Error
    
    var body: some View {
        Text("something went wrong")
            .font(.title)
            .foregroundColor(Color.primary)
            .fontWeight(.thin)
        Button(action: {
            requestController.retry()
        }, label: {
            Text("try again?")
        })
            .font(.subheadline)
            .fontWeight(.medium)
    }
}
#Preview {
    let controller = CreateController(MockSongLinkRequestFactory.self)
    ErrorView(requestController: controller, error: URLError(.badURL))
}
