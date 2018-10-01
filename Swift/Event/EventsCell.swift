//
//  EventsCell
//  EnciSport
//
//  Created by Luciano Calderano on 26/10/16.
//  Copyright © 2016 Kanito. All rights reserved.
//

import UIKit
import LcLib

class EventsCell: UITableViewCell {
    class func dequeue (_ tableView: UITableView, indexPath: IndexPath) -> EventsCell {
        return tableView.dequeueReusableCell(withIdentifier: "EventsCell", for: indexPath) as! EventsCell
    }
    
    var dicData = JsonDict() {
        didSet {
            showData(dicData.dictionary("Event"))
        }
    }
    
    @IBOutlet private var title: MYLabel!
    @IBOutlet private var region_name: MYLabel!
    @IBOutlet private var place: MYLabel!
    @IBOutlet private var association_business_name: MYLabel!
    @IBOutlet private var subscription: MYLabel!
    @IBOutlet private var event_start: MYLabel!
    @IBOutlet private var infoTrophy: MYLabel!

    private func showData(_ dic: JsonDict) -> Void {
        region_name.text = dic.string("region_name").capitalized
        place.text = dic.string("place")
        association_business_name.text = Lng("eventOrg") + " " +  dic.string("association_business_name")
        title.text = Config.Challenge.name
        
        let eventDate = dic.string("event_start").toDate(withFormat: Config.DateFmt.Db)
        event_start.text = " " + eventDate!.toString(withFormat: "dd")

        let sino = (dic.string("enci_trophy") == "No") ? "NO" : "SI"
        infoTrophy.text = Lng("Trophy") + ": " + Lng(sino)

        let dIni = dic.string("subscription_start").toDate(withFormat: Config.DateFmt.Db)
        let dEnd = dic.string("subscription_end").toDate(withFormat: Config.DateFmt.Db)
        let today = Date()
        if (today.compare(dIni!) == .orderedAscending || today.compare(dEnd!) == .orderedDescending) {
            subscription.text = Lng("subsClos")
            subscription.textColor = .myRed
        } else {
            subscription.text = Lng("subsOpen")
            subscription.textColor = .myGreen
        }
    }
}
