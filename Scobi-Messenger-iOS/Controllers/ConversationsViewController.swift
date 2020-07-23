//
//  ViewController.swift
//  Scobi-Messenger-iOS
//
//  Created by Onur Osman Güler on 24.07.2020.
//  Copyright © 2020 Design X. All rights reserved.
//

import UIKit

class ConversationsViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
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
        }
    }


}

