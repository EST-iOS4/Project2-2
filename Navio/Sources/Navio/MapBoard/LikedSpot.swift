//
//  LikedSpot.swift
//  Navio
//
//  Created by 김민우 on 9/8/25.
//
import Foundation
import Combine
import ToolBox


// MARK: Object
@MainActor
public final class LikedSpot: Sendable, ObservableObject {
    // core
    internal init(owner: MapBoard.ID, name: String, location: Location, address: String) {
        self.owner = owner
        self.name = name
        self.location = location
        self.address = address
        
        LikedSpotManager.register(self)
    }
    internal func delete() {
        LikedSpotManager.unregister(self.id)
    }
    
    
    // state
    public nonisolated let id = ID()
    internal nonisolated let owner: MapBoard.ID
    
    public var name: String
    public var location: Location
    public var address: String
    
    // action
    
    
    // value
    @MainActor
    public struct ID: Sendable, Hashable {
        public let value = UUID()
        nonisolated init() { }
        
        public var isExist: Bool {
            LikedSpotManager.container[self] != nil
        }
        public var ref: LikedSpot? {
            LikedSpotManager.container[self]
        }
    }
}


// MARK: ObjectManager
@MainActor
fileprivate final class LikedSpotManager: Sendable {
    // core
    static var container: [LikedSpot.ID: LikedSpot] = [:]
    static func register(_ object: LikedSpot) {
        container[object.id] = object
    }
    static func unregister(_ id: LikedSpot.ID) {
        container[id] = nil
    }
}

