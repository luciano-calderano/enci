//
//  PayPalSwiftCtrl
//  EnciSport
//
//  Created by Luciano Calderano on 28/10/16.
//  Copyright © 2016 Kanito. All rights reserved.
//

import UIKit

class PayPalSwiftCtrl: MYViewController {
    class func Instance () -> PayPalSwiftCtrl {
        PayPal.initialize(withAppID: "APP-80W284485P519543T", for: ENV_SANDBOX)
        //      PayPal.initialize(withAppID: "APP-59C55318YH321703Y", for: ENV_LIVE)
        let sb = UIStoryboard.init(name: "PayPalSwift", bundle: nil)
        return sb.instantiateViewController(withIdentifier: "PayPalSwiftCtrl") as! PayPalSwiftCtrl
    }
    
    @IBOutlet private var tableView: UITableView!
    
    var key = ""
    var ipnNotificationUrl = ""
    var payPalClass: PayPalClass?
    var totale = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        
        if UIApplication.shared.isIgnoringInteractionEvents == true {
            UIApplication.shared.endIgnoringInteractionEvents()
        }
        payPalClass = PayPalClass.init(main: self)
        payPalClass?.ipnNotificationUrl = ipnNotificationUrl
    }
}

// MARK:- table view

extension PayPalSwiftCtrl: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        
        let btn = UIButton() //.init(frame: CGRect.init(x: 5, y: 5, width: tableView.frame.size.width - 10, height: 70))
        
        btn.titleLabel?.font = .withSize(20)
        btn.setImage(UIImage.init(named: "paypal.png"), for: .normal)
        btn.setTitle("  " +  String.init(format: "%.02f", totale)  + " " + (payPalClass?.valuta)!, for: .normal)
        btn.backgroundColor = .myBlue
        btn.addTarget(self, action: #selector(openPayPal), for: .touchUpInside)
        
        return btn
    }
    @objc func openPayPal () {
        payPalClass?.openPayPal()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArray.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return (indexPath.row == dataArray.count) ? 80 : 40
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCell.CellStyle.value1, reuseIdentifier: "Cell")
        cell.textLabel?.font = .withSize(16)
        cell.textLabel?.textColor = .myBlue
        cell.detailTextLabel?.font = .withSize(18)
        cell.detailTextLabel?.textColor = UIColor.darkGray
        
        let dict = dataArray[indexPath.row] as! JsonDict
        cell.textLabel?.text = dict.string("email")
        cell.detailTextLabel?.text = dict.string("payment") + " " + (payPalClass?.valuta)!
        cell.contentView.layer.borderWidth = 0;
        totale += dict.double("payment")
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

class PayPalClass: NSObject, PayPalPaymentDelegate {
    enum PaymentStatus: Int {
        case PAYMENTSTATUS_SUCCESS
        case PAYMENTSTATUS_FAILED
        case PAYMENTSTATUS_CANCELED
    }
    
    let valuta = "EUR"
    var ipnNotificationUrl = ""
    var totale = 0.0
    var status = PaymentStatus.PAYMENTSTATUS_CANCELED
    var statusDesc = ""
    
    var mainCtrl: PayPalSwiftCtrl?
    
    init(main: PayPalSwiftCtrl) {
        super.init()
        mainCtrl = main
    }
    
    func openPayPal() {
        guard let pp = PayPal.getInst() else { return }
        pp.delegate = self
        pp.shippingEnabled = false
        pp.dynamicAmountUpdateEnabled = false
        pp.feePayer = FEEPAYER_EACHRECEIVER
        
        let payment = PayPalAdvancedPayment()
        payment.paymentCurrency = valuta
        payment.memo = "Memo " + ipnNotificationUrl
        payment.ipnUrl = ipnNotificationUrl
        
        payment.receiverPaymentDetails = NSMutableArray()
        for dict in (mainCtrl?.dataArray)! {
            let dic = dict as! JsonDict
            let detail = PayPalReceiverPaymentDetails()
            detail.description = "to: " + dic.string("email")
            detail.recipient = dic.string("email")
            detail.merchantName = "ENCI Sport";
            
            detail.subTotal = NSDecimalNumber(string: dic.string("payment"))
            detail.invoiceData = PayPalInvoiceData()
            detail.invoiceData.totalShipping = 0
            detail.invoiceData.totalTax = 0
            
            let item = PayPalInvoiceItem()
            item.totalPrice = detail.subTotal
            item.name = dic.string("email")
            detail.invoiceData.invoiceItems = NSMutableArray()
            detail.invoiceData.invoiceItems.add(item)
            payment.receiverPaymentDetails.add(detail)
        }
        pp.advancedCheckout(with: payment)
    }
    
    func paymentSuccess(withKey payKey: String!, andStatus paymentStatus: PayPalPaymentStatus) {
        status = PaymentStatus.PAYMENTSTATUS_SUCCESS
        statusDesc = payKey
        
        UserDefaults.standard.setValue([(mainCtrl?.key)!: payKey], forKey: "PayPal")
        UserDefaults.standard.setValue(payKey, forKey: "PayPal." + (mainCtrl?.key)!)
        
        print(payKey, status)
        print(PayPal.getInst().responseMessage)
    }
    
    func paymentFailed(withCorrelationID correlationID: String!) {
        status = PaymentStatus.PAYMENTSTATUS_FAILED
        statusDesc = correlationID
        print(correlationID)
        print(PayPal.getInst().responseMessage)
    }
    
    func paymentCanceled() {
        status = PaymentStatus.PAYMENTSTATUS_CANCELED
        print("paymentCanceled")
    }
    
    func paymentLibraryExit() {
        var title = ""
        var msg = "Touch [Pay with PayPal] to try again."
        switch status {
        case .PAYMENTSTATUS_SUCCESS:
            title = "Confermato !";
            msg = "Id: " + statusDesc
        case .PAYMENTSTATUS_FAILED:
            title = "Order failed !";
        default:
            title = "Order canceled";
        }
        mainCtrl?.showAlert(title, message: msg, okBlock: { (UIAlertAction) in
            _ = self.mainCtrl?.navigationController?.popViewController(animated: true)
        })
    }
}
