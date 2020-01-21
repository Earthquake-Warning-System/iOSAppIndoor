//
//  coreData.swift
//  iOSAppIndoor
//
//  Created by mwnlMacbookPro on 2020/1/21.
//  Copyright © 2020 mwnl. All rights reserved.
//

import Foundation
import CoreData
import UIKit

func addLastDate(){
    guard let appDel = UIApplication.shared.delegate as? AppDelegate else {return}
    
    let context = appDel.persistentContainer.viewContext
    let entity = NSEntityDescription.entity(forEntityName: "LastData", in: context)
    let lastData = NSManagedObject(entity: entity!, insertInto: context)
    lastData.setValue(LastEqTime, forKeyPath: "lastDate")
    lastData.setValue(valueOfReliable, forKey: "reliability")
    lastData.setValue("Data", forKey: "name")
    do{
        try context.save()
        print("save successfully")
    }catch{
        print(error)
    }
}

func fetchCoreData (){
    guard let appDel = UIApplication.shared.delegate as? AppDelegate else { return }
    
    let context = appDel.persistentContainer.viewContext
    let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "LastData")
    fetchRequest.fetchLimit = 5
    
    do {
        let result = try context.fetch(fetchRequest)
        for data in result as! [NSManagedObject] {
            
            print("Searching name is \(data.value(forKey: "name") as! String)")
            //To know whether the data is stored or not.
            if data.value(forKey: "name") as! String == "Data"{
                isNoData = false
            }
            if data.value(forKey: "lastDate") as? Date == nil{
                print("No action of detection.")
            }else{
                print("Searching lastDate is \(data.value(forKey: "lastDate") as! Date)")
            }
            LastEqTime = data.value(forKey: "lastDate") as? Date
            print(LastEqTime as Any)
            print("Searching reliability is \(data.value(forKey: "reliability") as! Int32)")
        }
    } catch {
        
        print("Failed")
    }
}

func updateData(){
    guard let appDel = UIApplication.shared.delegate as? AppDelegate else { return }
    
    let context = appDel.persistentContainer.viewContext
    let request: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest.init(entityName: "LastData")
    request.predicate = NSPredicate(format: "name == %@", "Data")
    
    do{
        let test = try context.fetch(request)
        
        let objectUpdate = test[0] as! NSManagedObject
        objectUpdate.setValue("Data", forKey: "name")
        objectUpdate.setValue(LastEqTime, forKey: "lastDate")
        objectUpdate.setValue(valueOfReliable, forKey: "reliability")
        do{
            try context.save()
        }catch{
            print(error)
        }
    } catch {
        fatalError("Failed to update data: \(error)")
    }
}
