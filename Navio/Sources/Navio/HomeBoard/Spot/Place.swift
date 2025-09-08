//
//  Place.swift
//  Navio
//
//  Created by 김민우 on 9/8/25.
//
import Foundation
import Combine


// MARK: Object
@MainActor
public final class Place: Sendable, ObservableObject {
    // core
    internal init(owner: Spot.ID) {
        self.owner = owner
        
        PlaceManager.register(self)
    }
    internal func delete() {
        PlaceManager.unregister(self.id)
    }
    
    
    // state
    public nonisolated let id = ID()
    internal nonisolated let owner: Spot.ID
    
    public internal(set) var image: URL? = nil
    
    public internal(set) var like: Bool = false
    
    
    // action
    public func likePlace() {
        
    }
    public func dislikePlace() {
        
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



