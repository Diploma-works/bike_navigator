//
//  MainViewModel.swift
//  mapboxTest
//
//  Created by Artamonov Aleksandr on 05.05.2021.
//

import Mapbox
import Combine
import Moya
import MapboxSearch

final class MainViewModel {

   private let provider = MoyaProvider<LanesEndpoint>(plugins: [NetworkLoggerPlugin()])
   
   var parkingAnnotations = PassthroughSubject<[MGLPointAnnotation], Never>()
   var lanes = CurrentValueSubject<MGLShape?, Never>(nil)
   var searchResults = PassthroughSubject<[MapboxSearch.SearchSuggestion], Never>()

   var selectedCoordinate: CLLocationCoordinate2D?
   var routes: (MGLShape, MGLShape)?


   func loadData() {
      provider.request(.lanes) { [weak self] result in
         switch result {
         case .success(let response):
            if let shape = try? MGLShape(data: response.data, encoding: String.Encoding.utf8.rawValue) {
               self?.lanes.send(shape)
            }
         case .failure(let error):
            print("Network error: \(error.localizedDescription)")
         }
      }
   }
}
