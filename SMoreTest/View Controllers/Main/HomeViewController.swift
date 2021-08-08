//
//  HomeViewController.swift
//  SMoreTest
//
//  Created by Onseen on 8/5/21.
//

import UIKit

class HomeViewController: BaseViewController {

    @IBOutlet weak var viewMask: UIView!
    @IBOutlet weak var viewInputPanel: UIView!
    @IBOutlet weak var viewSendPhotoButton: UIView!
    @IBOutlet weak var viewSendLighteningButton: UIView!
    @IBOutlet weak var viewSendMessageButton: UIView!
    
    @IBOutlet weak var textviewMessage: UITextView!
    
    @IBOutlet weak var constraintInputPanelTrailingSpace: NSLayoutConstraint!       /// 30 / 100
    @IBOutlet weak var constraintInputPanelHeight: NSLayoutConstraint!              /// 60 / 150
    
    @IBOutlet weak var constraintSendMessageButtonWidth: NSLayoutConstraint!        /// 30 / 60
    @IBOutlet weak var constraintSendLighteningButtonWidth: NSLayoutConstraint!     /// 20 / 40
    @IBOutlet weak var constraintSendPhotoButtonWidth: NSLayoutConstraint!          /// 20 / 40
    
    var photoVC: PhotoPickerController? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupUI()
    }
    
    func setupUI() {
        self.textviewMessage.delegate = self
        
        self.photoVC = PhotoPickerController()
        self.photoVC?.delegate = self
        self.photoVC?.parentVC = self
    }
    
    // MARK: - Biz Logic
    
    func uploadPhoto(image: UIImage) {
        let message = MessageDataModel()
        message.id = UtilsString.generateObjectId()
        message.enumType = .PHOTO
        message.date = Date()
        message.enumStatus = .NEW
        MessageManager.sharedInstance.addMessage(message: message)
        
        self.showLoading()
        MessageManager.sharedInstance.requestUploadPhoto(message: message, image: image) { response in
            if response.isSuccess() {
                MessageManager.sharedInstance.requestSendMessage(message: message) { response in
                    self.hideLoading()
                    self.gotoChatRoomVC()
                }
            }
            else {
                self.hideLoading()
                self.showMessage(message: response.getBeautifiedErrorMessage())

                message.enumStatus = .DELIVERY_FAILED
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    self.gotoChatRoomVC()
                }
            }
        }
    }
    
    // MARK: - Navigations
    
    func gotoChatRoomVC() {
        DispatchQueue.main.async {
            let storyboard = UIStoryboard.init(name: UIConfig.StoryboardName.MAIN.rawValue, bundle: nil)
            if let vc = storyboard.instantiateViewController(withIdentifier: UIConfig.StoryboardID.CHAT_ROOM.rawValue) as? ChatRoomViewController {
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
    func showPhotoAddPopup() {
        let storyboard = UIStoryboard.init(name: UIConfig.StoryboardName.MAIN.rawValue, bundle: nil)
        if let vc = storyboard.instantiateViewController(withIdentifier: UIConfig.StoryboardID.CHAT_PHOTOPOPUP.rawValue) as? ChatPhotoPopupViewController {
            vc.delegate = self
            self.showPopupVC(popup: vc)
        }
    }

    // MARK: - Animations
    
    func animateToExpand() {
        DispatchQueue.main.async {
            self.viewInputPanel.layer.removeAllAnimations()
            self.viewMask.layer.removeAllAnimations()
            
            self.viewMask.isHidden = false
            self.viewMask.alpha = 0
            
            self.constraintInputPanelHeight.constant = 150
            self.constraintInputPanelTrailingSpace.constant = 100
            
            UIView.animate(withDuration: 0.5) {
                self.viewMask.alpha = 1
                self.view.layoutIfNeeded()
            } completion: { completed in
                self.viewMask.alpha = 1
                self.animateBubblesToShowButtons()
            }
        }
    }
    
    func animateBubblesToShowButtons() {
        DispatchQueue.main.async {
            self.viewSendMessageButton.layer.removeAllAnimations()
            self.viewSendMessageButton.isHidden = false
            self.viewSendMessageButton.layer.removeAllAnimations()
            
            self.constraintSendMessageButtonWidth.constant = 60
            UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.25, initialSpringVelocity: 10, options: .curveEaseInOut) {
                self.viewSendMessageButton.layoutIfNeeded()
            } completion: { completed in
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            self.viewSendLighteningButton.layer.removeAllAnimations()
            self.viewSendLighteningButton.isHidden = false
            self.viewSendLighteningButton.layer.removeAllAnimations()
            
            self.constraintSendLighteningButtonWidth.constant = 40
            UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.25, initialSpringVelocity: 10, options: .curveEaseInOut) {
                self.viewSendLighteningButton.layoutIfNeeded()
            } completion: { completed in
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.viewSendPhotoButton.layer.removeAllAnimations()
            self.viewSendPhotoButton.isHidden = false
            self.viewSendPhotoButton.layer.removeAllAnimations()
            
            self.constraintSendPhotoButtonWidth.constant = 40
            UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.25, initialSpringVelocity: 10, options: .curveEaseInOut) {
                self.viewSendPhotoButton.layoutIfNeeded()
            } completion: { completed in
            }
        }
    }
    
    func animateToShrink() {
        DispatchQueue.main.async {
            self.viewInputPanel.layer.removeAllAnimations()
            self.viewMask.layer.removeAllAnimations()
            self.viewSendPhotoButton.layer.removeAllAnimations()
            self.viewSendLighteningButton.layer.removeAllAnimations()
            self.viewSendMessageButton.layer.removeAllAnimations()
            
            self.viewMask.isHidden = false
            self.viewSendPhotoButton.isHidden = false
            self.viewSendLighteningButton.isHidden = false
            self.viewSendMessageButton.isHidden = false
            
            self.viewMask.alpha = 1
            self.viewSendPhotoButton.alpha = 1
            self.viewSendLighteningButton.alpha = 1
            self.viewSendMessageButton.alpha = 1
            
            self.constraintInputPanelHeight.constant = 60
            self.constraintInputPanelTrailingSpace.constant = 30
            self.constraintSendPhotoButtonWidth.constant = 20
            self.constraintSendLighteningButtonWidth.constant = 20
            self.constraintSendMessageButtonWidth.constant = 30
            
            UIView.animate(withDuration: 0.5) {
                self.viewMask.alpha = 0
                self.viewSendPhotoButton.alpha = 0
                self.viewSendLighteningButton.alpha = 0
                self.viewSendMessageButton.alpha = 0
                
                self.view.layoutIfNeeded()
            } completion: { completed in
                self.viewMask.alpha = 1
                self.viewSendPhotoButton.alpha = 1
                self.viewSendLighteningButton.alpha = 1
                self.viewSendMessageButton.alpha = 1
                
                self.viewMask.isHidden = true
                self.viewSendPhotoButton.isHidden = true
                self.viewSendLighteningButton.isHidden = true
                self.viewSendMessageButton.isHidden = true
            }
        }
    }
    
    // MARK: - Actions
    
    @IBAction func onButtonTestClick(_ sender: Any) {
        self.gotoChatRoomVC()
    }
    
    @IBAction func onButtonSendPhotoClick(_ sender: Any) {
        self.view.endEditing(true)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.showPhotoAddPopup()
        }
    }

}

extension HomeViewController: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        self.animateToExpand()
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        self.animateToShrink()
    }
    
}

extension HomeViewController: ChatPhotoPopupViewControllerDelegate {
    
    func didChatPhotoPopupCameraClick() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.photoVC?.takePhotoFromCamera()
        }
    }
    
    func didChatPhotoPopupAlbumClick() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.photoVC?.takePhotoFromAlbum()
        }
    }
    
    func didChatPhotoPopupCancelClick() {
        
    }
    
}

extension HomeViewController: PhotoPickerControllerDelegate {
    
    func didPhotoPickerControllerFinish(image: UIImage) {
        self.uploadPhoto(image: image)
    }
    
}
