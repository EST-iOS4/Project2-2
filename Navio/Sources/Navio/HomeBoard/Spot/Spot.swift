//
//  HotPlace.swift
//  Navio
//
//  Created by 김민우 on 9/8/25.
//
import Foundation
import Combine
import ToolBox
import UIKit


// MARK: Object
@MainActor
public final class Spot: Sendable, ObservableObject {
    // MARK: core
    internal init(owner: HomeBoard.ID, name: String, image: UIImage) {
        self.owner = owner
        self.name = name
        self.image = image
        
        SpotManager.register(self)
    }
    internal func delete() {
        SpotManager.unregister(self.id)
    }
    
    
    // MARK: state
    public nonisolated let id = ID()
    internal nonisolated let owner: HomeBoard.ID
    
    public nonisolated let name: String
    public nonisolated let image: UIImage
    
    public internal(set) var places: [Place.ID] = []
    
    
    
    // MARK: action
    public func fetchPlaces() async {
        // capture
        guard places.isEmpty else {
            print(#file, #function, #line, "already fetched")
            return
        }
        
        // compute
        let places = LocalDB.builtInSpots
            .filter { $0.name == self.name }
            .flatMap { $0.places }
            .map { placeData in
                let newPlaceRef = Place(
                    owner: self.id,
                    name: placeData.name,
                    image: placeData.image,
                    address: placeData.address,
                    number: placeData.name,
                    location: placeData.location)
                
                return newPlaceRef.id
            }
        
        // mutate
        self.places = places
    }
    
    
    
    // MARK: value
    @MainActor
    public struct ID: Sendable, Hashable {
        public let value = UUID()
        nonisolated init() { }
        
        public var isExist: Bool {
            SpotManager.container[self] != nil
        }
        public var ref: Spot? {
            SpotManager.container[self]
        }
    }
}


// MARK: ObjectManager
@MainActor
fileprivate final class SpotManager: Sendable {
    // core
    static var container: [Spot.ID: Spot] = [:]
    static func register(_ object: Spot) {
        container[object.id] = object
    }
    static func unregister(_ id: Spot.ID) {
        container[id] = nil
    }
}
