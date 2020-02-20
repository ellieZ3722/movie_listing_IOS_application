//
//  DetailViewController.swift
//  LetsGoToMovie
//
//  Created by Kiwiinthesky72 on 2/15/20.
//  Copyright © 2020 Kiwiinthesky72. All rights reserved.
//

import UIKit
import SafariServices

class DetailViewController: UIViewController {
    @IBOutlet var movieName: UILabel!
    @IBOutlet var price: UILabel!
    @IBOutlet var rating: UILabel!
    @IBOutlet var longDescription: UITextView!
    var previewUrl: String?
    
    let safariIcon = UIImage(systemName: "safari")
    
    var movie: Movie?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.largeTitleDisplayMode = .never
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: safariIcon, style: .plain, target: self, action: #selector(safariTapped(_:)))
        
        movieName.numberOfLines = 0
        movieName.text = movie?.trackName
        if let moviePrice = movie?.trackPrice {
            price.text = "$\(String(describing: moviePrice))"
        }
        rating.text = movie?.contentAdvisoryRating
        longDescription.text = movie?.longDescription
        previewUrl = movie?.previewUrl
    }
    
    @objc func safariTapped(_ button: UIBarButtonItem) {
        if let previewUrl = previewUrl {
            guard let url = URL(string: previewUrl) else {return}
            let svc = SFSafariViewController(url: url)
            present(svc, animated: true, completion: nil)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.hidesBarsOnTap = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.hidesBarsOnTap = false
    }

}
