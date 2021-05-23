//
//  UIColor.swift
//  mapboxTest
//
//  Created by Artamonov Aleksandr on 10.05.2021.
//

import UIKit


struct ApplicationColors {
   static let mainBlack = UIColor(hex: "#101010")!
   static let mainCyan = UIColor(hex: "#03DAC5")!
   static let darkCyan = UIColor(hex: "#006B61")!
   static let mainOrange = UIColor(hex: "#FF7002")!
   static let darkOrange = UIColor(hex: "#562500")!
   static let hintTextColor = UIColor(hex: "#BCBCBC")!
   static let separatorColor = UIColor(hex: "#212121")!
}

extension UIColor {

   public convenience init?(hex: String) {

      let rgbaData = getrgbaData(hexString: hex)

      if rgbaData != nil {
         self.init(red: rgbaData!.r,
                   green: rgbaData!.g,
                   blue: rgbaData!.b,
                   alpha: rgbaData!.a)
         return
      }
      return nil
   }
}

private func getrgbaData(hexString: String) -> (r: CGFloat, g: CGFloat, b: CGFloat, a: CGFloat)? {

   var rgbaData : (r: CGFloat, g: CGFloat, b: CGFloat, a: CGFloat)?

   if hexString.hasPrefix("#") {

      let start = hexString.index(hexString.startIndex, offsetBy: 1)
      let hexColor = String(hexString[start...])

      let scanner = Scanner(string: hexColor)
      var hexNumber: UInt64 = 0

      if scanner.scanHexInt64(&hexNumber) {

         rgbaData = {
            switch hexColor.count {
            case 8:

               return ( r: CGFloat((hexNumber & 0xff000000) >> 24) / 255,
                        g: CGFloat((hexNumber & 0x00ff0000) >> 16) / 255,
                        b: CGFloat((hexNumber & 0x0000ff00) >> 8)  / 255,
                        a: CGFloat( hexNumber & 0x000000ff)        / 255
               )
            case 6:

               return ( r: CGFloat((hexNumber & 0xff0000) >> 16) / 255,
                        g: CGFloat((hexNumber & 0x00ff00) >> 8)  / 255,
                        b: CGFloat((hexNumber & 0x0000ff))       / 255,
                        a: 1.0
               )
            default:
               return nil
            }
         }()

      }
   }

   return rgbaData
}
