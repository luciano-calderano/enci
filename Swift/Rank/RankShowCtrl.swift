//
//  RankShowCtrl
//  EnciSport
//
//  Created by Luciano Calderano on 28/10/16.
//  Copyright © 2016 Kanito. All rights reserved.
//

import UIKit
class RankShowCtrl: MYViewController {
    class func Instance () -> RankShowCtrl {
        let sb = UIStoryboard.init(name: "Ranking", bundle: nil)
        return sb.instantiateViewController(withIdentifier: "RankShowCtrl") as! RankShowCtrl
    }
    
    var trofeoType = 1
    var year = 0
    var areaId = 0
    var cateId = 0
    var strAreaDesc = ""
    var strCateDesc = ""

    @IBOutlet private var btn1: MYButton!
    @IBOutlet private var btn2: MYButton!
    @IBOutlet private var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        btn1.setTitle("Junior", for: .normal)
        btn2.setTitle("Senior", for: .normal)
        
        selectedButton(btn: btn1)
        headerTitle = strCateDesc + " - " + strAreaDesc
    }
    
    @IBAction func buttonTapped(sender: MYButton) {
        selectedButton(btn: sender)
    }

    private func selectedButton(btn: MYButton) {
        switch btn {
        case btn1:
            trofeoType = 1
            btn1.backgroundColor = .myGreen
            btn2.backgroundColor = .myBlue
        case btn2:
            trofeoType = 2
            btn1.backgroundColor = .myBlue
            btn2.backgroundColor = .myGreen
        default:
            break
        }
        loadData()
    }

    private func loadData() {
        let request =  MYHttpRequest.software("agility-dog/opens/trophy")
        request.json = [
            "year"         : self.year,
            "region_id"    : "",
            "area_id"      : self.areaId,
            "class_id"     : trofeoType,
            "category_id"  : self.cateId,
        ]
        request.start() { (success, response) in
            if success {
                self.httpResponse(response)
            }
        }
    }
    
    private func httpResponse(_ resultDict: JsonDict) {
        dataArray = resultDict.array("trophy_ranking")
        tableView.reloadData()
    }
}

    // MARK:- table view
    
extension RankShowCtrl: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArray.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = RankShowCell.dequeue(tableView, indexPath: indexPath)
        cell.dicData = dataArray[indexPath.row] as! JsonDict
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }    
}

