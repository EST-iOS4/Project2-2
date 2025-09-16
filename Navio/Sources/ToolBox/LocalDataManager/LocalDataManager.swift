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
    package private(set) var spots: [Spot] = {
        let hongdaePlaces = [
            Place(name: "큐브이스케이프", imageName: "cube_escape_hongdae",
                  location: .init(latitude: 37.553584, longitude: 126.920718),
                  address: "서울 마포구 양화로16길 15 무광빌딩 4층",
                  number: "02-323-5567"),
            Place(name: "아이뮤지엄", imageName: "eyemuseum_hongdae",
                  location: .init(latitude: 37.553792, longitude: 126.921918),
                  address: "서울 마포구 홍익로3길 20 서교프라자 지하2층",
                  number: "02-322-8177")
        ]
        let hongdae = Spot(name: "홍대", imageName: "hongdae", places: hongdaePlaces)
        
        let busanPlaces: [Place] = [
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
        let busan = Spot(name: "부산", imageName: "busan", places: busanPlaces)
        
        let gyeongjuPlaces: [Place] = [
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
        let gyeongju = Spot(name: "경주",imageName: "gyeongju", places: gyeongjuPlaces)
        
        let jamsilPlaces: [Place] = [
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
        let jamsil = Spot(name: "잠실", imageName: "jamsil", places: jamsilPlaces)
        
        return [hongdae, busan, gyeongju, jamsil]
    }()
    
    
    // MARK: action
    
    
    // MARK: value
    package struct Spot: Sendable, Hashable {
        // core
        package let name: String
        package let imageURL: URL
        package let places: [Place]
        
        private init (name: String, imageURL: URL, places: [Place] = []) {
            self.name = name
            self.imageURL = imageURL
            self.places = places
        }
        fileprivate init(name: String, imageName: String, places: [Place] = []) {
            self.name = name
            
            let url = Bundle.main.url(forResource: imageName, withExtension: "png")
            self.imageURL = url!
            
            self.places = places
        }
        
        // operator
        fileprivate func withPlaces(_ places: [Place]) -> Spot {
            return .init(name: name, imageURL: imageURL, places: places)
        }
    }
    
    package struct Place: Sendable, Hashable {
        // core
        package let name: String
        package let imageURL: URL
        package let location: Location
        package let address: String
        package let number: String
        
        fileprivate init(name: String, imageName: String, location: Location, address: String, number: String) {
            self.name = name
            self.imageURL = Bundle.main.url(forResource: imageName, withExtension: "png")!
            self.location = location
            self.address = address
            self.number = number
        }
    }
}



