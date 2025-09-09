//
//  HotPlace.swift
//  Navio
//
//  Created by 김민우 on 9/8/25.
//
import Foundation
import Combine
import ToolBox


// MARK: Object
@MainActor
public final class Spot: Sendable, ObservableObject {
    // core
    internal init(owner: HomeBoard.ID) {
        self.owner = owner
        self.seed = nil
        SpotManager.register(self)
    }
    public convenience init(owner: HomeBoard.ID, data: LocalDB.SpotData) {
        self.init(owner: owner)
        self.seed = data
        // seed를 기반으로 Place들을 구성
        self.setUpFromLocalDB()
    }
    internal func delete() {
        SpotManager.unregister(self.id)
    }
    
    
    // state
    public nonisolated let id = ID()
    internal nonisolated let owner: HomeBoard.ID
    
    public var image: URL? = nil
    internal var seed: LocalDB.SpotData? = nil
    
    public internal(set) var places: [Place.ID] = []
    
    
    // action
    public func setUpFromLocalDB() {
        guard let seed else {
            return
        }
        var ids: [Place.ID] = []
        for placeData in seed.places {
            // Place의 시그니처가 (owner: Spot.ID, data: LocalDB.PlaceData)라고 가정
            let place = Place(owner: self.id, data: placeData)
            ids.append(place.id)
        }
        self.places = ids
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
