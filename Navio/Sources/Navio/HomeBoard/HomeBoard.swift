//
//  HomeBoard.swift
//  Navio
//
//  Created by 김민우 on 9/8/25.
//
import Foundation
import Combine
import ToolBox


// MARK: Object
@MainActor
public final class HomeBoard: Sendable, ObservableObject {
    // MARK: core
    internal init(owner: Navio) {
        self.owner = owner
    }
    
    
    // MARK: state
    internal nonisolated let owner: Navio
    
    public internal(set) var spots: [Spot] = []
    
    
    // MARK: action
    public func fetchSpots() async {
        // capture
        guard spots.isEmpty else {
            print(#file, #function, #line, "already fetched")
            return
        }
        
        // compute
        let spots = LocalDB.builtInSpots
            .map { spotData in
                let newSpotRef = Spot(owner: self,
                                      name: spotData.name,
                                      imageName: spotData.imageName)
                return newSpotRef
            }
        
        // mutate
        self.spots = spots
    }
    
    
    // MARK: value
}
