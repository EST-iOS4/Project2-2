//
//  RecentSpot.swift
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
public final class RecentPlace: Sendable, ObservableObject {
    // MARK: core
    internal init(owner: MapBoard, name: String) {
        self.owner = owner
        self.name = name
    }
    
    
    // MARK: state
    internal nonisolated let owner: MapBoard
    
    public nonisolated let name: String
    
    
    // MARK: action
    public func apply() async {
        let mapBoardRef = owner
        
        mapBoardRef.searchInput = name
        
        await mapBoardRef.fetchSearchPlaces()
    }
    
    
    // MARK: value
}
