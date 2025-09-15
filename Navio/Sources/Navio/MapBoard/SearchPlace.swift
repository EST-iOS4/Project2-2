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


// MARK: Object
@MainActor
public final class SearchPlace: Sendable, ObservableObject {
    // MARK: core
    internal init(owner: MapBoard, data: PlaceData) {
        self.owner = owner
        self.placeData = data
        self.name = data.name
        self.imageName = data.imageName
        self.location = data.location
        self.address = data.address
        self.number = data.number
    }
    
    
    // MARK: state
    internal nonisolated let owner: MapBoard
    public let placeData: PlaceData
    
    public nonisolated let name: String
    public nonisolated let imageName: String
    public var image: UIImage?
    
    public nonisolated let location: Location
    public nonisolated let address: String
    public nonisolated let number: String

    
    // MARK: value
}

