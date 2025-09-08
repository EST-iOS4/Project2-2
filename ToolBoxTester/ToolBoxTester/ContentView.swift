//
//  ContentView.swift
//  ToolBoxTester
//
//  Created by 김민우 on 9/8/25.
//

import SwiftUI
import ToolBox

struct ContentView: View {
    
    @State var location: Location? = nil
    
    
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
