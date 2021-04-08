//
//  AddViewController.swift
//  Mac Scoreboard
//
//  Created by J. Matthew Conover on 2/1/21.
//

import Cocoa
import CoreData

protocol AddDelegate : NSObjectProtocol{
    func reloadAdd(data: String)
}

class AddViewController: NSViewController, NSTextFieldDelegate  {
    
    weak var delegate : AddDelegate?
    @IBOutlet weak var test: NSTextField!
    @IBOutlet weak var tagField: NSTextField!
    @IBOutlet weak var addButton: NSButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        tagField.isEditable = true
        test.stringValue = ""
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }


    //Add a Tag to the CoreData database
    @IBAction func AddTag(_ sender: Any) {
        let name = tagField.stringValue
        print(name)
        let context = (NSApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "Player", in: context)
        let saveThis = NSManagedObject(entity: entity!, insertInto: context)
        saveThis.setValue(name, forKey: "name")
        do{
            try context.save()
            //print("Tag was saved!")
        }
        catch {
            print("Update failed, \(error)")
        } //*/
        reload(name)
        
    }
    
    //Trigger loadMenus for MainViewController
    func reload(_ name: String){
       // print("This ran")
        if let delegate = delegate {
            //print("run")
            delegate.reloadAdd(data: name)
        } else {
            //print("Delegate has fail")
        }
    }
    
}
