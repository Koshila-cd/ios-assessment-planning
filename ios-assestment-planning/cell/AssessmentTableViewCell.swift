//
//  AssessmentTableViewCell.swift
//  ios-assestment-planning
//
//  Created by Koshila Dissanayake on 5/13/20.
//  Copyright © 2020 Koshila Dissanayake. All rights reserved.
//

import UIKit

class AssessmentTableViewCell: UITableViewCell {

    @IBOutlet weak var endDate: UILabel!
    @IBOutlet weak var assessmentName: UILabel!
    @IBOutlet weak var moduleName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
