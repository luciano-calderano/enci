//
//  MyNavigationBar.swift
//  EnciSport
//
//  Created by Luciano Calderano on 17/11/16.
//  Copyright © 2016 Kanito. All rights reserved.
//

import UIKit

protocol MYNavigationBarDelegate: class {
    func myNavigationBarOptionButtonTapped()
    func myNavigationBarBackButtonTapped()
}

class MYNavigationBar : UINavigationBar {

    @IBOutlet var titleLabel: MYLabel!
    @IBOutlet var optionButton: UIButton!
    @IBOutlet var backButton: UIButton!

    weak var myDelegate:MYNavigationBarDelegate?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        let nib = UINib(nibName: "MYNavigationBar", bundle: nil)
        let nibView = nib.instantiate(withOwner: self, options: nil).first as! UIView
        
        nibView.frame = self.bounds
        nibView.backgroundColor = .myBlue
        nibView.tintColor = UIColor.white
        self.addSubview(nibView)
    }
    
    @IBAction func MYNavigationBarBackButtonTapped() {
        self.myDelegate?.myNavigationBarBackButtonTapped()
    }
    
    @IBAction func myNavigationBarOptionButtonTapped () {
        self.myDelegate?.myNavigationBarOptionButtonTapped()
    }

    func header (ctrl: MYViewController) {
        if ctrl.optionImage == nil {
            optionButton.isHidden = true
        } else {
            optionButton.isHidden = false
            optionButton.setImage(ctrl.optionImage, for: UIControl.State.normal)
        }
        
        if ctrl.headerTitle == nil {
            titleLabel.text = ""
        } else {
            titleLabel.text = ctrl.headerTitle?.toLang()
        }
        if ctrl.headerImage == nil {
            return
        }

        let imageAttach = NSTextAttachment()
        imageAttach.image =  self.resizeImage(image: ctrl.headerImage!, newWidth: 20)
        
        let str = NSMutableAttributedString(attributedString: NSAttributedString(attachment: imageAttach))
        let txt = NSMutableAttributedString(attributedString: NSAttributedString(string:" " + titleLabel.text!))
        
        str.append(txt)
        self.titleLabel.attributedText = str
        self.titleLabel.tintColor = UIColor.white
    }
    
    private func resizeImage(image: UIImage, newWidth: CGFloat) -> UIImage? {
        let scale = newWidth / image.size.width
        let newHeight = image.size.height * scale
        UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
        image.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
}
