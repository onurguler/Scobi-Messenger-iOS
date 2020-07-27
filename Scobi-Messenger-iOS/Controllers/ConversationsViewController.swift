//
//  ViewController.swift
//  Scobi-Messenger-iOS
//
//  Created by Onur Osman Güler on 24.07.2020.
//  Copyright © 2020 Design X. All rights reserved.
//

import UIKit

class ConversationsViewController: UIViewController {
    private var userLoaded = false
    private var conversations = [APIService.Conversation]()
    
    private let tableView: UITableView = {
        let table = UITableView()
        table.isHidden = true
        table.register(ConversationTableViewCell.self, forCellReuseIdentifier: ConversationTableViewCell.identifier)
        return table
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(tableView)
        
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let isLoggedIn = UserDefaults.standard.bool(forKey: "logged_in")
        
        if !isLoggedIn {
            // Navigate to sign in screen
            guard let vc = self.storyboard?.instantiateViewController(withIdentifier: "Sign In") else {
                return
            }
            let nav = UINavigationController(rootViewController: vc)
            nav.modalPresentationStyle = .fullScreen
            present(nav, animated: true)
        } else {
            if !userLoaded {
                fetchConversations()
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        tableView.frame = view.bounds
    }

    private func fetchConversations() {
        APIService.shared.fetchAuthenticatedUser { [weak self] (result) in
            switch result {
            case .success(let response):
                guard let status = response["status"] as? Int,
                    let data = response["data"] as? [String: Any] else {
                        return
                }
                
                print("fetch authenticated user: \(response)")
                
                if status == 200 {
                    guard let first_name = data["first_name"] as? String,
                        let last_name = data["last_name"] as? String,
                        let username = data["username"] as? String,
                        let uuid = data["uuid"] as? String else {
                            return
                    }
                    
                    UserDefaults.standard.set(first_name, forKey: "first_name")
                    UserDefaults.standard.set(last_name, forKey: "last_name")
                    UserDefaults.standard.set(username, forKey: "username")
                    UserDefaults.standard.set(uuid, forKey: "uuid")
                    
                    APIService.shared.fetchConversations { (result) in
                        switch result {
                        case .success(let response):
                            guard let status = response["status"] as? Int,
                                let data = response["data"] as? [[String: Any]] else {
                                    return
                            }
                            
                            let currentUser = UserDefaults.standard.string(forKey: "username")
                            
                            if status == 200 {
                                var conversations = [APIService.Conversation]()
                                
                                for conversation in data {
                                    guard let uuid = conversation["uuid"] as? String,
                                        let participants = conversation["participants"] as? [[String: Any]],
                                        let createdAt = conversation["created_at"] as? String,
                                        let updatedAt = conversation["updated_at"] as? String,
                                        let lastMessage = conversation["last_message"] as? [String: Any] else {
                                            return
                                    }
                                    
                                    guard let owner = lastMessage["owner"] as? [String: Any],
                                        let ownerId = owner["uuid"] as? String,
                                        let ownerFirstName = owner["first_name"] as? String,
                                        let ownerLastName = owner["last_name"] as? String,
                                        let ownerUsername = owner["username"] as? String,
                                        let lastMessageText = lastMessage["text"] as? String,
                                        let lastMessageCreatedAt = lastMessage["created_at"] as? String,
                                        let lastMessageUpdatedAt = lastMessage["updated_at"] as? String else {
                                            return
                                    }
                                    
                                    let lastMessageOwner = APIService.Participant(uuid: ownerId,
                                                                                  username: ownerUsername,
                                                                                  firstName: ownerFirstName,
                                                                                  lastName: ownerLastName)
                                    
                                    let lastMessageObj = APIService.ConversationLastMessage(owner: lastMessageOwner,
                                                                                            text: lastMessageText,
                                                                                            createdAt: lastMessageCreatedAt,
                                                                                            updatedAt: lastMessageUpdatedAt)
                                    
                                    var participantsDict = [APIService.Participant]()
                                    
                                    var displayName = "Conversation"
                                    
                                    for participant in participants {
                                        guard let uuid = participant["uuid"] as? String,
                                            let firstName = participant["first_name"] as? String,
                                            let lastName = participant["last_name"] as? String,
                                            let username = participant["username"] as? String else {
                                                return
                                        }
                                        
                                        if username != currentUser {
                                            displayName = "\(firstName) \(lastName)"
                                        }
                                        
                                        participantsDict.append(APIService.Participant(uuid: uuid,
                                                                                       username: username,
                                                                                       firstName: firstName,
                                                                                       lastName: lastName))
                                    }
                                    
                                    conversations.append(APIService.Conversation(uuid: uuid,
                                                                                 displayName: displayName,
                                                                                 participants: participantsDict,
                                                                                 lastMessage: lastMessageObj,
                                                                                 createdAt: createdAt,
                                                                                 updatedAt: updatedAt))
                                }

                                self?.conversations = conversations

                                DispatchQueue.main.async {
                                    if conversations.isEmpty {
                                        self?.tableView.isHidden = true
                                    } else {
                                        self?.tableView.isHidden = false
                                        self?.tableView.reloadData()
                                    }
                                }
                                self?.userLoaded = true
                            }
                        case .failure(let error):
                            print("Failed to get conversations: \(error)")
                        }
                    }
                }
            case .failure(let error):
                print("Failed to get authenticated user: \(error)")
            }
        }
    }

}

extension ConversationsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return conversations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ConversationTableViewCell.identifier,
                                                 for: indexPath) as! ConversationTableViewCell
        
        let model = conversations[indexPath.row]
        
        cell.configure(with: model)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 84
    }
    
}

