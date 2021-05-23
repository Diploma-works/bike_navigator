//
//  RoundedButton.swift
//  mapboxTest
//
//  Created by Artamonov Aleksandr on 08.05.2021.
//

import UIKit

class RoundedButton: UIButton {
   init() {
      super.init(frame: .zero)
      contentEdgeInsets = .init(top: 12.0, left: 16, bottom: 12.0, right: 16.0)
      setBackgroundColor(color: ApplicationColors.mainBlack, forState: .normal)
   }

   override func layoutSubviews() {
      super.layoutSubviews()
      layer.cornerRadius = bounds.height / 2.0
   }

   required init?(coder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
   }
}

extension UIButton {
   func setBackgroundColor(color: UIColor?, forState: UIControl.State) {
      self.clipsToBounds = true
      UIGraphicsBeginImageContext(CGSize(width: 1, height: 1))
      if let context = UIGraphicsGetCurrentContext(),
         let col = color {
         context.setFillColor(col.cgColor)
         context.fill(CGRect(x: 0, y: 0, width: 1, height: 1))
         let colorImage = UIGraphicsGetImageFromCurrentImageContext()
         UIGraphicsEndImageContext()
         self.setBackgroundImage(colorImage, for: forState)
      }
   }
}
