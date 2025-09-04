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
    
    
    @Published public private(set) var currentLocation: Location? = nil
    @Published public private(set) var isUpdatingLocation: Bool = false
    private func setLocation(_ newLocation: Location?) {
        self.currentLocation = newLocation
    }
    
    @Published public internal(set) var setting: Setting.ID? = nil
    @Published public internal(set) var spots: Set<Spot.ID> = []
    @Published public internal(set) var stats: Stats.ID? = nil
    
    @Published public internal(set) var issue: String? = nil
    
    
    // MARK: action
    public func setUp() {
        // 1. setting 객체를 생성하고, 이를 setting에 할당한다.
        // 2. spot 객체를 생성하고, 이를 stats에 할당한다.
        fatalError()
    }
    
    public func bringWhereIAm() async {
        // 현재 위치를 가져와 currentLocation을 업데이트한다.
        fatalError()
    }
    
    public func startUpdating() async {
        // capture
        guard self.isUpdatingLocation == false else {
            print("위치가 현재 업데이트 중입니다.")
            return
        }
        let navio = self.id
        
        // compute
        await LocationManager.shared.addHandler { newLocation in
            Task {
                await navio.ref?.setLocation(newLocation)
            }
        }
        
        await LocationManager.shared.startStreaming()
        
        // mutate
        self.isUpdatingLocation = true
    }
    public func stopUpdating() async {
        // compute
        await LocationManager.shared.stopStreaming()
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
