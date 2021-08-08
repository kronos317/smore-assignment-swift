//
//  MessageBaseTableViewCell.swift
//  SMoreTest
//
//  Created by Onseen on 8/7/21.
//

import UIKit

protocol MessageBaseTableViewCellDelegate: AnyObject {
    
    func didMessageTableViewCellViewDetailsClick(cell: MessageBaseTableViewCell)
    func didMessageTableViewCellRetryClick(cell: MessageBaseTableViewCell)
    
}

class MessageBaseTableViewCell: UITableViewCell {
    
    var index: Int! = 0
    weak var delegate: MessageBaseTableViewCellDelegate? = nil

}
