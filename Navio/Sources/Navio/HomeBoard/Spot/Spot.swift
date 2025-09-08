//
//  HotPlace.swift
//  Navio
//
//  Created by 김민우 on 9/8/25.
//
import Foundation
import Combine


// MARK: Object
@MainActor
public final class Spot: Sendable, ObservableObject {
    // core
    internal init(owner: HomeBoard.ID) {
        self.owner = owner
        
        SpotManager.register(self)
    }
    internal func delete() {
        SpotManager.unregister(self.id)
    }
    
    
    // state
    public nonisolated let id = ID()
    internal nonisolated let owner: HomeBoard.ID
    
    public var image: URL? = nil
    
    public internal(set) var places: [Place.ID] = []
    
    
    // action
    public func fetchPlaces() {
        
    }
    
    
    // value
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
