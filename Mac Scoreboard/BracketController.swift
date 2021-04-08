//
//  BracketController.swift
//  Mac Scoreboard
//
//  Created by J. Matthew Conover on 2/15/21.
//

import Cocoa
import CoreData

//Trigger loadMenus in main
protocol BracketDelegate : NSObjectProtocol{
    func reload3()
}

class BracketController: NSViewController, NSTextFieldDelegate, NSPopoverDelegate  {
    
    weak var delegate : BracketDelegate?
    let context = (NSApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Addedbrackets")
    var verify = false
    @IBOutlet weak var BracketField: NSTextField!
    @IBOutlet weak var addedBrackets: NSPopUpButton!
    @IBOutlet weak var Remove_Field: NSTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        var tag = ""
        
        //load dropdown for bracket items
        do {
            let result = try? (context.fetch(request) as![NSManagedObject])
            for i in result!{
               tag = (i.value(forKey: "bracket") as! String)
                //print(tag)
                addedBrackets.addItem(withTitle: tag)
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
    
    //Add a new Bracket type and save it
    @IBAction func addB(_ sender: Any) {
        let name = BracketField.stringValue
        print(name)
        let context = (NSApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "Addedbrackets", in: context)
        let saveThis = NSManagedObject(entity: entity!, insertInto: context)
        saveThis.setValue(name, forKey: "bracket")
        do{
            try context.save()
            //print("Bracket was saved!")
            addedBrackets.addItem(withTitle: name)
        }
        catch {
            //print("Update failed, \(error)")
        }
        if let delegate = delegate {
            //print("run")
            delegate.reload3()
        } else {
            //print("Delegate has fail")
        }
    }
    
    //Remove a Bracket type and save
    @IBAction func removeB(_ sender: Any) {
        var tag = ""
        let index = addedBrackets.indexOfSelectedItem
        
        //Prevent crash if Brackets is somehow empty
        if (addedBrackets.titleOfSelectedItem==nil){
        }
        else {
            //Safeguard to check if user truly wants to delete Bracket
            if(!verify){
                verify = true
                Remove_Field.stringValue = "      Are You sure?"
            }
            else{ //Delete bracket and save change
                
             
                tag = addedBrackets.titleOfSelectedItem!
                print(tag)
              
                addedBrackets.removeItem(at: index)
                let result = try? context.fetch(request) as![NSManagedObject]
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
                Remove_Field.stringValue = "Remove bracket type"
                verify = false
            }
            if let delegate = delegate {
                //print("run")
                delegate.reload3()
            } else {
                //print("Delegate has fail")
            }
        }
    }
}
