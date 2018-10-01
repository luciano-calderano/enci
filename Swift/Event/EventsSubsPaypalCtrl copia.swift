//
//  BinomiCtrl.swift
//  EnciSport
//
//  Created by Luciano Calderano on 28/10/16.
//  Copyright © 2016 Kanito. All rights reserved.
//

import UIKit

enum PaymentStatus: Int {
    case PAYMENTSTATUS_SUCCESS
    case PAYMENTSTATUS_FAILED
    case PAYMENTSTATUS_CANCELED
}
class EventsSubsPaypalCtrl: MYViewController, UITableViewDelegate, UITableViewDataSource, PayPalPaymentDelegate {
    class func instanceFromSb (_ sb: UIStoryboard!) -> EventsSubsPaypalCtrl {
        return sb.instantiateViewController(withIdentifier: "EventsSubsPaypalCtrl") as! EventsSubsPaypalCtrl
    }
    
    @IBOutlet private var tableView: UITableView!
    
    var payPalConfig = PayPalConfiguration()
    var environment:String = PayPalEnvironmentNoNetwork
//    var environment:String = PayPalEnvironmentSandbox
//    var environment:String = PayPalEnvironmentProduction

    var paypalDict = JsonDict()
    var totale = 0.0
    let valuta = "EUR"
    var ipnNotificationUrl = ""
    var paypalStatus = PaymentStatus.PAYMENTSTATUS_CANCELED.hashValue
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")

        self.dataArray = self.paypalDict.array("receivers_list") as! [JsonDict]
        ipnNotificationUrl = self.paypalDict.string(ipnNotificationUrl)
        if UIApplication.shared.isIgnoringInteractionEvents == true {
            UIApplication.shared.endIgnoringInteractionEvents()
        }

        self.paypal_initialization()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.paypal_initialization()
    }
    
    @IBAction private func paypal_initialization() {
        PayPalMobile.initializeWithClientIds(forEnvironments: [
                PayPalEnvironmentProduction: "APP-80W284485P519543T",
                PayPalEnvironmentSandbox   : "APP-59C55318YH321703Y"
            ])
        PayPalMobile.preconnect(withEnvironment: environment)
    }
    
    // MARK: table view
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataArray.count + 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return (indexPath.row == self.dataArray.count) ? 80 : 40
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = UITableViewCell(style: UITableViewCellStyle.value1, reuseIdentifier: "Cell")
        cell.textLabel?.font = UIFont.mySize(16)
        cell.textLabel?.textColor = UIColor.myBlue()
        cell.detailTextLabel?.font = UIFont.mySize(18)
        cell.detailTextLabel?.textColor = UIColor.darkGray
        
        if (indexPath.row == self.dataArray.count) {
            cell.backgroundColor = UIColor.init(r: 250, g: 250, b: 250)
            cell.textLabel?.text = ""
            cell.detailTextLabel?.text = String (totale)  + " " + valuta
            cell.contentView.layer.borderColor = UIColor.myBlue().cgColor;
            cell.contentView.layer.borderWidth = 1;

            let btn = UIButton.init(frame: CGRect.init(x: 15, y: 15, width: 200, height: 45))
            btn.setTitle("Paga con paypal", for: .normal)
            btn.backgroundColor = UIColor.myBlue()
            btn.addTarget(self, action: #selector(pagaConPaypal), for: .touchUpInside)
            cell.addSubview(btn)
        }
        else {
            let dict = self.dataArray[indexPath.row] as! JsonDict
            cell.textLabel?.text = dict.string("email")
            cell.detailTextLabel?.text = dict.string("payment") + " " + valuta
            cell.contentView.layer.borderWidth = 0;
            totale += dict.double("payment")
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func pagaConPaypal () {
        self.showAlert("Confermo il pagamento ?",
                       message: valuta + ": " + String(totale),
                       cancelBlock: nil,
                       okBlock: { (UIAlertAction) in
                        self.confermaPagamento()
        })
    }
    
    func confermaPagamento() {
        payPalConfig.acceptCreditCards = false
        payPalConfig.merchantName = "EnciSport"
        var items = [Any]()
        for dict in self.dataArray {
            let dic = dict as! JsonDict
            let item = PayPalItem(name: dic.string("email"),
                                  withQuantity: 1,
                                  withPrice: NSDecimalNumber(string: dic.string("payment")),
                                  withCurrency: self.valuta,
                                  withSku: dic.string("email"))
            items.append(item)
        }
        let total = PayPalItem.totalPrice(forItems: items)
        let payment = PayPalPayment (amount: total,
                                    currencyCode: self.valuta,
                                    shortDescription: "EnciSport",
                                    intent: .sale)
        payment.items = items
//        payment.memo = "Memo " + self.ipnNotificationUrl
//        payment.ipnUrl = self.ipnNotificationUrl;
    }
        
        
    func payPalPaymentDidCancel(_ paymentViewController: PayPalPaymentViewController) {
        print("PayPal Payment Cancelled")
        paymentViewController.dismiss(animated: true, completion: nil)
    }
    
    func payPalPaymentViewController(_ paymentViewController: PayPalPaymentViewController, didComplete completedPayment: PayPalPayment) {
        print("PayPal Payment Success !")
        do {
            let json = try JSONSerialization.data(withJSONObject: completedPayment.confirmation,
                                                         options: [])
            print (json)
        }
        catch {
            print("Json error")
        }

        paymentViewController.dismiss(animated: true, completion: { () -> Void in
            // send completed confirmaion to your server
            print("Here is your proof of payment:\n\n\(completedPayment.confirmation)\n\nSend this to your server for confirmation and fulfillment.")
            
        })
    }
}

/*

- (void)paymentSuccessWithKey:(NSString *)payKey andStatus:(PayPalPaymentStatus)paymentStatus {
 strIdPayment = payKey;
 NSLog(@"%@", payKey);
 NSString *severity = ([PayPal getPayPalInst].responseMessage)[@"severity"];
 NSString *category = ([PayPal getPayPalInst].responseMessage)[@"category"];
 NSString *errorId  = ([PayPal getPayPalInst].responseMessage)[@"errorId"];
 NSString *message  = ([PayPal getPayPalInst].responseMessage)[@"message"];
 NSString *msg = [NSString stringWithFormat:
 @"paymentSuccessWithKey:\nseverity: %@\ncategory: %@\nerrorId: %@\nmessage: %@\nPayPalPaymentStatus: %d",
 severity, category, errorId, message, paymentStatus];
 myLog(msg);
 status = PAYMENTSTATUS_SUCCESS;
 }
 
 - (void)paymentFailedWithCorrelationID:(NSString *)correlationID {
 NSString *severity = ([PayPal getPayPalInst].responseMessage)[@"severity"];
 NSString *category = ([PayPal getPayPalInst].responseMessage)[@"category"];
 NSString *errorId  = ([PayPal getPayPalInst].responseMessage)[@"errorId"];
 NSString *message  = ([PayPal getPayPalInst].responseMessage)[@"message"];
 NSString *msg = [NSString stringWithFormat:
 @"paymentFailedWithCorrelationID:\nseverity: %@\ncategory: %@\nerrorId: %@\nmessage: %@\nCorrelation: %@",
 severity, category, errorId, message, correlationID];
 myLog(msg);
 
 status = PAYMENTSTATUS_FAILED;
 }
 
 - (void)paymentCanceled {
 status = PAYMENTSTATUS_CANCELED;
 }
 
 - (void)paymentLibraryExit {
 NSString *title = @"";
 NSString *msg;
 switch (status) {
 case PAYMENTSTATUS_SUCCESS:
 title = @"Confermato !";
 msg = [NSString stringWithFormat:@"Id: %@", strIdPayment];
 break;
 case PAYMENTSTATUS_FAILED:
 title = @"Order failed";
 msg = @"Your order failed. Touch \"Pay with PayPal\" to try again.";
 break;
 case PAYMENTSTATUS_CANCELED:
 title = @"Order canceled";
 msg = @"You canceled your order. Touch \"Pay with PayPal\" to try again.";
 break;
 default:
 title = @"Order canceled";
 msg = [NSString stringWithFormat:@"status: %d", status];
 }
 [self showAlertWithTitle:title
 msg:msg confirm:^{
 [self.navigationController popToRootViewControllerAnimated:YES];
 }];
 
 */
