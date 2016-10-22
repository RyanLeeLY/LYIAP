//
//  DemoViewController.swift
//  LYIAP
//
//  Created by 李尧 on 2016/10/22.
//  Copyright © 2016年 ryanleely. All rights reserved.
//

import UIKit

class DemoViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        LYIAPHelper.shared.config()
        
        LYIAPHelper.shared.requestProductsWithIds(NSSet(array: ["PRODUCT_IDENTIFIER"]), completion: {Void in
            // Do something when products have been loaded.
        })
        
        LYIAPHelper.shared.purchaseProductWithId(productId: "PRODUCT_IDENTIFIER", completion: {transaction in
            // Identifier of the product that has been purchased
            debugPrint(transaction.payment.productIdentifier)
        })
        
        LYIAPHelper.shared.restoreWithCompletion(
           success: {transaction in
                // Identifier of the product that has been restored
                // You must add restore function to your app accroding to APPLE's provisions
                debugPrint(transaction.payment.productIdentifier)
            },
           finish: {isSucceess in
                // It is called when restore is finished. isSuccess will be true when some products have been restored successfully.
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
