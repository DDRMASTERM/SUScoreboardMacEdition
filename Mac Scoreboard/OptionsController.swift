//
//  OptionsController.swift
//  Mac Scoreboard
//
//  Created by J. Matthew Conover on 3/30/21.
//

import Cocoa

//Protocols for returning options selections to Main
protocol OptionsDelegate : NSObjectProtocol{
    func commentatorOption(_ i: Int)
    func twitterOption(_ i: Int)
    func sponsorOption(_ i: Int)
    func flagOption(_ i: Int)
}

class OptionsController : NSViewController, NSPopoverDelegate, NSTextFieldDelegate {
    
    let context = (NSApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Options")
   
    
    weak var delegate : OptionsDelegate?
    var optionsArr = [Int]()
    @IBOutlet weak var cOption: NSButton!
    @IBOutlet weak var tOption: NSButton!
    @IBOutlet weak var sOption: NSButton!
    @IBOutlet weak var fOption: NSButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Set items according to previous option selections
        if(optionsArr[0] == 1){
            fOption.setNextState()
        }
        if(optionsArr[1] == 1){
            cOption.setNextState()
        }
        if(optionsArr[2] == 1){
            sOption.setNextState()
        }
        if(optionsArr[3] == 1){
            tOption.setNextState()
        }
    }
    
    // Commentator selected
    @IBAction func cClicked(_ sender: Any) {
        saveOption(cOption.state.rawValue, "c")
        if let delegate = delegate {
            delegate.commentatorOption(cOption.state.rawValue)
        }
    }
    
    // Twitter selected
    @IBAction func tClicked(_ sender: Any) {
        saveOption(tOption.state.rawValue, "t")
        if let delegate = delegate {
            delegate.twitterOption(tOption.state.rawValue)
        }
    }
    
    // Sponsor selected
    @IBAction func sClicked(_ sender: Any) {
        saveOption(sOption.state.rawValue, "s")
        if let delegate = delegate {
            delegate.sponsorOption(sOption.state.rawValue)
        }
    }
    
    // Flag selected
    @IBAction func fClicked(_ sender: Any) {
        saveOption(fOption.state.rawValue, "f")
        if let delegate = delegate {
            delegate.flagOption(fOption.state.rawValue)
        }
    }
    
    //Save options after they're selected
    func saveOption(_ value: Int, _ option: String){
        
        print(cOption.state.rawValue)
        let result = try? (context.fetch(request) as![NSManagedObject])
        
        //Store player selections for later re-use
        for i in result!{
            i.setValue(value, forKey: option)
        }
        do{
            try context.save()
            //print("Option saved!")
        }
        catch {
            //print("Update failed, \(error)")
        }
    }
    
}
