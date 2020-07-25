//
//  LoginViewController.swift
//  Scobi-Messenger-iOS
//
//  Created by Onur Osman Güler on 24.07.2020.
//  Copyright © 2020 Design X. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    private let label: UILabel = {
        let label = UILabel()
        label.text = "Login Screen"
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        view.backgroundColor = .white
        view.addSubview(label)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        label.frame = CGRect(x: 100, y: 100, width: 300, height: 50)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
    }

}
