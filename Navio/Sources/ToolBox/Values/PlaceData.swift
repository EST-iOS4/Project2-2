//
//  PlaceData.swift
//  Navio
//
//  Created by 김민우 on 9/9/25.
//
import Foundation


// MARK: Value
public struct PlaceData: Sendable, Hashable {
    // MARK: core
    public let name: String
    public let imageName: String
    public let location: Location
    public let address: String
    public let number: String
    
    public init(name: String, imageName: String, location: Location, address: String, number: String) {
        self.name = name
        self.imageName = imageName
        self.location = location
        self.address = address
        self.number = number
    }
    
    // MARK: operator
    package var isLikedKey: String {
        return "\(name).isLiked"
    }
}
