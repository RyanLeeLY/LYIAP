//
//  ViewController.swift
//  LYIAP
//
//  Created by 李尧 on 2016/10/19.
//  Copyright © 2016年 ryanleely. All rights reserved.
//

import UIKit
import StoreKit

class ViewController: UIViewController,LYIAPDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        let productsIds = NSSet(array: ["com.xxx.xxx.abc"])
        LYIAP.setRequestWithProducts(productsIds, delegate: self)
        LYIAP.startRequest()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func requestFinished() {
        // Do something when products have been loaded.
    }
    
    func transactionPurchased(_ queue: SKPaymentQueue, transaction: SKPaymentTransaction) {
        // Identifier of the product that has been purchased
        debugPrint(transaction.payment.productIdentifier)
        
        LYIAP.verifyPruchase(completion: {(receipt,error) in
            // You can verify the transaction. In this callback, you will get the receipt if the transaction is verified by the APPLE. You can compare some tranction infomation with the receipt.
            debugPrint(receipt)
        })
    }
    
    func transactionRestore(_ queue: SKPaymentQueue, transaction: SKPaymentTransaction) {
        // Identifier of the product that has been restored
        // You must add restore function to your app accroding to APPLE's provisions
        debugPrint(transaction.payment.productIdentifier)
    }
    
    func transactionRestoreFinished(_ isSuccess: Bool) {
        // It is called when restore is finished. isSuccess will be true when some products have been restored successfully.
    }

}

