//
//  RemoveViewController.swift
//  Mac Scoreboard
//
//  Created by J. Matthew Conover on 2/1/21.
//

import Cocoa
import CoreData

//Trigger loadMenus in Main
protocol RemoveDelegate : NSObjectProtocol{
    func reload2()
}

class RemoveViewController: NSViewController {
    
    weak var delegate : RemoveDelegate?
    let context = (NSApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Player")
    @IBOutlet weak var removeButton: NSButton!
    @IBOutlet weak var tagList: NSPopUpButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        var tag = ""
        
        //Load current players
        request.returnsObjectsAsFaults = false
        do {
            let result = try? (context.fetch(request) as![NSManagedObject])
            for i in result!{
                if(((i.value(forKey: "name") as? String)) == nil){
                    context.delete(i)
                    print("thing deleted")
                    do{
                        try context.save()
                        //print("Name removed")
                    }
                    catch {
                        //print("Clear failed, \(error)")
                    }
                }
                else{
                   tag = (i.value(forKey: "name") as! String)
                    //print(tag)
                    tagList.addItem(withTitle: tag)
                }
            }
        }
        catch {
            //print("retrieval failed \(error)")
        }        // Do any additional setup after loading the view.
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    //Remove selected tag and save change
    @IBAction func removeTag(_ sender: Any) {
        //print(tagList.indexOfSelectedItem)
        var tag = ""
        if (tagList.titleOfSelectedItem==nil){
            
        }
        else{
            tag = tagList.titleOfSelectedItem!
            print(tag)
            let index = tagList.indexOfSelectedItem
            tagList.removeItem(at: index)
            let result = try? (context.fetch(request) as![NSManagedObject])
            context.delete(result![index])
            /*if let result = try? context.fetch(request) {
                for i in result as![NSManagedObject]{
                    context.delete(i)
                }
            }*/
            do{
                try context.save()
                //print("Name removed")
            }
            catch {
                //print("Clear failed, \(error)")
            }
            if let delegate = delegate {
                //print("run")
                delegate.reload2()
            } else {
                //print("Delegate has fail")
            }
        }
        
        
    }

}
