//
//  MYPickerCell.swift
//  EnciSport
//
//  Created by Luciano Calderano on 22/11/16.
//  Copyright © 2016 Kanito. All rights reserved.
//

import UIKit

class MyPickerCell: UILabel {
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        self.commonInit()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
    }
    
    func commonInit(){
        self.font = .withSize(35)
        self.adjustsFontSizeToFitWidth = true
        self.textAlignment = NSTextAlignment.center
        self.textColor = UIColor.white
        self.backgroundColor = .myBlue
        self.layer.masksToBounds = true
        self.layer.cornerRadius = 5;
    }
}
