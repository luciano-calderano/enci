//
//  ResultsShowCtrl
//  EnciSport
//
//  Created by Luciano Calderano on 28/10/16.
//  Copyright © 2016 Kanito. All rights reserved.
//

import UIKit
import LcLib

class ResultsShowCtrl: MYViewController {
    class func Instance () -> ResultsShowCtrl {
        let sb = UIStoryboard.init(name: "Results", bundle: nil)
        return sb.instantiateViewController(withIdentifier: "ResultsShowCtrl") as! ResultsShowCtrl
    }
    @IBOutlet private var tableView: UITableView!
    @IBOutlet private var btn01: MYButton!
    @IBOutlet private var btn02: MYButton!
    @IBOutlet private var btn03: MYButton!
    @IBOutlet private var lblNoResults: MYLabel!
    
    var openId = 0
    var trialId = 0
    var classId = 0
    var categId = 0
    var titleSelection = ""

    private let qualificationDescription = QualificationDescription()
    private var combined = false
    private var testId = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.lblNoResults.layer.borderColor = UIColor.myBlue.cgColor
        self.lblNoResults.layer.borderWidth = 2.0
        self.lblNoResults.layer.cornerRadius = 5.0
        self.lblNoResults.isHidden = true
        
        self.btn01.setTitle(Lng("agilAgil"), for: .normal)
        self.btn02.setTitle(Lng("agilJump"), for: .normal)
        self.btn03.setTitle(Lng("agilComb"), for: .normal)

        self.selectedBtn(self.btn01)
    }

    @IBAction func btnTestClick(sender: MYButton) {
        self.selectedBtn(sender)
    }

    func selectedBtn (_ btn: MYButton) {
        self.btn01.backgroundColor = .myBlue
        self.btn02.backgroundColor = .myBlue
        self.btn03.backgroundColor = .myBlue
        btn.backgroundColor = .myGreen
        switch btn {
        case btn01, btn02:
            self.loadResults(btn)
        default:
            self.loadCombined()
        }
    }
    
    func loadResults(_ btn: MYButton) {
        combined = false
        var dic = [
            "event_id"      : self.trialId,
            "test_id"       : btn == btn01 ? 1 : 2,
            "class_id"      : self.classId,
            "category_id"   : self.categId,
        ]
        var page = ""
        if (self.openId > 0) {
            dic["open_id"] = self.openId
            page = "agility-dog/opens/ranking/partial"
        } else {
            page = "agility-dog/ranking/partial"
        }
        self.loadPage(page, jsonDic: dic)
    }

    func loadCombined(){
        combined = true
        var dic = [
            "event_id"      : self.trialId,
            "class_id"      : self.classId,
            "category_id"   : self.categId,
            ]
        var page = ""
        if (self.openId > 0) {
            dic["open_id"] = self.openId
            page = "agility-dog/opens/ranking/combined"
        } else {
            page = "agility-dog/ranking/combined"
        }
        self.loadPage(page, jsonDic: dic)
    }

    func loadPage(_ page: String, jsonDic: JsonDict) {
        let request =  MYHttpRequest.software(page)
        request.json = jsonDic
        
        request.start() { (success, response) in
            if success {
                self.httpResponse(response)
            }
        }
    }
    
    private func httpResponse(_ resultDict: JsonDict) {
        dataArray = resultDict.array("ranking")
        if (dataArray.count == 0) {
            self.lblNoResults.isHidden = false
            self.lblNoResults.alpha = 1.0
            UIView.animate(withDuration: 1.0, animations: {
                self.lblNoResults.alpha = 0.0
            }, completion: { (Bool) in
                self.lblNoResults.isHidden = true
            })
        }
        tableView.setContentOffset(CGPoint.zero, animated: false)
        tableView.reloadData()
    }
    
    
// MARK:-
    
    private class QualificationDescription: QualificationDescriptionDataSource {
        private var dicQualificationDescription = JsonDict()
        
        init() {
            let request =  MYHttpRequest.base("agility-dog/qualifications")
            request.json = [ : ]
            
            request.start() { (success, response) in
                if success {
                    self.dicQualificationDescription = response.dictionary("qualifications")
                }
            }
        }
        
        func getQualificationDescription (_ key: String) -> String {
            let desc = self.dicQualificationDescription.string(key)
            return desc.isEmpty ? key : desc
        }
    }
}
    
    // MARK:- table view

extension ResultsShowCtrl: UITableViewDelegate, UITableViewDataSource {
   func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 20
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if (dataArray.count == 0) {
            return nil
        }
        
        let label = MYLabel()
        label.backgroundColor = UIColor.white
        label.textColor = .myBlue
        label.font = .withSize(16)
        label.text = " " + titleSelection
        return label
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArray.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = ResultsShowCell.dequeue(tableView, indexPath: indexPath)
        
        cell.dataSource = self.qualificationDescription
        cell.openId = self.openId
        cell.combined = self.combined
        cell.dicData = dataArray[indexPath.row] as! JsonDict

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}


