//
//  CollectionViewCell.swift
//  LetsGoToMovie
//
//  Created by Kiwiinthesky72 on 2/15/20.
//  Copyright © 2020 Kiwiinthesky72. All rights reserved.
//

import UIKit

class CollectionViewCell: UICollectionViewCell {
    @IBOutlet var movieName: UILabel!
    @IBOutlet var rating: UILabel!
    @IBOutlet var moviePrice: UILabel!
    @IBOutlet var movieImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
}
