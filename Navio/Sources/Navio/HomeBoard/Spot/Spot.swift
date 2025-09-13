//
//  HotPlace.swift
//  Navio
//
//  Created by 김민우 on 9/8/25.
//
import Foundation
import Combine
import ToolBox
import UIKit

private let logger = NavioLogger("Spot")


// MARK: Object
@MainActor
public final class Spot: Sendable, ObservableObject {
    // MARK: core
    internal init(owner: HomeBoard, data: SpotData) {
        self.owner = owner
        self.name = data.name
        self.imageName = data.imageName
    }
    
    
    // MARK: state
    internal nonisolated let owner: HomeBoard
    
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
    
    @Published public internal(set) var places: [Place] = []
    
    
    
    // MARK: action
    public func setUpSamplePlaces() {
        logger.start()
        
        // capture
        guard places.isEmpty else {
            logger.failure("이미 사전에 정의된 Spot(\(self.name))에 대한 장소 데이터가 있습니다.")
            return
        }
        
        // mutate
        switch self.name {
        case "홍대":
            self.places = hongdaeDatas
                .map { Place(owner: self, data: $0) }
        case "부산":
            self.places = busanPlaceDatas
                .map { Place(owner: self, data: $0)}
        case "경주":
            self.places = gyeongjuPlaceDatas
                .map { Place(owner: self, data: $0) }
        case "잠실":
            self.places = jamsilPlaceDatas
                .map { Place(owner: self, data: $0) }
        default:
            logger.failure("홍대, 부산, 경주, 잠실이 아닌 \(self.name)이 처리되었습니다.")
            return
        }
    }
    
    
    
    // MARK: value
    private let hongdaeDatas: [PlaceData] = [
        .init(name: "큐브이스케이프", imageName: "cube_escape_hongdae",
              location: .init(latitude: 37.553584, longitude: 126.920718),
              address: "서울 마포구 양화로16길 15 무광빌딩 4층", number: "02-323-5567"),
        .init(name: "아이뮤지엄", imageName: "eyemuseum_hongdae",
              location: .init(latitude: 37.553792, longitude: 126.921918),
              address: "서울 마포구 홍익로3길 20 서교프라자 지하2층", number: "02-322-8177")
    ]
    
    private let busanPlaceDatas: [PlaceData] = [
        .init(
            name: "감천문화마을",
            imageName: "gamcheon_busan",
            location: .init(latitude: 35.097776, longitude: 129.010592),
            address: "부산 사하구 감내2로 203 감천문화마을안내센터",
            number: "051-204-1444"
        ),
        .init(
            name: "해운대",
            imageName: "haeundae_busan",
            location: .init(latitude: 35.160508, longitude: 129.160213),
            address: "부산 해운대구 우동",
            number: "051-749-5700"
        ),
        .init(
            name: "오시리아관광단지",
            imageName: "osiria_busan",
            location: .init(latitude: 35.200420, longitude: 129.211648),
            address: "부산 기장군 기장읍 시랑리",
            number: ""
        )
    ]
    
    private let gyeongjuPlaceDatas: [PlaceData] = [
        .init(
            name: "첨성대",
            imageName: "cheomsungdae_gyeongju",
            location: .init(latitude: 35.835147, longitude: 129.218916),
            address: "경북 경주시 인왕동 839-1",
            number: "054-772-3843"
        ),
        .init(
            name: "동궁",
            imageName: "donggung_gyeongju",
            location: .init(latitude: 35.835060, longitude: 129.226522),
            address: "경북 경주시 원화로 102 안압지",
            number: "054-750-8655"
        ),
        .init(
            name: "뽀로로빌리지",
            imageName: "pororo_gyeongju",
            location: .init(latitude: 35.861189, longitude: 129.270650),
            address: "경북 경주시 보문로 182-27",
            number: "054-777-8300"
        )
    ]
    
    private let jamsilPlaceDatas: [PlaceData] = [
        .init(
            name: "롯데월드",
            imageName: "lotteworld_jamsil",
            location: .init(latitude: 37.511591, longitude: 127.098210),
            address: "서울 송파구 올림픽로 240",
            number: "1661-2000"
        ),
        .init(
            name: "석촌호수",
            imageName: "seokchon_jamsil",
            location: .init(latitude: 37.508488, longitude: 127.100746),
            address: "서울 송파구 잠실동",
            number: "02-412-0190"
        ),
        .init(
            name: "잠실종합운동장",
            imageName: "playground_jamsil",
            location: .init(latitude: 37.515505, longitude: 127.072979),
            address: "서울 송파구 올림픽로 25 서울종합운동장",
            number: "02-2240-8800"
        )
    ]
}
