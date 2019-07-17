//
//  TimeSet.swift
//  WeeklyApp
//
//  Created by Mike on 3/5/19.
//  Copyright © 2019 rdm. All rights reserved.
//

import UIKit
import Foundation
import SQLite3

class TimeSet: UIViewController, UITextFieldDelegate{
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    let timePicker = UIDatePicker()
    let DBHelper = EntryDB()
    var dropMenu = dropDownButton()
    
    @IBOutlet weak var confirmReference: UIButton!
    
    @IBOutlet weak var TaskNameReference: UITextField!
    
    @IBOutlet weak var TaskTimeReference: UITextField!
    //Code for the cancel button
    @IBAction func returnToMain(_ sender: Any) {
        self.performSegue(withIdentifier: "TimeToMain", sender: self)
    }
    //End of cancel button
    
    //Code for confirm button
    @IBAction func confirmButton(_ sender: Any) {
        //check for empty field
        if(EventName.text != nil && EventName.text != "" && TimePickView.text != "" && TimePickView.text != nil && dropMenu.titleLabel?.text! != "Day"){ 
            EntryDB.ConfirmButtonDB(DBHelper)(arg: EventName.text!, arg: TimePickView.text!, arg: (dropMenu.titleLabel?.text!)!)
            self.performSegue(withIdentifier: "TimeToMain", sender: self)
        } else{
            let alertController = UIAlertController(title: "Incomplete Field", message:
                "Please fill out all fields", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Dismiss", style: .default))
            
            self.present(alertController, animated: true, completion: nil)
        }
    }
    //End of confirm button
    
    //Code for time picker field, perhaps make it bigger
    @IBOutlet weak var TimePickView: UITextField!
    func createDatePicker(){
        timePicker.datePickerMode = .time
        //picks which part of datepicker is used
        TimePickView.inputView = timePicker
        
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        let doneButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.done, target: self, action: #selector(self.doneClicked))
        
        toolbar.setItems([doneButton], animated:true)
        TimePickView.inputAccessoryView = toolbar
        
    }
    
    //code for when the confirm button is clicked
    @objc func doneClicked(){
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .none
        dateFormatter.timeStyle = .short //.short gives hours and minutes, .medium gives seconds
        
        TimePickView.text = dateFormatter.string(from: timePicker.date)
        self.view.endEditing(true)
    }
    //End of time picker code
    
    
    //Start of Name picker code
    @IBOutlet weak var EventName: UITextField!
    func createNamePicker(){
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
            
        let NameDoneButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.done, target: self, action: #selector(self.textFieldShouldReturn(_:)))
            
        toolbar.setItems([NameDoneButton], animated:true)
        EventName.inputAccessoryView = toolbar
    }
    
    //code for what the done button on keyboard popup does
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == EventName {
            textField.resignFirstResponder()
            EventName.becomeFirstResponder()
        }else{
            EventName.resignFirstResponder()
        }
        let name: String = EventName.text!
        print("\(name)")
        return true
    }
    //End of name picker
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //initializes the time picker
        createDatePicker()
        createNamePicker()
        EventName.delegate = self
        let borderColor = UIColor.green

        confirmReference.layer.borderWidth = 1
        confirmReference.layer.borderColor = borderColor.cgColor
        
        TaskNameReference.layer.borderWidth = 1
        TaskNameReference.layer.borderColor = borderColor.cgColor
        TaskTimeReference.layer.borderWidth = 1
        TaskTimeReference.layer.borderColor = borderColor.cgColor
        
        //dropdown menu initialize and creation
        dropMenu = dropDownButton.init(frame: CGRect(x: 0, y:0, width:0, height: 0))
        dropMenu.layer.borderWidth = 1
        dropMenu.layer.borderColor = borderColor.cgColor
        dropMenu.setTitle("Day", for: .normal)
        dropMenu.setTitleColor(UIColor.green, for: .normal)
        dropMenu.titleLabel?.textAlignment = .center
        dropMenu.translatesAutoresizingMaskIntoConstraints = false // turn off auto resize, it messes with the other constraints
        
        self.view.addSubview(dropMenu)
        
        dropMenu.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true //centers it on the x axis
        dropMenu.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true //centers it on the y axis
        
        //dropMenu.widthAnchor.constraint(equalToConstant: 220).isActive = true //the actual size
        //dropMenu.heightAnchor.constraint(equalToConstant: 80).isActive = true
 
        dropMenu.titleLabel?.font = UIFont(name: (dropMenu.titleLabel?.font.fontName)!, size:self.view.frame.size.width/20)
        
        dropMenu.widthAnchor.constraint(equalToConstant: self.view.frame.size.width/3).isActive = true
        dropMenu.heightAnchor.constraint(equalToConstant: self.view.frame.size.height/20).isActive = true
 
        dropMenu.dropView.dropDownOptions = ["Monday","Tuesday","Wednesday","Thursday","Friday","Saturday","Sunday"]
        // Do any additional setup after loading the view, typically from a nib.
        

    }
    

    
}


/*----------------------------------------------------------------------------------------*/
//code for dropdown menu
protocol dropDownProtocol{
    func dropDownPressed(string: String)
}

class dropDownButton: UIButton, dropDownProtocol{
    func dropDownPressed(string: String){
        self.setTitle(string, for: .normal)
        self.dismissDropDown()
    }
    
    var dropView = dropDownView()
    var height = NSLayoutConstraint()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.black
        dropView = dropDownView.init(frame: CGRect.init(x: 0, y: 0, width: 0, height: 0))
        
        dropView.delegate = self
        
        dropView.translatesAutoresizingMaskIntoConstraints = false
        self.superview?.addSubview(dropView)
        self.superview?.bringSubviewToFront(dropView) //where the dropdown goes, front/back
    }
    
    override func didMoveToSuperview() {
        self.superview?.addSubview(dropView)
        self.superview?.bringSubviewToFront(dropView) //where the dropdown goes, front/back
        dropView.topAnchor.constraint(equalTo: self.bottomAnchor).isActive = true //where the dropdown goes in relation to the button
        dropView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        dropView.widthAnchor.constraint(equalTo: self.widthAnchor).isActive = true
        height = dropView.heightAnchor.constraint(equalToConstant: 0)
    }
    
    var isOpen = false
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if isOpen == false{
            isOpen = true
            NSLayoutConstraint.deactivate([self.height])
            
            if self.dropView.tableView.contentSize.height>150{
                self.height.constant = 150
            } else {
                self.height.constant = self.dropView.tableView.contentSize.height
            }
            
            NSLayoutConstraint.activate([self.height])
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseIn, animations: {
                self.dropView.layoutIfNeeded()
                self.dropView.center.y += self.dropView.frame.height/2 //takes height of the new contsant
                }, completion: nil)
            
            //UIView.animate(withDuration: 0.5, animations: self.dropView.layoutIfNeeded())
        } else {
            isOpen = false
            
            NSLayoutConstraint.deactivate([self.height])
            self.height.constant = 0
            NSLayoutConstraint.activate([self.height])
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseIn, animations: {
                self.dropView.center.y -= self.dropView.frame.height/2
                self.dropView.layoutIfNeeded()
                }, completion: nil)
        }
    }
    
    func dismissDropDown() {
        isOpen = false
        
        NSLayoutConstraint.deactivate([self.height])
        self.height.constant = 0
        NSLayoutConstraint.activate([self.height])
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseIn, animations: {
            self.dropView.center.y -= self.dropView.frame.height/2
            self.dropView.layoutIfNeeded()
        }, completion: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        
        fatalError("init(coder:) has not been implemented")
    }
}

class dropDownView: UIView, UITableViewDelegate, UITableViewDataSource{
    var dropDownOptions = [String]()
    
    var tableView = UITableView()
    
    var delegate : dropDownProtocol!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.black
        tableView.backgroundColor  = UIColor.black
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(tableView)
        
        tableView.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        tableView.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        tableView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dropDownOptions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = dropDownOptions[indexPath.row]
        let borderColor = UIColor.green
        cell.layer.borderWidth = 1
        cell.layer.borderColor = borderColor.cgColor
        cell.backgroundColor = UIColor.black
        cell.textLabel?.textColor = UIColor.green
        cell.textLabel?.textAlignment = .center
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.delegate.dropDownPressed(string: dropDownOptions[indexPath.row]) //this passes the string back up to the set title
        //print(dropDownOptions[indexPath.row])
        self.tableView.deselectRow(at: indexPath, animated: true)
    }
    
}
// end of drop down button code
