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
        
    @Published public internal(set) var likePlaces: [LikePlace.ID] = []
    @Published public internal(set) var recentPlaces: [RecentPlace.ID] = []
    
    @Published public var searchInput: String = ""
    @Published public internal(set) var searchPlaces: [SearchPlace.ID] = []
    
    
    // action
    public func updateLocation() async {
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
    
    public func fetchLikePlaces() async {
        // capture
        let boardRef = self.id
        let oldIDs = self.likePlaces
        
        // compute
        let userDefaultBoxKey = "LIKED_PLACES"
        let userDefaultIDsKey = "MAPBOARD_LIKEPLACE_IDS"
        let ud = UserDefaults.standard
        
        let box = (ud.dictionary(forKey: userDefaultBoxKey) as? [String: [String: String]]) ?? [:]
        let orderedNames = (ud.array(forKey: userDefaultIDsKey) as? [String]) ?? box.keys.sorted()
        
        // mutate
        for id in oldIDs {
            guard let nm = id.ref?.name else { continue }
            if orderedNames.contains(nm) == false {
                id.ref?.delete()
            }
        }
        
        self.likePlaces = []
        
        for name in orderedNames {
            guard let rec = box[name] else { continue }
            let imageName = rec["imageName"] ?? ""
            let address = rec["address"] ?? ""
            
            if let exist = oldIDs.first(where: { $0.ref?.name == name }) {
                self.likePlaces.append(exist)
                continue
            }
            
            let data = PlaceData(
                name: name,
                imageName: imageName,
                location: .init(latitude: 0, longitude: 0),
                address:address, number: ""
            )
            let likeRef = LikePlace(owner: boardRef, data: data)
            self.likePlaces.append(likeRef.id)
        }
    }
    
    public func fetchRecentPlaces() async {
        
        // mutate
        self.recentPlaces = []
    }
    public func fetchSearchPlaces() async {
        // capture
        
        // compute
        
        // mutate
        fatalError()
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
