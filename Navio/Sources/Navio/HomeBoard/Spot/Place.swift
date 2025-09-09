//
//  Place.swift
//  Navio
//
//  Created by 김민우 on 9/8/25.
//
import Foundation
import Combine
import UIKit
import ToolBox


// MARK: Object
@MainActor
public final class Place: Sendable, ObservableObject {
    // MARK: core
    internal init(owner: Spot.ID, name: String, imageName: String, address: String, number: String, location: Location) {
        self.owner = owner
        self.name = name
        self.imageName = imageName
        self.address = address
        self.number = number
        self.location = location
        
        PlaceManager.register(self)
    }
    
    
    // MARK: state
    public nonisolated let id = ID()
    internal nonisolated let owner: Spot.ID
    
    public internal(set) var name: String
    public internal(set) var imageName: String
    
    public internal(set) var address: String
    public internal(set) var number: String
    public internal(set) var location: Location
    public internal(set) var like: Bool = false
    
    
    // MARK: action
    public func toggleLike() {
        // 변경된 like를 UserDefaults에 저장
        
        // 어떤 상태 변화?
        // false -> true
        // true -> false
    }
    
    
    // MARK: value
    @MainActor
    public struct ID: Sendable, Hashable {
        public let value = UUID()
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
