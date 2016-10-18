# LYIAP
- iOS IAP by Swift 3.0
- Easy to use

## Step1
- Conforming to ```LYIAPDelegate``` protocol（遵守```LYIAPDelegate```协议）

```swift
	class ViewController: UIViewController, LYIAPDelegate {
		override func viewDidLoad() {
       	super.viewDidLoad()
    	}
	}
```

## Step2
- Set delegate and send product request（设置代理并发送商品请求）

```swift
	 override func viewDidLoad() {
        super.viewDidLoad()
        LYIAP.setRequestWithProducts(NSSet(array: ["PRODUCT_IDENTIFIER"]), delegate: self)
        LYIAP.startRequest()
    }
```
## Step3
- Implement delegate function（实现代理方法）

```swift
    func requestFinished() {
        // Do something when products have been loaded.
    }

    func transactionPurchased(_ queue: SKPaymentQueue, transaction: SKPaymentTransaction) {
        // Identifier of the product that has been purchased
        debugPrint(transaction.payment.productIdentifier)
        
        LYIAP.verifyPruchase(completion: {(receipt,error) in
            // You can verify the transaction. 
            // In this callback, you will get the receipt if the transaction is verified by the APPLE. 
            // You can compare some tranction infomation with the receipt.
            debugPrint(receipt)
        })
    }
    
    func transactionRestore(_ queue: SKPaymentQueue, transaction: SKPaymentTransaction) {
        // Identifier of the product that has been restored
        // You must add restore function to your app accroding to APPLE's provisions
        debugPrint(transaction.payment.productIdentifier)
    }
```

## More Details（更多的细节）
```swift
    @objc optional func requestFinished()
    func transactionPurchased(_ queue: SKPaymentQueue, transaction: SKPaymentTransaction)
    @objc optional func transactionFailed(_ queue: SKPaymentQueue, transaction: SKPaymentTransaction)
    @objc optional func transactionRestore(_ queue: SKPaymentQueue, transaction: SKPaymentTransaction)
    @objc optional func transactionDeferred(_ queue: SKPaymentQueue, transaction: SKPaymentTransaction)
    @objc optional func transactionPurchasing(_ queue: SKPaymentQueue, transaction: SKPaymentTransaction)
    @objc optional func transactionRestoreFailedWithError(_ error:Error)
    @objc optional func transactionRestoreFinished(_ isSuccess:Bool)
```
