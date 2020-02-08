import CoreData
import UIKit
final class DataStoreManager{
    static func saveFavID(id: Int)->Bool{
        //1
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return false
        }
        
        let managedContext =
            appDelegate.persistentContainer.viewContext
        
        //2
        let fetchRequest =
            NSFetchRequest<NSManagedObject>(entityName: "UserFavModel")
        var success = false
        do{
            let fetchResults = try managedContext.fetch(fetchRequest)
            
            if fetchResults.count != 0 {
                // update
                let managedObject = fetchResults[0]
                managedObject.setValue(id, forKeyPath: "id")
                try managedContext.save()
                success = true
            } else {
                //insert as new data
                let entity =
                    NSEntityDescription.entity(forEntityName: "UserFavModel",
                                               in: managedContext)!
                let person = NSManagedObject(entity: entity,
                                             insertInto: managedContext)
                
                // 3
                person.setValue(id, forKeyPath: "id")
                
                // 4
                do {
                    try managedContext.save()
                    success = true
                } catch let error as NSError {
                    print("Could not save. \(error), \(error.userInfo)")
                }
                
            }
            
        }catch{
            print(error)
        }
        return success
    }
    static func getAllFavouriteIDs() -> [NSManagedObject]{
        var favUserIDListObj:[NSManagedObject] = []
        //1
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return []
        }
        
        let managedContext =
            appDelegate.persistentContainer.viewContext
        
        //2
        let fetchRequest =
            NSFetchRequest<NSManagedObject>(entityName: "UserFavModel")
        
        //3
        do {
            favUserIDListObj = try managedContext.fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        return favUserIDListObj
    }
    static func deleteFavID(id:Int)->Bool{
        //1
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return false
        }
        
        let managedContext =
            appDelegate.persistentContainer.viewContext
        var success = false
        //2
        let fetchRequest =
            NSFetchRequest<NSManagedObject>(entityName: "UserFavModel")
        do{
            let fetchResults = try managedContext.fetch(fetchRequest)
            
            if fetchResults.count != 0 {
                // update
                let objToDelete = fetchResults[0]
                managedContext.delete(objToDelete)
                try managedContext.save()
                success = true
            }
            
        }catch{
            print(error)
        }
        return success
    }
}
