//  Created by Rohan Thomare on 12/23/24.

import SwiftUI

struct ErrorView: View {
    var error: Error
    
    var body: some View {
        Text("error")
            .font(.title)
            .foregroundColor(Color.primary)
            .fontWeight(.thin)
    }
}
#Preview {
    ErrorView(error: URLError(.badURL))
}
