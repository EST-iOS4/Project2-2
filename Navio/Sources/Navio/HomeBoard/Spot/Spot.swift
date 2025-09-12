//
//  HotPlace.swift
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
public final class Spot: Sendable, ObservableObject {
    // MARK: core
    internal init(owner: HomeBoard, name: String, imageName: String) {
        self.owner = owner
        self.name = name
        self.imageName = imageName
    }
    
    
    // MARK: state
    internal nonisolated let owner: HomeBoard
    
    public nonisolated let name: String
    public nonisolated let imageName: String
    public var image: UIImage {
        let imageURL = Bundle.module.url(
            forResource: imageName,
            withExtension: "png")!
        let data = try? Data(contentsOf: imageURL)
        let uiImage = UIImage(data: data!)
        return uiImage!
    }
    
    public internal(set) var places: [Place] = []
    
    
    
    // MARK: action
    public func fetchPlaces() async {
        // capture
        guard places.isEmpty else {
            print(#file, #function, #line, "already fetched")
            return
        }
        
        // compute
        let places = LocalDB.builtInSpots
            .filter { $0.name == self.name }
            .flatMap { $0.places }
            .map {
                return Place(owner: self, data: $0)
            }
        
        // mutate
        self.places = places
    }
    
    
    
    // MARK: value
}
