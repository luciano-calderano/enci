//
//  ResultsShowCell
//  EnciSport
//
//  Created by Luciano Calderano on 26/10/16.
//  Copyright © 2016 Kanito. All rights reserved.
//

import UIKit

protocol QualificationDescriptionDataSource: class {
    func getQualificationDescription (_ key: String) -> String
}

class ResultsShowCell: UITableViewCell {
    class func dequeue (_ tableView: UITableView, indexPath: IndexPath) -> ResultsShowCell {
        return tableView.dequeueReusableCell(withIdentifier: "ResultsShowCell", for: indexPath) as! ResultsShowCell
    }
    var combined = false
    var openId = 0

    var dicData = JsonDict() {
        didSet {
            showData(dicData)
        }
    }
    
    weak var dataSource: QualificationDescriptionDataSource?
    
    @IBOutlet private var chest_number: MYLabel!
    @IBOutlet private var dog: MYLabel!
    @IBOutlet private var name: MYLabel!
    @IBOutlet private var business_name: MYLabel!
    @IBOutlet private var qualification: MYLabel!
    @IBOutlet private var errors: MYLabel!
    @IBOutlet private var time: MYLabel!
    @IBOutlet private var ranking: MYLabel!
    @IBOutlet private var chip: MYLabel!
    @IBOutlet private var breed: MYLabel!

    @IBOutlet private var imageview: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()

        ranking.layer.masksToBounds = true
        ranking.layer.cornerRadius = ranking.frame.size.width / 2
    }
    
    private func showData(_ dicMain: JsonDict) -> Void {
        var dic = dicMain.dictionary("Subscriber")
        
        chest_number.text = dic.string("chest_number")
        business_name.text = dic.string("Association.business_name")
        if (business_name.text?.isEmpty)! {
            business_name.text = "(Privato)"
        }
        
        dic = dic.dictionary("Binomial")
        name.text = dic.string("Athlete.name")  + " " + dic.string("Athlete.last_name")
        dog.text = dic.string("Dog.name")
        chip.text = dic.string("Dog.microchip")
        breed.text = dic.string("Dog.Breed.name")
        

        let key = (self.openId > 0) ? "AgilityDogOpenResult" : "AgilityDogResult"
        dic = dicMain.dictionary(key)
        
        qualification.text = self.dataSource?.getQualificationDescription(dic.string("qualification"))
        
        if (self.combined) {
            time.text = dic.string("combined_time")
            
            var f = 0.0
            f = dic.double("combined_track_penalties")
            let pen = (f > 0) ? String.init(format: "%.2f", f) : "0"

            f = dic.double("combined_time_penalties")
            let tim = (f > 0) ? String.init(format: "%.2f", f) : "0"

            f = dic.double("combined_tot_penalties")
            let tot = (f > 0) ? String.init(format: "%.2f", f) : "0"

            errors.text = "TrackP (" + pen + ") TimeP (" + tim + ") TotalP (" + tot + ")"
        } else {
            let f = dic.double("tot_penalties")
            let err = dic.int("errors")
            let ref = dic.int("refuses")
            let pen = f > 0 ? String.init(format: "%.2f",f) : "0"

            errors.text = "Err (" + String(err) + ") Ref (" + String(ref) + ") Pen (" + pen + ")"
            time.text = dic.string("time")
        }
        
        ranking.text = dic.string("ranking")
        if (ranking.text?.isEmpty)! {
            ranking.text = qualification.text?.left(lenght: 1).uppercased()
            ranking.backgroundColor = UIColor.gray
            time.isHidden = true
            imageview.isHidden = true
        } else {
            ranking.backgroundColor = .myBlue
            time.isHidden = false
            imageview.isHidden = false
        }
    }
}
