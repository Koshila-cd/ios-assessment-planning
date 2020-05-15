//
//  TaskTableViewCell.swift
//  ios-assestment-planning
//
//  Created by Koshila Dissanayake on 5/14/20.
//  Copyright © 2020 Koshila Dissanayake. All rights reserved.
//

import UIKit

class TaskTableViewCell: UITableViewCell {

    @IBOutlet weak var taskNo: UILabel!
    @IBOutlet weak var taskName: UILabel!
    
    @IBOutlet weak var progressBar: UIProgressView!
    @IBOutlet weak var endDate: UILabel!
    @IBOutlet weak var taskNote: UILabel!
    
    @IBOutlet weak var circleProgress: CircleProgress!
    override func awakeFromNib() {
        super.awakeFromNib()
   
        progressBar.transform = progressBar.transform.scaledBy(x: 1, y: 10)
        taskName.font = UIFont.boldSystemFont(ofSize: 18.0)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
