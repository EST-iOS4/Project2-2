//
//  FindSpot.swift
//  Navio
//
//  Created by 김민우 on 9/8/25.
//
import Foundation
import Combine


// MARK: Object
@MainActor
public final class FindSpot: Sendable, ObservableObject {
    // core
    internal init(owner: MapBoard.ID) {
        self.owner = owner
        
        FindSpotManager.register(self)
    }
    internal func delete() {
        FindSpotManager.unregister(self.id)
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
            FindSpotManager.container[self] != nil
        }
        public var ref: FindSpot? {
            FindSpotManager.container[self]
        }
    }
}


// MARK: ObjectManager
@MainActor
fileprivate final class FindSpotManager: Sendable {
    // core
    static var container: [FindSpot.ID: FindSpot] = [:]
    static func register(_ object: FindSpot) {
        container[object.id] = object
    }
    static func unregister(_ id: FindSpot.ID) {
        container[id] = nil
    }
}

