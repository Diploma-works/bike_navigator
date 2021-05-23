//
//  SearchViewModel.swift
//  mapboxTest
//
//  Created by Artamonov Aleksandr on 09.05.2021.
//

import Combine
import MapboxSearch

enum SearchSection {
   case main
}

final class SearchViewModel {
   var searchResults = CurrentValueSubject<[MapboxSearch.SearchSuggestion], Never>([])
}
