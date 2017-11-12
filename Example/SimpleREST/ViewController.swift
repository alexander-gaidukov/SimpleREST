//
//  ViewController.swift
//  SimpleREST
//
//  Created by alexander-gaidukov on 10/21/2017.
//  Copyright (c) 2017 alexander-gaidukov. All rights reserved.
//

import UIKit
import SimpleREST

class ViewController: UIViewController {
    
    static let sharedWebClient = WebClient.init(baseUrl: "http://www.mocky.io/v2")
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var friends: [User] = [] {
        didSet {
            updateUI()
        }
    }
    
    var friendsTask: URLSessionDataTask!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.tableFooterView = UIView(frame: .zero)
        loadFriends(error: false)
    }
    
    private func showErrorAlert(with message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }
    
    private func moveToLogin() {
        
    }
    
    private func handleError(_ error: WebError<CustomError>) {
        switch error {
        case .noInternetConnection:
            showErrorAlert(with: "The internet connection is lost")
        case .unauthorized:
            moveToLogin()
        case .other(let code, let error):
            showErrorAlert(with: "Unfortunately something went wrong. Code:\(code). Description: \(error?.localizedDescription ?? "")")
        case .wrongDataFormat:
            showErrorAlert(with: "Wrong response format")
        case .custom(let error):
            showErrorAlert(with: error.message)
        }
    }
    
    private func loadFriends(error: Bool) {
        friendsTask?.cancel()
        
        activityIndicator.startAnimating()
        
        let path = error ? "/59edcc8e3300005600b5c6ff" : "/5a07ff0f2f0000ef16e61108"
        
        let friensResource = Resource<FriendsResponse, CustomError>(jsonDecoder: JSONDecoder(), path: path)
        
        friendsTask = ViewController.sharedWebClient.load(resource: friensResource) {[weak self] response in
            
            guard let controller = self else { return }
            
            DispatchQueue.main.async {
                controller.activityIndicator.stopAnimating()
                
                if let friends = response.value?.friends {
                    controller.friends = friends
                } else if let error = response.error {
                    controller.handleError(error)
                }
            }
        }
    }
    
    @IBAction private func refreshTapped() {
        loadFriends(error: false)
    }
    
    @IBAction private func loadError() {
        loadFriends(error: true)
    }
    
    private func updateUI() {
        tableView.reloadData()
    }
}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return friends.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FriendCell", for: indexPath) as! UserCell
        let friend = friends[indexPath.row]
        cell.configure(user: friend)
        return cell
    }
}

