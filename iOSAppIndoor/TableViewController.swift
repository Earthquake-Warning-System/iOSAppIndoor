//
//  TableViewController.swift
//  iOSAppIndoor
//
//  Created by mwnlMacbookPro on 2020/2/6.
//  Copyright © 2020 mwnl. All rights reserved.
//

import UIKit
import CoreData

var name = ["a","b","c","d","e","f","g","h","i","j"]
var numberArray = ["one","two","three","four","five","six"]
var nameToDelete: String?
var reff = ""
class TableViewController: UITableViewController {

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchData()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
         self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return name.count

    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)

        // Configure the cell...
        cell.textLabel?.text = name[indexPath.row]
        return cell
    }
    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        reff = name[indexPath.row]
    }
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = name[indexPath.row]
        if editingStyle == .delete {
            // Delete the row from the data source
            nameToDelete = cell.textLabel?.text
            var n = 0
            while n < deviceToken.count{
                print(n)
                if reff == name[n]{
                    let sender = PushNotificationSender()
                    sender.sendPushNotification(to: deviceToken[n], title: "Unpair", body: "Already unpaired.")
                    break
                }else{
                    n += 1
                }
            }
            deleteToken()
            name.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }
    

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    func fetchData(){
        
        guard let appDel = UIApplication.shared.delegate as? AppDelegate else { return }
        
        let context = appDel.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Token")
        fetchRequest.fetchLimit = 10
        var arr = [String]()
        do {
            let result = try context.fetch(fetchRequest)
            for data in result as! [NSManagedObject] {
                print(data.value(forKey: "name") as! String)
                print(data.value(forKey: "token") as! String)
                arr.append(data.value(forKey: "name") as! String)
            }
        } catch {
            
            print("Failed")
        }
        name = arr
        print(name)
        print(deviceToken)
    }
    func deleteToken(){
        guard let appDel = UIApplication.shared.delegate as? AppDelegate else { return }
        
        let context = appDel.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Token")
        fetchRequest.predicate = NSPredicate(format: "name = %@", nameToDelete!)
        
        do{
            let test = try context.fetch(fetchRequest)
            
            let objectToDelete = test[0] as! NSManagedObject
            context.delete(objectToDelete)
            do {
                try context.save()
            } catch  {
                print(error)
            }
        }catch{
            print(error)
        }
    }
    @IBAction func Test(_ sender: Any) {
        print(reff)
        var n = 0
        while n < deviceToken.count{
            print(n)
            if reff == name[n]{
                let sender = PushNotificationSender()
                sender.sendPushNotification(to: deviceToken[n], title: "Test", body: "Ready to delete.")
                break
            }else{
                n += 1
            }
        }
    }
}
