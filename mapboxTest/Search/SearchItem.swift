//
//  SearchItem.swift
//  mapboxTest
//
//  Created by Artamonov Aleksandr on 09.05.2021.
//

import MapboxSearch

struct SearchItem: Hashable {
   static func == (lhs: SearchItem, rhs: SearchItem) -> Bool {
      return lhs.searchSuggestion.id == rhs.searchSuggestion.id
   }

   func hash(into hasher: inout Hasher) {
      hasher.combine(self.searchSuggestion.id)
   }

   let searchSuggestion: MapboxSearch.SearchSuggestion

   var name: String {
      if let street = searchSuggestion.address?.street,
         let house = searchSuggestion.address?.houseNumber {
         return "\(street), \(house)"
      }
      return searchSuggestion.name
   }
}
