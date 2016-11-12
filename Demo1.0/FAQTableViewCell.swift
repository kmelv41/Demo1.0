//
//  FAQTableViewCell.swift
//  Demo1.0
//
//  Created by User on 2016-11-08.
//  Copyright © 2016 Jolt. All rights reserved.
//

import UIKit

class FAQTableViewCell: UITableViewCell {

    @IBOutlet weak var questionView: UIView!
    @IBOutlet weak var answerView: UIView!
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var answerLabel: UILabel!
    
    @IBOutlet weak var answerHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var questionHeightConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func addHiddenConstraints() {
        
        questionLabel.lineBreakMode = .byWordWrapping
        questionLabel.numberOfLines = 0
        answerLabel.lineBreakMode = .byWordWrapping
        answerLabel.numberOfLines = 0
        
        let bottomConstraint = NSLayoutConstraint(item: questionView, attribute: .bottom, relatedBy: .equal, toItem: contentView, attribute: .bottom, multiplier: 1.0, constant: 0.0)
        
        NSLayoutConstraint.activate([bottomConstraint])
        
    }
    
    func addOpenConstraints() {
        
        questionLabel.lineBreakMode = .byWordWrapping
        questionLabel.numberOfLines = 0
        answerLabel.lineBreakMode = .byWordWrapping
        answerLabel.numberOfLines = 0
        
        let topConstraint = NSLayoutConstraint(item: answerView, attribute: .top, relatedBy: .equal, toItem: questionView, attribute: .bottom, multiplier: 1.0, constant: 0.0)
        
        let bottomConstraint = NSLayoutConstraint(item: answerView, attribute: .bottom, relatedBy: .equal, toItem: contentView, attribute: .bottom, multiplier: 1.0, constant: 0.0)
        
        NSLayoutConstraint.activate([topConstraint, bottomConstraint])
        
    }

}
