//
//  Common.swift
//  mapboxTest
//
//  Created by Artamonov Aleksandr on 08.05.2021.
//

import UIKit
import SnapKit

func configure<T>(_ value: T, using closure: (inout T) throws -> Void) rethrows -> T {
   var value = value
   try closure(&value)
   return value
}

extension Double {
   func isBetween(_ first: Double, _ second: Double) -> Bool {
      return (min(first, second)...max(first, second)).contains(self)
   }
}

extension UIView {
   var safeArea : ConstraintLayoutGuideDSL {
      return safeAreaLayoutGuide.snp
   }
}

extension Collection {
   subscript(safe index: Index) -> Iterator.Element? {
      guard indices.contains(index) else { return nil }
      return self[index]
   }
}
