//
//  RoundedTextField.swift
//  mapboxTest
//
//  Created by Artamonov Aleksandr on 10.05.2021.
//

import UIKit

class RoundedTextField: UITextField {

   private let insets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 40)

   var onClear: (() -> Void)?

   init() {
      super.init(frame: .zero)
      layer.cornerRadius = 8
   }

   required init?(coder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
   }

   override func textRect(forBounds bounds: CGRect) -> CGRect {
      return bounds.inset(by: insets)
   }

   override func editingRect(forBounds bounds: CGRect) -> CGRect {
      return bounds.inset(by: insets)
   }

   override func rightViewRect(forBounds bounds: CGRect) -> CGRect {
      return super.rightViewRect(forBounds: bounds).inset(by: UIEdgeInsets(top: 0, left: -10, bottom: 0, right: 10))
   }

   func modifyClearButtonWithImage(image : UIImage) {
      let clearButton = UIButton(type: .custom)
      clearButton.setImage(image, for: .normal)
      clearButton.addTarget(self, action: #selector(clear(_:)), for: .touchUpInside)
      self.rightView = clearButton
      self.rightViewMode = .whileEditing
   }

   @objc func clear(_ sender: AnyObject) {
      self.text = ""
      self.rightViewMode = .whileEditing
      endEditing(true)
      onClear?()
   }
}
