//
//  RegistrationnCtrl
//  EnciSport
//
//  Created by Luciano Calderano on 28/10/16.
//  Copyright © 2016 Kanito. All rights reserved.
//

import UIKit

class RegistrationnCtrl: MYViewController {
    @IBOutlet private var scrlUser: MYInputScrollView!
    var registrationSubView: RegistrationSubView?
    override func viewDidLoad() {
        super.viewDidLoad()
        registrationSubView = RegistrationSubView.addInputViewToInputScrollView(scrlUser) as? RegistrationSubView
        registrationSubView?.inputDelegate = self
    }
    
    func registrationDidSelectRegionCity() {
        openUserList(type: .regionAndCity)
    }
    func registrationDidSelectCountry() {
        openUserList(type: .countries)
    }
    
    private func openUserList(type: UserListType) {
        let ctrl = UserListCtrl.Instance()
        ctrl.delegate = self
        ctrl.listType = type
        navigationController?.show(ctrl, sender: self)
    }
}

//MARK:- UserListDelegate

extension RegistrationnCtrl : UserListDelegate {
    func userListDelegate(type: UserListType, id: String, name: String) {
        guard let reg = registrationSubView else { return }
        switch type {
        case .regionAndCity :
            reg.strRegiId = id
            reg.lblRegi.text = name
        case .cities :
            reg.strCittId = id
            reg.lblCitt.text = name
        case .countries :
            reg.strPaesId = id
            reg.lblPaes.text = name
        default:
            break
        }
    }
}

//MARK:- RegistrationSubViewDelegate

extension RegistrationnCtrl : RegistrationSubViewDelegate {
    func registrationDidSelect(dicUserData: JsonDict, userType: User.UserType) {
        let ctrl = RegUserTypeCtrl.instanceFromSb(self.storyboard)
        ctrl.dicUser = dicUserData
        ctrl.userType = userType
        navigationController?.show(ctrl, sender: self)
    }
}
