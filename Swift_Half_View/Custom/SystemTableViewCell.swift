//
//  SystemTableViewCell.swift
//  Swift_Half_View
//
//  Created by Chuchu Pro on 2021/11/13.
//

import UIKit

class SystemTableViewCell: UITableViewCell {

    @IBOutlet weak var chatView: UIView!
    @IBOutlet weak var systemAlertLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
