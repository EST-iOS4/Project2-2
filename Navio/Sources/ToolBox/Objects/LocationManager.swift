//
//  LocationManager.swift
//  Navio
//
//  Created by 김민우 on 9/4/25.
//
import Foundation
import Combine
import CoreLocation



// MARK: Object
@globalActor
public actor LocationManager: Sendable {
    // core
    public static let shared: LocationManager = .init()
    private init() {
        coreLocationManager = CLLocationManager()
        coreLocationManager.desiredAccuracy = kCLLocationAccuracyBest
        coreLocationManager.requestWhenInUseAuthorization()
        coreLocationManager.distanceFilter = kCLDistanceFilterNone
        coreLocationManager.pausesLocationUpdatesAutomatically = true
        
        coreLocationDelegate = CLDelegate()
        coreLocationManager.delegate = coreLocationDelegate
    }
    
    
    // state
    private let coreLocationManager: CLLocationManager
    private let coreLocationDelegate: CLDelegate
    
    public private(set) var location: Location? = nil
    private let locationStream = PassthroughSubject<Location, Never>()
    private func sendLocation(_ newLocation: Location) {
        self.locationStream.send(newLocation)
    }
    
    private var subscriptions: Set<AnyCancellable> = []
    private var subscriptionCount: Int = 0
    
    private var handlers: [LocationHandler] = []
    public func addHandler(_ handler: @escaping LocationHandler) {
        self.handlers.append(handler)
    }
    
    
    // action
    public func getUserAuthentication() {
        // Check if location services are enabled on the device
        guard CLLocationManager.locationServicesEnabled() else {
            print("[LocationManager] Location services are disabled.")
            return
        }

        // Evaluate current authorization status
        switch coreLocationManager.authorizationStatus {
        case .notDetermined:
            // Ask for permission
            coreLocationManager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse, .authorizedAlways:
            // Already authorized – begin streaming
            print("[LocationManager] Location permission is authorized.")
        case .restricted, .denied:
            // No permission – inform and stop updates
            print("[LocationManager] Location permission is restricted/denied.")
        @unknown default:
            break
        }
    }
    
    public func fetchMyLocation() {
        #warning("LocationManager.fetchMyLocation 구현")
        // 1. CoreLocationManager를 사용해 현재 위치를 가져온다.
        // 2. 가져온 현재 위치를 self.location에 업데이트한다.
    }
    
    public func startStreaming() {
        // mutate
        for locationHandler in handlers {
            locationStream
                .sink { newLocation in
                    locationHandler(newLocation)
                }
                .store(in: &subscriptions)
            
            subscriptionCount += 1
        }
        
        coreLocationManager.startUpdatingLocation()
    }
    public func stopStreaming() {
        // muatate
        subscriptionCount -= 1
        
        if subscriptionCount == 0 {
            coreLocationManager.stopUpdatingLocation()
        }
    }
    
    
    // value
    private final class CLDelegate: NSObject, CLLocationManagerDelegate {
        // 위치 업데이트 수신
        func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
            Task.detached {
                // 마지막 위치 가져오기
                guard let clLocation = locations.last?.coordinate else {
                    return
                }
                let location = clLocation.forNavio()
                
                // LocationManager 업데이트
                await LocationManager.shared.sendLocation(location)
            }
        }

        // 권한 상태 변경 감지 (iOS 14+)
        func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
            switch manager.authorizationStatus {
            case .authorizedWhenInUse, .authorizedAlways:
                Task { await LocationManager.shared.startStreaming() }
            case .restricted, .denied:
                Task { await LocationManager.shared.stopStreaming() }
            case .notDetermined:
                break
            @unknown default:
                break
            }
        }

        // 에러 처리
        func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
            print("위치 가져오기 실패: \(error)")
        }
    }
    
    public typealias LocationHandler = @Sendable (Location) -> Void
}
