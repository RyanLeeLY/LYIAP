//
//  IAPHelper.swift
//  LYIAP
//
//  Created by 李尧 on 2016/10/22.
//  Copyright © 2016年 ryanleely. All rights reserved.
//

import UIKit
import StoreKit

public typealias TransactionPurchasedCompletion = (_ transaction: SKPaymentTransaction)->Void
public typealias TransactionRestoredCompletion = (_ transaction: SKPaymentTransaction)->Void
public typealias ProductRequestCompletion = (Void)->Void
public typealias RestoreFinishCompletion = (Bool)->Void
public typealias VerifyCompletion = (NSDictionary?, NSError?) -> Void

public class LYIAPHelper: NSObject, LYIAPDelegate {
    static let shared:LYIAPHelper = LYIAPHelper()
    
    private var transactionPurchasedCompletion: ((_ transaction: SKPaymentTransaction)->Void)?
    private var transactionRestoredCompletion: ((_ transaction: SKPaymentTransaction)->Void)?
    private var productRequestCompletion: ((Void)->Void)?
    private var restoreFinishCompletion: ((Bool)->Void)?
    

    
    fileprivate override init() {
        super.init()
    }
    
    func config(){
        self.initWithDeledate(self)
    }
    
    func requestProductsWithIds(_ productsIds: NSSet, completion: @escaping ((Void)->Void) = {_ in }){
        self.productRequestCompletion = completion
        LYIAP.setRequestWithProducts(productsIds)
        LYIAP.startRequest()
    }
    
    func purchaseProductWithId(productId: String, completion:@escaping (_ transaction: SKPaymentTransaction)->Void){
        transactionPurchasedCompletion = completion
        LYIAP.startPaymentWithProductId(productId)
    }
    
    func restoreWithCompletion(success: @escaping (_ transaction: SKPaymentTransaction)->Void, finish: @escaping (Bool)->Void = {_ in }){
        transactionRestoredCompletion = success
        restoreFinishCompletion = finish
        LYIAP.restorePayment()
    }
    
    func verifyReceipt(completion: @escaping VerifyCompletion) {
        LYIAP.verifyPruchase(completion: completion)
    }
    
    fileprivate func initWithDeledate(_ deledate: LYIAPDelegate){
        LYIAP.setLYIAPDelegate(self)
    }
    
    public func transactionPurchased(_ queue: SKPaymentQueue, transaction: SKPaymentTransaction) {
        transactionPurchasedCompletion?(transaction)
    }
    
    public func transactionRestore(_ queue: SKPaymentQueue, transaction: SKPaymentTransaction) {
        transactionRestoredCompletion?(transaction)
    }
    
    public func transactionRestoreFinished(_ isSuccess: Bool) {
        restoreFinishCompletion?(isSuccess)
    }
    
    public func requestFinished() {
        productRequestCompletion?()
    }
}
