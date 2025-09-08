//
//  MapBoard.swift
//  Navio
//
//  Created by 김민우 on 9/8/25.
//
import Foundation
import Combine
import ToolBox


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
    
    @Published public private(set) var currentLocation: Location? = nil
    @Published public private(set) var isUpdatingLocation: Bool = false
    private func setLocation(_ newLocation: Location?) {
        self.currentLocation = newLocation
    }
    
    public var searchInput: String = ""
    
    public internal(set) var likedSpots: [LikedSpot.ID] = []
    public internal(set) var recentSpots: [RecentSpot.ID] = []
    public internal(set) var findSpots: [FindSpot.ID] = []
    
    
    // action
    public func updateLocationOnce() async {
        // capture
        
        
        // compute
        await LocationManager.shared.getUserAuthentication()
        
        await LocationManager.shared.fetchMyLocation()
        
        let currentLocation = await LocationManager.shared.location
        
        
        // mutate
        self.currentLocation = currentLocation
    }
    
    public func startUpdating() async {
        // capture
        guard self.isUpdatingLocation == false else {
            print("위치가 현재 업데이트 중입니다.")
            return
        }
        let navio = self.id
        
        // compute
        await LocationManager.shared.addHandler { newLocation in
            Task {
                await navio.ref?.setLocation(newLocation)
            }
        }
        
        await LocationManager.shared.startStreaming()
        
        // mutate
        self.isUpdatingLocation = true
    }
    public func stopUpdating() async {
        // compute
        await LocationManager.shared.stopStreaming()
    }
    
    public func loadLikedSpots() async { }
    public func loadRecentSpots() async { }
    public func fetchFindSpots() async {
        // capture
        
        // compute
        
        // mutate
    }
    
    
    
    
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
