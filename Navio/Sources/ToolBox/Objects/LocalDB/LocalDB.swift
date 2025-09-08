//
//  LocalDB.swift
//  Navio
//
//  Created by 김민우 on 9/8/25.
//
import Foundation
import CoreData
import UIKit


// LocalDB에서는 Spot, Place
// MARK: Object
@globalActor
public actor LocalDB: Sendable {
    // MARK: core
    public static let shared: LocalDB = .init()
    private init() { }
    
    
    // MARK: state
    
    
    // MARK: action
    
    
    // MARK: value
    public struct SearchKeyword: Sendable, Hashable {
        public let rawValue: String
        public init(_ rawValue: String) {
            self.rawValue = rawValue
        }
    }
    
    
    public struct SpotData: Sendable, Hashable {
        // core
        public let name: String
        public let imageName: String
        public let places: [PlaceData]
        
        private init(name: String,
                     imageName: String,
                     places: [PlaceData]) {
            self.name = name
            self.imageName = imageName
            self.places = places
        }
        
        public static let 홍대: SpotData = .init(
            name: "홍대",
            imageName: "hongdae",
            places: [
                .init(name: "큐브이스케이프", imageName: "cube_escape_hongdae"),
                .init(name: "아이뮤지엄", imageName: "eyemuseum_hongdae")
            ]
        )
        public static let 부산: SpotData = .init(
            name: "부산",
            imageName: "busan",
            places: [
                .init(name: "감천", imageName: "gamcheon_busan")
            ]
        )
        public static let 경주: SpotData = .init(
            name: "경주",
            imageName: "gyeongju",
            places: [
                .init(name: "첨성대", imageName: "cheomsungdae_gyeongju"),
                .init(name: "동궁", imageName: "donggung_gyeongju")
                
            ]
        )
        public static let 잠실: SpotData = .init(
            name: "잠실",
            imageName: "jamsil",
            places: [
                
            ]
        )
        
        // operator
        public var image: UIImage {
            let imageURL = Bundle.module.url(
                forResource: imageName,
                withExtension: "png")!
            let data = try? Data(contentsOf: imageURL)
            let uiImage = UIImage(data: data!)
            return uiImage!
        }
    }
    
    public struct PlaceData: Sendable, Hashable {
        // core
        public let name: String
        public let imageName: String
        
        fileprivate init(name: String, imageName: String) {
            self.name = name
            self.imageName = imageName
        }
        
        // operator
        public var image: UIImage {
            let imageURL = Bundle.module.url(
                forResource: imageName,
                withExtension: "png")!
            let data = try? Data(contentsOf: imageURL)
            let uiImage = UIImage(data: data!)
            return uiImage!
        }
    }
}
