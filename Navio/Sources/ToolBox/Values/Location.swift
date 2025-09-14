//
//  Location.swift
//  Navio
//
//  Created by 김민우 on 9/4/25.
//
import Foundation
import CoreLocation


// MARK: Value
public struct Location: Sendable, Hashable, Codable {
    // MARK: core
    public let latitude: Double
    public let longitude: Double
    
    public init(latitude: Double, longitude: Double) {
        self.latitude = latitude
        self.longitude = longitude
    }
    
    // MARK: operator
    public var toCLLocationCoordinate2D: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: self.latitude, longitude: self.longitude)
    }
}


// MARK: Extensions
public extension CLLocationCoordinate2D {
    func forNavio() -> Location {
        return Location(latitude: self.latitude, longitude: self.longitude)
    }
}
