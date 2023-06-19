/*****************************************************************************************************
 * Copyright 2013 appscape gmbh
 * Copyright 2014-2016 SPECURE GmbH
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *   http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *****************************************************************************************************/

import UIKit
import StoreKit

protocol StoreKitHelperDelegate: NSObjectProtocol {
    func cancelTransaction(_ identifier: String, error: NSError)
    func failedTransaction(_ identifier: String, error: NSError)
    func restoreTransaction(_ identifier: String)
    func completeTransaction(_ identifier: String, response: NSDictionary?)
    func productsDidLoad(_ products: [SKProduct]?)
}

class StoreKitHelper: NSObject {

    enum PurchaseIdentifier: String {
        case RemoveAds = "com.specure.nettest.remove_ads"
        case Unkowed = ""
    }
    
    fileprivate var buyObject: AnyObject?
    
    static let sharedManager = StoreKitHelper()
    
    fileprivate var isAddTransactionObserver = false
    
    fileprivate var selectedIdentifier: PurchaseIdentifier = .Unkowed
    
    fileprivate var buyCompletionHandler: ((_ success: Bool, _ identifier: PurchaseIdentifier?, _ error: NSError?) -> Void)?
    
    fileprivate var products: [SKProduct]?
    
    fileprivate var purchases: [Purchase]?
    
    fileprivate var verificatedProducts: [String] = []
    
    fileprivate var isLoading = false
    
    fileprivate var isNeedVerification = true
    
    fileprivate var productRequest: SKProductsRequest?
    
//    fileprivate let purchaceService = PurchaceService()
    
    weak var delegate: StoreKitHelperDelegate?
    
    func restoreAllProducts() {
        if !self.isAddTransactionObserver {
            SKPaymentQueue.default().add(self)
            _ = self.continueTransactions()
        }
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
    
    func price(for identifier: String) -> (price: NSDecimalNumber?, currency: String?) {
        if let product = self.products?.first(where: { (product) -> Bool in
            return product.productIdentifier == identifier
        }) {
            let price = product.price
            let currency = product.priceLocale.currencyCode
            return (price, currency)
        }
        
        return (nil, nil)
    }
    
    func buyProduct(identifier: PurchaseIdentifier, object: AnyObject?, completionHandler:((_ success: Bool, _ identifier: PurchaseIdentifier?, _ error: NSError?) -> Void)?) {
        
        self.selectedIdentifier = identifier
        self.buyObject = object
        self.buyCompletionHandler = completionHandler
        if self.products == nil {
            if self.isLoading == false {
                self.requestAllProductsData()
            }
            return
        }
        var selectedProduct: SKProduct? = nil
        
        if let products = self.products {
            for product in products {
                if let purchase = self.purchase(identifier.rawValue) , product.productIdentifier == purchase.identifier {
                    selectedProduct = product
                    break
                }
            }
        }
        
        if let product = selectedProduct {
            if !self.isAddTransactionObserver {
                SKPaymentQueue.default().add(self)
            }
            let payment = SKMutablePayment(product: product)
            SKPaymentQueue.default().add(payment)
        } else {
            let errorText = "You can try to buy a non-existent product. Please, contact with the administrator via the feedback form."
            let error = NSError(domain: "localhost", code: -1, userInfo: [NSLocalizedDescriptionKey: errorText])
            
            completionHandler?(false, self.selectedIdentifier, error)
            self.selectedIdentifier = .Unkowed
            self.buyObject = nil
            self.buyCompletionHandler = nil
        }
    }
    
    func continueTransactions() -> Bool {
        if SKPaymentQueue.default().transactions.count > 0 {
            if let transaction = SKPaymentQueue.default().transactions.first {
                self.completeTransaction(transaction)
                return true
            }
        }
        return false
    }
    
    func purchase(_ identifier: String) -> Purchase? {
        if let purchases = self.purchases {
            return purchases.first(where: { (purchase) -> Bool in
                return purchase.uniqueIdentifier == identifier
            })
        }
    
        return nil
    }
    
    //Need plist file with purchases
    func requestAllProductsData() {
        var array: [Purchase] = []
        var identifiers: Set<String> = Set()
        
        if let url = Bundle.main.path(forResource: "purchases", ofType: "plist"),
            let purchases = NSMutableArray(contentsOfFile: url) {
            for purchase in purchases {
                if let dictionary = purchase as? NSDictionary,
                    let identifier = (purchase as AnyObject).object(forKey: "id") as? String {
                    let p = Purchase(dictionary: dictionary)
                    array.append(p)
                    identifiers.insert(identifier)
                }
            }
        }
        
        self.purchases = array
        
        self.requestProductsData(identifiers)
    }
    
    func requestProductsData(_ identifiers: Set<String>) {
        if self.canMakePayments() {
            let request = SKProductsRequest(productIdentifiers: identifiers)
            request.delegate = self
            self.isLoading = true
            request.start()
            self.productRequest = request
        }
    }
    
    func canMakePayments() -> Bool {
        return SKPaymentQueue.canMakePayments()
    }
    
    func verification(_ transaction: SKPaymentTransaction, completionHandler:((_ isVerified: Bool, _ error: NSError?) -> Void)?) {
        completionHandler!(true, nil)
//        if let url = Bundle.main.appStoreReceiptURL,
//        let receipt = try? Data(contentsOf: url) {
//            let receiptString = receipt.base64EncodedString(options: NSData.Base64EncodingOptions.lineLength64Characters)
//
//            let transactions = SKPaymentQueue.default().transactions
//            self.purchaceService.verification(receiptString, transactions: transactions, completionHandler: { (verified, error) in
//                completionHandler?(verified, error)
//            })
//            completionHandler(true, nil)
//        }
    }
}

extension StoreKitHelper: SKProductsRequestDelegate {
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        self.products = response.products
        self.isLoading = false
        self.delegate?.productsDidLoad(self.products)
        
        if self.products != nil,
            self.selectedIdentifier != .Unkowed {
            self.buyProduct(identifier: self.selectedIdentifier, object: self.buyObject, completionHandler: self.buyCompletionHandler)
        } else {
            if self.selectedIdentifier != .Unkowed {
                let errorText = "Products can't load. Check network connection and try again"
                let error = NSError(domain: "localhost", code: -1, userInfo: [NSLocalizedDescriptionKey: errorText])
                self.buyCompletionHandler?(false, self.selectedIdentifier, error)
            }
        }
    }
}

extension StoreKitHelper: SKPaymentTransactionObserver {
    func paymentQueue(_ queue: SKPaymentQueue, restoreCompletedTransactionsFailedWithError error: Error) {
        self.delegate?.failedTransaction("Restore Failed", error: error as NSError)
    }
    
    func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
        self.delegate?.restoreTransaction("Restore Completed")
    }

    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch transaction.transactionState {
            case .purchased:
                self.completeTransaction(transaction)
            case .failed:
                self.failedTransaction(transaction)
            case .restored:
                self.restoreTransaction(transaction)
            default:
                break
            }
        }
    }
    
    func completeTransaction(_ transaction: SKPaymentTransaction) {
        if self.isNeedVerification {
            self.verification(transaction, completionHandler: { (isVerified, error) in
                if isVerified {
                    self.delegate?.completeTransaction(transaction.payment.productIdentifier, response: nil)
                    self.buyCompletionHandler?(true, self.selectedIdentifier, nil)
                } else {
                    let errorText = "Error verification on server"
                    let error = NSError(domain: "localhost", code: -1, userInfo: [NSLocalizedDescriptionKey: errorText])
                    self.delegate?.failedTransaction(transaction.payment.productIdentifier, error: error)
                    self.buyCompletionHandler?(false, self.selectedIdentifier, error)
                }
                for transaction: SKPaymentTransaction in SKPaymentQueue.default().transactions {
                    if transaction.transactionState == .purchased || transaction.transactionState == .failed || transaction.transactionState == .restored {
                        SKPaymentQueue.default().finishTransaction(transaction)
                    }
                }
            })
        } else {
            self.delegate?.completeTransaction(transaction.payment.productIdentifier, response: nil)
            for transaction: SKPaymentTransaction in SKPaymentQueue.default().transactions {
                SKPaymentQueue.default().finishTransaction(transaction)
            }
            self.buyCompletionHandler?(true, self.selectedIdentifier, nil)
        }
    }
    
    func restoreTransaction(_ transaction: SKPaymentTransaction) {
        self.delegate?.restoreTransaction(transaction.payment.productIdentifier)
        SKPaymentQueue.default().finishTransaction(transaction)
        self.buyCompletionHandler?(true, self.selectedIdentifier, nil)
    }
    
    func failedTransaction(_ transaction: SKPaymentTransaction) {
        if let error = transaction.error as NSError? {
            if error.code == SKError.paymentCancelled.rawValue {
                self.delegate?.cancelTransaction(transaction.payment.productIdentifier, error: error as NSError)
            } else {
                self.delegate?.failedTransaction(transaction.payment.productIdentifier, error: error as NSError)
            }
        }
        
        SKPaymentQueue.default().finishTransaction(transaction)
        self.buyCompletionHandler?(false, self.selectedIdentifier, transaction.error as NSError?)
    }
}
