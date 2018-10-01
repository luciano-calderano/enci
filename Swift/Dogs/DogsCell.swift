//
//  BinomiCell.swift
//  EnciSport
//
//  Created by Luciano Calderano on 26/10/16.
//  Copyright © 2016 Kanito. All rights reserved.
//

import UIKit
import LcLib

class DogsCell: UITableViewCell {
    class func dequeue (_ tableView: UITableView, indexPath: IndexPath) -> DogsCell {
        return tableView.dequeueReusableCell(withIdentifier: "DogsCell", for: indexPath) as! DogsCell
    }
    
    var dicData = JsonDict() {
        didSet {
            showData(dicData.dictionary("Dog"))
        }
    }

    @IBOutlet private var microchip: MYLabel!
    @IBOutlet private var athlete_name: MYLabel!
    @IBOutlet private var name: MYLabel!
    @IBOutlet private var breed_name: MYLabel!
    @IBOutlet private var class_name: MYLabel!

    private func showData(_ dic: JsonDict) -> Void {
        microchip.text = dic.string("microchip")
        athlete_name.text = dic.string("athlete_name") + " " + dic.string("athlete_last_name")
        name.text = dic.string("name").uppercased()
        name.layer.cornerRadius = 5
        let gender = dic.int("gender") > 0 ? Lng("gender1") :  Lng("gender0")
        breed_name.text = dic.string("breed_name") + " (" + gender + " " + dic.string("age") + " " + Lng("yearsOld") + ")"
        class_name.text = dic.string("class_name") + "  - " + dic.string("category_name")
    }
}
