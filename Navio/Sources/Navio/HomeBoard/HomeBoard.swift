//
//  HomeBoard.swift
//  Navio
//
//  Created by 김민우 on 9/8/25.
//
import Foundation
import Combine
import ToolBox

private let logger = NavioLogger("HomeBoard")


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
    internal nonisolated let id = ID()
    internal nonisolated let owner: Navio.ID
    
    @Published public internal(set) var spots: [Spot] = []
    
    
    // MARK: action
    public func setUpSpots() async {
        logger.start()
        
        // capture
        guard spots.isEmpty else {
            logger.failure("이미 Spot들이 존재합니다.")
            return
        }
        
        // compute
        let localSpots = await LocalDataManager.shared.spots
        
        // mutate
        let spots = localSpots
            .map { Spot(owner: self.id, data: $0) }
        self.spots = Self.sampleSpots
            .map { Spot(owner: self, data: $0)}
    }
    
    
    // MARK: value
    @MainActor
    public struct ID: Sendable, Hashable {
        public let rawValue = UUID()
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
    // MARK: core
    static var container: [HomeBoard.ID: HomeBoard] = [:]
    static func register(_ object: HomeBoard) {
        container[object.id] = object
    }
    static func unregister(_ id: HomeBoard.ID) {
        container[id] = nil
    }
}
