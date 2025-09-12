import Foundation
import Combine
import ToolBox
import UIKit
import CoreLocation

// MARK: Object
@MainActor
public final class LikePlace: Sendable, ObservableObject {
    // MARK: core
    internal init(owner: MapBoard, data: PlaceData) {
        self.owner = owner
        self.name = data.name
        self.imageName = data.imageName
        self.location = data.location
        self.address = data.address
        self.number = data.number
    }
    
    
    // MARK: state
    internal nonisolated let owner: MapBoard
    
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
    
    
    // MARK: action
    
    
    // MARK: value
}


// MARK: Extension
extension LikePlace: Pinnable {
    public nonisolated var coordinate: CLLocationCoordinate2D {
        return .init(latitude: self.location.latitude, longitude: self.location.longitude)
    }
    public nonisolated var title: String { self.name }
    public nonisolated var subtitle: String? { self.address }
}
