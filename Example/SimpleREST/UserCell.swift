//
//  UserCell.swift
//  SimpleREST_Example
//
//  Created by Alexandr Gaidukov on 23/10/2017.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import UIKit
import SimpleREST

class UserCell: UITableViewCell {
    
    static let cahedWebClient = CachedWebClient(webClient: WebClient(baseUrl: "https://cdn1.iconfinder.com/data/icons/user-pictures"))
    
    @IBOutlet private weak var avatarImageView: UIImageView!
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var emailLabel: UILabel!
    
    private var avatarTask: URLSessionDataTask?
    
    override func prepareForReuse() {
        super.prepareForReuse()
        avatarTask?.cancel()
        avatarImageView.image = nil
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        avatarImageView.clipsToBounds = true
        avatarImageView.contentMode = .scaleAspectFill
        avatarImageView.layer.cornerRadius = avatarImageView.frame.width
    }
    
    func configure(user: User) {
        nameLabel.text = user.name
        emailLabel.text = user.email
        
        let resource = Resource<UIImage, Error>(path: user.avatarPath, parse: { data in
            return UIImage(data: data)
        })
        
        avatarTask = UserCell.cahedWebClient.load(resource: resource, completion: {[weak self] result in
            if let image = result.value {
                DispatchQueue.main.async {
                    self?.avatarImageView?.image = image
                }
            }
        })
    }

}
