//
//  MYInputScrollView.swift
//  Lc
//
//  Created by Luciano Calderano on 17/11/16.
//  Copyright © 2016 Kanito. All rights reserved.
//

import UIKit

class MYInputView: UIView, UITextFieldDelegate {
    var inputScrollView: MYInputScrollView?
    @IBOutlet weak var inputViewDelegate: MYInputScrollView?
//    weak var inputViewDelegate: MYInputScrollView?
    weak var delegate: UIScrollViewDelegate?
    
    class func addInputViewToInputScrollView(_ inputScrollView: MYInputScrollView) -> MYInputView {
        let classPath = NSStringFromClass(self).components(separatedBy: ".")
        let className = classPath.last
        let me = Bundle.main.loadNibNamed(className!, owner: self, options: nil)?.first as! MYInputView
        inputScrollView.addSubview(me)
        inputScrollView.contentSize = me.bounds.size
        me.inputViewDelegate = inputScrollView
        return me
    }
    
//    override func layoutSubviews () {
//        if (self.frame.size.height == self.inputViewDelegate?.contentSize.height) {
//            return
//        }
//        super.layoutSubviews()
//        var rect = self.frame
//        rect.size = (self.inputViewDelegate?.contentSize)!
//        self.frame = rect
//    }
    

    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.inputViewDelegate?.textFieldDidBeginEditing(textField as! MYTextField)
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.inputViewDelegate?.textFieldDidEndEditing(textField as! MYTextField)
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return (self.inputViewDelegate?.textFieldShouldReturn(textField as! MYTextField))!
    }
}

/******************************/

class MYInputScrollView: UIScrollView {
    var activeField: MYTextField?
    var kbSize = CGSize.init(width: 0, height: 0)

    override func awakeFromNib() {
        super.awakeFromNib()
        self.initialize()
    }
    
    override func willMove(toWindow newWindow: UIWindow?) {
        super.willMove(toWindow: newWindow)
        if newWindow == nil {
            NotificationCenter.default.removeObserver(self)
        }
    }
    
    private func initialize() {
        self.clipsToBounds = true
        self.showsVerticalScrollIndicator = false
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.keyboardWillShow(notification:)),
                                               name:UIResponder.keyboardWillShowNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.keyboardWillHide(notification:)),
                                               name:UIResponder.keyboardWillHideNotification,
                                               object: nil)
    }

    func textFieldDidBeginEditing(_ textField: MYTextField) {
        self.activeField = textField
        self.newActiveField()
    }
    
    func textFieldDidEndEditing(_ textField: MYTextField) {
//        self.activeField = nil;
    }
    
    func textFieldShouldReturn(_ textField: MYTextField) -> Bool {
        self.returnPressed()
        return true
    }

    @objc func keyboardWillShow (notification: NSNotification) {
        if (kbSize.height > 0) {
            return
        }
        
        let sizeValue = notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as! NSValue
        
        kbSize = sizeValue.cgRectValue.size
        
        let contentInsets = UIEdgeInsets.init(top: 0.0, left: 0.0, bottom: kbSize.height, right: 0.0)
        self.contentInset = contentInsets;
        self.scrollIndicatorInsets = contentInsets;
    }
    
    @objc func keyboardWillHide (notification: NSNotification) {
        self.contentInset = .zero
        self.scrollIndicatorInsets = self.contentInset
        
        var p = self.contentOffset
        p.y -= kbSize.height
        if (p.y < 0) {
            p.y = 0
        }
        self.contentOffset = p
    }
    
    @objc func returnPressed() {
        self.activeField = self.activeField?.nextTextField
        self.newActiveField()
    }
    
    @objc func closeKeyboard() {
        self.endEditing (true)
    }
    
    private func newActiveField()  {
        if self.activeField != nil {
            self.activeField?.becomeFirstResponder()
            self.redesignKeyboard()
            self.moveView()
        } else {
            self.closeKeyboard()
        }
    }
    
    private func redesignKeyboard() {
        if UIDevice.current.userInterfaceIdiom != UIUserInterfaceIdiom.phone {
            return
        }

        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.default
        let chiudi = UIBarButtonItem.init(title: "\u{2716}", style: .plain, target: self, action: #selector(closeKeyboard))
        let space = UIBarButtonItem.init(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let ok = UIBarButtonItem.init(title: "\u{2714}", style: .plain, target: self, action: #selector (returnPressed))
        
        toolBar.setItems([chiudi, space, ok], animated: false)
        self.activeField?.inputAccessoryView = toolBar
        toolBar.sizeToFit()
    }

    private func moveView() {
        var visibleFrame = self.frame;
        visibleFrame.size.height -= kbSize.height
        
        let activeFieldPoint = self.activeField?.convert(CGPoint(x: 0, y: 0), to: self)
        var rect = self.activeField?.frame
        rect?.origin = activeFieldPoint!
        self.scrollRectToVisible(rect!, animated: true)
    }
}
