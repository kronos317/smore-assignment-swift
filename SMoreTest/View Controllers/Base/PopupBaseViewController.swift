//
//  PopupBaseViewController.swift
//  SMoreTest
//
//  Created by Onseen on 8/5/21.
//

import UIKit

class PopupBaseViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    // MARK: - Navigations
    
    func closeDialog() {
        DispatchQueue.main.async {
            self.presentingViewController?.dismiss(animated: true, completion: nil)
        }
    }
    
}
