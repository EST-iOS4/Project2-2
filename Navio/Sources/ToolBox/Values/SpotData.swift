//
//  SpotData.swift
//  Navio
//
//  Created by 김민우 on 9/8/25.
//
import Foundation
import CoreData
import UIKit


// MARK: Value
public struct SpotData: Sendable, Hashable {
    // core
    public let name: String
    public let imageName: String
    
    public init(name: String, imageName: String) {
        self.name = name
        self.imageName = imageName
    }
}
