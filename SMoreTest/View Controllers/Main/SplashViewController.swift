//
//  SplashViewController.swift
//  SMoreTest
//
//  Created by Onseen on 8/7/21.
//

import UIKit

class SplashViewController: BaseViewController {

    @IBOutlet weak var viewLoading: UIView!
    @IBOutlet weak var labelLoading: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.loadMessages()
    }
    
    // MARK: - Requests
    
    func loadMessages() {
        MessageManager.sharedInstance.requestGetMessages { response in
            if response.isSuccess() {
                if MessageManager.sharedInstance.arrayMessages.filter({ $0.enumType == .PHOTO }).count > 0 {
                    self.loadPhotos()
                    return
                }
                
                if MessageManager.sharedInstance.arrayMessages.count == 0 {
                    self.labelLoading.text = "Yay! No messages found..."
                }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.gotoHomeVC()
            }
        }
    }
    
    func loadPhotos() {
        MessageManager.sharedInstance.requestDownloadAllPhotos { response in
            if response.isSuccess() {
                self.gotoHomeVC()
            }
            else {
                self.viewLoading.isHidden = true
                self.showMessage(message: "Failed to download photos.")
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    self.gotoHomeVC()
                }
            }
        }
    }
    
    // MARK: - Navigations
    
    func gotoHomeVC() {
        DispatchQueue.main.async {
            let storyboard = UIStoryboard.init(name: UIConfig.StoryboardName.MAIN.rawValue, bundle: nil)
            if let vc = storyboard.instantiateViewController(withIdentifier: UIConfig.StoryboardID.MAIN_HOME.rawValue) as? HomeViewController {
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }

}
