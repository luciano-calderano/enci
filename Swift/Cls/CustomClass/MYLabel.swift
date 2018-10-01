//
//  MYButton.swift
//  Enci
//
//  Created by Luciano Calderano on 03/11/16.
//  Copyright © 2016 Kanito. All rights reserved.
//

import UIKit

class MYLabel: UILabel {
    var title: String {
        get {
            return self.text!
        }
        set {
            self.text = newValue.toLang()
        }
    }
    required internal init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.initialize()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.initialize()
    }
    override internal func awakeFromNib() {
        super.awakeFromNib()
        self.initialize()
    }
    
    private func initialize () {
        self.minimumScaleFactor = 0.75
        self.adjustsFontSizeToFitWidth = true
        self.font = .withSize(self.font.pointSize)
        if (self.text != nil) {
            self.title = self.text!
        }
    }
}
