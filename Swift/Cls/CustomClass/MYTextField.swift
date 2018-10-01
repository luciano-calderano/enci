//
//  MYTextField
//  Enci
//
//  Created by Luciano Calderano on 03/11/16.
//  Copyright © 2016 Kanito. All rights reserved.
//

import UIKit

class MYTextField: UITextField {
    
    @IBOutlet var nextTextField: MYTextField?
    
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
        self.font = .withSize(16)
        self.layer.borderColor = UIColor.myBlue.cgColor
        self.layer.borderWidth = 1
        self.layer.cornerRadius = 5
    }

    func showError () {
        self.becomeFirstResponder()
        self.layer.borderColor = UIColor.myRed.cgColor
        delayWithSeconds(2) {
            self.layer.borderColor = UIColor.myBlue.cgColor
        }
    }
    
    private func delayWithSeconds(_ seconds: Double, completion: @escaping () -> ()) {
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
            completion()
        }
    }
}
