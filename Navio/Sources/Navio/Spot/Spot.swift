//
//  Spot.swift
//  Navio
//
//  Created by 김민우 on 9/4/25.
//
import Foundation
import Combine


// MARK: Object
// Spot: 한강, 잠실, 한강공원, 여의도 -> Place의 집합
@MainActor
public final class Spot: Sendable {
    // core
    internal init(owner: Navio.ID) {
        self.owner = owner
        
        SpotManager.register(self)
    }
    internal func delete() {
        SpotManager.unregister(self.id)
    }
    
    
    // state
    public nonisolated let id = ID()
    internal nonisolated let owner: Navio.ID
    
    
    // action
    public func getCuratedCourse() {
        // capture
        
        
        
        // compute
        // 1. LocationManager.shared로 현재 위치를 가져온다.
        // 2. 카카오맵 API로 현재 Spot의
        
        
        
        // mutate
        // 1. 현재 Course 객체들을 전부 삭제
        // 2. 새로 생성한 객체들을
    }
    
    
    // value
    @MainActor
    public struct ID: Sendable, Hashable {
        // core
        public let value = UUID()
        nonisolated init() { }
        
        public var isExist: Bool {
            fatalError()
        }
        public var ref: Spot? {
            fatalError()
        }
    }
}


// MARK: ObjectManager
@MainActor
fileprivate final class SpotManager: Sendable {
    // core
    static var container: [Spot.ID: Spot] = [:]
    static func register(_ object: Spot) {
        container[object.id] = object
    }
    static func unregister(_ id: Spot.ID) {
        container[id] = nil
    }
}
