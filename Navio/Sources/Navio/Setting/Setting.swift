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
    // MARK: core
    internal init(owner: Navio) {
        self.owner = owner
    }
    
    
    // MARK: state
    internal nonisolated let owner: Navio
    
    @Published public var displayMode: DisplayMode = .system
    @Published public var collectKeyword: Bool = true
    
    
    // MARK: action
    public func load() {
        // compute
        let defaults = UserDefaults.standard
        if let rawMode = defaults.string(forKey: "Setting.displayMode"),
           let mode = DisplayMode(rawValue: rawMode) {
            self.displayMode = mode
        }
        
        // mutate
        self.collectKeyword = defaults.bool(forKey: "Setting.collectKeyword")
    }
    public func save() {
        // compute
        let defaults = UserDefaults.standard
        
        defaults.set(self.displayMode.rawValue,
                     forKey: "Setting.displayMode")
        
        defaults.set(self.collectKeyword, forKey: "Setting.collectKeyword")
        
        
    }
    
    
    
    // MARK: value
    public enum DisplayMode: String, Sendable, Hashable {
        case light
        case dark
        case system
    }
}
