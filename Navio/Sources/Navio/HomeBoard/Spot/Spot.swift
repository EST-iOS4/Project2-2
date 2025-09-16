//
//  HotPlace.swift
//  Navio
//
//  Created by 김민우 on 9/8/25.
//
import Foundation
import Combine
import ToolBox

private let logger = NavioLogger("Spot")


// MARK: Object
@MainActor
public final class Spot: Sendable, ObservableObject {
    // MARK: core
    internal init(owner: HomeBoard.ID, data: LocalDataManager.Spot) {
        self.owner = owner
        self.name = data.name
        self.imageURL = data.imageURL
        
        SpotManager.register(self)
    }
    internal func delete() {
        SpotManager.unregister(self.id)
    }
    
    
    // MARK: state
    internal nonisolated let id = ID()
    internal nonisolated let owner: HomeBoard.ID
    
    public nonisolated let name: String
    public nonisolated let imageURL: URL
    
    @Published public internal(set) var places: [Place] = []
    
    
    
    // MARK: action
    public func setUpPlaces() async {
        logger.start()
        
        // capture
        guard places.isEmpty else {
            logger.failure("이미 사전에 정의된 Spot(\(self.name))에 대한 장소 데이터가 있습니다.")
            return
        }
        
        // compute
        let localSpot = await LocalDataManager.shared
            .spots
            .first { $0.name == self.name }
        
        guard let localSpot else {
            logger.failure("LocalDataManager에 \(self.name) Spot이 존재하지 않습니다.")
            return
        }
        
        // mutate
        let places = localSpot.places
        
        fatalError()
    }
    
    
    // MARK: value
    @MainActor
    public struct ID: Sendable, Hashable {
        public let rawValue = UUID()
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
    // MARK: core
    static var container: [Spot.ID: Spot] = [:]
    static func register(_ object: Spot) {
        container[object.id] = object
    }
    static func unregister(_ id: Spot.ID) {
        container[id] = nil
    }
}
