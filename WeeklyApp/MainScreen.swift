//
//  ViewController.swift
//  WeeklyApp
//
//  Created by M on 3/5/19.
//  Copyright © 2019 rdm. All rights reserved.
//

import UIKit
import SQLite3
import UserNotifications

class MainScreen: UIViewController, UITableViewDelegate, UITableViewDataSource, UNUserNotificationCenterDelegate  {
    @IBOutlet weak var MainTable: UITableView!
    
    
    static var SaveList: Array<String> = []
    static var SaveListIDS: Array<Int> = []
    
    struct tempListPause{
        static var TempListStatus: Array<String> = []
        static var TempListIDS: Array<Int> = []
    }
    
    let DBHelper = EntryDB()
    
    var timer = Timer()
    
    struct DataTypes{
        var arrayID: Int
        var NotifID: String
    }
    
    struct DataTypes2{
        var arrayID: Int
        var NotifID: String
    }
    
    struct NotificationArray{
        static var array: Array<DataTypes> = []
    }

    //code for + button, swaps to time selection screen
    @IBAction func SwapToTime(_ sender: Any) {
        self.performSegue(withIdentifier: "MainToTime", sender: self)
    }
    
    
    //code for the checkbox whenever it is clicked
    @IBAction func checkBoxPressed(_ sender: UIButton) {
        let center = UNUserNotificationCenter.current()
        let buttonTag = sender.tag
        DBHelper.updateTableCheckboxPressed(arg: buttonTag)
        
        if(EntryDB.MainListStruct.MainList[buttonTag].status == "1"){
            //sets alarm when the box gets checked
            scheduleNotification(arg: buttonTag)
        } else if (MainScreen.NotificationArray.array.isEmpty){
            //Old method, possibly delete
        }else{
            var placeHolder = 0
            //cancel the notification when the box gets unchecked
            for index in 0 ... MainScreen.NotificationArray.array.count-1{
                if(MainScreen.NotificationArray.array[index].arrayID == buttonTag){
                    placeHolder = index
                }
            }
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [MainScreen.NotificationArray.array[placeHolder].NotifID])
            //center.removePendingNotificationRequests(withIdentifiers: [MainScreen.NotificationArray.array[placeHolder].NotifID])
            MainScreen.NotificationArray.array.remove(at: placeHolder)
        }
        
        self.MainTable.reloadData()
    }
    
    //schedules notification when called
    func scheduleNotification(arg entryID:Int) {
        let center = UNUserNotificationCenter.current()
        
        let stringDate = EntryDB.MainListStruct.MainList[entryID].time
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "hh:mm a"
        let date2 = dateFormatter.date(from: stringDate)!
        let calendar2 = Calendar.current
        let hour2 = calendar2.component(.hour, from: date2)
        let minute2 = calendar2.component(.minute, from: date2)
        
        var day2 = 1
        if(EntryDB.MainListStruct.MainList[entryID].day == "Sunday"){
            day2 = 1
        } else if (EntryDB.MainListStruct.MainList[entryID].day == "Monday"){
            day2 = 2
        } else if (EntryDB.MainListStruct.MainList[entryID].day == "Tuesday"){
            day2 = 3
        } else if (EntryDB.MainListStruct.MainList[entryID].day == "Wednesday"){
            day2 = 4
        } else if (EntryDB.MainListStruct.MainList[entryID].day == "Thursday"){
            day2 = 5
        } else if (EntryDB.MainListStruct.MainList[entryID].day == "Friday"){
            day2 = 6
        } else if (EntryDB.MainListStruct.MainList[entryID].day == "Saturday"){
            day2 = 7
        }
        
        if(EntryDB.MainListStruct.MainList[entryID].status == "1"){
            let center = UNUserNotificationCenter.current()
            let content = UNMutableNotificationContent()
            content.title = "Weekly Reset!"
            content.body = "\(EntryDB.MainListStruct.MainList[entryID].name) has reset"
            content.categoryIdentifier = "alarm"
            content.userInfo = ["customData": "fizzbuzz"]
            content.sound = UNNotificationSound.default
            
            var dateComponents = DateComponents()
            dateComponents.hour = hour2
            dateComponents.minute = minute2
            dateComponents.weekday = day2
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)

            let idHold = UUID().uuidString
            
            let request = UNNotificationRequest(identifier: idHold, content: content, trigger: trigger)
            center.add(request)
            
            let elm = DataTypes(arrayID: entryID, NotifID: idHold)
            MainScreen.NotificationArray.array.append(elm)
        }
        
    }
    
    //code for the read table button
    @IBAction func testDB(_ sender: Any) {
        EntryDB.ReturnFullTable(DBHelper)()
        print("Testing read table button")
        
        if(EntryDB.MainListStruct.MainList.count != 0){
            print(EntryDB.MainListStruct.MainList.count)
            print(EntryDB.MainListStruct.MainList)
        } else {
            print("Global variable is empty")
        }
    }
    
    //code for the delete table button
    @IBAction func deleteDB(_ sender: Any) {
        var db: OpaquePointer?
        let fileUrl = try! //try is an exception incase something goes wrong
            FileManager.default.url(for: .documentDirectory, //creates file for document directory
                in: .userDomainMask, appropriateFor: nil,create: //creates the file inside user domain mask, create true creates a new file every time, false makes it only if it doesn't already exist
                false).appendingPathComponent("TaskDatabase.sqlite") //the actual file name
        
        if sqlite3_open(fileUrl.path, &db) != SQLITE_OK{
            print("Error opening DB")
        }

        //delete the table
        sqlite3_exec(db, "DROP TABLE Tasks",nil,nil,nil)
        sqlite3_close(db)
        print("Deleted")
        EntryDB.ReturnFullTable(DBHelper)()
        print("New List \(EntryDB.MainListStruct.MainList)")
        self.MainTable.reloadData()
    }
    //end of delete db
    
    //Table view code
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return EntryDB.MainListStruct.MainList.count
    }

    let checkedImage = UIImage(named: "icons8-tick-box-80")! as UIImage
    let uncheckedImage = UIImage(named: "icons8-cancel-80")! as UIImage
    
    //customizing the table view, namely the cells
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell1", for: indexPath) as! TableView1
        
        cell.titlecell.text = EntryDB.MainListStruct.MainList[indexPath.row].name
        cell.refcell.text = "Resets every " + EntryDB.MainListStruct.MainList[indexPath.row].day + " at " + EntryDB.MainListStruct.MainList[indexPath.row].time

        if(EntryDB.MainListStruct.MainList[indexPath.row].status == "0"){
            cell.switchButton.setImage(uncheckedImage, for: UIControl.State.normal)
        } else {
            cell.switchButton.setImage(checkedImage, for: UIControl.State.normal)
        }

        cell.switchButton.centerYAnchor.constraint(equalTo: cell.cellView.centerYAnchor).isActive = true
        cell.switchButton.tag = indexPath.row;
        
        //for stretching the dividers
        cell.preservesSuperviewLayoutMargins = false
        cell.separatorInset = UIEdgeInsets.zero
        cell.layoutMargins = UIEdgeInsets.zero
        return cell
    }
    //end of table view code
    
    func compareNotifications(){
        MainScreen.SaveList.removeAll()
        MainScreen.SaveListIDS.removeAll()
        if(!MainScreen.NotificationArray.array.isEmpty){
            UNUserNotificationCenter.current().getPendingNotificationRequests(completionHandler: {requests -> () in
                for request in requests{
                    //print("TAG2 \(MainScreen.NotificationArray.array)")
                    for index in 0 ... MainScreen.NotificationArray.array.count-1{
                        if(MainScreen.NotificationArray.array[index].NotifID.contains(request.identifier)){
                            print("TAG2 Item found")
                            MainScreen.SaveList.append(request.identifier)
                            MainScreen.SaveListIDS.append(MainScreen.NotificationArray.array[index].arrayID)
                            print("TAG2 \(MainScreen.SaveList) + \(MainScreen.SaveListIDS)")

                        }
                    } //end of notification array loop
                } // end of notification array
            })
        }
        print("TAG2 \(MainScreen.SaveList) + \(MainScreen.SaveListIDS)")
 
    }
    
    func deleteTasks(){
        MainScreen.NotificationArray.array = []
        UNUserNotificationCenter.current().getPendingNotificationRequests(completionHandler: {requests -> () in
            for request in requests{
                if(MainScreen.SaveList.contains(request.identifier)){
                    print("TAG3 inside if")
                    let elm = DataTypes(arrayID: MainScreen.SaveListIDS[MainScreen.SaveList.firstIndex(of: request.identifier)!], NotifID: request.identifier)
                    MainScreen.NotificationArray.array.append(elm)
                } else {
                    print("TAG3 inside else")
                    
               UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [request.identifier])
                }
            }

        })
        print("TAG2 NEW GLOBAL LIST \(MainScreen.NotificationArray.array)")
        //EntryDB ID is always 1 higher than the SAVELIST one, add 1 to save list id
        
        if(MainScreen.SaveListIDS.isEmpty && !EntryDB.MainListStruct.MainList.isEmpty){
            if(EntryDB.MainListStruct.MainList[0].status == "1"){
                DBHelper.updateTableCheckboxPressed(arg:                 EntryDB.MainListStruct.MainList[0].id-1)
            }
        }
        
        if(!MainScreen.SaveListIDS.isEmpty && !EntryDB.MainListStruct.MainList.isEmpty){
            //do a check here between the MainScreen.MainList ids to the ids of saveListIDS
            print("TAG5 \(MainScreen.SaveListIDS), \(EntryDB.MainListStruct.MainList)")
            for index in 0 ... EntryDB.MainListStruct.MainList.count-1{
                
                
                for index2 in 0 ... MainScreen.SaveListIDS.count-1{
                    //let found = EntryDB.MainListStruct.MainList.contains{ $0.id == MainScreen.SaveListIDS[index2]+1}
                    /*
                    if(EntryDB.MainListStruct.MainList.contains{ $0.id == MainScreen.SaveListIDS[index2]+1}){
                        print("TAG5 item found")
                        print("TAG5 \(EntryDB.MainListStruct.MainList[index].id), \(MainScreen.SaveListIDS[index2]+1)")
                    } else {
                        print("TAG5 checkbox SWAP")
                        print("TAG5 \(EntryDB.MainListStruct.MainList[index].id), \(MainScreen.SaveListIDS[index2]+1)")
                        DBHelper.updateTableCheckboxPressed(arg: index)
                    }*/
                    
                    if(MainScreen.SaveListIDS.contains(EntryDB.MainListStruct.MainList[index].id-1)){
                        print("TAG5 item found")
                        print("TAG5 \(EntryDB.MainListStruct.MainList[index].id), \(MainScreen.SaveListIDS[index2]+1)")
                    } else {
                        print("TAG5 checkbox SWAP")
                        print("TAG5 \(EntryDB.MainListStruct.MainList[index].id), \(MainScreen.SaveListIDS[index2]+1)")
                        print("TAG5 Swapping Box number \(index+1), \(EntryDB.MainListStruct.MainList[index])")
                        if(EntryDB.MainListStruct.MainList[index].status == "1"){
                            DBHelper.updateTableCheckboxPressed(arg:                         EntryDB.MainListStruct.MainList[index].id-1)
                            print("TAG6 after box swap \(EntryDB.MainListStruct.MainList)")
                        }
                    }
                }
                
                
            }
        }
    }
    
    func autoUncheckBox(){
        print("TAG4 auto uncheck called")
        /*
        if(!MainScreen.NotificationArray.array.isEmpty){
            for index in 0 ... MainScreen.NotificationArray.array.count-1 {
                UNUserNotificationCenter.current().getPendingNotificationRequests(completionHandler: {requests -> () in
                    for request in requests{
                        if(!MainScreen.NotificationArray.array[index].NotifID.contains(request.identifier)){
                            print("TAG4 it does NOT contain \(MainScreen.NotificationArray.array[index].arrayID)")
                        } else {
                            print("TAG4 ELSE STATEMENT")
                        }
                    }
                })
            }
        }*/
 
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.MainTable.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("TAG view did load")
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
        EntryDB.ReturnFullTable(DBHelper)()
        autoUncheckBox()
        self.MainTable.reloadData()
        
        //MainTable.rowHeight = UITableView.automaticDimension
        //MainTable.estimatedRowHeight = 100
        
       
        // #1.1 - Create "the notification's category value--its type."
        let debitOverdraftNotifCategory = UNNotificationCategory(identifier: "notificationPopup", actions: [], intentIdentifiers: [], options: [])
        // #1.2 - Register the notification type.
        UNUserNotificationCenter.current().setNotificationCategories([debitOverdraftNotifCategory])
        
        //sets timer with timeInterval in seconds
        _ = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(MainScreen.repeatingTimeCheck), userInfo: nil, repeats: false)
    }
    
    @IBAction func testNotif(_ sender: Any) {
        print("TAG2 -----------------------------------------------------------------")
        print("TAG2 BIG ARRAY \(MainScreen.NotificationArray.array)")
        UNUserNotificationCenter.current().getPendingNotificationRequests(completionHandler: {requests -> () in
            print("TAG \(requests.count) requests -------")
            for request in requests{
                print("TAG2 NOTIFICATION ID \(request.identifier)")
            }
        })
        /*
        // find out what are the user's notification preferences
        UNUserNotificationCenter.current().getNotificationSettings { (settings) in
            
            // we're only going to create and schedule a notification
            // if the user has kept notifications authorized for this app
            guard settings.authorizationStatus == .authorized else { return }
            
            // create the content and style for the local notification
            let content = UNMutableNotificationContent()
            
            // #2.1 - "Assign a value to this property that matches the identifier
            // property of one of the UNNotificationCategory objects you
            // previously registered with your app."
            content.categoryIdentifier = "notificationPopup"
            
            // create the notification's content to be presented
            // to the user
            content.title = "Weekly Reset!"
            content.subtitle = "One or more of your weeklies have reset"
            content.body = "Blap blap blap"
            content.sound = UNNotificationSound.default
            
            // #2.2 - create a "trigger condition that causes a notification
            // to be delivered after the specified amount of time elapses";
            // deliver after 10 seconds
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
            
            // create a "request to schedule a local notification, which
            // includes the content of the notification and the trigger conditions for delivery"
            let uuidString = UUID().uuidString
            let request = UNNotificationRequest(identifier: uuidString, content: content, trigger: trigger)
            
            UNUserNotificationCenter.current().delegate = self
            // "Upon calling this method, the system begins tracking the
            // trigger conditions associated with your request. When the
            // trigger condition is met, the system delivers your notification."
            UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
 
        } // end getNotificationSettings
        */
    } // end of button function
    
    @objc func repeatingTimeCheck()
    {
        
        let date = Date()
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: date)
        let minutes = calendar.component(.minute, from: date)
        let day = calendar.component(.weekday, from: date)
        
        var compareDay = ""
        if (day == 1){
            compareDay = "Sunday"
        } else if (day == 2){
            compareDay = "Monday"
        } else if (day == 3){
            compareDay = "Tuesday"
        } else if (day == 4){
            compareDay = "Wednesday"
        } else if (day == 5){
            compareDay = "Thursday"
        } else if (day == 6){
            compareDay = "Friday"
        } else if (day == 7){
            compareDay = "Saturday"
        }
        //print(hour, " " , minutes, " " , seconds, "  " , day)
        //1 is sunday, 7 is saturday
        //time is 24 hour format
        //this type of timer does NOT run in the background even if the app isn't fully closed
        

        
        if(EntryDB.MainListStruct.MainList.count > 0){
            for index in 0...EntryDB.MainListStruct.MainList.count-1{
                
                let stringDate = EntryDB.MainListStruct.MainList[index].time
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "hh:mm a"
                let date2 = dateFormatter.date(from: stringDate)!
                let calendar2 = Calendar.current
                let hour2 = calendar2.component(.hour, from: date2)
                let minute2 = calendar2.component(.minute, from: date2)

                if(EntryDB.MainListStruct.MainList[index].status == "1" && hour == hour2 && minutes == minute2 && compareDay == EntryDB.MainListStruct.MainList[index].day){
                    print("TAG BING BING BING")
                    DBHelper.updateTableCheckboxPressed(arg: EntryDB.MainListStruct.MainList[index].id-1)
                    print("TAG ",EntryDB.MainListStruct.MainList[index].status)
                    self.MainTable.reloadData()
                    
                    notificatonCall(arg: index)
                } // end of time check code
                
            }
        }
    } // end of repeatingTimeCheck
    
    func notificatonCall(arg index:Int){
        // find out what are the user's notification preferences
        UNUserNotificationCenter.current().getNotificationSettings { (settings) in
            
            // we're only going to create and schedule a notification
            // if the user has kept notifications authorized for this app
            guard settings.authorizationStatus == .authorized else { return }
            
            // create the content and style for the local notification
            let content = UNMutableNotificationContent()
            
            // #2.1 - "Assign a value to this property that matches the identifier
            // property of one of the UNNotificationCategory objects you
            // previously registered with your app."
            content.categoryIdentifier = "notificationPopup"
            
            // create the notification's content to be presented
            // to the user
            content.title = "Weekly Reset!"
            content.subtitle = "One or more of your weeklies have reset"
            content.body = "\(EntryDB.MainListStruct.MainList[index].name) "
            content.sound = UNNotificationSound.default
            
            // #2.2 - create a "trigger condition that causes a notification
            // to be delivered after the specified amount of time elapses";
            // deliver after 10 seconds
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.1, repeats: false)
            
            // create a "request to schedule a local notification, which
            // includes the content of the notification and the trigger conditions for delivery"
            let uuidString = UUID().uuidString
            let request = UNNotificationRequest(identifier: uuidString, content: content, trigger: trigger)
            
            UNUserNotificationCenter.current().delegate = self
            // "Upon calling this method, the system begins tracking the
            // trigger conditions associated with your request. When the
            // trigger condition is met, the system delivers your notification."
            UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
        } // end getNotificationSettings
        
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        //displaying the ios local notification when app is in foreground
        completionHandler([.alert, .badge, .sound])
    }

}
