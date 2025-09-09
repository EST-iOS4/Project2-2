//
//  HomeBoard.swift
//  Navio
//
//  Created by 김민우 on 9/8/25.
//
import Foundation
import Combine
import ToolBox


// MARK: Object
@MainActor
public final class HomeBoard: Sendable, ObservableObject {
    // MARK: core
    internal init(owner: Navio.ID) {
        self.owner = owner
        
        HomeBoardManager.register(self)
    }
    internal func delete() {
        HomeBoardManager.unregister(self.id)
    }
    
    
    // MARK: state
    public nonisolated let id = ID()
    internal nonisolated let owner: Navio.ID
    
    public internal(set) var spots: [Spot.ID] = []
    
    
    // MARK: action
    public func fetchSpots() async {
        // capture
        guard spots.isEmpty else {
            print(#file, #function, #line, "already fetched")
            return
        }
        
        // compute
        let spots = LocalDB.builtInSpots
            .map { spotData in
                let newSpotRef = Spot(owner: self.id,
                                      name: spotData.name,
                                      imageName: spotData.imageName)
                return newSpotRef.id
            }
        
        // mutate
        self.spots = spots
    }
    
    
    // MARK: value
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
