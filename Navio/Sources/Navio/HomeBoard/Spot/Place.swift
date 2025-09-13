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
    internal init(owner: Spot, data: PlaceData) {
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
    
    @Published public internal(set) var isLiked = false
    @Published public private(set) var isFetchedFromDB = false
    
    
    // MARK: action
    public func fetchFromDB() {
        logger.start()

        // 이미 로드되었으면 중복 실행 방지
        guard self.isFetchedFromDB == false else {
            logger.failure("이미 DB로부터 데이터를 가져왔습니다.")
            return
        }

        let navioRef = self.owner.owner.owner
        let mapBoardRef = navioRef.mapBoard!

        // 키 존재 여부로 "미저장(false)"와 "키 없음" 구분
        let hasKey = userDefaults.object(forKey: placeData.isLikedKey) != nil
        if hasKey {
            let liked = userDefaults.bool(forKey: placeData.isLikedKey)
            if liked {
                let exists = mapBoardRef.likePlaces.contains { $0.name == self.name }
                if !exists {
                    let likePlaceRef = LikePlace(owner: mapBoardRef, data: placeData)
                    mapBoardRef.likePlaces.append(likePlaceRef)
                }
                self.isLiked = true
            } else {
                mapBoardRef.removeLikePlace(name: self.name)
                self.isLiked = false
            }
        } else {
            // 최초 실행: 아무것도 저장되지 않은 상태로 간주 (정책상 false)
            self.isLiked = false
        }

        self.isFetchedFromDB = true
    }
    public func toggleLike() {
        logger.start(info: "current: \(self.isLiked)")

        let navioRef = self.owner.owner.owner
        let mapBoardRef = navioRef.mapBoard!

        let willLike = (self.isLiked == false)

        // 1) 영속화
        userDefaults.set(willLike, forKey: placeData.isLikedKey)

        // 2) 컬렉션 수정 (중복/존재 체크 대칭)
        if willLike {
            if mapBoardRef.likePlaces.contains(where: { $0.name == self.name }) == false {
                let likePlaceRef = LikePlace(owner: mapBoardRef, data: placeData)
                mapBoardRef.likePlaces.append(likePlaceRef)
            }
        } else {
            mapBoardRef.removeLikePlace(name: self.name)
        }

        // 3) 상태 변경 (Combine로 UI 반영)
        self.isLiked = willLike
    }

    
    // MARK: value
}
