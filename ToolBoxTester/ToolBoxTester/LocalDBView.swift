//
//  LocalDBView.swift
//  ToolBoxTester
//
//  Created by 김민우 on 9/8/25.
//
import Foundation
import SwiftUI
import ToolBox


// MARK: View
struct LocalDBView: View {
    @State var placeImage: UIImage? = nil
    
    var body: some View {
        VStack {
            if let placeImage {
                Image(uiImage: placeImage)
                    .resizable()
                    .scaledToFit()
            } else {
                Text("Place 이미지가 존재하지 않습니다.")
            }
        }.font(.largeTitle)
        .task {
            self.placeImage = LocalDB.SpotData.홍대.image
        }
    }
}


#Preview {
    LocalDBView()
}
