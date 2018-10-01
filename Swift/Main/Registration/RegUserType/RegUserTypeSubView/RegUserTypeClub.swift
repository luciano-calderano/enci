//
//  RegistrationSubView
//  EnciSport
//
//  Created by Luciano Calderano on 28/10/16.
//  Copyright © 2016 Kanito. All rights reserved.
//

import UIKit
import LcLib

protocol RegUserTypeClubDelegate : class {
    func openAffililatedList()
}

class RegUserTypeClub : MYInputView {

    private let defWebTermCond = "http://www.enci.it/privacy.php"

    var strIdAffi = ""
    @IBOutlet var lblAffiName: MYLabel!

    @IBOutlet var lblDich: MYLabel!
    @IBOutlet var lblCond: MYLabel!
    @IBOutlet var lblAffi: MYLabel!

    @IBOutlet private var txtAtti: MYTextField!

    @IBOutlet private var selectDich: UISegmentedControl!
    @IBOutlet private var selectCond: UISegmentedControl!
    @IBOutlet private var selectOrga: UISegmentedControl!
    
    @IBOutlet var affiView: UIView!
    @IBOutlet var bottomView: UIView!
    @IBOutlet var btnAffi: MYButton!

    weak var regUserTypeClubDelegate: RegUserTypeClubDelegate?
    
    override func awakeFromNib () {
        super.awakeFromNib()
        
        selectCond.setTitle(Lng("NO"), forSegmentAt: 0)
        selectCond.setTitle(Lng("SI"), forSegmentAt: 1)
        
        selectOrga.setTitle(Lng("NO"), forSegmentAt: 0)
        selectOrga.setTitle(Lng("SI"), forSegmentAt: 1)
        
        selectOrga.setTitle(Lng("NO"), forSegmentAt: 0)
        selectOrga.setTitle(Lng("SI"), forSegmentAt: 1)
        
        let tap = UIGestureRecognizer.init(target: self, action: #selector (openTermAndContitions))
        lblCond.isUserInteractionEnabled = true
        lblCond.addGestureRecognizer(tap)
    }

    func checkFields () -> JsonDict {
        lblAffi.textColor = .myBlue
        lblCond.textColor = .myBlue
        lblDich.textColor = .myBlue
        
        if (txtAtti.text?.isEmpty)! {
            txtAtti.showError()
            return [:]
        }
        
        self.endEditing(true)
        
        if (selectDich.selectedSegmentIndex == 0) {
            lblDich.textColor = .myRed
            return [:]
        }
        
        if (selectCond.selectedSegmentIndex == 0) {
            if ((self.inputViewDelegate?.frame)!.contains(selectCond.frame.origin) == false) {
                self.inputViewDelegate?.scrollRectToVisible(selectCond.frame, animated: true)
            }
            lblCond.textColor = .myRed
            return [:]
        }
        if (selectOrga.selectedSegmentIndex == 1 && self.strIdAffi.isEmpty) {
            if ((self.inputViewDelegate?.frame)!.contains(selectOrga.frame.origin) == false) {
                self.inputViewDelegate?.scrollRectToVisible(selectOrga.frame, animated: true)
            }
            lblAffi.textColor = .myRed
            return [:]
        }
        let dic = [
            "business_name"          : txtAtti.text!,
            "responsable"            : 1,
            "organize_events"        : selectOrga.selectedSegmentIndex,
            "referral_association_id": self.strIdAffi,
            ] as JsonDict
        return dic
    }

    @IBAction func selectorOrgChange () {
        self.setNeedsLayout()
    }
    
    
    @IBAction func btnAffiList () {
        self.regUserTypeClubDelegate?.openAffililatedList()
    }
    
    func setAffiliatedName(name: String, id: String) {
        lblAffi.text = name
        self.strIdAffi = id
    }
    
    @IBAction func openTermAndContitions () {
        openUrl(defWebTermCond)
    }
}
