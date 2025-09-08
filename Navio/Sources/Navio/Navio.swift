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


// MARK: Object
@MainActor
public final class Navio: Sendable, ObservableObject {
    // MARK: core
    public init() {
        NavioManager.register(self)
    }

    
    // MARK: state
    public nonisolated let id = ID()
    
    @Published public private(set) var homeBoard: HomeBoard.ID? = nil
    @Published public private(set) var mapBoard: MapBoard.ID? = nil
    @Published public private(set) var setting: Setting.ID? = nil
    
    
    // MARK: action
    public func setUp() async {
        // capture
        guard self.homeBoard == nil, self.mapBoard == nil, self.setting == nil else {
            print(#file, #function, #line, "이미 세팅된 상태입니다.")
            return
        }
        
        // mutate
        let homeBoardRef = HomeBoard(owner: self.id)
        let mapBoardRef = MapBoard(owner: self.id)
        let settingRef = Setting(owner: self.id)
        
        self.homeBoard = homeBoardRef.id
        self.mapBoard = mapBoardRef.id
        self.setting = settingRef.id
    }
    

    
    // MARK: value
    @MainActor
    public struct ID: Sendable, Hashable {
        // core
        public let value: UUID = UUID()
        nonisolated init() { }
        
        public var isExist: Bool {
            NavioManager.container[self] != nil
        }
        public var ref: Navio? {
            NavioManager.container[self]
        }
    }
}



// MARK: - ObjectManager
@MainActor
fileprivate final class NavioManager: Sendable {
    // core
    static var container: [Navio.ID: Navio] = [:]
    static func register(_ object: Navio) {
        container[object.id] = object
    }
    static func unregister(_ id: Navio.ID) {
        container[id] = nil
    }
}
