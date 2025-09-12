//
//  Pinnable.swift
//  Navio
//
//  Created by 구현모 on 9/11/25.
//

import Foundation
import CoreLocation

// 은영님이 만드신 캐러셀 데이터 모델과 기존의 LikePlace 모델을 둘다 사용하기 위해 프로토콜을 정의했습니다.
public protocol Pinnable {
    var coordinate: CLLocationCoordinate2D { get }
    var title: String { get }
    var subtitle: String? { get }
}
