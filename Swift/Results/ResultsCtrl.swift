//
//  BinomiCtrl.swift
//  EnciSport
//
//  Created by Luciano Calderano on 28/10/16.
//  Copyright © 2016 Kanito. All rights reserved.
//

import UIKit
import LcLib

class ResultsCtrl: MYViewController {
    @IBOutlet private var tableView: UITableView!
    @IBOutlet private var txtSrch: UITextField!
    
    var dicEventsMonth = [String: [JsonDict]]()
    var trialId = 0
    
    var numPage = 1
    var maxRecords = 25
    var lastPage = false
    
    var strZoneId = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        txtSrch!.placeholder = Lng("srch")
        loadData()
    }
    
    override func myNavigationBarOptionButtonTapped() {
        let ctrl = UserListCtrl.Instance()
        ctrl.delegate = self
        ctrl.listType = .regionsOnly
        navigationController?.show(ctrl, sender: self)
    }
    
    private func loadData() {
        let request =  MYHttpRequest.base("list-events")
        
        request.json = [
            "page"           : numPage,
            "maxrecords"     : maxRecords,
            "type"           : Config.Challenge.type,
            "challenge_type" : Config.Challenge.desc,
            "src"            : txtSrch.text!,
            "country_id"     : "",
            "region_id"      : strZoneId,
            "city_id"        : "",
            "img_width"      : 120,
            "img_height"     : 80,
            "img_crop"       : 1,
            "img_bg"         : "FFFFFF",
            "past_events"    : 1,
        ]
        request.start() { (success, response) in
            if success {
                self.httpResponse(response)
            }
        }
    }
    
    private func httpResponse(_ resultDict: JsonDict) {
        let array = resultDict.array("events")
        
        lastPage = (array.count < maxRecords) ? true : false
        if (numPage == 1) {
            tableView.setContentOffset(CGPoint.zero, animated: false)
            dicEventsMonth.removeAll()
        }
        for dict in array as! [JsonDict] {
            let str = dict.string("Event.event_start")
            let annoMese = str.mid(startAtChar: 7, lenght: 4) + str.mid(startAtChar: 4, lenght: 2)
            var arrMese = dicEventsMonth[annoMese] ?? []
            arrMese.append(dict)
            dicEventsMonth[annoMese] = arrMese
        }
        
        dataArray = dicEventsMonth.keys.sorted {
            $0 > $1
        }
        tableView.reloadData()
    }
    
    
    private func getDictAtIndex(_ indexPath: IndexPath) -> JsonDict {
        let month = dataArray[indexPath.section] as! String
        let array = dicEventsMonth[month]! as [JsonDict]
        return array[indexPath.row]
    }
    
    private func loadTrial () {
        let request =  MYHttpRequest.base("agility-dog/opens/list-trials")
        request.json = [
            "event_id" : trialId,
        ]
        request.start() { (success, response) in
            if success {
                self.httpResponseTrial(response)
            }
        }
    }
    
    private func httpResponseTrial (_ resultDict: JsonDict) {
        if resultDict.int ("totals") > 0 {
            showOpenType (resultDict.array("opens") as! Array<JsonDict>)
        } else {
            showOptions()
        }
    }
    
    private func showOpenType (_ arrOpen: [JsonDict]) {
        let ctrl = ResultsTypeCtrl.Instance()
        ctrl.trialId = trialId
        ctrl.dataArray = arrOpen
        navigationController?.show(ctrl, sender: self)
    }
    
    private func showOptions () {
        let ctrl = ResultsOptsCtrl.Instance()
        ctrl.trialId = trialId
        navigationController?.show(ctrl, sender: self)
    }
    
    // MARK: Search
    
    @IBAction func btnSrch() {
        numPage = 1
        loadData()
        txtSrch?.resignFirstResponder()
    }
}

// MARK:- table view

extension ResultsCtrl: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return dataArray.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let mese = dataArray[section] as! String
        let arr = dicEventsMonth[mese]
        return arr!.count
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let label = MYLabel()
        label.backgroundColor = .myBlue
        label.textColor = UIColor.white
        label.font = .withSize(24)
        
        let eventDate = (dataArray[section] as! String).toDate(withFormat: "yyyyMM")
        label.text = " " + eventDate!.toString(withFormat: "MMMM yyyy").capitalized
        return label
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 125
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = ResultsCell.dequeue(tableView, indexPath: indexPath)
        cell.dicData = getDictAtIndex(indexPath)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let dict  = getDictAtIndex(indexPath)
        trialId = dict.int("Event.id")
        
        loadTrial()
    }
}

// MARK:- UIScrollViewDelegate

extension ResultsCtrl: UIScrollViewDelegate {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if (lastPage == true) {
            return
        }
        let lastRow = (tableView.indexPath(for: tableView.visibleCells.last!)?.row)! + 1
        if lastRow == numPage * maxRecords {
            numPage += 1
            loadData()
        }
    }
}

// MARK:- UserListDelegate

extension ResultsCtrl: UserListDelegate {
    func userListDelegate(type: UserListType, id: String, name: String) {
        numPage = 1
        strZoneId = id
        loadData()
    }
}

