//
//  UIView+Nib.swift
//  BrightcovePlayerPlugin
//
//  Created by Roman Karpievich on 1/24/19.
//

import Foundation

extension UIView {
    
    class func nibInstance() -> Self {
        return initFromNib()
    }
    
    private class func initFromNib<T>() -> T {
        let bundle = Bundle(for: T.self as! AnyClass)
        return bundle.loadNibNamed(String(describing: self),
                                        owner: nil,
                                        options: nil)?[0] as! T        
    }
}
