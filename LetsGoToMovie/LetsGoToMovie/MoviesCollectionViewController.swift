//
//  MoviesCollectionViewController.swift
//  LetsGoToMovie
//
//  Created by Kiwiinthesky72 on 2/15/20.
//  Copyright © 2020 Kiwiinthesky72. All rights reserved.
//

import UIKit

private let reuseIdentifier = "Cell"

//use delegate protocal to transmit information from the popover view to the MovieCollectionViewController
protocol PopoverDelegate {
    func ratingLimit(rating: Int) -> Void
    func priceLimit(price: Double) -> Void
}

internal class MoviesCollectionViewController: UICollectionViewController {
    @IBOutlet var collectView: UICollectionView!
    @IBOutlet var filterButton: UIBarButtonItem!
    
    var dataSource: UICollectionViewDiffableDataSource<String, Movie>!
    var snapshot: NSDiffableDataSourceSnapshot<String, Movie>!
    
    //array to hold all movies that is queried from the API
    var movies: [Movie] = []
    //array to hold the currently legitimate movies under the constraint of pricing and rating
    var filteredMovies: [Movie] = []
    //array to store the genres that need to be presented at current time
    var genres: [String] = []
    //dictionary to store genres and the corresponding movies 
    var listOfGenres: [String: [Movie]] = [:]
    
    var priceBound: Double = 20
    var ratingCategory: Int = 4
    
    let indexToRatingName: [Int: String] = [0: "G", 1: "PG", 2: "PG-13", 3: "R", 4: "All"]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Ghost Movies"
        
        //fetch movies from the api
        let client = MovieClient()
        client.fetchMovies(completion: {
            (data, error) -> Void in
            
            if let data = data, error == nil {
                for dataEle in data {
                    self.movies.append(dataEle)
                    if let genreName = dataEle.primaryGenreName {
                        if !self.genres.contains(genreName) {
                            self.genres.append(genreName)
                        }
                    }
                }
            } else {
                if let error = error {
                    print(error)
                }
            }
            self.filteredMovies = self.movies
            
            //create diffable data source
            self.configureDataSource()
            
            //configure the datasource to update the supplementray view for section headers
            self.confugureHeader()
            
            // create and apply the snapshot to the datasource
            self.updateUI(movies: self.filteredMovies)
        })
        
        collectView.collectionViewLayout = makeLayout()
    }
    
    //function to update the UI with new snapshot
    func updateUI(movies: [Movie]) {
        snapshot = NSDiffableDataSourceSnapshot<String, Movie>()
        
        snapshot.appendSections(genres)
        
        for movie in movies {
            if let genreName = movie.primaryGenreName {
                if !listOfGenres.keys.contains(genreName) {
                    listOfGenres[genreName] = []
                }
                listOfGenres[genreName]?.append(movie)
            }
        }
        
        for genreName in listOfGenres.keys {
            if let moviesOfAGenre = listOfGenres[genreName] {
                snapshot.appendItems(moviesOfAGenre, toSection: genreName)
            }
        }
        dataSource.apply(snapshot)
        
    }
    
    //function to configure the diffable datasource to update collection view cells
    func configureDataSource() {
        self.dataSource = UICollectionViewDiffableDataSource(collectionView: self.collectView) {collectView, indexPath,movie in
            let cell = collectView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! CollectionViewCell
            cell.movieName.text = movie.trackName
            
            if let price = movie.trackPrice {
                cell.moviePrice.text = "$\(String(describing: price))"
            }
            
            cell.rating.text = movie.contentAdvisoryRating

            cell.contentView.backgroundColor = UIColor.systemGray6
            
            //start downloading the corresponding poster only when a cell is on the screen
            if let artworkUrl100 = movie.artworkUrl100 {
                self.getImage(imageView: cell.movieImage, imgURL: artworkUrl100)
            }
            return cell
        }
       
    }
    
    //function to configure the section headers
    func confugureHeader() {
        dataSource.supplementaryViewProvider = {
            (collectionView: UICollectionView,
            kind: String,
            indexPath: IndexPath) -> UICollectionReusableView? in
            
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "Header", for: indexPath) as! TitleSupplementaryView
            
            header.backgroundColor = UIColor.systemGray6
            header.headerText.text = self.genres[indexPath.section]
            return header
        }
    }
    
    //prepare function to assign delegates
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "popoverSeg" {
            segue.destination.preferredContentSize = CGSize(width: 300, height: 200)
            
            if let naviController = segue.destination as? UINavigationController {
                if let pvc = naviController.viewControllers[0] as? PopoverViewController {
                    pvc.delegate = self
                }
            }
            
            if let presentationController = segue.destination.popoverPresentationController {
                presentationController.delegate = self
            }
        }
    }
    
    //funciton to download movie poster from the url
    func getImage(imageView: UIImageView, imgURL: String) {
        guard let url = URL(string: imgURL) else {
            fatalError("Unable to create NSURL from string")
        }
        
        let session = URLSession.shared
        let task = session.dataTask(with: url as URL, completionHandler: {(data, response, error) -> Void in
            if let data = data, error == nil {
                DispatchQueue.main.async {
                    imageView.image = UIImage(data: data)
                }
            }
        })
        task.resume()
    }
    
    //function to configure the collection view layout
    func makeLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout{(section: Int, enviroment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
            let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: NSCollectionLayoutDimension.fractionalWidth(1.0), heightDimension: NSCollectionLayoutDimension.absolute(150)))
            item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20)
            
            let groupSize = NSCollectionLayoutSize(widthDimension: NSCollectionLayoutDimension.fractionalWidth(1.0), heightDimension: NSCollectionLayoutDimension.absolute(170))
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 2)
            
            let section = NSCollectionLayoutSection(group: group)
            section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 5, bottom: 10, trailing: 5)
            
            let headerFooterSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                          heightDimension: .estimated(44))
            let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(
                layoutSize: headerFooterSize,
                elementKind:  UICollectionView.elementKindSectionHeader, alignment: .top)
            section.boundarySupplementaryItems = [sectionHeader]
            
            return section
        }
        
        return layout
    }
    
    //function to enable the clicking and pushing the detail view controller
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let dvc = storyboard?.instantiateViewController(withIdentifier: "Detail") as? DetailViewController{
            let genre = genres[indexPath.section]
            let listOfMovies = listOfGenres[genre]
            
            if let listOfMovies = listOfMovies {
                dvc.movie = listOfMovies[indexPath.row]
            }
            
            navigationController?.pushViewController(dvc, animated: true)
        }
    }

}

extension MoviesCollectionViewController: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController,
                                   traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return .none 
    }
}

extension MoviesCollectionViewController: PopoverDelegate {
    
    //function to update the limit on rating specified in the popover window
    func ratingLimit(rating: Int) {
        ratingCategory = rating
        
        updateUIAfterFirstTime()
    }
    
    //function to update the limit on price specified in the popover window
    func priceLimit(price: Double) {
        priceBound = price
        
        updateUIAfterFirstTime()
    }
    
    //function to select the legitimate movies for presentation
    func updateUIAfterFirstTime() {
        filteredMovies = []
        genres = []
        listOfGenres = [:]
        
        for movie in movies {
            if let price = movie.trackPrice, price > priceBound {
                continue
            }
            if let rating = movie.contentAdvisoryRating {
                if ratingCategory != 4 && rating != indexToRatingName[ratingCategory] {
                    continue
                }
            }
            filteredMovies.append(movie)
            
            //updating at current time how many genres should be presented
            if let genreName = movie.primaryGenreName, !genres.contains(genreName) {
                genres.append(genreName)
            }
        }
        confugureHeader()
        updateUI(movies: filteredMovies)
    }
}
