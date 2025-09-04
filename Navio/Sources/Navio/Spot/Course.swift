//
//  Course.swift
//  Navio
//
//  Created by 김민우 on 9/4/25.
//
import Foundation
import Combine


// MARK: Object
// Spot: 한강, 잠실, 한강공원, 여의도 -> Place의 집합
@MainActor
public final class Course: Sendable, ObservableObject {
    // core
    internal init(owner: Spot.ID) {
        self.owner = owner
        
        CourseManager.register(self)
    }
    internal func delete() {
        CourseManager.unregister(self.id)
    }
    
    
    // state
    public nonisolated let id = ID()
    internal nonisolated let owner: Spot.ID
    
    
    // action
    
    
    // value
    @MainActor
    public struct ID: Sendable, Hashable {
        // core
        public let value = UUID()
        nonisolated init() { }
        
        public var isExist: Bool {
            CourseManager.container[self] != nil
        }
        public var ref: Course? {
            CourseManager.container[self]
        }
    }
}


// MARK: ObjectManager
@MainActor
fileprivate final class CourseManager: Sendable {
    // core
    static var container: [Course.ID: Course] = [:]
    static func register(_ object: Course) {
        container[object.id] = object
    }
    static func unregister(_ id: Course.ID) {
        container[id] = nil
    }
}
