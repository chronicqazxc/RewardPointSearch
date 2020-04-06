//
//  ContentView.swift
//  RewardPointSearch
//
//  Created by Wayne Hsiao on 2020/4/5.
//  Copyright © 2020 Wayne Hsiao. All rights reserved.
//

import SwiftUI
import Combine

struct ContentView: View {
    @ObservedObject var viewModel: ContentViewModel
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20.0) {
                Text(viewModel.subtitle)
                    .font(.subheadline)
                    .foregroundColor(Color(UIColor.systemGray))
                HStack {
                    Text(viewModel.usernameLabelText)
                        .bold()
                    Divider()
                        .fixedSize()
                    TextField(viewModel.usernamePlaceholder, text: $viewModel.username)
                }
                Spacer()
                Text("\(viewModel.display)")
                    .font(.title)
                ForEach(1 ... 5, id: \.self) { _ in
                    Group {
                        Spacer()
                    }
                }
            }
            .padding()
            .navigationBarTitle(viewModel.title)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(viewModel: ContentViewModel(service: MockService()))
    }
}
