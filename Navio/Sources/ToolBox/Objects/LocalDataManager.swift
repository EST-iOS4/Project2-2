//
//  LocalDBManager.swift
//  Navio
//
//  Created by 김민우 on 9/16/25.
//
import Foundation
import Combine


// MARK: LoaclDBManager
@globalActor
package actor LocalDataManager: Sendable {
    // MARK: core
    public static let shared: LocalDataManager = .init()
    private init() { }
    
    
    // MARK: state
    
    
    // MARK: action
    
    
    // MARK: value
    package struct Spot: Sendable, Hashable {
        
    }
    
    package struct Place: Sendable, Hashable {
        
    }
}
