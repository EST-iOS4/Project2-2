//
//  Stats.swift
//  Navio
//
//  Created by 김민우 on 9/4/25.
//
import Foundation
import Combine


// MARK: Object
@MainActor
public final class Stats: Sendable, ObservableObject {
    // core
    internal init(owner: Navio.ID) {
        self.owner = owner
        
        StatsManager.register(self)
    }
    internal func delete() {
        StatsManager.unregister(self.id)
    }
    
    
    // state
    public nonisolated let id = ID()
    internal nonisolated let owner: Navio.ID
    
    
    // action
    
    
    // value
    @MainActor
    public struct ID: Sendable, Hashable {
        public let value = UUID()
        nonisolated init() { }
        
        public var isExist: Bool {
            fatalError()
        }
        public var ref: Stats? {
            fatalError()
        }
    }
}


// MARK: ObjectManager
@MainActor
fileprivate final class StatsManager: Sendable {
    // core
    static var container: [Stats.ID: Stats] = [:]
    static func register(_ object: Stats) {
        container[object.id] = object
    }
    static func unregister(_ id: Stats.ID) {
        container[id] = nil
    }
}
