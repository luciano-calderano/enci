//
//  BinomiCtrl.swift
//  EnciSport
//
//  Created by Luciano Calderano on 28/10/16.
//  Copyright © 2016 Kanito. All rights reserved.
//

import UIKit
import LcLib

class EventsSubsBinomiCtrl: MYViewController {
    class func Instance () -> EventsSubsBinomiCtrl {
        let sb = UIStoryboard.init(name: "Events", bundle: nil)
        return sb.instantiateViewController(withIdentifier: "EventsSubsBinomiCtrl") as! EventsSubsBinomiCtrl
    }
    
    @IBOutlet private var tableView: UITableView!
    
    var binomialId = 0
    var userId = 0
    var eventId = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        
        userId = User.shared.userId
        loadData()
    }
    
    private func loadData(){
        let request =  MYHttpRequest.base("book-event")
        request.json = [
            "event_id"      : eventId,
            "owner_id"      : userId,
            "binomial_id"   : binomialId,
            "sender_device" : "app_ios",
            "rules"         : "true",
        ]
        request.start() { (success, response) in
            if success {
                self.httpResponse(response)
            }
        }
    }
    private func httpResponse(_ resultDict: JsonDict) {
        switch (resultDict.int("status")) {
        case 0:
            showAlert(resultDict.string("error_msg"), message: "", okBlock: nil)
        case 1:
            gotoPaypal (resultDict)
        case 2:
            dataArray = resultDict.array("binomials_list")
            tableView.reloadData()
        default:
            break
        }
    }
    private func gotoPaypal(_ resultDict: JsonDict) {
        var array = [[String: String]]()
        for dict in resultDict.array("receivers_list") as! [JsonDict] {
            array.append(["email": dict.string("email"), "payment": dict.string("payment")])
        }
        
        let ctrl = PayPalSwiftCtrl.Instance()
        ctrl.dataArray = array;
        ctrl.key = "\(eventId).\(binomialId)"
        ctrl.ipnNotificationUrl = resultDict.string("ipnNotificationUrl")
        navigationController?.show(ctrl, sender: self)
    }
}

// MARK:- table view

extension EventsSubsBinomiCtrl: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArray.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCell.CellStyle.subtitle, reuseIdentifier: "Cell")
        
        cell.textLabel?.font = .withSize(16)
        cell.textLabel?.textColor = .myBlue
        cell.detailTextLabel?.font = .withSize(14)
        cell.detailTextLabel?.textColor = .darkGray
        
        let dict = dataArray[indexPath.row] as! JsonDict
        cell.textLabel?.text = dict.string("Athlete.name") + " " +
            dict.string("Athlete.last_name") + " " +
            Lng("subsCon") + " " +
            dict.string("Dog.name") + " (" +
            dict.string("Dog.Breed.name") + ")"
        
        cell.detailTextLabel?.text = dict.string("Association.business_name")
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let dict = dataArray[indexPath.row] as! JsonDict
        binomialId = dict.int("Binomial.id")
        loadData()
    }
}

