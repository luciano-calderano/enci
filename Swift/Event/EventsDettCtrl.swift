//
//  EventsDettCtrl
//  EnciSport
//
//  Created by Luciano Calderano on 28/10/16.
//  Copyright © 2016 Kanito. All rights reserved.
//

import UIKit
import LcLib

class EventsDettCtrl: MYViewController {
    class func Instance () -> EventsDettCtrl {
        let sb = UIStoryboard.init(name: "Events", bundle: nil)
        return sb.instantiateViewController(withIdentifier: "EventsDettCtrl") as! EventsDettCtrl
    }
    var eventId = 0
    var dicEvnt = JsonDict()
    
    @IBOutlet private var scrlEvntDett: UIScrollView!
    @IBOutlet private var imvLocandinaFull: UIImageView!
    @IBOutlet private var btnSign: UIButton!
    
    var eventView: EventsDettSubView?
    let rectLocandina = CGRect.zero
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.eventView = EventsDettSubView.addToScrollView(scrlEvntDett)
        self.showSubview()
        btnSign.isHidden = User.shared.userType == User.UserType.Club
    }
    
    private func loadData(){
        let size = UIScreen.main.bounds.size
        let request =  MYHttpRequest.base("event-details")
        request.json = [
            "event_id"   : self.eventId,
            "img_height" : size.height,
            "img_width"  : size.width,
            "img_crop"   : 1,
            "img_bg"     : "FFFFFF",
        ]
        request.start() { (success, response) in
            if success {
                self.httpResponse(response)
            }
        }
    }
    
    private func httpResponse(_ resultDict: JsonDict) {
        self.dicEvnt = resultDict.dictionary("event.Event")
        self.showSubview()
    }
    
    private func showSubview() {
        if self.dicEvnt.count == 0 {
            return
        }
        eventView?.dicData = self.dicEvnt
        self.eventId = self.dicEvnt.int("id")
        
        btnSign.isEnabled = false
        let dIni = self.dicEvnt.string("subscription_start").toDate(withFormat: Config.DateFmt.Db)
        let today = Date()
        if (today.compare(dIni!) == .orderedAscending) {
            btnSign.setTitle(Lng("evntEarl"), for: .normal)
            btnSign.backgroundColor = .myBlue
            return
        }
        let dEnd = self.dicEvnt.string("subscription_end").toDate(withFormat: Config.DateFmt.Db)
        if (today.compare(dEnd!) == .orderedDescending) {
            btnSign.setTitle(Lng("subsClos"), for: .normal)
            btnSign.backgroundColor = .myRed
            return
        }
        btnSign.backgroundColor = .myGreen
        btnSign.isEnabled = true
        
        if self.dicEvnt.int("subs_status") == 0 {
            let user = User.shared
            if user.userType == .Athl {
                btnSign.setTitle(Lng("evntSuOk"), for: .normal)
            } else {
                btnSign.setTitle(Lng("evntLog0"), for: .normal)
                btnSign.isEnabled = false
            }
        } else {
            btnSign.setTitle(Lng("evntUnsu"), for: .normal)
            btnSign.backgroundColor = .myRed
        }
    }
    
    @IBAction func btnSubscribe () {
        let ctrl = EventsSubsBinomiCtrl.Instance()
        ctrl.eventId = self.eventId
        navigationController?.show(ctrl, sender: self)
    }
}

