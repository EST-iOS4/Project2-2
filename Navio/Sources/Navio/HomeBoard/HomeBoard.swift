//
//  HomeBoard.swift
//  Navio
//
//  Created by 김민우 on 9/8/25.
//
import Foundation
import Combine
import ToolBox

private let logger = NavioLogger("HomeBoard")


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
        logger.start()
        
        // capture
        guard spots.isEmpty else {
            logger.failure("이미 Spot들이 존재합니다.")
            return
        }
        
        // mutate
        self.spots = sampleSpotDatas
            .map { Spot(owner: self, data: $0)}
    }
    
    
    // MARK: value
    private let sampleSpotDatas: [SpotData] = [
        .init(name: "홍대",imageName: "hongdae"),
        .init(name: "부산", imageName: "busan"),
        .init(name: "경주",imageName: "gyeongju"),
        .init(name: "잠실", imageName: "jamsil")
    ]
}
