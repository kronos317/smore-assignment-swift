//
//  ChatRoomViewController.swift
//  SMoreTest
//
//  Created by Onseen on 8/5/21.
//

import UIKit
import SwifterSwift

class ChatRoomViewController: BaseViewController {

    @IBOutlet weak var viewMessagePanel: UIView!
    @IBOutlet weak var textfieldMessage: UITextField!
    @IBOutlet weak var tableView: UITableView!
    
    var photoVC: PhotoPickerController? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.refreshTableView()
    }
    
    func setupUI() {
        self.viewMessagePanel.layer.cornerRadius = 30
        self.viewMessagePanel.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner]
        
        self.viewMessagePanel.addShadow(ofColor: .gray, radius: 5, offset: .zero, opacity: 0.2)
        self.registerNibsForTableViewCell()
        
        self.photoVC = PhotoPickerController()
        self.photoVC?.delegate = self
        self.photoVC?.parentVC = self
    }
    
    // MARK: - Biz Logic
    
    func sendPhotoMessage(image: UIImage) {
        let message = MessageDataModel()
        message.id = UtilsString.generateObjectId()
        message.enumType = .PHOTO
        message.date = Date()
        message.enumStatus = .NEW
        MessageManager.sharedInstance.addMessage(message: message)
        
        self.refreshTableView()
        MessageManager.sharedInstance.requestUploadPhoto(message: message, image: image) { response in
            if response.isSuccess() {
                MessageManager.sharedInstance.requestSendMessage(message: message) { response in
                    self.refreshTableView()
                }
            }
            else {
                message.enumStatus = .DELIVERY_FAILED
                self.refreshTableView()
            }
        }
    }
    
    func retryToSendPhoto(index: Int) {
        let message = MessageManager.sharedInstance.arrayMessages[index]
        if message.enumStatus != .DELIVERY_FAILED || message.enumType != .PHOTO {
            return
        }
        guard let image = message.modelMedia.imageCache else {
            return
        }
        
        message.enumStatus = .NEW
        self.refreshTableView()
        MessageManager.sharedInstance.requestUploadPhoto(message: message, image: image) { response in
            if response.isSuccess() {
                MessageManager.sharedInstance.requestSendMessage(message: message) { response in
                    self.refreshTableView()
                }
            }
            else {
                message.enumStatus = .DELIVERY_FAILED
                self.refreshTableView()
            }
        }
    }
    
    func sendTextMessage() {
        let text = self.textfieldMessage.text ?? ""
        if text.isEmpty == true {
            return
        }
        
        let message = MessageDataModel()
        message.id = UtilsString.generateObjectId()
        message.enumType = .TEXT
        message.szMessage = text
        message.date = Date()
        message.enumStatus = .DELIVERED
        MessageManager.sharedInstance.addMessage(message: message)
        
        MessageManager.sharedInstance.requestSendMessage(message: message) { response in
            self.textfieldMessage.text = ""
            self.refreshTableView()
        }
    }
    
    // MARK: - Navigation
    
    func showPhotoAddPopup() {
        let storyboard = UIStoryboard.init(name: UIConfig.StoryboardName.MAIN.rawValue, bundle: nil)
        if let vc = storyboard.instantiateViewController(withIdentifier: UIConfig.StoryboardID.CHAT_PHOTOPOPUP.rawValue) as? ChatPhotoPopupViewController {
            vc.delegate = self
            self.showPopupVC(popup: vc)
        }
    }
    
    func openPhotoInBrowser(index: Int) {
        let message = MessageManager.sharedInstance.arrayMessages[index]
        if message.enumStatus != .DELIVERED || message.enumType != .PHOTO {
            return
        }
        
        if let url = URL(string: UrlManager.Message.getPhoto(filename: message.modelMedia.szFileName)) {
            DispatchQueue.main.async {
                UIApplication.shared.open(url)
            }
        }
    }
    
    // MARK: - Actions
    
    @IBAction func onButtonBackClick(_ sender: Any) {
        self.view.endEditing(true)
        self.gotoBack()
    }
    
    @IBAction func onButtonPhotoClick(_ sender: Any) {
        self.view.endEditing(true)
        self.showPhotoAddPopup()
    }
    
    @IBAction func onButtonSendClick(_ sender: Any) {
        self.sendTextMessage()
    }
    
}

extension ChatRoomViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == self.textfieldMessage {
            self.sendTextMessage()
            return false
        }
        return true
    }
    
}

extension ChatRoomViewController: UITableViewDataSource, UITableViewDelegate {
    
    func updateTableContentInset() {
        let numRows = self.tableView.numberOfRows(inSection: 0)
        var contentInsetTop = self.tableView.bounds.size.height
        for i in 0..<numRows {
            let rowRect = self.tableView.rectForRow(at: IndexPath(item: i, section: 0))
            contentInsetTop -= rowRect.size.height
            if contentInsetTop <= 0 {
                contentInsetTop = 0
            }
        }
        self.tableView.contentInset = UIEdgeInsets(top: contentInsetTop,left: 0,bottom: 0,right: 0)
    }
    
    func registerNibsForTableViewCell() {
        self.tableView.register(UINib(nibName: UIConfig.TableViewCellNibName.MESSAGES_MYITEM_TEXT.rawValue, bundle: nil), forCellReuseIdentifier: UIConfig.TableViewCellID.MESSAGES_MYITEM_TEXT.rawValue)
        self.tableView.register(UINib(nibName: UIConfig.TableViewCellNibName.MESSAGES_MYITEM_PHOTO.rawValue, bundle: nil), forCellReuseIdentifier: UIConfig.TableViewCellID.MESSAGES_MYITEM_PHOTO.rawValue)
        
        self.tableView.tableFooterView = UIView.init()
        self.tableView.separatorStyle = .none
    }
    
    func refreshTableView() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
            self.updateTableContentInset()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.tableView.scrollToBottom(animated: true)
            }
        }
    }
    
    func configureMyTextCell(cell: MessageMyTextTableViewCell, indexSection: Int, indexRow: Int) {
        let message = MessageManager.sharedInstance.arrayMessages[indexRow]
        cell.setupView(message: message, index: indexRow)
        cell.delegate = self
    }
    
    func configureMyPhotoCell(cell: MessageMyPhotoTableViewCell, indexSection: Int, indexRow: Int) {
        let message = MessageManager.sharedInstance.arrayMessages[indexRow]
        cell.setupView(message: message, index: indexRow)
        cell.delegate = self
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return MessageManager.sharedInstance.arrayMessages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = indexPath.row
        let message = MessageManager.sharedInstance.arrayMessages[row]
        
        if message.enumType == .PHOTO {
            let cell = tableView.dequeueReusableCell(withIdentifier: UIConfig.TableViewCellID.MESSAGES_MYITEM_PHOTO.rawValue) as! MessageMyPhotoTableViewCell
            self.configureMyPhotoCell(cell: cell, indexSection: indexPath.section, indexRow: indexPath.row)
            return cell
        }
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: UIConfig.TableViewCellID.MESSAGES_MYITEM_TEXT.rawValue) as! MessageMyTextTableViewCell
            self.configureMyTextCell(cell: cell, indexSection: indexPath.section, indexRow: indexPath.row)
            return cell
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
        
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let row = indexPath.row
        let message = MessageManager.sharedInstance.arrayMessages[row]
        
        if message.enumType == .PHOTO {
            return MessageMyPhotoTableViewCell.getPreferredHeight()
        }
        return MessageMyTextTableViewCell.getPreferredHeight()
    }
    
}

extension ChatRoomViewController: ChatPhotoPopupViewControllerDelegate {
    
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

extension ChatRoomViewController: PhotoPickerControllerDelegate {
    
    func didPhotoPickerControllerFinish(image: UIImage) {
        self.sendPhotoMessage(image: image)
    }
    
}

extension ChatRoomViewController: MessageBaseTableViewCellDelegate {
    
    func didMessageTableViewCellRetryClick(cell: MessageBaseTableViewCell) {
        let index: Int = cell.index
        self.retryToSendPhoto(index: index)
    }
    
    func didMessageTableViewCellViewDetailsClick(cell: MessageBaseTableViewCell) {
        let index: Int = cell.index
        self.openPhotoInBrowser(index: index)
    }
    
}
