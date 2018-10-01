//
//  BinomiCtrl.swift
//  EnciSport
//
//  Created by Luciano Calderano on 28/10/16.
//  Copyright © 2016 Kanito. All rights reserved.
//

import UIKit
import LcLib

class EventsCtrl: MYViewController {
    @IBOutlet private var tableView: UITableView!
    @IBOutlet private var txtSrch: UITextField!
    
    var dicEventsMonth = [String: [JsonDict]]()
    
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

    private func loadData(){
        let request =  MYHttpRequest.base("list-events")
        request.json = [
            "page"           : numPage,
            "maxrecords"     : maxRecords,
            "src"            : txtSrch.text!,
            "type"           : Config.Challenge.type,
            "challenge_type" : Config.Challenge.desc,
            "country_id"     : "",
            "region_id"      : strZoneId,
            "city_id"        : "",
            "img_width"      : 120,
            "img_height"     : 80,
            "img_crop"       : 1,
            "img_bg"         : "FFFFFF",
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
            self.dicEventsMonth.removeAll()
        }
        for dict in array as! [JsonDict] {
            let str = dict.string("Event.event_start")
            let annoMese = str.mid(startAtChar: 7, lenght: 4) + str.mid(startAtChar: 4, lenght: 2)
            
            var arrMese = self.dicEventsMonth[annoMese] ?? []
            arrMese.append(dict)
            dicEventsMonth[annoMese] = arrMese
        }
        
        dataArray = dicEventsMonth.keys.sorted {
            $0 < $1
        }
        tableView.reloadData()
    }
    
    // MARK: Search
    
    @IBAction func btnSrch() {
        numPage = 1
        loadData()
        txtSrch?.resignFirstResponder()
    }
}
    // MARK:- table view
    
extension EventsCtrl: UITableViewDelegate, UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return dataArray.count
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

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let mese = dataArray[section] as! String
        let arr = self.dicEventsMonth[mese]
        return arr!.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 145
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = EventsCell.dequeue(tableView, indexPath: indexPath)
        cell.dicData = self.getDictAtIndex(indexPath)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let dict  = self.getDictAtIndex(indexPath)
        
        let ctrl = EventsDettCtrl.Instance()
        ctrl.dicEvnt = dict.dictionary("Event")
        ctrl.eventId = dict.int("Event.id")
        navigationController?.show(ctrl, sender: self)
    }

    private func getDictAtIndex(_ indexPath: IndexPath) -> JsonDict {
        let month = dataArray[indexPath.section] as! String
        let array = self.dicEventsMonth[month]! as [JsonDict]
        return array[indexPath.row]
    }
}

// MARK:- UIScrollViewDelegate
    
extension EventsCtrl: UIScrollViewDelegate {
   func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if (lastPage == true) {
            return
        }
        let lastRow = (tableView.indexPath(for: tableView.visibleCells.last!)?.row)! + 1
        if lastRow == self.numPage * self.maxRecords {
            numPage += 1
            loadData()
        }
    }
}

// MARK:- UserListDelegate

extension EventsCtrl: UserListDelegate {
    func userListDelegate(type: UserListType, id: String, name: String) {
        self.numPage = 1
        self.strZoneId = id
        loadData()
    }
}

