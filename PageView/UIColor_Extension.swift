//
//  UIColor_Extension.swift
//  UIColor_Extension
//
//  Created by 王亚威 on 2023/6/25.
//

import UIKit

extension UIColor {
    convenience init(r: CGFloat, g: CGFloat, b: CGFloat, _ a: CGFloat = 1.0) {
        self.init(red: r/255.0, green: g/255.0, blue: b/255.0, alpha: a)
    }
    
    convenience init?(hex: String, alpha: CGFloat = 1.0) {
        guard hex.count >= 6 else {
            return nil
        }
        
        var tempHex = hex.uppercased()
        if tempHex.hasPrefix("0x") || tempHex.hasPrefix("##") {
            tempHex = (tempHex as NSString).substring(from: 2)
        }
        if tempHex.hasPrefix("#") {
            tempHex = (tempHex as NSString).substring(from: 1)
        }
        
        var range = NSRange.init(location: 0, length: 2)
        let rHex = (tempHex as NSString).substring(with: range)
        range.location = 2
        let gHex = (tempHex as NSString).substring(with: range)
        range.location = 4
        let bHex = (tempHex as NSString).substring(with: range)
        var r: UInt64 = 0, g: UInt64 = 0, b: UInt64 = 0
        Scanner.init(string: rHex).scanHexInt64(&r)
        Scanner.init(string: gHex).scanHexInt64(&g)
        Scanner.init(string: bHex).scanHexInt64(&b)

        self.init(r: CGFloat(r), g: CGFloat(g), b: CGFloat(b))
    }
    
    class func randomColor() -> UIColor {
       return UIColor(r: CGFloat(arc4random_uniform(256)), g: CGFloat(arc4random_uniform(256)), b: CGFloat(arc4random_uniform(256)))
    }
    
    class func getRGBDelta(_ firstColor: UIColor, _ secondColor: UIColor) -> (CGFloat, CGFloat, CGFloat) {
        let firstRGB = firstColor.getRGB()
        let secondRGB = secondColor.getRGB()
        return (firstRGB.0 - secondRGB.0, firstRGB.1 - secondRGB.1, firstRGB.2 - secondRGB.2)
    }
    
    func getRGB() -> (CGFloat, CGFloat, CGFloat) {
        guard let cpms = cgColor.components, cpms.count > 3 else {
            fatalError("保证颜色是RGB方式传入")
        }
        return (cpms[0]*255, cpms[1]*255, cpms[2]*255)
    }
}
