//
//  Place.swift
//  Navio
//
//  Created by 김민우 on 9/8/25.
//
import Foundation
import Combine
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
    public var imageData: Data? {
        let imageURL = Bundle.module.url(
            forResource: imageName,
            withExtension: "png")!
        let data = try? Data(contentsOf: imageURL)
        return data
    }
    
    public internal(set) var address: String
    public internal(set) var number: String
    public internal(set) var location: Location
    
    @Published public internal(set) var isLiked = false
    @Published public private(set) var isFetchedFromDB = false
    
    
    // MARK: action
    public func fetchFromDB() {
        logger.start()

        logger.failure("미구현")
    }
    public func toggleLike() {
        logger.start(info: "current: \(self.isLiked)")

        logger.failure("미구현")
    }

    
    // MARK: value
}
