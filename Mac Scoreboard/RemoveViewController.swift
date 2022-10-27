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
    let requestG = NSFetchRequest<NSFetchRequestResult>(entityName: "Pronouns")
    @IBOutlet weak var pronounBox: NSPopUpButton!
    @IBOutlet weak var pronounRemove: NSButton!
    @IBOutlet weak var PronounLabel: NSTextField!
    @IBOutlet weak var removeButton: NSButton!
    @IBOutlet weak var tagList: NSPopUpButton!
    @IBOutlet weak var pronounList: NSPopUpButtonCell!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        var tag = ""
        var tags = Set<String>()
        var pronouns = Set<String>()
        var pronoun = ""
        /*pronounBox.isHidden = true
        PronounLabel.isHidden = true
        pronounRemove.isHidden = true*/
        
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
                        print("Name removed")
                    }
                    catch {
                        print("Clear failed, \(error)")
                    }
                }
                else{
                    tag = (i.value(forKey: "name") as! String)
                    
                    tags.insert(tag)
                }
            }
        }
        catch {
            //print("retrieval failed \(error)")
        }
        tagList.addItems(withTitles: Array(tags.sorted(by: { $0.lowercased() < $1.lowercased() })))
        
        do {
            let result = try? (context.fetch(requestG) as![NSManagedObject])
            for i in result!{
                if(((i.value(forKey: "pronouns") as? String)) == nil){
                    context.delete(i)
                    print("thing deleted")
                    do{
                        try context.save()
                        print("Name removed")
                    }
                    catch {
                        print("Clear failed, \(error)")
                    }
                }
                else{
                    tag = (i.value(forKey: "pronouns") as! String)
                    
                    pronouns.insert(tag)
                }
            }
        }
        catch {
            //print("retrieval failed \(error)")
        }
        
        pronounBox.addItems(withTitles: Array(pronouns.sorted(by: { $0.lowercased() < $1.lowercased() })))
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    //Remove selected tag and save change
    @IBAction func removeTag(_ sender: Any) {
        print(tagList.indexOfSelectedItem)
        var tag = ""
        if (tagList.titleOfSelectedItem==nil || tagList.indexOfSelectedItem == -1){
            
        }
        else{
            tag = tagList.titleOfSelectedItem!
            //print(tag)
            let index = tagList.indexOfSelectedItem
            tagList.removeItem(at: index)
            
            if let result = try? context.fetch(request) {
                for i in result as![NSManagedObject]{
                    if((i.value(forKey: "name") as! String) == tag){
                        //print(i)
                        context.delete(i)
                    }
                }
            }
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
    
    @IBAction func removePronoun(_ sender: Any) {
        print(pronounBox.indexOfSelectedItem)
        var tag = ""
        if (pronounBox.titleOfSelectedItem==nil || pronounBox.indexOfSelectedItem == -1){
            
        }
        else{
            tag = pronounBox.titleOfSelectedItem!
            //print(tag)
            let index = pronounBox.indexOfSelectedItem
            pronounBox.removeItem(at: index)
            
            if let result = try? context.fetch(requestG) {
                for i in result as![NSManagedObject]{
                    if((i.value(forKey: "pronouns") as! String) == tag){
                        //print(i)
                        context.delete(i)
                    }
                }
            }
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
