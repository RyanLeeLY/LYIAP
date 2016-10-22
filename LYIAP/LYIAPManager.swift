//
//  LYIAPManager.swift
//  crater
//
//  Created by 李尧 on 2016/10/11.
//  Copyright © 2016年 secstudio. All rights reserved.
//

import UIKit
import StoreKit

private func printLog<T>(_ message:T, file:String = #file, method:String = #function, line:Int = #line){
    #if DEBUG
        print("\((file as NSString).lastPathComponent)[\(line)], \(method): \(message)")
    #endif
}

@objc public protocol LYIAPDelegate: LYIAPRequestDelegate, LYIAPPaymentDelegate{
    
}

@objc public protocol LYIAPRequestDelegate: NSObjectProtocol{
    @objc optional func requestFinished()

}

@objc public protocol LYIAPPaymentDelegate: NSObjectProtocol{
    func transactionPurchased(_ queue: SKPaymentQueue, transaction: SKPaymentTransaction)
    @objc optional func transactionFailed(_ queue: SKPaymentQueue, transaction: SKPaymentTransaction)
    @objc optional func transactionRestore(_ queue: SKPaymentQueue, transaction: SKPaymentTransaction)
    @objc optional func transactionDeferred(_ queue: SKPaymentQueue, transaction: SKPaymentTransaction)
    @objc optional func transactionPurchasing(_ queue: SKPaymentQueue, transaction: SKPaymentTransaction)
    @objc optional func transactionRestoreFailedWithError(_ error:Error)
    @objc optional func transactionRestoreFinished(_ isSuccess:Bool)
    
}

public let LYIAP = LYIAPManager.LYIAPInstance

public class LYIAPManager: NSObject, SKPaymentTransactionObserver, SKProductsRequestDelegate {
    fileprivate let VERIFY_RECEIPT_URL = "https://buy.itunes.apple.com/verifyReceipt"
    fileprivate let ITMS_SANDBOX_VERIFY_RECEIPT_URL = "https://sandbox.itunes.apple.com/verifyReceipt"
    fileprivate var restoreSuccess = false
    
    fileprivate var productDict:NSMutableDictionary?
    
    static let LYIAPInstance = LYIAPManager()
    
    var request:SKProductsRequest?
    var observer:SKPaymentTransactionObserver?
    
    weak var delegate:LYIAPDelegate?
    weak var requestDelegate:LYIAPRequestDelegate?
    weak var paymentDelegate:LYIAPPaymentDelegate?
    
    fileprivate override init() {
        
    }
    /**
     Example: let productsIds = NSSet(array: ["com.xxx.xxx.abc"])
     */
    func setRequestWithProducts(_ productsIds: NSSet, delegate: LYIAPDelegate? = nil) {
        request = SKProductsRequest(productIdentifiers: productsIds as! Set<String>)
        request?.delegate = self
        SKPaymentQueue.default().add(self)
        
        if(delegate != nil){
            setLYIAPDelegate(delegate!)
        }
    }
    
    func setLYIAPDelegate(_ delegate: LYIAPDelegate){
        self.delegate = delegate
        paymentDelegate = delegate
        requestDelegate = delegate
    }
    
    
    func setPaymentTransactionsDelegate(_ delegate: LYIAPPaymentDelegate){
        paymentDelegate = delegate
    }
    
    func setProductsRequestDelegate(_ delegate: LYIAPRequestDelegate){
        requestDelegate = delegate
    }
    
    func removeRequestDelegate(){
        requestDelegate = nil
    }
    
    func removeProductsDelegate(){
        paymentDelegate = nil
    }
    
    func startRequest(){
        testIsNil()
        request?.start()
    }
    
    func cancelRequest(){
        testIsNil()
        request?.cancel()
    }
    
    func startPaymentWithProductId(_ productId: String){
        //if loaded
        if(SKPaymentQueue.canMakePayments()){
            guard productDict != nil else{
                printLog("products haven't been loaded")
                return
            }
            requestPaymentWithProduct(productDict![productId] as! SKProduct)
        }else{
            printLog("IAP is not supported!")
        }
    }
    
    func restorePayment(){
        restoreSuccess = false
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
    
    public func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        if (productDict == nil) {
            printLog("first load products")
            productDict = NSMutableDictionary(capacity: response.products.count)
        }
        for product in response.products  {
            printLog("product \(product.productIdentifier) loaded")
            productDict!.setObject(product, forKey: product.productIdentifier as NSCopying)
        }
        requestDelegate?.requestFinished?()
    }
    
    public func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        print("updatedTransactions")
        for transaction in transactions {
            switch transaction.transactionState{
            case .purchased:
                printLog("purchased")
                paymentDelegate?.transactionPurchased(queue, transaction: transaction)
                SKPaymentQueue.default().finishTransaction(transaction)
                break
            case .failed:
                printLog("failed")
                paymentDelegate?.transactionFailed?(queue, transaction: transaction)
                SKPaymentQueue.default().finishTransaction(transaction)
                break
            case .restored:
                printLog("restore")
                restoreSuccess = true
                paymentDelegate?.transactionRestore?(queue, transaction: transaction)
                SKPaymentQueue.default().finishTransaction(transaction)
                break
            case .purchasing:
                paymentDelegate?.transactionPurchasing?(queue, transaction: transaction)
                printLog("purchasing")
                break
            case .deferred:
                paymentDelegate?.transactionDeferred?(queue, transaction: transaction)
                printLog("deferred")
                break
            }
        }
    }
    
    public func paymentQueue(_ queue: SKPaymentQueue, restoreCompletedTransactionsFailedWithError error: Error) {
        printLog("retore failed with error:\(error)")
        paymentDelegate?.transactionRestoreFailedWithError?(error)
        
    }
    public func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
        printLog("finished restore")
        paymentDelegate?.transactionRestoreFinished?(restoreSuccess)
    }
    
    private func requestPaymentWithProduct(_ product: SKProduct){
        let payment = SKPayment(product: product)
        SKPaymentQueue.default().add(payment)
    }
    
    
    
    private func testIsNil(){
        if(request == nil){
            printLog("request hasn't been init")
        }else if(request?.delegate == nil){
            printLog("request delegate hasn't been set")
        }
    }
    
    func verifyPruchase(completion:@escaping(NSDictionary?, NSError?) -> Void) {
        // 验证凭据，获取到苹果返回的交易凭据
        let receiptURL = Bundle.main.appStoreReceiptURL
        // 从沙盒中获取到购买凭据
        let receiptData = NSData(contentsOf: receiptURL!)
        #if DEBUG
            let url = NSURL(string: ITMS_SANDBOX_VERIFY_RECEIPT_URL)
        #else
            let url = NSURL(string: VERIFY_RECEIPT_URL)
        #endif
        let request = NSMutableURLRequest(url: url! as URL, cachePolicy: NSURLRequest.CachePolicy.useProtocolCachePolicy, timeoutInterval: 10.0)
        request.httpMethod = "POST"
        let encodeStr = receiptData?.base64EncodedString(options: NSData.Base64EncodingOptions.endLineWithLineFeed)
        let payload = NSString(string: "{\"receipt-data\" : \"" + encodeStr! + "\"}")
        let payloadData = payload.data(using: String.Encoding.utf8.rawValue)
        request.httpBody = payloadData;
        
        let session = URLSession.shared
        let semaphore = DispatchSemaphore(value: -1)
        
        let dataTask = session.dataTask(with: request as URLRequest,
            completionHandler: {(data, response, error) -> Void in
                if error != nil{
                    print("error1")
                    completion(nil,error as NSError?)
                }else{
                    if (data==nil) {
                        print("error2")
                        completion(nil,error as NSError?)
                    }
                    do{
                        let jsonResult: NSDictionary = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary
                        if (jsonResult.count != 0) {
                            // 比对字典中以下信息基本上可以保证数据安全
                            // bundle_id&application_version&product_id&transaction_id
                            // 验证成功
                            let receipt = jsonResult["receipt"] as! NSDictionary
                            completion(receipt,nil)
                        }
                        print(jsonResult)
                    }catch{
                        print("error3")
                        completion(nil,nil)
                    }
                }
                
                semaphore.signal()
        }) as URLSessionTask
        dataTask.resume()
        semaphore.wait()
    }
}
