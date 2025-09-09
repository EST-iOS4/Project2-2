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
    internal init(owner: Spot.ID, data: PlaceData) {
        self.owner = owner
        self.name = data.name
        self.imageName = data.imageName
        self.address = data.address
        self.number = data.number
        self.location = data.location
        
        PlaceManager.register(self)
    }
    
    
    // MARK: state
    public nonisolated let id = ID()
    internal nonisolated let owner: Spot.ID
    
    public internal(set) var name: String
    public internal(set) var imageName: String
    public var image: UIImage {
        let imageURL = Bundle.module.url(
            forResource: imageName,
            withExtension: "png")!
        let data = try? Data(contentsOf: imageURL)
        let uiImage = UIImage(data: data!)
        return uiImage!
    }
    
    public internal(set) var address: String
    public internal(set) var number: String
    public internal(set) var location: Location
    public internal(set) var like: Bool = false
    
    
    // MARK: action
    public func toggleLike() {
        // capture
        let spotRef = self.owner.ref!
        let homeboardRef = spotRef.owner.ref!
        let navioRef = homeboardRef.owner.ref!
        let mapBoardRef = navioRef.mapBoard!.ref!

        let isChangedToLike = self.like == false

        // compute
        //
        let userDefaultBoxKey = "LIKED_PLACES"
        let userDefaultIDsKey = "MAPBOARD_LIKEPLACE_IDS"
        let ud = UserDefaults.standard
        var box = (ud.dictionary(forKey: userDefaultBoxKey) as? [String: [String: String]]) ?? [:]
        var ids = (ud.array(forKey: userDefaultIDsKey) as? [String]) ?? []
        let placeKey = self.name // 이름 유일 전제

        // 저장소에 기록할 데이터(필요 필드만)
        let placeData = PlaceData(
            name: self.name,
            imageName: self.imageName,
            location: self.location,
            address: self.address,
            number: self.number
        )

        // mutate
        if isChangedToLike {
            // 인스턴스 생성
            let newLikePlaceRef = LikePlace(owner: mapBoardRef.id, data: placeData)
            mapBoardRef.likePlaces.append(newLikePlaceRef.id)

            // UserDefaults 추가
            box[placeKey] = [
                "name": self.name,
                "imageName": self.imageName,
                "address": self.address
            ]
            if ids.contains(placeKey) == false { ids.append(placeKey) }
            ud.set(box, forKey: userDefaultBoxKey)
            ud.set(ids, forKey: userDefaultIDsKey)
        } else {
            // 인스턴스 삭제
            mapBoardRef.likePlaces
                .first { $0.ref?.name == self.name }?
                .ref?.delete()

            // 배열에서 ID 제거
            mapBoardRef.likePlaces.removeAll { likePlace in
                likePlace.ref?.name == self.name
            }

            // UserDefaults 제거
            box[placeKey] = nil
            ids.removeAll { $0 == placeKey }
            if box.isEmpty { ud.removeObject(forKey: userDefaultBoxKey) } else { ud.set(box, forKey: userDefaultBoxKey) }
            if ids.isEmpty { ud.removeObject(forKey: userDefaultIDsKey) } else { ud.set(ids, forKey: userDefaultIDsKey) }
        }

        self.like.toggle()
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
