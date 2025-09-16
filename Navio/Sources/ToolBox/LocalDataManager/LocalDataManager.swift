//
//  LocalDBManager.swift
//  Navio
//
//  Created by 김민우 on 9/16/25.
//
import Foundation
import Combine


// MARK: LoaclDBManager
@globalActor
package actor LocalDataManager: Sendable {
    // MARK: core
    public static let shared: LocalDataManager = .init()
    private init() { }
    
    
    // MARK: state
    package private(set) var spots: [Spot] = {
        let hongdae = Spot(name: "홍대", imageName: "hongdae")
        let busan = Spot(name: "부산", imageName: "busan")
        let gyeongju = Spot(name: "경주",imageName: "gyeongju")
        let jamsil = Spot(name: "잠실", imageName: "jamsil")
        
        return [hongdae, busan, gyeongju, jamsil]
    }()
    
    
    // MARK: action
    
    
    // MARK: value
    package struct Spot: Sendable, Hashable {
        // core
        package let name: String
        package let imageURL: URL
        package let places: [Place]
        
        private init (name: String, imageURL: URL, places: [Place] = []) {
            self.name = name
            self.imageURL = imageURL
            self.places = places
        }
        fileprivate init(name: String, imageName: String, places: [Place] = []) {
            self.name = name
            
            let url = Bundle.main.url(forResource: imageName, withExtension: "png")
            self.imageURL = url!
            
            self.places = places
        }
        
        // operator
        fileprivate func withPlaces(_ places: [Place]) -> Spot {
            return .init(name: name, imageURL: imageURL, places: places)
        }
    }
    
    package struct Place: Sendable, Hashable {
        // core
        package let name: String
        package let imageURL: URL
        package let location: Location
        package let address: String
        package let number: String
        
        fileprivate init(name: String, imageURL: URL, location: Location, address: String, number: String) {
            self.name = name
            self.imageURL = imageURL
            self.location = location
            self.address = address
            self.number = number
        }
    }
}



