//
//  MessageMyTextTableViewCell.swift
//  SMoreTest
//
//  Created by Onseen on 8/5/21.
//

import UIKit

class MessageMyTextTableViewCell: MessageBaseTableViewCell {

    @IBOutlet weak var viewMessagePanel: UIView!
    @IBOutlet weak var labelMessage: UILabel!
    @IBOutlet weak var labelTimestamp: UILabel!
    
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
        self.labelMessage.text = message.szMessage
        self.labelTimestamp.text = UtilsDate.toString(message.date, format: EnumDateTimeFormat.hhmma_MMMd.rawValue, timeZone: nil)
        
        if message.enumStatus == .DELIVERY_FAILED {
            self.buttonRetry.isHidden = false
            self.labelTimestamp.isHidden = true
        }
        else {
            self.buttonRetry.isHidden = true
            self.labelTimestamp.isHidden = false
        }

        self.contentView.backgroundColor = .clear
        self.selectionStyle = .none
        
        self.index = index
    }
    
    static func getPreferredHeight() -> CGFloat {
        return UITableView.automaticDimension
    }

    @IBAction func onButtonRetryClick(_ sender: Any) {
        self.delegate?.didMessageTableViewCellRetryClick(cell: self)
    }
    
}
