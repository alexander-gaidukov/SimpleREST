//
//  CachingViewController.swift
//  SimpleREST_Example
//
//  Created by Alexandr Gaidukov on 31/07/2019.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import UIKit
import SimpleREST

struct Joke: Decodable {
    let id: String
    let value: String
    static let all = Resource<JokesResponse, APIError>(baseURL: URL(string: "https://matchilling-chuck-norris-jokes-v1.p.rapidapi.com")!,
                                                   path: "jokes/search",
                                                   params: ["query":"hello"],
                                                   method: .get,
                                                   headers: ["X-RapidAPI-Key": "3daef25ae4mshabcfa916eaed13cp108d55jsnae66725f1d26"],
                                                   decoder: JSONDecoder()).map { $0.result }
}

struct JokesResponse: Decodable {
    let result: [Joke]
}

final class CachingViewController: UIViewController {
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var refreshButtonItem: UIBarButtonItem!
    
    var jokes: [Joke] = [] {
        didSet {
            self.tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView(frame: .zero)
        tableView.estimatedRowHeight = 60
        tableView.rowHeight = UITableViewAutomaticDimension
        loadNews()
    }
    
    @IBAction private func refresh() {
        loadNews(refresh: true)
    }
    
    private func handleError(_ error: HTTPError<APIError>) {
        let message: String
        switch error {
        case .noInternetConnection:
            message = "No internet connection"
        case .responseParseError:
            message = "Response Parsing Error"
        case .serverUnavailable:
            message = "Server unavailable"
        case .custom(let apiError):
            message = apiError.message
        case .other(let code):
            message = "Something went wrong. HTTP code: \(code)"
        }
        
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    private func loadNews(refresh: Bool = false) {
        refreshButtonItem.isEnabled = false
        activityIndicator.startAnimating()
        
        let resource =  Joke.all.cacheable()
        if refresh {
            HTTPCache.shared.clearCache(for: resource)
        }
        
        URLSession.shared.load(resource: resource) {[weak self] result in
            DispatchQueue.main.async {
                self?.activityIndicator.stopAnimating()
                self?.refreshButtonItem.isEnabled = true
                switch result {
                case .success(let jokes):
                    self?.jokes = jokes
                case .failure(let error):
                    self?.handleError(error)
                }
            }
        }
    }
}

extension CachingViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return jokes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Joke Cell", for: indexPath)
        (cell.viewWithTag(1) as? UILabel)?.text = jokes[indexPath.row].value
        return cell
    }
}
