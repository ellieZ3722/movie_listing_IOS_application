//
//  MovieClient.swift
//  LetsGoToMovie
//
//  Created by Kiwiinthesky72 on 2/17/20.
//  Copyright © 2020 Kiwiinthesky72. All rights reserved.
//

import Foundation

struct Movie: Codable, Hashable{
    let trackName: String?
    let trackPrice: Double?
    let contentAdvisoryRating: String?
    let longDescription: String?
    let artworkUrl100: String?
    let previewUrl: String?
    let primaryGenreName: String?
}

class Result: Codable {
    let resultCount: Int?
    let results: [Movie]?
}

class MovieClient {
    func fetchMovies(completion: @escaping ([Movie]?, Error?) -> Void) {
        let urlString = "https://itunes.apple.com/search?country=US&media=movie&limit=200&term=ghost"
        
        guard let url = URL(string: urlString) else {
            fatalError("Unable to create NSURL from string")
        }
        
        let session = URLSession.shared
        let task = session.dataTask(with: url as URL, completionHandler: {(data, response, error) -> Void in
            guard let data = data, error == nil else {
                DispatchQueue.main.async {completion(nil, error)}
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let result = try decoder.decode(Result.self, from: data)
                
                DispatchQueue.main.async {
                    completion(result.results, nil)
                }
            } catch {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
            }
        })
        
        task.resume()
    }
}
