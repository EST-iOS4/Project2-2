//
//  MapBoard.swift
//  Navio
//
//  Created by 김민우 on 9/8/25.
//
import Foundation
import Combine


// MARK: Object
@MainActor
public final class MapBoard: Sendable, ObservableObject {
    // core
    internal init(owner: Navio.ID) {
        self.owner = owner
        
        MapBoardManager.register(self)
    }
    internal func delete() {
        MapBoardManager.unregister(self.id)
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
            MapBoardManager.container[self] != nil
        }
        public var ref: MapBoard? {
            MapBoardManager.container[self]
        }
    }
}


// MARK: ObjectManager
@MainActor
fileprivate final class MapBoardManager: Sendable {
    // core
    static var container: [MapBoard.ID: MapBoard] = [:]
    static func register(_ object: MapBoard) {
        container[object.id] = object
    }
    static func unregister(_ id: MapBoard.ID) {
        container[id] = nil
    }
}
