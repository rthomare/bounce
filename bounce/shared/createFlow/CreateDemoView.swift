//
//  CreateDemoView.swift
//  bounce
//
//  Created by Rohan Thomare on 12/25/24.
//

import SwiftUI

struct CreateDemoView: View {
    var body: some View {
        CreateView(requestBuilder: MockSongLinkRequestFactory.self)
    }
}

#Preview {
    CreateDemoView()
}
