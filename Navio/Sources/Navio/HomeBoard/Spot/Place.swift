//
//  Place.swift
//  Navio
//
//  Created by 김민우 on 9/8/25.
//
import Foundation
import Combine
import UIKit
import ToolBox


// MARK: Object
@MainActor
public final class Place: Sendable, ObservableObject {
    // core
    internal init(owner: Spot.ID,
                  data: LocalDB.PlaceData) {
        self.owner = owner
        self.name = data.name
        self.address = data.address
        self.number = data.number
        self.location = data.location
        self.image = data.image
    }
    
    
    // state
    public nonisolated let id = ID()
    internal nonisolated let owner: Spot.ID
    
    public internal(set) var name: String
    public internal(set) var address: String
    public internal(set) var number: String
    public internal(set) var location: Location
    public internal(set) var image: UIImage
    public internal(set) var like: Bool = false
    
    
    // action
    public func likePlace() {
        let defaults = UserDefaults.standard
        
        // 저장
        defaults.set(true, forKey: "\(name).like")
    }
    public func dislikePlace() {
        // compute
        let defaults = UserDefaults.standard
        defaults.set(false, forKey: "\(name).like")
        
        // mutate
        self.like = false
    }
    
    
    // value
    @MainActor
    public struct ID: Sendable, Hashable {
        public let value = UUID()
        nonisolated init() { }
        
        public var isExist: Bool {
            PlaceManager.container[self] != nil
        }
        public var ref: Place? {
            PlaceManager.container[self]
        }
    }
    
    public func setUpFromLocalDB() {
        
    
    }
}


// MARK: ObjectManager
@MainActor
fileprivate final class PlaceManager: Sendable {
    // core
    static var container: [Place.ID: Place] = [:]
    static func register(_ object: Place) {
        container[object.id] = object
    }
    static func unregister(_ id: Place.ID) {
        container[id] = nil
    }
}
