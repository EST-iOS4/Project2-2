//
//  Navio.swift
//  Navio
//
//  Created by 김민우 on 9/4/25.
//
import Foundation
import CoreLocation
import Combine
import ToolBox

private let logger = NavioLogger("Navio")


// MARK: Object
@MainActor
public final class Navio: Sendable, ObservableObject {
    // MARK: core
    public static let shared: Navio = .init()
    public init(mode: SystemMode = .test) {
        self.mode = mode
    }

    
    // MARK: state
    internal nonisolated let mode: SystemMode
    
    @Published public private(set) var homeBoard: HomeBoard? = nil
    @Published public private(set) var mapBoard: MapBoard? = nil
    @Published public private(set) var setting: Setting? = nil
    
    
    // MARK: action
    public func setUp() {
        logger.start()
        
        // capture
        guard self.homeBoard == nil, self.mapBoard == nil, self.setting == nil else {
            logger.failure("이미 setUp되어있습니다.")
            return
        }
        
        // mutate
        self.homeBoard = HomeBoard(owner: self)
        self.mapBoard = MapBoard(owner: self)
        self.setting = Setting(owner: self)
    }
}
