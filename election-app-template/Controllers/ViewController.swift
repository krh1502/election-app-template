//
//  ViewController.swift
//  election-app-template
//
//  Created by Kate Halushka on 3/27/20.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var IDTextField: UITextField!
    @IBOutlet weak var enterIDButton: UIButton!
    var userIsAuthenticated: Bool = false
    
    var id: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func authenticate(with text: String) {
        if let id = ID(rawValue: text) {
            userIsAuthenticated = true
            self.id = id.rawValue
            performSegue(withIdentifier: "authToVote", sender: self)
        } else {
            alertUser()
            IDTextField.text = ""
        }
    }
    
    @IBAction func enterButtonPressed(_ sender: UIButton) {
        if let text = IDTextField.text {
            authenticate(with: text)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! BallotViewController
        if !userIsAuthenticated {
            return
        }
        destinationVC.id = self.id
    }

    
    func alertUser() {
        let alert = UIAlertController(title: "Incorrect PIN", message: "Please Re-Enter your voting PIN", preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .cancel) { action in
            alert.dismiss(animated: true, completion: nil)
        }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    


}

