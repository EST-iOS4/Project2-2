//
//  Place.swift
//  Navio
//
//  Created by 김민우 on 9/4/25.
//
import Foundation
import Combine


// MARK: Object
// Place: 역전할머니맥주, CU 잠실점 등 명확한 위치
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
    
    
    // action
    
    
    
    // value
    @MainActor
    public struct ID: Sendable, Hashable {
        // core
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
