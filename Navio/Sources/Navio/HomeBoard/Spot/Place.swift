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

private let logger = NavioLogger("Place")


// MARK: Object
@MainActor
public final class Place: Sendable, ObservableObject {
    // MARK: core
    public init(owner: Spot, data: PlaceData) {
        self.owner = owner
        self.placeData = data
        self.name = data.name
        self.imageName = data.imageName
        self.address = data.address
        self.number = data.number
        self.location = data.location
    }
    
    
    // MARK: state
    internal nonisolated let owner: Spot
    private let userDefaults = UserDefaults.standard
    private let placeData: PlaceData
    
    public internal(set) var name: String
    public internal(set) var imageName: String
    public var image: UIImage {
        if let customImage = self.customImage {
            return customImage
        } else {
            let imageURL = Bundle.module.url(
                forResource: imageName,
                withExtension: "png")!
            let data = try? Data(contentsOf: imageURL)
            let uiImage = UIImage(data: data!)
            return uiImage!
        }
    }
    
    public var customImage: UIImage? = nil
    
    public internal(set) var address: String
    public internal(set) var number: String
    public internal(set) var location: Location
    
    @Published public internal(set) var isLiked = false
    @Published public private(set) var isFetchedFromDB = false
    
    
    // MARK: action
    public func fetchFromDB() {
        logger.start()

        // 중복 실행 방지
        guard self.isFetchedFromDB == false else {
            logger.failure("이미 DB로부터 데이터를 가져왔습니다.")
            return
        }

        let navioRef = self.owner.owner.owner
        let mapBoardRef = navioRef.mapBoard!

        // UserDefaults 저장 구조
        let userDefaultBoxKey = "LIKED_PLACES"              // 이름→필드 사전
        let userDefaultIDsKey = "MAPBOARD_LIKEPLACE_IDS"    // 표시 순서 배열
        let ud = UserDefaults.standard

        // 박스에서 현재 Place가 존재하는지로 isLiked 판단
        let box = (ud.dictionary(forKey: userDefaultBoxKey) as? [String: [String: String]]) ?? [:]
        let existsInBox = box[self.name] != nil

        if existsInBox {
            // likePlaces에 동일 이름이 없으면 추가
            if mapBoardRef.likePlaces.contains(where: { $0.name == self.name }) == false {
                let likePlaceRef = LikePlace(owner: mapBoardRef, data: self.placeData)
                mapBoardRef.likePlaces.append(likePlaceRef)
            }
            self.isLiked = true
        } else {
            // 저장된 것이 없으면 false로 간주하고 목록에서도 제거
            mapBoardRef.removeLikePlace(name: self.name)
            self.isLiked = false
        }

        // IDs 배열에 현재 항목이 존재하지만 박스에 없다면 정합성 회복(옵셔널)
        var ids = (ud.array(forKey: userDefaultIDsKey) as? [String]) ?? []
        if existsInBox {
            if ids.contains(self.name) == false {
                ids.insert(self.name, at: 0)
                ud.set(ids, forKey: userDefaultIDsKey)
            }
        } else {
            if ids.contains(self.name) {
                ids.removeAll { $0 == self.name }
                ud.set(ids, forKey: userDefaultIDsKey)
            }
        }

        self.isFetchedFromDB = true
    }
    public func toggleLike() {
        logger.start(info: "current: \(self.isLiked)")

        let navioRef = self.owner.owner.owner
        let mapBoardRef = navioRef.mapBoard!

        // 토글 후 상태
        let willLike = (self.isLiked == false)

        // UserDefaults 저장 키들(박스 + 표시순서)
        let userDefaultBoxKey = "LIKED_PLACES"
        let userDefaultIDsKey = "MAPBOARD_LIKEPLACE_IDS"
        let ud = UserDefaults.standard

        // 0) 과거 호환: 단일 불리언 키도 계속 써서 뒤로호환 유지
        ud.set(willLike, forKey: placeData.isLikedKey)

        // 1) 박스 갱신(이름 → 필드 사전)
        var box = (ud.dictionary(forKey: userDefaultBoxKey) as? [String: [String: String]]) ?? [:]
        if willLike {
            box[self.name] = [
                "imageName": self.imageName,
                "address": self.address,
                "number": self.number
            ]
        } else {
            box.removeValue(forKey: self.name)
        }
        ud.set(box, forKey: userDefaultBoxKey)

        // 2) 표시 순서 배열 갱신(MRU 스타일: 앞쪽 삽입)
        var ids = (ud.array(forKey: userDefaultIDsKey) as? [String]) ?? []
        ids.removeAll { $0 == self.name }
        if willLike { ids.insert(self.name, at: 0) }
        ud.set(ids, forKey: userDefaultIDsKey)

        // 3) in-memory likePlaces 동기화
        if willLike {
            if mapBoardRef.likePlaces.contains(where: { $0.name == self.name }) == false {
                let likePlaceRef = LikePlace(owner: mapBoardRef, data: placeData)
                likePlaceRef.customImage = self.customImage
                mapBoardRef.likePlaces.append(likePlaceRef)
            }
        } else {
            mapBoardRef.removeLikePlace(name: self.name)
        }

        // 4) 상태 변경 (Combine로 UI 반영)
        self.isLiked = willLike
    }

    
    // MARK: value
}
