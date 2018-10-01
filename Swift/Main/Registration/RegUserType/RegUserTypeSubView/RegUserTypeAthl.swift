//
//  RegistrationSubView
//  EnciSport
//
//  Created by Luciano Calderano on 28/10/16.
//  Copyright © 2016 Kanito. All rights reserved.
//

import UIKit
import LcLib

class RegUserTypeAthl : MYInputView {

    private let defWebTermCond = "http://www.enci.it/privacy.php"
    
    @IBOutlet var lblCert: MYLabel!
    @IBOutlet var lblCond: MYLabel!

    @IBOutlet private var txtCogn: MYTextField!
    @IBOutlet private var txtNome: MYTextField!
    @IBOutlet private var txtCodF: MYTextField!
    @IBOutlet private var txtCard: MYTextField!
    
    @IBOutlet private var selectSess: UISegmentedControl!
    @IBOutlet private var selectCert: UISegmentedControl!
    @IBOutlet private var selectCond: UISegmentedControl!

    @IBOutlet private var pickerNasc: UIDatePicker!

    override func awakeFromNib () {
        super.awakeFromNib()
        
        selectSess.setTitle(Lng("gender0"), forSegmentAt: 0)
        selectSess.setTitle(Lng("gender1"), forSegmentAt: 1)

        selectCert.setTitle(Lng("NO"), forSegmentAt: 0)
        selectCert.setTitle(Lng("SI"), forSegmentAt: 1)

        selectCond.setTitle(Lng("NO"), forSegmentAt: 0)
        selectCond.setTitle(Lng("SI"), forSegmentAt: 1)

        let attb = [NSAttributedString.Key.font: UIFont.withSize(18)]
        selectSess.setTitleTextAttributes(attb, for: UIControl.State.normal)

        pickerNasc.maximumDate = Calendar.current.date(byAdding: .year, value: -18, to: Date())
        
        #if arch(x86_64)
            txtCogn.text = "CognomeMio";
            txtNome.text = "NomeMio";
            txtCodF.text = "CodFisMio";
            txtCard.text = "TesseraMia";
        #endif
    }
    
    func checkFields () -> JsonDict {
        if (txtCogn.text?.isEmpty)! {
            txtCogn.showError()
            return [:]
        }
        if (txtNome.text?.isEmpty)! {
            txtNome.showError()
            return [:]
        }
        if (txtCodF.text?.isEmpty)! {
            txtCodF.showError()
            return [:]
        }

        if (selectCert.selectedSegmentIndex == 0) {
            if ((self.inputViewDelegate?.frame)!.contains(selectCert.frame.origin) == false) {
                self.inputViewDelegate?.scrollRectToVisible(selectCert.frame, animated: true)
            }
            lblCert.textColor = .myRed
            return [:]
        }
        if (selectCond.selectedSegmentIndex == 0) {
            if ((self.inputViewDelegate?.frame)!.contains(selectCond.frame.origin) == false) {
                self.inputViewDelegate?.scrollRectToVisible(selectCond.frame, animated: true)
            }
            lblCond.textColor = .myRed
            return [:]
        }
        self.endEditing(true)
        
        let dic = [
            "last_name"      : txtCogn.text!,
            "name"           : txtNome.text!,
            "ssn"            : txtCodF.text!,
            "enci_card_code" : txtCard.text!,
            "birthday"       : pickerNasc.date.toString(withFormat: "dd-MM-yyyy"),
            "gender"         : selectSess.selectedSegmentIndex,
            ] as JsonDict
        return dic
    }
    
    private func validateUser(candidate: String) -> Bool {
        let valid = "[A-Za-z0-9]{3,20}"
        return NSPredicate(format: "SELF MATCHES %@", valid).evaluate(with: candidate)
    }
    private func validateEmail(candidate: String) -> Bool {
        let valid = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}"
        return NSPredicate(format: "SELF MATCHES %@", valid).evaluate(with: candidate)
    }
    
    @IBAction func openTermAndContitions () {
        openUrl(defWebTermCond)
    }

}
