//
//  RoundController.swift
//  Mac Scoreboard
//
//  Created by J. Matthew Conover on 2/15/21.
//

import Cocoa
import CoreData

//Trigger loadMenus in Main
protocol RoundDelegate : NSObjectProtocol{
    func reload4()
}

class RoundController : NSViewController, NSTextFieldDelegate  {
    weak var delegate : RoundDelegate?
    let context = (NSApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Addedrounds")
    @IBOutlet weak var RoundField: NSTextField!
    @IBOutlet weak var addedRounds: NSPopUpButton!
    @IBOutlet weak var Remove_Field: NSTextField!
    var verify = false
    override func viewDidLoad() {
        super.viewDidLoad()
        var tag = ""
        
        //Load current Rounds items
        do {
            let result = try? (context.fetch(request) as![NSManagedObject])
            for i in result!{
               tag = (i.value(forKey: "round") as! String)
                //print(tag)
                addedRounds.addItem(withTitle: tag)
            }
        }
        catch {
            print("\(error)")
        }
    }
    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    //Add and save new round item
    @IBAction func addR(_ sender: Any) {
        let name = RoundField.stringValue
        print(name)
        let context = (NSApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "Addedrounds", in: context)
        let saveThis = NSManagedObject(entity: entity!, insertInto: context)
        saveThis.setValue(name, forKey: "round")
        do{
            try context.save()
            //print("Bracket was saved!")
            addedRounds.addItem(withTitle: name)
        }
        catch {
            //print("Update failed, \(error)")
        }
        if let delegate = delegate {
            //print("run")
            delegate.reload4()
        } else {
            //print("Delegate has fail")
        }
    }
    
    //Remove round item and save change
    @IBAction func removeR(_ sender: Any) {
        var tag = ""
        
        //Prevent crash if rounds are currently empty
        if (addedRounds.titleOfSelectedItem==nil){
            
        }
        else{
            //Check if intending to remove a round field
            if(!verify){
                verify = true
                Remove_Field.stringValue = "      Are You sure?"
            }
            else{//Remove selected round item and save change
                tag = addedRounds.titleOfSelectedItem!
                print(tag)
                let index = addedRounds.indexOfSelectedItem
                addedRounds.removeItem(at: index)
                let result = try? context.fetch(request) as![NSManagedObject]
                context.delete(result![index])
                /*if let result = try? context.fetch(request) {
                    for i in result as![NSManagedObject]{
                        context.delete(i)
                    }
                }*/
                do{
                    try context.save()
                    //print("Round removed")
                }
                catch {
                    //print("Clear failed, \(error)")
                }
                Remove_Field.stringValue = "      Remove Round Type"
                verify = false
            }
        }
        
        //Delegate to run in Main
        if let delegate = delegate {
            delegate.reload4()
            //print(delegate)
        } else {
            //print("Delegate has fail")
        }
    }
    
    
}
