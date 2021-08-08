//
//  BaseViewController.swift
//  SMoreTest
//
//  Created by Onseen on 8/5/21.
//

import UIKit
import Toast_Swift

class BaseViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    // MARK: - HUDs
    
    public func showLoading() {
        DispatchQueue.main.async {
            if let nav = self.navigationController {
                self.showLoading(onView: nav.view)
            }
            else {
                self.showLoading(onView: self.view)
            }
        }
    }
    
    public func showLoading(onView: UIView) {
        DispatchQueue.main.async {
            onView.makeToastActivity(.center)
            onView.isUserInteractionEnabled = false
        }
    }
    
    public func hideLoading() {
        DispatchQueue.main.async {
            if let nav = self.navigationController {
                self.hideLoading(onView: nav.view)
            }
            else {
                self.hideLoading(onView: self.view)
            }
        }
    }
    
    public func hideLoading(onView: UIView) {
        DispatchQueue.main.async {
            onView.hideToastActivity()
            onView.isUserInteractionEnabled = true
        }
    }
    
    public func showMessage(message: String) {
        DispatchQueue.main.async {
            self.view.makeToast(message, duration: 3.0, position: .bottom)
        }
    }
    
    // MARK: - Navigations
    
    func gotoBack() {
        DispatchQueue.main.async {
            self.navigationController?.popViewController(animated: true)
        }
    }

    public func showPopupVC(popup: UIViewController) {
        popup.providesPresentationContextTransitionStyle = true
        popup.definesPresentationContext = true
        popup.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        popup.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
        
        DispatchQueue.main.async {
            if let tabBarController = self.tabBarController {
                tabBarController.present(popup, animated: true, completion: nil)
            }
            else if let nav = self.navigationController {
                nav.present(popup, animated: true, completion: nil)
            }
            else {
                self.present(popup, animated: true, completion: nil)
            }
        }
    }
    
}
