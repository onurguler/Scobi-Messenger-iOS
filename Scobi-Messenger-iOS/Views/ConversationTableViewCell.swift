//
//  ConversationTableViewCell.swift
//  Scobi-Messenger-iOS
//
//  Created by Onur Osman Güler on 27.07.2020.
//  Copyright © 2020 Design X. All rights reserved.
//

import UIKit

class ConversationTableViewCell: UITableViewCell {

    static let identifier = "ConversationTableViewCell"
    
    private let avatarView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 32
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 21, weight: .bold)
        label.numberOfLines = 1
        return label
    }()
    
    private let messageLabel: UILabel = {
        let label = UILabel()
        label.textColor = .gray
        label.font = .systemFont(ofSize: 19, weight: .regular)
        label.numberOfLines = 1
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(avatarView)
        contentView.addSubview(nameLabel)
        contentView.addSubview(messageLabel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        avatarView.frame = CGRect(x: 10,
                                  y: 10,
                                  width: 64,
                                  height: 64)
        
        nameLabel.frame = CGRect(x: avatarView.right + 10,
                                 y: 18,
                                 width: contentView.width - 20 - avatarView.width,
                                 height: 20)
        
        messageLabel.frame = CGRect(x: avatarView.right + 10,
                                    y: nameLabel.bottom + 10,
                                    width: contentView.width - 20 - avatarView.width,
                                    height: 20)
    }
    
    public func configure(with model: APIService.Conversation) {
        // @TODO: SD Web image conversation avatar
        self.avatarView.image = UIImage(systemName: "person.circle")
        self.nameLabel.text = model.displayName
        self.messageLabel.text = model.lastMessage.text
    }
    
}
