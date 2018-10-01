//
//  LoginCtrl
//  EnciSport
//
//  Created by Luciano Calderano on 28/10/16.
//  Copyright © 2016 Kanito. All rights reserved.
//

import UIKit
import LcLib

class LoginCtrl : MYViewController {
    
    @IBOutlet private var txtUser: MYTextField!
    @IBOutlet private var txtPass: MYTextField!
    @IBOutlet private var passLabel: MYLabel!
    @IBOutlet private var btnPwdRes: UIButton?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        #if arch(x86_64)
            txtUser.text = "jollysa87asso"; // asd
            txtUser.text = "jollysa87atleta";     //
            txtPass.text = "qwerty";
            //   txtUser.text = @"TOVE";
            //   txtPass.text = @"DUST2003";
        #endif
        btnPwdRes?.setTitle(Lng("pwdReset"), for: UIControl.State.normal)
    }
    
    @IBAction func btnLogin() {
        if (txtUser?.text?.isEmpty)! {
            txtUser?.becomeFirstResponder()
            return
        }
        if (txtPass?.text?.isEmpty)! {
            txtPass?.becomeFirstResponder()
            return
        }
        self.view.endEditing(true)
        if (btnPwdRes?.isHidden)! {
            self.resetPassword()
        } else {
            self.login()
        }
    }

    @IBAction func btnReset() {
        passLabel.text = "E-MAIL"
        passLabel.textColor = .myRed
        btnPwdRes?.isHidden = true
        txtPass?.text = ""
    }

    private func login () -> Void {
        let request = MYHttpRequest.base("login")
        request.json =  [
            "username": txtUser.text!,
            "password": txtPass.text!,
        ]
        
        request.start() { (success, response) in
            if success {
                if (response.int("status") == 0) {
                    self.showAlert("Error",
                                   message: response.string("error_msg"),
                                   okBlock: { (UIAlertAction) in
                                    _ = self.navigationController?.popToRootViewController(animated: true)
                    })
                }
                else {
                    User.shared.saveUser(response,
                                         name: self.txtUser.text!,
                                         pass: self.txtPass.text!)
                    _ = self.navigationController?.popToRootViewController(animated: true)
                }
            }
        }
    }
    
    private func resetPassword () -> Void {
        self.view.endEditing(true)

        let request = MYHttpRequest.base("reset-password")
        request.json =  [
            "username": txtUser.text!,
            "email":    txtPass.text!,
        ]
        
        request.start() { (success, response) in
            self.showAlert("Reset password",
                           message: success ? Lng("sgnReset") : "Password reset error",
                           okBlock: { (UIAlertAction) in
                    _ = self.navigationController?.popToRootViewController(animated: true)
            })
        }
    }


    @IBAction func btnSingUp() {
        let sb = UIStoryboard (name: "Registration", bundle: nil)
        let ctrl = sb.instantiateInitialViewController()
        navigationController?.show(ctrl!, sender: self)
    }
}
