//
//  BinomiCell.swift
//  EnciSport
//
//  Created by Luciano Calderano on 26/10/16.
//  Copyright © 2016 Kanito. All rights reserved.
//

import UIKit
import LcLib

class ResultsCell: UITableViewCell {
    class func dequeue (_ tableView: UITableView, indexPath: IndexPath) -> ResultsCell {
        return tableView.dequeueReusableCell(withIdentifier: "ResultsCell", for: indexPath) as! ResultsCell
    }
    
    var dicData = JsonDict() {
        didSet {
            showData(dicData.dictionary("Event"))
        }
    }
    
    @IBOutlet private var title: MYLabel!
    @IBOutlet private var region_name: MYLabel!
    @IBOutlet private var province_name: MYLabel!
    @IBOutlet private var association_business_name: MYLabel!
    @IBOutlet private var num_subscribers: MYLabel!
    @IBOutlet private var event_start_day: MYLabel!
    @IBOutlet private var event_start_month: MYLabel!
    @IBOutlet private var infoTrophy: MYLabel!

    private func showData(_ dic: JsonDict) -> Void {

        region_name.text = dic.string("region_name")
        province_name.text = dic.string("province_name")
        association_business_name.text = dic.string("association_business_name")
        
        var subs = dic.string("num_subscribers")
        if (subs.isEmpty) {
            subs = "0"
        }
        num_subscribers.text = subs + ": " + Lng("resuPart")
        title.text = Config.Challenge.name
        
        let eventDate = dic.string("event_start").toDate(withFormat: Config.DateFmt.Db)
        
        event_start_day.text = eventDate!.toString(withFormat: "dd")
        event_start_month.text = eventDate!.toString(withFormat: "MMM")

        let sino =  dic.string("enci_trophy") == "No" ? Lng("NO") : Lng("SI")
        infoTrophy.text = Lng("Trophy") + ": " + sino

    }
}
