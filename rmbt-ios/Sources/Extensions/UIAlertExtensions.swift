//
//  UIAlertExtensions.swift
//  RMBT
//
//  Created by Tomas Baculák on 23/11/2016.
//  Copyright © 2016 SPECURE GmbH. All rights reserved.
//

import Foundation
import RMBTClient

typealias AlertAction = ((UIAlertAction) -> Void)?
typealias AlertGetTextAction = ((UITextField) -> Void)?
typealias GenericCompletition = (() -> Void)?

extension UIAlertController {
    
    /// specific project functions
    /// returs an optional object UIAlertController just flexibility reasons
    
    // ONT project specific
    class func presentAlertConsumption(_ dismissAction: AlertAction) -> UIAlertController? {
    
        let title = RMBTAppTitle()//+" "+RMBTAppCustomerName()
        
        let alert = UIAlertController(title: title, message: String.localizedStringWithFormat(L("test.intro-message"), RMBTAppTitle(), RMBTAppCustomerName()), preferredStyle: .alert)
            alert.addAction(UIAlertAction.genericConfirmAction(dismissAction))
        
        //
        alert.show()
        return alert
    }
    
    class func presentAlertDevCode(_ dismissAction: AlertAction, codeAction: AlertGetTextAction, textFieldConfiguration: AlertGetTextAction) -> UIAlertController? {
        
        let alert = UIAlertController(title: L("dev.code"), message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction.genericCancelAction(dismissAction))
        alert.addAction(UIAlertAction.synchEnterCodeAction({ [weak alert] (action) in
            if alert?.textFields?.count ?? 0 > 0,
                let textField = alert?.textFields?[0] {
                codeAction?(textField)
            }
        }))
        //
        alert.addTextField(configurationHandler: textFieldConfiguration)
        
        //
        alert.show()
        
        return alert
    }
    
    ///
    // Synch alerts
    //
    class func presentAlertEnterCode(_ dismissAction: AlertAction, syncAction: AlertAction, codeAlertAction: AlertGetTextAction) -> UIAlertController? {
        
        let alert = UIAlertController(title: L("history.sync.code.enter-text"), message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction.genericCancelAction(dismissAction))
            alert.addAction(UIAlertAction.synchDevicesAction(syncAction))
            //
            alert.addTextField(configurationHandler: codeAlertAction)
        
            //
            alert.show()
        
        return alert
    }
    
    //
    class func presentActionSync(sender: Any, _ dismissAction: AlertAction, requestAction: AlertAction, enterCodeAction: AlertAction) -> UIAlertController? {

        let alert = UIAlertController(title: L("history.sync.merge"), message: nil, preferredStyle: .actionSheet)
            alert.addAction(UIAlertAction.genericCancelAction(dismissAction))
            alert.addAction(UIAlertAction.synchRequestAction(requestAction))
            alert.addAction(UIAlertAction.synchEnterCodeAction(enterCodeAction))
            //
        
        if let popoverController = alert.popoverPresentationController {
            if let barButtonItem = sender as? UIBarButtonItem {
                popoverController.barButtonItem = barButtonItem
            }
            if let view = sender as? UIView {
                popoverController.sourceView = view.superview
                popoverController.sourceRect = CGRect(x: view.center.x, y: view.center.y, width: 0, height: 0)
            }
        }
        
        alert.show()
        
        return alert
    }
    
    ///
    class func presentSyncCode(code: String, dismissAction: AlertAction, copyAction: AlertAction) -> UIAlertController? {
        
        let alert = UIAlertController(title: L("history.sync.code-text"), message: code, preferredStyle: .alert)
            alert.addAction(UIAlertAction.genericConfirmAction(dismissAction))
            alert.addAction(UIAlertAction.synchCopyCodeAction(copyAction))
            //
            alert.show()
        
        return alert
    }
    
    ///
    class func presentSuccess(code: String, dismissAction: AlertAction, reloadAction: AlertAction) -> UIAlertController? {
        
        let alert = UIAlertController(title: L("general.alertview.success"), message: L("history.sync.success-message"), preferredStyle: .alert)
        alert.addAction(UIAlertAction.genericConfirmAction(dismissAction))
        alert.addAction(UIAlertAction.synchReloadAction(reloadAction))
        //
        alert.show()
        
        return alert
    }
        
    ///
    // Test alerts
    //
    class func presentAlertBeforeStart(_ dismissAction: AlertAction, continueAction: AlertAction) -> UIAlertController? {
        
        let message = String.localizedStringWithFormat(L("test.intro-message"), RMBTAppTitle(), RMBTAppCustomerName())
        let title = RMBTAppTitle()+" "+RMBTAppCustomerName()
        //
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction.measurementDidFailDismiss(dismissAction))
            alert.addAction(UIAlertAction.genericConfirmAction(continueAction))
            //
            alert.show()
        
        return alert
    }
    
    //
    class func presentDidFailAlert(_ reason: RMBTClientCancelReason, dismissAction: AlertAction, startAction: AlertAction) -> UIAlertController? {
        
        logger.debug("MEASUREMENT FAILED: \(reason)")
        
        var message = L("measurement.unknown_error.message")
        let title = L("measurement.unknown_error.title")
        
        switch reason {
        case .userRequested:
            logger.debug("Test cancelled on users request")
            //dismissAction
            return nil
        case .appBackgrounded:
            logger.debug("Test cancelled because app backgrounded")
            message = L("test.aborted-message")
        case .mixedConnectivity:
            logger.debug("Test cancelled because of mixed connectivity")
            //startAction
//            return nil
        case .noConnection:
            logger.debug("Test cancelled because of NO connectivity")
            message = L("test.connection.lost")
        case .errorFetchingSpeedMeasurementParams:
            logger.debug("Test cancelled because test params couldn't be fetched")
            message = L("test.connection.could-not-connect")
        case .errorSubmittingSpeedMeasurement:
            logger.debug("Test cancelled because test result couldn't be uploaded to the control server")
            message = L("test.result.not-submitted")
        // TODO: other errors
        default:
            break
        }
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction.measurementDidFailDismiss(dismissAction))
            alert.addAction(UIAlertAction.measurementDidFailStartAgain(startAction))
            //
            alert.show()
        
        return alert
    }
    
    // 
    class func presentAbortAlert(_ continueAction: AlertAction, abortAction: AlertAction) -> UIAlertController? {
        
        let alert = UIAlertController(title: L("test.abort.title"), message: L("test.abort.message"), preferredStyle: .alert)
            alert.addAction(UIAlertAction.measurementAbortConfirm(continueAction))
            alert.addAction(UIAlertAction.measurementAbortDismiss(abortAction))
            //
            alert.show()
        
        return alert
    }
    
    class func presentAbortLoopModeAlert(_ continueAction: AlertAction, abortAction: AlertAction, keepAction: AlertAction) -> UIAlertController? {
        
        let alert = UIAlertController(title: L("loopmode.abort.title"), message: L("loopmode.abort.message"), preferredStyle: .alert)
        alert.addAction(UIAlertAction.measurementAbortLoopModeContinue(continueAction))
        alert.addAction(UIAlertAction.measurementAbortLoopModeDismiss(keepAction))
//        alert.addAction(UIAlertAction.measurementAbortLoopModeDismiss(abortAction))
//        alert.addAction(UIAlertAction.measurementAbortLoopModeKeep(keepAction))
        //
        alert.show()
        
        return alert
    }
    
    class func presentSurveyAlert(_ yesAction: AlertAction, neverAction: AlertAction, remindAction: AlertAction) -> UIAlertController? {
        
        let title = "Do you want to take a survey?"
        let alert = UIAlertController(title: title, message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction.genericYesAction(yesAction))
        alert.addAction(UIAlertAction.genericNeverAction(neverAction))
        alert.addAction(UIAlertAction.genericRemindAction(remindAction))
        //
        alert.show()
        
        return alert
    }
    
    ///
    // Error alerts
    //
    class func presentErrorAlert(_ error: NSError, dismissAction: AlertAction) -> UIAlertController? {
        // TODO: handle error
        let alert = UIAlertController(title: L("general.alertview.error"), message: error.localizedDescription, preferredStyle: .alert)
            alert.addAction(UIAlertAction.genericConfirmAction(dismissAction))
        
            alert.show()
        
        return alert
    }
    
    class func presentAlert(_ title: String, _ msg: String? = nil, dismissAction: AlertAction) -> UIAlertController? {
        // TODO: handle error
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        alert.addAction(UIAlertAction.genericConfirmAction(dismissAction))
        
        alert.show()
        
        return alert
    }
    
    // main function to show
    private func show() {
        present(true, completion: nil)
    }
    
    // main function to present
    private func present(_ animated: Bool, completion: GenericCompletition) {
        if let rootVC = UIApplication.shared.keyWindow?.rootViewController {
            presentFromController(rootVC, animated: animated, completion: completion)
        }
    }
    
    private func presentFromController(_ controller: UIViewController, animated: Bool, completion: GenericCompletition) {
        if  let navVC = controller as? UINavigationController,
            let visibleVC = navVC.visibleViewController {
            presentFromController(visibleVC, animated: animated, completion: completion)
        } else {
            if  let tabVC = controller as? UITabBarController,
                let selectedVC = tabVC.selectedViewController {
                presentFromController(selectedVC, animated: animated, completion: completion)
            } else {
                controller.present(self, animated: animated, completion: completion)
            }
        }
    }
}

extension UIAlertAction {
    
    /// Measurement did fail
    //
    class func measurementDidFailStartAgain(_ performAction: AlertAction) -> UIAlertAction {
        return UIAlertAction(title: L("test.startagain"), style: .default, handler: performAction)
    }
    
    //
    class func measurementDidFailDismiss(_ performAction: AlertAction) -> UIAlertAction {
        return UIAlertAction(title: L("general.alertview.dismiss"), style: .cancel, handler: performAction)
    }
    
    /// Abort measurement situation
    //
    class func measurementAbortDismiss(_ performAction: AlertAction) -> UIAlertAction {
        return UIAlertAction(title: L("test.abort.abort"), style: .cancel, handler: performAction)
    }
    
    //
    class func measurementAbortConfirm(_ performAction: AlertAction) -> UIAlertAction {
        return UIAlertAction(title: L("test.abort.continue"), style: .default, handler: performAction)
    }
    
    class func measurementAbortLoopModeDismiss(_ performAction: AlertAction) -> UIAlertAction {
        return UIAlertAction(title: L("loopmode.abort.abort"), style: .cancel, handler: performAction)
    }
    
    //
    class func measurementAbortLoopModeContinue(_ performAction: AlertAction) -> UIAlertAction {
        return UIAlertAction(title: L("loopmode.abort.continue"), style: .default, handler: performAction)
    }
    
    class func measurementAbortLoopModeKeep(_ performAction: AlertAction) -> UIAlertAction {
        return UIAlertAction(title: L("loopmode.abort.keep"), style: .default, handler: performAction)
    }
    
    /// History
    // Data Synchronisation
    //
    class func synchDevicesAction(_ performAction: AlertAction) -> UIAlertAction {
        return UIAlertAction(title: L("history.sync.sync"), style: .default, handler: performAction)
    }
    //
    class func synchRequestAction(_ performAction: AlertAction) -> UIAlertAction {
        return UIAlertAction(title: L("history.sync.code.request"), style: .default, handler: performAction)
    }
    //
    class func synchEnterCodeAction(_ performAction: AlertAction) -> UIAlertAction {
        return UIAlertAction(title: L("history.sync.code.enter"), style: .default, handler: performAction)
    }
    //
    class func synchCopyCodeAction(_ performAction: AlertAction) -> UIAlertAction {
        return UIAlertAction(title: L("history.sync.code.copy"), style: .default, handler: performAction)
    }
    //
    class func synchReloadAction(_ performAction: AlertAction) -> UIAlertAction {
        return UIAlertAction(title: L("general.alertview.reload"), style: .default, handler: performAction)
    }
    
    /// Generic
    //
    class func genericConfirmAction(_ performAction: AlertAction) -> UIAlertAction {
        return UIAlertAction(title: L("general.alertview.ok"), style: .default, handler: performAction)
    }
    
    //
    class func genericCancelAction(_ performAction: AlertAction) -> UIAlertAction {
        return UIAlertAction(title: L("general.alertview.cancel"), style: .cancel, handler: performAction)
    }
    
    //
    class func genericYesAction(_ performAction: AlertAction) -> UIAlertAction {
        return UIAlertAction(title: "Yes", style: .default, handler: performAction)
    }
    
    class func genericNeverAction(_ performAction: AlertAction) -> UIAlertAction {
        return UIAlertAction(title: "Never", style: .default, handler: performAction)
    }
    
    class func genericRemindAction(_ performAction: AlertAction) -> UIAlertAction {
        return UIAlertAction(title: "Remind me later", style: .default, handler: performAction)
    }
}
