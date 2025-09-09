//
//  Setting.swift
//  Navio
//
//  Created by 김민우 on 9/4/25.
//
import Foundation
import Combine


// MARK: Object
@MainActor
public final class Setting: Sendable, ObservableObject {
    // core
    internal init(owner: Navio.ID) {
        self.owner = owner
        
        SettingManager.register(self)
    }
    internal func delete() {
        SettingManager.unregister(self.id)
    }
    
    
    // state
    public nonisolated let id = ID()
    internal nonisolated let owner: Navio.ID
    
    @Published public var displayMode: DisplayMode = .system
    @Published public var collectKeyword: Bool = true
    
    // action
    public func loadSettingFromDB() {
        let defaults = UserDefaults.standard
        if let rawMode = defaults.string(forKey: "Setting.displayMode"),
           let mode = DisplayMode(rawValue: rawMode) {
            self.displayMode = mode
        }
        self.collectKeyword = defaults.bool(forKey: "Setting.collectKeyword")
    }
    public func saveToDB() {
        let defaults = UserDefaults.standard
        
        defaults.set(self.displayMode.rawValue,
                     forKey: "Setting.displayMode")
        
        defaults.set(self.collectKeyword, forKey: "Setting.collectKeyword")
    }
    
    
    
    
    // value
    @MainActor
    public struct ID: Sendable, Hashable {
        public let value = UUID()
        nonisolated init() { }
        
        public var isExist: Bool {
            SettingManager.container[self] != nil
        }
        public var ref: Setting? {
            SettingManager.container[self]
        }
    }
    
    public enum DisplayMode: String, Sendable, Hashable {
        case light
        case dark
        case system
    }
}


// MARK: ObjectManager
@MainActor
fileprivate final class SettingManager: Sendable {
    // core
    static var container: [Setting.ID: Setting] = [:]
    static func register(_ object: Setting) {
        container[object.id] = object
    }
    static func unregister(_ id: Setting.ID) {
        container[id] = nil
    }
}
