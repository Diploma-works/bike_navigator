//
//  PanelInstrictLayout.swift
//  mapboxTest
//
//  Created by Artamonov Aleksandr on 08.05.2021.
//

import UIKit
import FloatingPanel

class PanelInstrictLayout: FloatingPanelLayout {
   let position: FloatingPanelPosition = .bottom
   let initialState: FloatingPanelState = .tip

   var anchors: [FloatingPanelState: FloatingPanelLayoutAnchoring] {
      return [
         .full: FloatingPanelLayoutAnchor(absoluteInset: 10.0, edge: .top, referenceGuide: .safeArea),
         .tip: FloatingPanelLayoutAnchor(absoluteInset: 90.0, edge: .bottom, referenceGuide: .safeArea),
      ]
   }

   func backdropAlpha(for state: FloatingPanelState) -> CGFloat {
      return 0.0
   }
}

class DetailsLayout: FloatingPanelLayout {
   let position: FloatingPanelPosition = .bottom
   let initialState: FloatingPanelState = .tip

   var anchors: [FloatingPanelState: FloatingPanelLayoutAnchoring] {
      return [
         .tip: FloatingPanelLayoutAnchor(absoluteInset: 100.0, edge: .bottom, referenceGuide: .safeArea),
      ]
   }

   func backdropAlpha(for state: FloatingPanelState) -> CGFloat {
      return 0.0
   }
}
