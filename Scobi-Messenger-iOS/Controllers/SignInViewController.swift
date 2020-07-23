//
//  SignInViewController.swift
//  Scobi-Messenger-iOS
//
//  Created by Onur Osman Güler on 24.07.2020.
//  Copyright © 2020 Design X. All rights reserved.
//

import UIKit

class SignInViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        navigationController?.isNavigationBarHidden = true
    }

}
