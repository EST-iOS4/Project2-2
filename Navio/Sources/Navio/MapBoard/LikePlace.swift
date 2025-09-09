import Foundation
import Combine
import ToolBox
import UIKit


// MARK: Object
@MainActor
public final class LikePlace: Sendable, ObservableObject {
    // core
    internal init(owner: MapBoard.ID, data: PlaceData) {
        self.owner = owner
        self.name = data.name
        self.imageName = data.imageName
        self.location = data.location
        self.address = data.address
        self.number = data.number
        
        LikedSpotManager.register(self)
    }
    internal func delete() {
        LikedSpotManager.unregister(self.id)
    }
    
    
    // state
    public nonisolated let id = ID()
    internal nonisolated let owner: MapBoard.ID
    
    public nonisolated let name: String
    public nonisolated let imageName: String
    public var image: UIImage {
        let imageURL = Bundle.module.url(
            forResource: imageName,
            withExtension: "png")!
        let data = try? Data(contentsOf: imageURL)
        let uiImage = UIImage(data: data!)
        return uiImage!
    }
    
    public nonisolated let location: Location
    public nonisolated let address: String
    public nonisolated let number: String
    
    // action
    
    
    // value
    @MainActor
    public struct ID: Sendable, Hashable {
        public let value = UUID()
        nonisolated init() { }
        
        public var isExist: Bool {
            LikedSpotManager.container[self] != nil
        }
        public var ref: LikePlace? {
            LikedSpotManager.container[self]
        }
    }
}


// MARK: ObjectManager
@MainActor
fileprivate final class LikedSpotManager: Sendable {
    // core
    static var container: [LikePlace.ID: LikePlace] = [:]
    static func register(_ object: LikePlace) {
        container[object.id] = object
    }
    static func unregister(_ id: LikePlace.ID) {
        container[id] = nil
    }
}

