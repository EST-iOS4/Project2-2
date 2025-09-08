//
//  HomeBoard.swift
//  Navio
//
//  Created by 김민우 on 9/8/25.
//
import Foundation
import Combine


// MARK: Object
@MainActor
public final class HomeBoard: Sendable, ObservableObject {
    // core
    internal init(owner: Navio.ID) {
        self.owner = owner
        
        HomeBoardManager.register(self)
    }
    internal func delete() {
        HomeBoardManager.unregister(self.id)
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
            HomeBoardManager.container[self] != nil
        }
        public var ref: HomeBoard? {
            HomeBoardManager.container[self]
        }
    }
}


// MARK: ObjectManager
@MainActor
fileprivate final class HomeBoardManager: Sendable {
    // core
    static var container: [HomeBoard.ID: HomeBoard] = [:]
    static func register(_ object: HomeBoard) {
        container[object.id] = object
    }
    static func unregister(_ id: HomeBoard.ID) {
        container[id] = nil
    }
}
