//  Created by Rohan Thomare on 12/23/24.

import SwiftUI

struct ErrorView: View {
    var flowController: CreateFlowController
    var error: Error
    
    var body: some View {
        Text("something went wrong")
            .font(.title)
            .foregroundColor(Color.primary)
            .fontWeight(.thin)
        Button(action: {
            flowController.retry()
        }, label: {
            Text("try again?")
        })
            .font(.subheadline)
            .fontWeight(.medium)
    }
}
#Preview {
    let flowController = CreateFlowController(MockSongLinkRequestFactory.self)

    ErrorView(flowController: flowController, error: URLError(.badURL))
}
