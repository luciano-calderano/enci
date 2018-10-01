//
//  BinomiCell.swift
//  EnciSport
//
//  Created by Luciano Calderano on 26/10/16.
//  Copyright © 2016 Kanito. All rights reserved.
//

import UIKit

class RankShowCell: UITableViewCell {
    class func dequeue (_ tableView: UITableView, indexPath: IndexPath) -> RankShowCell {
        return tableView.dequeueReusableCell(withIdentifier: "RankShowCell", for: indexPath) as! RankShowCell
    }
    
    var dicData = JsonDict() {
        didSet {
            self.showData(dicData)
        }
    }

    @IBOutlet private var lblCurPos: MYLabel!
    @IBOutlet private var lblAtlNam: MYLabel!
    @IBOutlet private var lblDogNam: MYLabel!
    @IBOutlet private var lblDogBrd: MYLabel!
    @IBOutlet private var lblPoints: MYLabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        lblCurPos.layer.cornerRadius = lblCurPos.frame.size.height / 2;
        lblCurPos.layer.masksToBounds = true
    }
    
    private func showData(_ dic: JsonDict) -> Void {
        lblCurPos.text = dic.string("AgilityDogOpenTrophy.ranking")
        lblPoints.text = dic.string("AgilityDogOpenTrophy.score")
        
        lblAtlNam.text = dic.string("Binomial.Athlete.name").capitalized + " " +
                         dic.string("Binomial.Athlete.last_name").capitalized
        
        lblDogNam.text = dic.string("Binomial.Dog.name").uppercased()
        lblDogBrd.text = dic.string("Binomial.Dog.Breed.name").capitalized
    }
}
