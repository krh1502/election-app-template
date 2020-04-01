//
//  BallotViewController.swift
//  election-app-template
//
//  Created by Kate Halushka on 3/28/20.
//

import UIKit
import Loading

class BallotViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    @IBOutlet weak var candidatePickerField: UITextField!
    @IBOutlet weak var castVoteButton: UIButton!
    @IBOutlet weak var positionLabel: UILabel!
    var id: String = ""
    var records: [Record] = []
    var names: [String] = []
    var networkManager = NetworkManager()
    let picker = UIPickerView()
    //add, edit, or delete positions you are voting on
    let positions = ["N'siah", "S'ganit", "Mit Mom", "Sh'licha", "Mazkirah", "Gizborit"]
    var candidateNum = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        networkManager.votingID = self.id
        positionLabel.text = positions[networkManager.position]
        setup()
    }
    
    @IBAction func castVoteButtonPressed(_ sender: UIButton) {
        alertUser(with: names[candidateNum])
    }
    
    func alertUser(with candidate: String) {
        let alert = UIAlertController(title: "Confirm Selection", message: "Are you sure you want to vote for \(candidate)", preferredStyle: .alert)
        let action1 = UIAlertAction(title: "Yes, I am sure.", style: .default) { action in
            let candidateID = self.records[self.networkManager.position].fields.Candidates?[self.candidateNum]
            self.networkManager.castVote(with: candidateID ?? "", and: self.positions[self.networkManager.position])
            self.names = []
            self.networkManager.getCandidates()
            self.candidatePickerField.isUserInteractionEnabled = false
            self.castVoteButton.isUserInteractionEnabled = false
            self.view.loading.start(.circle(line: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1), line: 3.0))
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                self.names.append(contentsOf: self.networkManager.names)
                self.candidatePickerField.isUserInteractionEnabled = true
                self.castVoteButton.isUserInteractionEnabled = true
                self.insertPicker()
                self.candidatePickerField.text = ""
                self.view.loading.stop()
            }
        }
        let action2 = UIAlertAction(title: "Go Back", style: .cancel) { action in
            alert.dismiss(animated: true, completion: nil)
        }
        alert.addAction(action1)
        alert.addAction(action2)
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func refreshButtonPressed(_ sender: Any) {
        setup()
    }
    @IBAction func nextPositionButtonPressed(_ sender: Any) {
        networkManager.position += 1
        positionLabel.text = positions[networkManager.position]
        setup()
    }
    
    func setup() {
        view.loading.start(.circle(line: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1), line: 3.0))
        candidatePickerField.isUserInteractionEnabled = false
        castVoteButton.isUserInteractionEnabled = false
        names = []
        networkManager.names = []
        networkManager.records = []
        records = []
        networkManager.getCandidates()
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.records = self.networkManager.records
            self.names.append(contentsOf: self.networkManager.names)
            self.insertPicker()
            self.candidatePickerField.isUserInteractionEnabled = true
            self.castVoteButton.isUserInteractionEnabled = true
            self.view.loading.stop()
        }
    }
    
    
    func insertPicker() {
        picker.delegate = self
        picker.dataSource = self
        candidatePickerField.inputView = picker
        picker.reloadAllComponents()
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return names.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return names[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        candidatePickerField.text = names[row]
        pickerView.resignFirstResponder()
        pickerView.endEditing(true)
        view.endEditing(true)
        candidateNum = row
    }
    
}
