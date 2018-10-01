//
//  RegistrationSubView
//  EnciSport
//
//  Created by Luciano Calderano on 28/10/16.
//  Copyright © 2016 Kanito. All rights reserved.
//

import UIKit
import LcLib

protocol RegistrationSubViewDelegate {
    func registrationDidSelectRegionCity()
    func registrationDidSelectCountry()
    func registrationDidSelect(dicUserData: JsonDict, userType: User.UserType)
}

class RegistrationSubView : MYInputView {
    
    @IBOutlet var lblCitt: MYLabel!
    @IBOutlet var lblRegi: MYLabel!
    @IBOutlet var lblPaes: MYLabel!
    
    @IBOutlet private var txtUser: MYTextField!
    @IBOutlet private var txtPass: MYTextField!
    @IBOutlet private var txtConf: MYTextField!
    @IBOutlet private var txtMail: MYTextField!
    @IBOutlet private var txtTelN: MYTextField!
    @IBOutlet private var txtIndi: MYTextField!
    @IBOutlet private var txtCap_: MYTextField!
    
    @IBOutlet private var selectType: UISegmentedControl!
    
    var strPaesId = ""
    var strRegiId = ""
    var strCittId = ""
    var strCittaStraniera = ""
    
    var inputDelegate: RegistrationSubViewDelegate?
    
    override func awakeFromNib () {
        super.awakeFromNib()
        
        lblRegi.textColor = .myRed
        lblCitt.textColor = .myRed
        
        txtTelN.keyboardType = .numberPad;
        txtCap_.keyboardType = .numberPad;
        
        selectType.setTitle(Lng("UserTypeA"), forSegmentAt: 0)
        selectType.setTitle(Lng("UserTypeC"), forSegmentAt: 1)
        
        let attributes = [NSAttributedString.Key.font: UIFont.withSize(18)]
        selectType.setTitleTextAttributes(attributes, for: UIControl.State.normal)
        strCittaStraniera = ""
        #if arch(x86_64)
            txtUser.text = "utente"
            txtPass.text = "qwerty"
            txtIndi.text = "Via roma 57"
            txtCap_.text = "00100"
            txtMail.text = "email@email.com"
            txtConf.text = "email@email.com"
            txtTelN.text = "06060"
            lblRegi.text = "Regione prova"
            lblCitt.text = "Citta prova"
            lblRegi.textColor = .myBlue
            lblCitt.textColor = .myBlue
            strRegiId = "1"
            strCittId = "1"
        #endif
        
        self.loadDefaultCountry()
    }
    
    private func loadDefaultCountry () -> Void {
        let request = MYHttpRequest.base("default-country")
        request.json = [:]
        
        request.start() { (success, response) in
            if success {
                let dic = response.dictionary("default_country")
                self.lblPaes.text = dic.string("Country.name")
                self.strPaesId = dic.string("Country.id")
            }
        }
    }
    
    @IBAction func btnCountry () {
        inputDelegate?.registrationDidSelectCountry()
    }
    
    @IBAction func btnRegions () {
        inputDelegate?.registrationDidSelectRegionCity()
    }
    
    @IBAction func btnSingUp () {
        if validateUser(candidate: txtUser.text!) == false {
            txtUser.showError()
            return
        }
        if (txtPass.text?.isEmpty)! {
            txtPass.showError()
            return
        }
        if self.validateEmail(candidate: txtMail.text!) == false {
            txtMail.showError()
            return
        }
        if (txtConf.text != txtMail.text) {
            txtConf.showError()
            return
        }
        if (txtTelN.text?.isEmpty)! {
            txtTelN.showError()
            return
        }
        if (txtIndi.text?.isEmpty)! {
            txtIndi.showError()
            return
        }
        if (txtCap_.text?.isEmpty)! {
            txtCap_.showError()
            return
        }
        if strCittId.isEmpty {
            return
        }
        
        self.endEditing(true)
        let dic = [
            "username"       : txtUser.text!,
            "password"       : txtPass.text!,
            "email"          : txtMail.text!,
            "account_type"   : selectType.selectedSegmentIndex == 0 ? "athlete" : "association",
            "phone"          : txtTelN.text!,
            "address"        : txtIndi.text!,
            "cap"            : txtCap_.text!,
            "city_id"        : strCittId,
            "country_id"     : strPaesId,
            "foreign_city"   : strCittaStraniera,
            "terms"          : 1,
            ] as JsonDict
        inputDelegate?.registrationDidSelect(dicUserData: dic,
                                             userType: selectType.selectedSegmentIndex == 0 ? User.UserType.Athl : User.UserType.Club)
    }
    
    private func validateUser(candidate: String) -> Bool {
        let valid = "[A-Za-z0-9]{3,20}"
        return NSPredicate(format: "SELF MATCHES %@", valid).evaluate(with: candidate)
    }
    private func validateEmail(candidate: String) -> Bool {
        let valid = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}"
        return NSPredicate(format: "SELF MATCHES %@", valid).evaluate(with: candidate)
    }
}
