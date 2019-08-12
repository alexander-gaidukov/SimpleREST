//
//  MultipartRequestViewController.swift
//  SimpleREST_Example
//
//  Created by Alexandr Gaidukov on 12/08/2019.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import UIKit
import SimpleREST

struct Tag: Decodable {
    let label: String
    let color: String
    
    static func all(for imagePath: String) -> Resource<[Tag], APIError> {
        let attachment = try! Attachment(path: imagePath)
        let body: Body = .multipart(params: [:], attachments: ["image": [attachment]])
        return Resource<TagsResponse, APIError>(baseURL: URL(string: "https://apicloud-colortag.p.rapidapi.com")!,
                                         path: "tag-file",
                                         params: [:],
                                         method: .post(body),
                                         headers: ["X-RapidAPI-Key": "3daef25ae4mshabcfa916eaed13cp108d55jsnae66725f1d26"],
                                         decoder: JSONDecoder()).map { $0.tags }
    }
}

struct TagsResponse: Decodable {
    let tags: [Tag]
}

class MultipartRequestViewController: UIViewController {
    
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var button: UIButton!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    
    var imagePath: String {
        return Bundle.main.path(forResource: "image", ofType: "jpeg")!
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.image = UIImage(contentsOfFile: imagePath)//UIImage(data: try! Data(contentsOf: imageURL))
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
    
    private func handleTags(_ tags: [Tag]) {
        
    }
    
    private func analyzeColors() {
        button.isEnabled = false
        activityIndicator.startAnimating()
        URLSession.shared.load(resource: Tag.all(for: imagePath)) {[weak self] result in
            DispatchQueue.main.async {
                self?.activityIndicator.stopAnimating()
                self?.button.isEnabled = true
                switch result {
                case .success(let tags):
                    self?.handleTags(tags)
                case .failure(let error):
                    self?.handleError(error)
                }
            }
        }
    }
    
    @IBAction private func buttonTapped() {
        analyzeColors()
    }

}
