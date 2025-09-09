//
//  HotPlace.swift
//  Navio
//
//  Created by 김민우 on 9/8/25.
//
import Foundation
import Combine
import ToolBox
import UIKit


// MARK: Object
@MainActor
public final class Spot: Sendable, ObservableObject {
    // MARK: core
    internal init(owner: HomeBoard.ID, name: String, image: UIImage, places: [Place.ID]) {
        self.owner = owner
        self.name = name
        self.image = image
        self.places = places
        
        SpotManager.register(self)
    }
    internal func delete() {
        SpotManager.unregister(self.id)
    }
    
    
    // MARK: state
    public nonisolated let id = ID()
    internal nonisolated let owner: HomeBoard.ID
    
    public nonisolated let name: String
    public nonisolated let image: UIImage
    
    public nonisolated let places: [Place.ID]
    
    
    // MARK: action
    
    
    
    // MARK: value
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
