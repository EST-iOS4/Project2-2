//
//  RecentSpot.swift
//  Navio
//
//  Created by 김민우 on 9/8/25.
//
import Foundation
import Combine


// MARK: Object
@MainActor
public final class RecentSpot: Sendable, ObservableObject {
    // core
    internal init(owner: MapBoard.ID) {
        self.owner = owner
        
        RecentSpotManager.register(self)
    }
    internal func delete() {
        RecentSpotManager.unregister(self.id)
    }
    
    
    // state
    public nonisolated let id = ID()
    internal nonisolated let owner: MapBoard.ID
    
    
    // action
    
    
    // value
    @MainActor
    public struct ID: Sendable, Hashable {
        public let value = UUID()
        nonisolated init() { }
        
        public var isExist: Bool {
            RecentSpotManager.container[self] != nil
        }
        public var ref: RecentSpot? {
            RecentSpotManager.container[self]
        }
    }
}


// MARK: ObjectManager
@MainActor
fileprivate final class RecentSpotManager: Sendable {
    // core
    static var container: [RecentSpot.ID: RecentSpot] = [:]
    static func register(_ object: RecentSpot) {
        container[object.id] = object
    }
    static func unregister(_ id: RecentSpot.ID) {
        container[id] = nil
    }
}
