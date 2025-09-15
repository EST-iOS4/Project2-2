//
//  FindSpot.swift
//  Navio
//
//  Created by 김민우 on 9/8/25.
//
import Foundation
import Combine
import ToolBox
import UIKit

private let logger = NavioLogger("SearchPlace")


// MARK: Object
@MainActor
public final class SearchPlace: Sendable, ObservableObject {
    // MARK: core
    internal init(owner: MapBoard, data: PlaceData, googlePlaceId: String) {
        self.owner = owner
        self.placeData = data
        self.googlePlaceId = googlePlaceId
        
        self.name = data.name
        self.imageName = data.imageName
        self.location = data.location
        self.address = data.address
        self.number = data.number
    }
    
    public static let udKey = "savedGooglePlaceIDs"
    
    
    // MARK: state
    internal nonisolated let owner: MapBoard
    public let placeData: PlaceData
    internal let googlePlaceId: String
    
    public nonisolated let name: String
    public nonisolated let imageName: String
    public var image: UIImage?
    
    public nonisolated let location: Location
    public nonisolated let address: String
    public nonisolated let number: String

    
    // MARK: action
    public func save() {
        logger.start()
        
        // UserDefaults로 저장
        let defaults = UserDefaults.standard
        var ids = Self.load()
        let newId = GooglePlaceID(googlePlaceId, name: self.name)
        if !ids.contains(newId) {
            ids.append(newId)
            
            do {
                let data = try JSONEncoder().encode(ids)
                defaults.set(data, forKey: Self.udKey)
                
                
            } catch {
                logger.failure(error)
            }
        }
    }
    
    // MARK: Helpher
    public static func load() -> [GooglePlaceID] {
        logger.start()
        
        
        let defaults = UserDefaults.standard
        
        guard let data = defaults.data(forKey: Self.udKey) else {
            logger.failure("Key에 맞는 값이 존재하지 않습니다.")
            return  []
        }
        
        do {
            return try JSONDecoder().decode([GooglePlaceID].self, from: data)
        } catch {
            logger.failure(error)
            return []
        }
    }
    
    
    // MARK: value
    public struct GooglePlaceID: Sendable, Hashable, Codable {
        public let rawValue: String
        public let name: String
        public init(_ rawValue: String, name: String) {
            self.rawValue = rawValue
            self.name = name
        }
    }
}

