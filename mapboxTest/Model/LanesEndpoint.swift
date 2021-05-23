//
//  LanesEndpoint.swift
//  mapboxTest
//
//  Created by Artamonov Aleksandr on 16.05.2021.
//

import Moya
import CoreLocation
import Foundation

public enum LanesEndpoint {

   // MARK: - Parkings
   case lanes
}

extension LanesEndpoint: TargetType {
   public var baseURL: URL {
      return URL(string: "http://localhost:8080")!
   }

   public var path: String {
      switch self {
      case .lanes:
         return "lanes"
      }
   }

   public var method: Moya.Method {
      return .get
   }

   public var sampleData: Data {
      return Data()
   }

   public var task: Task {
      switch self {
      case .lanes:
         return .requestPlain
      }
   }

   public var headers: [String : String]? {
      return [
         "Accept": "application/json"
      ]
   }

   public var validationType: ValidationType {
      return .successCodes
   }
}
