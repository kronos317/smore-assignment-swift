//
//  ChatPhotoPopupViewController.swift
//  SMoreTest
//
//  Created by Onseen on 8/5/21.
//

import UIKit

protocol ChatPhotoPopupViewControllerDelegate: AnyObject {
    
    func didChatPhotoPopupCameraClick()
    func didChatPhotoPopupAlbumClick()
    func didChatPhotoPopupCancelClick()
    
}

class ChatPhotoPopupViewController: PopupBaseViewController {

    @IBOutlet weak var constraintCancelBottomSpace: NSLayoutConstraint!     // 20 / -300
    
    weak var delegate: ChatPhotoPopupViewControllerDelegate? = nil
    
    var didActionSheetsShow: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.animateToShowActionSheets()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    // MARK: - Navigations
    
    // MARK: - Animations
    
    func animateToShowActionSheets() {
        DispatchQueue.main.async {
            self.constraintCancelBottomSpace.constant = 20
            UIView.animate(withDuration: 0.25) {
                self.view.layoutIfNeeded()
            } completion: { completed in
                
            }
        }
    }
    
    func animateToHideActionSheets() {
        DispatchQueue.main.async {
            self.constraintCancelBottomSpace.constant = -300
            UIView.animate(withDuration: 0.25) {
                self.view.layoutIfNeeded()
            } completion: { completed in
            }
        }
    }
    
    // MARK: - Actions
    
    @IBAction func onButtonCameraClick(_ sender: Any) {
        self.delegate?.didChatPhotoPopupCameraClick()
        self.closeDialog()
    }
    
    @IBAction func onButtonAlbumClick(_ sender: Any) {
        self.delegate?.didChatPhotoPopupAlbumClick()
        self.closeDialog()
    }
    
    @IBAction func onButtonCancelClick(_ sender: Any) {
        self.delegate?.didChatPhotoPopupCancelClick()
        self.closeDialog()
    }    

}
