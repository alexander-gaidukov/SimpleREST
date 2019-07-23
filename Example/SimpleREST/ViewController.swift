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
    
}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = "Simple Request"
        return cell
    }
}

extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        performSegue(withIdentifier: "Show simple request", sender: nil)
    }
}

