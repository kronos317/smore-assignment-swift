//
//  MessageMyPhotoTableViewCell.swift
//  SMoreTest
//
//  Created by Onseen on 8/5/21.
//

import UIKit

class MessageMyPhotoTableViewCell: MessageBaseTableViewCell {

    @IBOutlet weak var viewMessagePanel: UIView!
    @IBOutlet weak var imageviewPhoto: UIImageView!
    
    @IBOutlet weak var buttonTimestamp: UIButton!
    @IBOutlet weak var buttonRetry: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.viewMessagePanel.layer.cornerRadius = 20
        self.viewMessagePanel.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner]
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setupView(message: MessageDataModel, index: Int) {
        self.imageviewPhoto.image = message.modelMedia.imageCache
        self.buttonTimestamp.setTitle(UtilsDate.toString(message.date, format: EnumDateTimeFormat.hhmma_MMMd.rawValue, timeZone: nil), for: .normal)
        
        if message.enumStatus == .DELIVERY_FAILED {
            self.buttonRetry.isHidden = false
            self.buttonTimestamp.isHidden = true
        }
        else if message.enumStatus == .NEW {
            self.buttonRetry.isHidden = true
            self.buttonTimestamp.isHidden = false
            self.buttonTimestamp.setTitle("Sending...", for: .normal)
        }
        else {
            self.buttonRetry.isHidden = true
            self.buttonTimestamp.isHidden = false
        }
        
        self.contentView.backgroundColor = .clear
        self.selectionStyle = .none
        
        self.index = index
    }
    
    static func getPreferredHeight() -> CGFloat {
        return 240
    }

    @IBAction func onButtonTimestampClick(_ sender: Any) {
        self.delegate?.didMessageTableViewCellViewDetailsClick(cell: self)
    }
    
    @IBAction func onButtonRetryClick(_ sender: Any) {
        self.delegate?.didMessageTableViewCellRetryClick(cell: self)
    }
    
}
