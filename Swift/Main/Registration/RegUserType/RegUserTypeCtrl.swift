//
//  RegistrationnCtrl
//  EnciSport
//
//  Created by Luciano Calderano on 28/10/16.
//  Copyright © 2016 Kanito. All rights reserved.
//

import UIKit
import LcLib

class RegUserTypeCtrl : MYViewController, RegUserTypeClubDelegate, UserListDelegate {
    class func instanceFromSb (_ sb: UIStoryboard!) -> RegUserTypeCtrl {
        return sb.instantiateViewController(withIdentifier: "RegUserTypeCtrl") as! RegUserTypeCtrl
    }
    
    @IBOutlet private var scrlUser: MYInputScrollView!
    var userType: User.UserType!
    var dicUser = JsonDict()
    var userTypeInputView: MYInputView?
    
    private var dicUserType = JsonDict()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        switch self.userType.hashValue {
        case User.UserType.Athl.hashValue :
            let sub = RegUserTypeAthl.addInputViewToInputScrollView(scrlUser) as! RegUserTypeAthl
            userTypeInputView = sub
        case User.UserType.Club.hashValue :
            let sub = RegUserTypeClub.addInputViewToInputScrollView(scrlUser) as! RegUserTypeClub
            sub.regUserTypeClubDelegate = self
            userTypeInputView = sub
        default:
            break
        }
    }
    
    @IBAction func signUpBtnTapped () {
        switch self.userType.hashValue {
        case User.UserType.Athl.hashValue :
            let sub = self.userTypeInputView as! RegUserTypeAthl
            dicUserType = sub.checkFields()
        case User.UserType.Club.hashValue :
            let sub = self.userTypeInputView as! RegUserTypeClub
            dicUserType = sub.checkFields()
        default:
            break
        }
        
        if (dicUserType.count == 0) {
            return
        }
        
        self.showAlert(Lng("warning"), message: Lng("warnSignUp"), okBlock: {
            (action) in
            self.registration()
        })
    }
    
    private func registration () {
        var dic = [String: String]()
        for (k, v) in self.dicUser {
            dic[k] = v as? String
        }
        for (k, v) in self.dicUserType {
            dic[k] = v as? String
        }
        
        let request = MYHttpRequest.base("registration")
        request.json = dic
        
        request.start() { (success, response) in
            guard success else { return }
            var title = ""
            if response.int("status") == 0 {
                title = response.string("error_msg")
            } else {
                title = Lng("sgnUpOk")
                User.shared.saveUser(dic,
                                     name: self.dicUser.string("username"),
                                     pass: self.dicUser.string("password"))
            }
            self.showAlert(title, message: "", okBlock: { (UIAlertAction) in
                if response.int("status") > 0 {
                    _ = self.navigationController?.popToRootViewController(animated: true)
                }
            })
        }
    }
    
    func openAffililatedList() {
        let ctrl = UserListCtrl.Instance()
        ctrl.delegate = self
        ctrl.listType = .affiliates
        navigationController?.show(ctrl, sender: self)
    }
    func userListDelegate(type: UserListType, id: String, name: String) {
        let sub = self.userTypeInputView as! RegUserTypeClub
        sub.lblAffiName.text = name
        sub.strIdAffi = id
    }
}
