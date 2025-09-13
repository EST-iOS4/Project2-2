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
    @Published public private(set) var isFecthedFromDB = true
    
    
    // MARK: action
    public func fetchFromDB() {
        logger.start()
        
        // capture
        guard self.isFecthedFromDB == false else {
            logger.failure("이미 DB로부터 데이터를 가져왔습니다.")
            return
        }
        
        let navioRef = self.owner.owner.owner
        let mapBoardRef = navioRef.mapBoard!
        
        // compute
        let isLikedFromDB = userDefaults.bool(forKey: placeData.isLikedKey)
        
        // mutate
        switch isLikedFromDB {
        case true:
            let liekPlaceRef = LikePlace(owner: mapBoardRef, data: placeData)
            mapBoardRef.likePlaces.append(liekPlaceRef)
            self.isLiked = true
        case false:
            mapBoardRef.removeLikePlace(name: self.name)
            self.isLiked = false
        }
    }
    public func toggleLike() {
        logger.start()
        
        // capture
        let navioRef = self.owner.owner.owner
        let mapBoardRef = navioRef.mapBoard!
        
        let isMarkingToLike = (self.isLiked == false)
        
        // compute
        switch isMarkingToLike {
        case true: // false -> true
            userDefaults.set(true, forKey: placeData.isLikedKey)
        case false: // true -> false
            userDefaults.set(false, forKey: placeData.isLikedKey)
        }
        
        // mutate
        switch isMarkingToLike {
        case true: // false -> true
            let liekPlaceRef = LikePlace(owner: mapBoardRef, data: placeData)
            let isLikePlaceAlreadyExist = mapBoardRef.likePlaces.contains { $0.name == self.name }
            guard isLikePlaceAlreadyExist == false else {
                logger.failure("이미 좋아요 목록에 포함되어 있습니다.")
                return
            }
            
            mapBoardRef.likePlaces.append(liekPlaceRef)
            self.isLiked = true
        case false: // true -> false
            mapBoardRef.removeLikePlace(name: self.name)
            self.isLiked = false
        }
    }

    
    // MARK: value
}
