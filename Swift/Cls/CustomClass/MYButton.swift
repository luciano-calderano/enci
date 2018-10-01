//
//  MYButton.swift
//  Enci
//
//  Created by Luciano Calderano on 03/11/16.
//  Copyright © 2016 Kanito. All rights reserved.
//

import UIKit

class MYButton: UIButton {
    @IBInspectable let cornerRadius:CGFloat = 5.0

    @IBInspectable var borderMargins:Bool {
        get { return self.layer.borderWidth > 0 }
        set { self.layer.borderWidth = newValue ? 1 : 0; self.layer.borderColor = UIColor.lightGray.cgColor }
    }
    var title: String {
        get { return self.titleLabel!.text! }
        set { self.setTitle(newValue.toLang(), for: UIControl.State()) }
    }
    
    required internal init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.initialize()
    }
    
    private func initialize () {
        self.layer.masksToBounds = false
        
        self.showsTouchWhenHighlighted = true
        self.backgroundColor = .myBlue
        self.setTitleColor(UIColor.white, for: UIControl.State.normal)
        self.titleLabel?.font = .withSize((self.titleLabel?.font.pointSize)!)
        self.title = self.currentTitle!
        
        self.borderMargins = false
        self.layer.cornerRadius = cornerRadius
    }
}

