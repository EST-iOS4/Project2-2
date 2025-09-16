//
//  Place.swift
//  Navio
//
//  Created by 김민우 on 9/8/25.
//
import Foundation
import Combine
import ToolBox

private let logger = NavioLogger("Place")


// MARK: Object
@MainActor
public final class Place: Sendable, ObservableObject {
    // MARK: core
    internal init(owner: Spot.ID, data: LocalDataManager.Place) {
        self.owner = owner
        
        self.name = data.name
        self.imageURL = data.imageURL
        self.address = data.address
        self.number = data.number
        self.location = data.location
        
        PlaceManager.register(self)
    }
    internal func delete() {
        PlaceManager.unregister(self.id)
    }
    
    
    // MARK: state
    internal nonisolated let id = ID()
    internal nonisolated let owner: Spot.ID
    
    private let userDefaults = UserDefaults.standard
    
    public nonisolated let name: String
    public nonisolated let imageURL: URL
    
    public nonisolated let address: String
    public nonisolated let number: String
    public nonisolated let location: Location
    
    @Published public internal(set) var isLiked = false
    @Published public private(set) var isFetchedFromDB = false
    
    
    // MARK: action
    public func fetchFromDB() {
        logger.start()

        logger.failure("미구현")
    }
    public func toggleLike() {
        logger.start(info: "current: \(self.isLiked)")

        logger.failure("미구현")
    }

    
    // MARK: value
    @MainActor
    public struct ID: Sendable, Hashable {
        public let rawValue = UUID()
        nonisolated init() { }
        
        public var isExist: Bool {
            PlaceManager.container[self] != nil
        }
        public var ref: Place? {
            PlaceManager.container[self]
        }
    }
}


// MARK: ObjectManager
@MainActor
fileprivate final class PlaceManager: Sendable {
    // MARK: core
    static var container: [Place.ID: Place] = [:]
    static func register(_ object: Place) {
        container[object.id] = object
    }
    static func unregister(_ id: Place.ID) {
        container[id] = nil
    }
}
