//
//  ClubList
//  EnciSport
//
//  Created by Luciano Calderano on 26/10/16.
//  Copyright © 2016 Kanito. All rights reserved.
//

import UIKit
import LcLib
import MessageUI

class ViewSwipe: UIView {
    var strPhon = ""
    var strMail = ""
    var mainCtrl: ClubList?
    var timer = Timer()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.cornerRadius = 10;
        let tap = UITapGestureRecognizer.init(target: self, action: #selector (hideView))
        self.addGestureRecognizer(tap)
    }
    
    func startTimer()  {
        let sel = #selector(hideView)
        timer.invalidate()
        timer = Timer.scheduledTimer(timeInterval: 3, target: self, selector: sel, userInfo: nil, repeats: false)
    }
    
    @objc func hideView () {
        timer.invalidate()
        UIView.animate(withDuration: 0.3, animations: {
            var rect = self.frame
            rect.origin.x = UIScreen.main.bounds.size.width
            self.frame = rect;
        })
    }
    
    @IBAction func btnPhone () {
        openUrl("telprompt://" +  strPhon)
    }
    
    @IBAction func btnEmail () {
        guard let ctrl = mainCtrl else { return }
        let mailComposeViewController = ctrl.configuredMailComposeViewController(strMail)
        if MFMailComposeViewController.canSendMail() {
            ctrl.present(mailComposeViewController, animated: true, completion: nil)
        } else {
            ctrl.showSendMailErrorAlert("Could Not Send Email")
        }
    }
}
//
//extension ViewSwipe: MFMailComposeViewControllerDelegate {
//    func configuredMailComposeViewController(_ dest: String) -> MFMailComposeViewController {
//        let mailComposerVC = MFMailComposeViewController()
//        mailComposerVC.mailComposeDelegate = self
//        mailComposerVC.setToRecipients([dest])
//        mailComposerVC.setSubject("")
//        mailComposerVC.setMessageBody("", isHTML: false)
//
//        return mailComposerVC
//    }
//
//    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
//        if (error != nil) {
//            self.showSendMailErrorAlert((error?.localizedDescription)!)
//        }
//        controller.popViewController(animated: true)
//    }
//
//    func showSendMailErrorAlert(_ title: String) {
//        let alertController = UIAlertController(title: title, message: "", preferredStyle: .alert)
//        let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
//        alertController.addAction(defaultAction)
//        mainCtrl?.present(alertController, animated: true, completion: nil)
//    }
//}

//MARK:-

class ClubList: MYViewController {
    
    @IBOutlet private var tableView: UITableView!
    @IBOutlet private var txtSrch: UITextField!
    @IBOutlet private var viewSwipe: ViewSwipe!
    
    var numPage = 1
    var maxRecords = 25
    var lastPage = false
    
    var strRegionId = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadData()
        viewSwipe.isHidden = true
        viewSwipe.mainCtrl = self
        
        let swipe = UISwipeGestureRecognizer.init(target: self, action: #selector (swipeRight(sender:)))
        swipe.direction = .right
        tableView.addGestureRecognizer(swipe)
    }
    
    override func myNavigationBarOptionButtonTapped() {
        let ctrl = UserListCtrl.Instance()
        ctrl.delegate = self
        ctrl.listType = .regionsOnly
        navigationController?.show(ctrl, sender: self)
    }
    
    @objc func swipeRight(sender: UILongPressGestureRecognizer) {
        let p = sender.location(in: tableView)
        let indexPath = tableView.indexPathForRow(at: p)
        let dic = dataArray[(indexPath?.row)!] as! JsonDict
        viewSwipe.strPhon = dic.string("phone")
        viewSwipe.strMail = dic.string("email")
        viewSwipe.startTimer()
        let cell = tableView.cellForRow(at: indexPath!)
        cell?.addSubview(viewSwipe)
        
        var rect = viewSwipe.frame
        rect.origin.x = -rect.size.width
        rect.origin.y = 24
        rect.size.height = (cell?.frame.size.height)! - (rect.origin.y + 2);
        viewSwipe.frame = rect
        viewSwipe.isHidden = false
        
        UIView.animate(withDuration: 0.3, animations: {
            var rect = self.viewSwipe.frame
            rect.origin.x = 0;
            self.viewSwipe.frame = rect;
        })
    }
    
    private func loadData() {
        let request =  MYHttpRequest.base("associations-list")
        request.json = [
            "page"       : numPage,
            "maxrecords" : maxRecords,
            "region_id"  : strRegionId,
            "lang_id"    : Lng("iso"),
            "src"        : txtSrch!.text!,
            "img_width"  : 80,
            "img_height" : 80,
            "img_crop"   : 2,
            "img_bg"     : "FFFFFF",
        ]
        request.start() { (success, response) in
            if success {
                self.httpResponse(response)
            }
        }
    }
    
    private func httpResponse(_ resultDict: JsonDict) {
        let arr = resultDict.array("associations")
        
        lastPage = (arr.count < maxRecords) ? true : false
        if (numPage == 1) {
            dataArray.removeAll()
        }
        dataArray += arr
        tableView.reloadData()
    }
    
    // MARK: Search
    
    @IBAction func btnSrch() {
        numPage = 1
        loadData()
        txtSrch?.resignFirstResponder()
    }
}
// MARK: table view

extension ClubList: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArray.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120.0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = ClubListCell.dequeue(tableView, indexPath: indexPath)
        cell.dicData = dataArray[indexPath.row] as! JsonDict
        cell.delegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

// MARK:- UIScrollViewDelegate

extension ClubList: UIScrollViewDelegate {
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

extension ClubList: UserListDelegate {
    func userListDelegate(type: UserListType, id: String, name: String) {
        numPage = 1
        strRegionId = id
        self.headerTitle = name
        loadData()
    }
}

// MARK:- ClubListCellDelegate

extension ClubList: ClubListCellDelegate {
    func clubListCellDidPhoneTapped(value: String) {
        openUrl("telprompt://" + value)
    }
    
    func clubListCellDidEmailTapped(value: String) {
        let mailComposeViewController = configuredMailComposeViewController(value)
        if MFMailComposeViewController.canSendMail() {
            present(mailComposeViewController, animated: true, completion: nil)
        } else {
            showSendMailErrorAlert("Could Not Send Email")
        }
    }
}

// MARK:- MFMailComposeViewControllerDelegate

extension ClubList: MFMailComposeViewControllerDelegate {
    func configuredMailComposeViewController(_ dest: String) -> MFMailComposeViewController {
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self
        mailComposerVC.setToRecipients([dest])
        mailComposerVC.setSubject("")
        mailComposerVC.setMessageBody("", isHTML: false)
        
        return mailComposerVC
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        if error == nil {
            controller.popViewController(animated: true)
        } else {
            showSendMailErrorAlert((error?.localizedDescription)!)
        }
    }
    
    func showSendMailErrorAlert(_ title: String) {
        let alertController = UIAlertController(title: title, message: "", preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(defaultAction)
        present(alertController, animated: true, completion: nil)
    }
}
