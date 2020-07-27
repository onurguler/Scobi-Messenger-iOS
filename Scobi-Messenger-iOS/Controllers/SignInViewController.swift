//
//  SignInViewController.swift
//  Scobi-Messenger-iOS
//
//  Created by Onur Osman Güler on 24.07.2020.
//  Copyright © 2020 Design X. All rights reserved.
//

import UIKit

class SignInViewController: UIViewController {
    
    @IBOutlet private weak var usernameTextField: UITextField!
    @IBOutlet private weak var passwordTextField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction private func loginButtonTapped(button: UIButton) {
        guard let username = usernameTextField.text,
            let password = passwordTextField.text,
            let usernameTrimmed: String = username.trimmingCharacters(in: .whitespacesAndNewlines),
            let passwordTrimmed: String = password.trimmingCharacters(in: .whitespacesAndNewlines),
            !usernameTrimmed.isEmpty, !passwordTrimmed.isEmpty else {
            return
        }
        
        APIService.shared.signIn(with: usernameTrimmed, password: passwordTrimmed) { [weak self] result in
            switch result {
            case .success(let response):
                guard let status = response["status"] as? Int,
                    let data = response["data"] as? [String: Any] else {
                        return
                }

                if status == 200 {
                    guard let token = data["token"] as? String else {
                        return
                    }
                    
                    print("Login successful. Token: \(token)")
                    
                    UserDefaults.standard.set(token, forKey: "token")
                    UserDefaults.standard.set(true, forKey: "logged_in")
                    
                    DispatchQueue.main.async {
                        self?.dismiss(animated: true, completion: nil)
                    }
                }
            case .failure(let error):
                print("Error to login: \(error)")
            }
        }
    }

}
