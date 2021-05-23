//
//  MainViewController+Search.swift
//  mapboxTest
//
//  Created by Artamonov Aleksandr on 23.05.2021.
//

import UIKit
import MapboxSearch
import FloatingPanel

extension MainViewController: UITextFieldDelegate {
   public func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
      searchFpc.move(to: .full, animated: true)
      return true
   }

   public func textFieldDidBeginEditing(_ textField: UITextField) {
      textField.rightViewMode = .always
   }

   @objc func textFieldTextDidChanged() {
      if let text = contentVC.textField.text {
         let bounds = BoundingBox(saintPetersburgBounds.sw, saintPetersburgBounds.ne)
         let options = SearchEngine.RequestOptions(boundingBox: bounds, unsafeParameters: ["limit":"10"])
         searchEngine.search(query: text, options: options)
      }
   }
}

extension MainViewController: SearchEngineDelegate {
   public func resultsUpdated(searchEngine: SearchEngine) {
      print("Number of search results: \(searchEngine.items.count) for query: \(searchEngine.query)")
      contentVC.viewModel.searchResults.send(searchEngine.items)
   }

   public func resolvedResult(result: SearchResult) {
      print("Dumping resolved result:", dump(result))
      view.endEditing(true)
      searchFpc.move(to: .tip, animated: false)
      viewModel.selectedCoordinate = result.coordinate
      updateUserPin(to: result.coordinate)
   }

   public func searchErrorHappened(searchError: SearchError) {
      print("Error during search: \(searchError)")
   }
}

extension MainViewController: FloatingPanelControllerDelegate {
   public func floatingPanelWillBeginAttracting(_ fpc: FloatingPanelController, to state: FloatingPanelState) {
      if state != .full {
         view.endEditing(true)
      }
   }

   public func floatingPanelShouldBeginDragging(_ fpc: FloatingPanelController) -> Bool {
      return false
   }
}
