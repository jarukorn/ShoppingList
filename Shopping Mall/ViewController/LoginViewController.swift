//
//  LoginViewController.swift
//  Shopping Mall
//
//  Created by Jarukorn Thuengjitvilas on 28/2/2565 BE.
//

import UIKit
import FirebaseAuth

class LoginViewController: UIViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var loginContainerView: UIView!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var signInButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.loginContainerView.layer.cornerRadius = 12
        self.signInButton.layer.cornerRadius = 12
        
    }

    @IBAction func signInButtonClicked(_ sender: UIButton) {
        if let username = usernameTextField.text,
           let password = passwordTextField.text {
            Auth.auth().signIn(withEmail: username, password: password) { result, error in
                if let result = result {
                    print("Hello: \(result.user.email ?? "")")
                    if let vc = self.storyboard?.instantiateViewController(withIdentifier: "MainViewController") as? MainViewController {
                        let nav = UINavigationController(rootViewController: vc)
                        nav.modalPresentationStyle = .fullScreen
                        nav.navigationBar.prefersLargeTitles = true
                        self.present(nav, animated: true) {
                            self.usernameTextField.text = ""
                            self.passwordTextField.text = ""
                        }
                    }
                } else {
                    if let error = error {
                        let alert = UIAlertController(title: "Authentication failed", message: "\(error.localizedDescription)", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                        self.present(alert, animated: true)
                    }
                }
            }
        }
    }
    
    @IBAction func createNewUserButtonClicked(_ sender: Any) {
        if let username = usernameTextField.text,
           let password = passwordTextField.text {
            Auth.auth().createUser(withEmail: username, password: password) { result, error in
                if let result = result {
                    print("Successfully Create User: \(result.user.email ?? "")")
                    let alert = UIAlertController(title: "Successfully Create User: \(result.user.email ?? "")", message: nil, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(alert, animated: true) {
                        self.usernameTextField.text = ""
                        self.passwordTextField.text = ""
                    }
                } else {
                    if let error = error {
                        let alert = UIAlertController(title: "Unable to create a user", message: "\(error.localizedDescription)", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                        self.present(alert, animated: true)
                    }
                }
            }
        } else {
            let alert = UIAlertController(title: "Invalid Input", message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alert, animated: true)
        }
    }
    
}

