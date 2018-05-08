//
//  EditRecordingTableViewCell.swift
//  StoryOrganizer
//
//  Created by Weston Verhulst on 5/7/18.
//  Copyright © 2018 Zachary Kipping. All rights reserved.
//

import UIKit

class EditRecordingTableViewCell: UITableViewCell {
    @IBOutlet weak var textField: UITextField!
    var id: Int = 0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
