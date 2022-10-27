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
    func sponsorImagesOption(_ i: Int)
    func sponsorSeparateOption(_ i: Int)
    func dynamicOption(_ i: Int)
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
    @IBOutlet weak var siOption: NSSwitch!
    @IBOutlet weak var sepOption: NSSwitch!
    @IBOutlet weak var dOption: NSSwitch!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(optionsArr)
        
        //Set items according to previous option selections
        if(optionsArr[0] == 1){
            fOption.state = NSButton.StateValue.on
        }
        if(optionsArr[1] == 1){
            cOption.state = NSButton.StateValue.on
        }
        if(optionsArr[2] == 1){
            sOption.state = NSButton.StateValue.on
        }
        if(optionsArr[3] == 1){
            tOption.state = NSButton.StateValue.on
        }
        if(optionsArr[4] == 1){
            siOption.state = NSSwitch.StateValue.on
        }
        if(optionsArr[5] == 1){
            sepOption.state = NSSwitch.StateValue.on
        }
        if(optionsArr[6] == 1){
            dOption.state = NSSwitch.StateValue.on
        }
        
        
        print("fOption: " + fOption.stringValue)
        print("cOption: " + cOption.stringValue)
        print("sOption: " + sOption.stringValue)
        print("tOption: " + tOption.stringValue)
        print("siOption: " + siOption.stringValue)
        print("sepOption: " + sepOption.stringValue)
        print("dOption: " + dOption.stringValue)
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
    
    @IBAction func siClicked(_ sender: Any) {
        saveOption(siOption.state.rawValue, "si")
        if let delegate = delegate {
            delegate.sponsorImagesOption(siOption.state.rawValue)
        }
    }
    
    
    // Flag selected
    @IBAction func fClicked(_ sender: Any) {
        saveOption(fOption.state.rawValue, "f")
        if let delegate = delegate {
            delegate.flagOption(fOption.state.rawValue)
        }
    }
    
    @IBAction func sepClicked(_ sender: Any) {
        saveOption(sepOption.state.rawValue, "sep")
        if let delegate = delegate {
            delegate.sponsorSeparateOption(sepOption.state.rawValue)
        }
    }
    
    @IBAction func dClicked(_ sender: Any) {
        saveOption(sepOption.state.rawValue, "d")
        if let delegate = delegate {
            delegate.dynamicOption(dOption.state.rawValue)
        }
    }
    
    //Save options after they're selected
    func saveOption(_ value: Int, _ option: String){
        
        print(value)
        let result = try? (context.fetch(request) as![NSManagedObject])
        
        
        //Store player selections for later re-use
        for i in result!{
            i.setValue(value, forKey: option)
        }
        do{
            try context.save()
            print("\(option) Option saved!")
        }
        catch {
            //print("Update failed, \(error)")
        }
    }
    
}
