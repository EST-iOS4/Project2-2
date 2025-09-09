//
//  ContentView.swift
//  ToolBoxTester
//
//  Created by 김민우 on 9/8/25.
//

import SwiftUI
import ToolBox

struct LocationManagerView: View {
    @State var location: Location? = nil
    
    var body: some View {
        VStack {
            if let location {
                VStack {
                    Text("\(location.latitude)")
                    Text("\(location.longitude)")
                }
            } else {
                Text("Location이 비어있습니다.")
            }
            
            Button("위치 가져오기") {
                Task {
                    await LocationManager.shared.getUserAuthentication()
                    
                    await LocationManager.shared.fetchMyLocation()
                    
                    if let newLocation = await LocationManager.shared.location {
                        self.location = newLocation
                    } else {
                        print("새로운 Location이 업데이트되지 않았습니다.")
                    }
                }
            }
        }
        .font(.largeTitle)
        .padding()
    }
}

#Preview {
    LocationManagerView()
}
