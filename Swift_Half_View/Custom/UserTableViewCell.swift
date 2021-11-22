//
//  UserTableViewCell.swift
//  Swift_Half_View
//
//  Created by Chuchu Pro on 2021/11/13.
//

import UIKit

class UserTableViewCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var chatLabel: UILabel!
    @IBOutlet weak var profilePhoto: UIImageView!
    @IBOutlet weak var thumbnailBtn: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    @IBAction func thumbnailClicked(_ sender: UIButton) {
        print(thumbnailBtn.tag)
    }
    
}
