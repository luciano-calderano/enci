//
//  Main
//  EnciSport
//
//  Created by Luciano Calderano on 28/10/16.
//  Copyright © 2016 Kanito. All rights reserved.
//

import UIKit

enum NextSb: String {
    case User
    case Login
    case News
    case Events
    case Results
    case Ranking
    case Dogs
    case Club
}

class MainCtrl: MYViewController {
    @IBOutlet private var btnNews: UIButton!
    @IBOutlet private var btnRuns: UIButton!
    @IBOutlet private var btnResu: UIButton!
    @IBOutlet private var btnStat: UIButton!
    @IBOutlet private var btnClub: UIButton!
    @IBOutlet private var btnDogs: UIButton!
    @IBOutlet private var btnUser: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.myNavigationBar?.backgroundColor = UIColor.white
        self.view.backgroundColor = .myBlue
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.myNavigationBar?.isHidden = true
    }
    
    @IBAction func btnClick (_ sender: UIButton) {
        var strStor = ""
        switch (sender) {
        case btnUser:
            let logged = User.shared.userType == User.UserType.None
            strStor = logged ? NextSb.Login.rawValue : NextSb.User.rawValue
        case btnNews:
            strStor = NextSb.News.rawValue
        case btnRuns:
            strStor = NextSb.Events.rawValue
        case btnResu:
            strStor = NextSb.Results.rawValue
        case btnStat:
            strStor = NextSb.Ranking.rawValue
        case btnDogs:
            strStor = NextSb.Dogs.rawValue
        case btnClub:
            strStor = NextSb.Club.rawValue
        default:
            return
        }
        self.gotoNextViewCtrl(strStor)
    }
    
    private func gotoNextViewCtrl (_ strStor: String) {
        let sb = UIStoryboard (name: strStor, bundle: nil)
        let ctrl = sb.instantiateInitialViewController()
        
        navigationController?.show(ctrl!, sender: self)
    }
    
}
