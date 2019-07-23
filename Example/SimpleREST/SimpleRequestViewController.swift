//
//  SimpleRequestViewController.swift
//  SimpleREST_Example
//
//  Created by Alexandr Gaidukov on 23/07/2019.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import UIKit
import SimpleREST

struct Country: Decodable {
    let name: String
    let capital: String
    
    static let all = Resource<[Country], APIError>(baseURL: URL(string: "https://restcountries-v1.p.rapidapi.com")!,
                                            path: "all",
                                            params: [:],
                                            method: .get,
                                            headers: ["X-RapidAPI-Key": "3daef25ae4mshabcfa916eaed13cp108d55jsnae66725f1d26"],
                                            decoder: JSONDecoder())
}

struct APIError: Error, Decodable {
    let message: String
}

final class SimpleRequestViewController: UIViewController {
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet private weak var tableView: UITableView!
    
    var countries: [Country] = [] {
        didSet {
            self.tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView(frame: .zero)
        loadCountries()
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
    
    private func loadCountries() {
        activityIndicator.startAnimating()
        URLSession.shared.load(resource: Country.all) {[weak self] result in
            DispatchQueue.main.async {
                self?.activityIndicator.stopAnimating()
                switch result {
                case .success(let countries):
                    self?.countries = countries
                case .failure(let error):
                    self?.handleError(error)
                }
            }
        }
    }
}

extension SimpleRequestViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return countries.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Country Cell", for: indexPath)
        let country = countries[indexPath.row]
        cell.textLabel?.text = country.name
        cell.detailTextLabel?.text = country.capital
        return cell
    }
}
