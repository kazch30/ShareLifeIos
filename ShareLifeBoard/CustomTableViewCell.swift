//
//  CustomTableViewCell.swift
//  ShareLifeBoard
//
//  Created by 土師一哉 on 2020/08/22.
//  Copyright © 2020 土師一哉. All rights reserved.
//

import UIKit

class CustomTableViewCell: UITableViewCell {

    @IBOutlet weak var ImageView: UIImageView!
    @IBOutlet weak var NameLabel: UILabel!
    @IBOutlet weak var TimeLabel: UILabel!
    @IBOutlet weak var ContentLabel: UILabel!
    @IBOutlet weak var StackView: UIView!
    @IBOutlet weak var ImageButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }

    @IBAction func tapButton(_ sender: Any) {
        debugPrint("tapButton()->")
        
        debugPrint("<-tapButton()")
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
