//
//  PopoverViewController.swift
//  LetsGoToMovie
//
//  Created by Kiwiinthesky72 on 2/17/20.
//  Copyright © 2020 Kiwiinthesky72. All rights reserved.
//

import UIKit

class PopoverViewController: UIViewController {
    @IBOutlet var priceStepper: UIStepper!
    @IBOutlet var ratingControl: UISegmentedControl!
    @IBOutlet var lessThanLabel: UILabel!
    @IBOutlet var priceLabel: UILabel!
    @IBOutlet var ratingLabel: UILabel!
    
    @IBAction func stepperChanges(_ sender: UIStepper) {
        lessThanLabel.text = "Less than $\(Int(sender.value).description)"
        delegate?.priceLimit(price: sender.value)
    }
    
    var delegate: PopoverDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Filter"
        
        priceLabel.backgroundColor = UIColor.systemGray5
        ratingLabel.backgroundColor = UIColor.systemGray5
        
        if let delegate = delegate as? MoviesCollectionViewController {
            priceStepper.value = delegate.priceBound
            lessThanLabel.text = "Less than $\(Int(delegate.priceBound).description)"
            ratingControl.selectedSegmentIndex = delegate.ratingCategory
        }
        
        ratingControl.addTarget(self, action: #selector(ratingControlChanges(_:)), for: .valueChanged)
        
    }
    
    @objc func ratingControlChanges(_ ratingChange: UISegmentedControl) {
        
        delegate?.ratingLimit(rating: ratingChange.selectedSegmentIndex)
    }
}
