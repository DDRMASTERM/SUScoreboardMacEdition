//
//  ViewController.swift
//  Mac Scoreboard
//
//  Created by J. Matthew Conover on 1/20/21.
//

import Cocoa
import CoreData


//Allow user to choose location of files to save
extension NSOpenPanel {
    var selectUrl: URL? {
        title = "Select Folder"
        allowsMultipleSelection = false
        canChooseDirectories = true
        canChooseFiles = false
        canCreateDirectories = false
        return runModal() == .OK ? urls.first : nil
    }
}

// These three functions allow for saving png files to the
extension NSBitmapImageRep {
    var png: Data? { representation(using: .png, properties: [:]) }
}
extension Data {
    var bitmap: NSBitmapImageRep? { NSBitmapImageRep(data: self) }
}
extension NSImage {
    var png: Data? { tiffRepresentation?.bitmap?.png }
}

class MainViewController: NSViewController, NSPopoverDelegate, FileManagerDelegate, ImageDelegate, AddDelegate, RemoveDelegate, BracketDelegate, RoundDelegate, SponsorDelegate, OptionsDelegate {
    
    //Retrieve Coredata Memory for each entity
    let context = (NSApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    let requestP = NSFetchRequest<NSFetchRequestResult>(entityName: "Player")
    let requestB = NSFetchRequest<NSFetchRequestResult>(entityName: "Addedbrackets")
    let requestR = NSFetchRequest<NSFetchRequestResult>(entityName: "Addedrounds")
    let requestL = NSFetchRequest<NSFetchRequestResult>(entityName: "FileLocation")
    let requestS = NSFetchRequest<NSFetchRequestResult>(entityName: "Sponsors")
    let requestO = NSFetchRequest<NSFetchRequestResult>(entityName: "Options")
    
    //Create important global variables
    var nameArr : [String] = [""]
    var p1Selected = false
    var p2Selected = false
    var p1Current = ""
    var p2Current = ""
    var p2ACurrent = ""
    var p4Current = ""
    var p1IString = ""
    var p2IString = ""
    var p2AIString = ""
    var p3IString = ""
    var p1Index = 0
    var p2Index = 0
    var fileLocation = URL(string: NSSearchPathForDirectoriesInDomains(.documentDirectory, .allDomainsMask, true)[0])
    var L1 = 0
    var L2 = 0
    var doubles = false
    var sponsorsOption = 0
    var TwitterOption = 0
    var commentatorOption = 0
    var flagsOption = 0
    var sponsorNames = [String]()
    var sponsorURLs = [URL]()
    var temp1 = ("","")
    var temp2 = ("","")
   
    //Names for important items in project
    @IBOutlet weak var Bracket: NSComboBox!
    @IBOutlet weak var Round: NSComboBox!
    @IBOutlet weak var RoundNum: NSTextField!
    @IBOutlet weak var swapB: NSButton!
    @IBOutlet weak var updateB: NSButton!
    @IBOutlet weak var p1Games: NSStepper!
    @IBOutlet weak var p2Games: NSStepper!
    @IBOutlet weak var p1Tag: NSComboBox!
    @IBOutlet weak var p2Tag: NSComboBox!
    @IBOutlet weak var outputB: NSButton!
    @IBOutlet weak var p1Character: NSComboBox!
    @IBOutlet weak var p2Character: NSComboBox!
    @IBOutlet weak var p1Score: NSTextField!
    @IBOutlet weak var p2Score: NSTextField!
    @IBOutlet weak var p1Image: NSImageView!
    @IBOutlet weak var p2Image: NSImageView!
    @IBOutlet weak var p1Color: NSButton!
    @IBOutlet weak var p2Color: NSButton!
    @IBOutlet weak var p1L: NSButton!
    @IBOutlet weak var p2L: NSButton!
    @IBOutlet weak var p1Sponsor: NSComboBox!
    @IBOutlet weak var p2Sponsor: NSComboBox!
    @IBOutlet weak var p2ASponsor: NSComboBox!
    @IBOutlet weak var p3Sponsor: NSComboBox!
    @IBOutlet weak var s1Image: NSImageView!
    @IBOutlet weak var s2Image: NSImageView!
    @IBOutlet weak var s2AImage: NSImageView!
    @IBOutlet weak var s3Image: NSImageView!
    @IBOutlet weak var p2Label: NSTextField!
    @IBOutlet weak var p2ALabel: NSTextField!
    @IBOutlet weak var p2ATag: NSComboBox!
    @IBOutlet weak var p3Label: NSTextField!
    @IBOutlet weak var p3Tag: NSComboBox!
    @IBOutlet weak var p2ACharacter: NSComboBox!
    @IBOutlet weak var p2AImage: NSImageView!
    @IBOutlet weak var p2AColor: NSButton!
    @IBOutlet weak var p4Character: NSComboBox!
    @IBOutlet weak var p3Image: NSImageView!
    @IBOutlet weak var p3Color: NSButton!
    @IBOutlet weak var addSponsor: NSButton!
    @IBOutlet weak var p1Twitter: NSTextField!
    @IBOutlet weak var p2Twitter: NSTextField!
    @IBOutlet weak var p2ATwitter: NSTextField!
    @IBOutlet weak var p3Twitter: NSTextField!
    @IBOutlet weak var c1Label: NSTextField!
    @IBOutlet weak var c2Label: NSTextField!
    @IBOutlet weak var c1tag: NSComboBox!
    @IBOutlet weak var c2tag: NSComboBox!
    
    //Setup default values
    override func viewDidLoad() {
        super.viewDidLoad()
        //print("Did I Change?")
        setupCharacters()
        p1Games.maxValue = 15
        p1Games.minValue = 0
        p1Games.increment = 1
        p2Games.maxValue = 15
        p2Games.minValue = 0
        p2Games.increment = 1
        requestP.returnsObjectsAsFaults = false
        loadMenus()
        loadSponsors()
        
        //Default images
        let img = NSImage.init(named: "Banjo & Kazooie1")
        p1Image.image = img
        p2Image.image = img
        p2AImage.image = img
        p3Image.image = img
        
        //Hide elements not always needed
        p1L.isHidden = true
        p2L.isHidden = true
        p2ALabel.isHidden = true
        p2ATag.isHidden = true
        p2ACharacter.isHidden = true
        p2AColor.isHidden = true
        p2AImage.isHidden = true
        p3Label.isHidden = true
        p3Tag.isHidden = true
        p3Color.isHidden = true
        p3Image.isHidden = true
        p4Character.isHidden = true
        p1Sponsor.isHidden = true
        p2Sponsor.isHidden = true
        p2ASponsor.isHidden = true
        p3Sponsor.isHidden = true
        s1Image.isHidden = true
        s2Image.isHidden = true
        s2AImage.isHidden = true
        s3Image.isHidden = true
        addSponsor.isHidden = true
        p1Twitter.isHidden = true
        p2Twitter.isHidden = true
        p2ATwitter.isHidden = true
        p3Twitter.isHidden = true
        c1tag.isHidden = true
        c2tag.isHidden = true
        c1Label.isHidden = true
        c2Label.isHidden = true
        
        //Get fileLocation if selected previously
        requestL.returnsObjectsAsFaults = false
        do {
            let result = try? (context.fetch(requestL) as![NSManagedObject])
            for i in result!{
                if(((i.value(forKey: "url") as? String)) == nil){
                    context.delete(i)
                    //print("thing deleted")
                }
                else{
                    fileLocation = URL(string: i.value(forKey: "url") as! String)
                }
                /*
                do{
                    try context.save()
                    print("Location deleted saved!")
                }
                catch {
                    print("Update failed, \(error)")
                }*/
            }
        }
        catch {
            //print("inventory retrieval failed \(error)")
        }
        
        //Retrieve options selected previously
        do {
            let result = try? (context.fetch(requestO) as![NSManagedObject])
            for i in result!{
                if(((i.value(forKey: "f") as? Int)) == nil){
                    context.delete(i)
                }
                else{
                    flagsOption = i.value(forKey: "f") as! Int
                    flagOption(flagsOption)
                }
                if(((i.value(forKey: "c") as? Int)) == nil){
                    context.delete(i)
                }
                else{
                    commentatorOption = i.value(forKey: "c") as! Int
                    //print(commentatorOption)
                    commentatorOption(commentatorOption)
                }
                if(((i.value(forKey: "s") as? Int)) == nil){
                    context.delete(i)
                }
                else{
                    sponsorsOption = i.value(forKey: "s") as! Int
                    //print(sponsorsOption)
                    sponsorOption(sponsorsOption)
                }
                if(((i.value(forKey: "t") as? Int)) == nil){
                    context.delete(i)
                }
                else{
                    TwitterOption = i.value(forKey: "t") as! Int
                    //print(TwitterOption)
                    twitterOption(TwitterOption)
                }
            }
        }
        catch {
            //print("inventory retrieval failed \(error)")
        }
        
        //defaults for main items
        Bracket.stringValue = "Singles Bracket"
        Round.stringValue = "Winners Round"
        p1Character.stringValue = "Banjo & Kazooie"
        p2Character.stringValue = "Banjo & Kazooie"
        p2ACharacter.stringValue = "Banjo & Kazooie"
        p4Character.stringValue = "Banjo & Kazooie"
    }


    //Increment/decrement player one score
    @IBAction func g1di(_ sender: NSStepper) {
        p1Score.stringValue = String(p1Games.intValue)
    }
    
    //Increment/decrement player one score
    @IBAction func g2di(_ sender: Any) {
        p2Score.stringValue = String(p2Games.intValue)
    }
    
    //Reset score values
    @IBAction func scoreReset(_ sender: Any) {
        p1Games.intValue = 0
        p2Games.intValue = 0
        p1Score.stringValue = String(p1Games.intValue)
        p2Score.stringValue = String(p2Games.intValue)
    }
    
    
    
    //Set value for p1Tag selection and retrieve data stored on player (if any)
    @IBAction func P1clicked(_ sender: Any) {
        let result = returnPlayer(p1Tag.stringValue, p1Tag.indexOfItem(withObjectValue: p1Tag.stringValue))
        p1IString = result.imgName
        temp1.1 = result.imgName
        if(!doubles || flagsOption == 0){
            p1Character.stringValue = result.character
            let img = NSImage.init(named: result.imgName)
            p1Image.image = img
        }
        p1Sponsor.stringValue = result.sponsor
        p1Twitter.stringValue = result.twitter
        //print(result.sponsor)
        let index = p1Sponsor.indexOfItem(withObjectValue: result.sponsor)
        var img2 = NSImage()
        if (index < sponsorURLs.count) {
            img2 = NSImage(contentsOf: sponsorURLs[index])!
        }
        s1Image.image = img2
    }
    
    //Set value for p2Tag selection and retrieve data stored on player (if any)
    @IBAction func P2clicked(_ sender: Any) {
        let result = returnPlayer(p2Tag.stringValue, p2Tag.indexOfItem(withObjectValue: p2Tag.stringValue))
        p2IString = result.imgName
        if(!doubles) {
            p2Character.stringValue = result.character
            
        }
        else {
            p4Character.stringValue = result.character
        }
        if(!doubles || flagsOption == 0){
            let img = NSImage.init(named: result.imgName)
            p2Image.image = img
        }
        p2Sponsor.stringValue = result.sponsor
        p2Twitter.stringValue = result.twitter
        let index = p2Sponsor.indexOfItem(withObjectValue: result.sponsor)
        var img2 = NSImage()
        if (index < sponsorURLs.count) {
            img2 = NSImage(contentsOf: sponsorURLs[index])!
        }
        s2Image.image = img2
        temp2.1 = result.imgName
    }
    
    //Set value for p2ATag selection and retrieve data stored on player (if any)
    @IBAction func p2AClicked(_ sender: Any) {
        let result = returnPlayer(p2ATag.stringValue, p2ATag.indexOfItem(withObjectValue: p2ATag.stringValue))
        p2AIString = result.imgName
        p2ACharacter.stringValue = result.character
        let img = NSImage.init(named: result.imgName)
        p2AImage.image = img
        p2ASponsor.stringValue = result.sponsor
        p2ATwitter.stringValue = result.twitter
        let index = p2ASponsor.indexOfItem(withObjectValue: result.sponsor)
        var img2 = NSImage()
        if (index < sponsorURLs.count) {
            img2 = NSImage(contentsOf: sponsorURLs[index])!
        }
        s2AImage.image = img2
    }
    
    //Set value for p3Tag selection and retrieve data stored on player (if any)
    @IBAction func p3Clicked(_ sender: Any) {
        let result = returnPlayer(p3Tag.stringValue, p3Tag.indexOfItem(withObjectValue: p3Tag.stringValue))
        p3IString = result.imgName
        p2Character.stringValue = result.character
        let img = NSImage.init(named: result.imgName)
        p3Image.image = img
        p3Sponsor.stringValue = result.sponsor
        p3Twitter.stringValue = result.twitter
        let index = p3Sponsor.indexOfItem(withObjectValue: result.sponsor)
        var img2 = NSImage()
        if (index < sponsorURLs.count) {
            img2 = NSImage(contentsOf: sponsorURLs[index])!
        }
        s3Image.image = img2
    }
    

        
    
    
    
    //Set default image for character selection on P1
    @IBAction func p1Select(_ sender: Any) {
        if(p1Current != p1Character.stringValue) {
            p1Current = p1Character.stringValue
            p1IString = p1Character.stringValue + "1"
            let img = NSImage.init(named: p1IString)
            if(img==nil){
                
            }
            else {
                p1Image.image = img
            }
        }
    }
    
    //Set default image for character on P2
    @IBAction func p2Select(_ sender: Any) {
        if(p2Current != p2Character.stringValue){
            //print("did I run?")
            p2Current = p2Character.stringValue
            var img = NSImage(named: "")
            if(!doubles || flagsOption == 1){
                //print(p2Character)
                p2IString = p2Character.stringValue + "1"
                img = NSImage.init(named: p2IString)
            }
            else {
                p3IString = p2Character.stringValue + "1"
                img = NSImage.init(named: p3IString)
            }
            if(img==nil){
                //print("that wasn't supposed to happen...")
                
            }
            else {
                //print("?")
                if(!doubles || flagsOption == 1){
                    p2IString = p2Character.stringValue + "1"
                    img = NSImage.init(named: p2IString)
                    p2Image.image = img
                }
                else{
                    p3IString = p2Character.stringValue + "1"
                    img = NSImage.init(named: p3IString)
                    p3Image.image = img
                }
            }
        }
    }
    
    //Set default image for character on P2A
    @IBAction func p2ASelect(_ sender: Any) {
        if(p2ACurrent != p2ACharacter.stringValue) {
            p2ACurrent = p2ACharacter.stringValue
            p2AIString = p2ACharacter.stringValue + "1"
            let img = NSImage.init(named: p2AIString)
            if(img==nil){
                
            }
            else {
                p2AImage.image = img
            }
        }
    }
    
    //Set default image for character on P4
    @IBAction func p4Select(_ sender: Any) {
        if(p4Current != p4Character.stringValue) {
            p4Current = p4Character.stringValue
            p2IString = p4Character.stringValue + "1"
            let img = NSImage.init(named: p2IString)
            if(img==nil){
                
            }
            else {
                p2Image.image = img
            }
        }
    }
    
    
    
    
    
    //Check if Round is grand finals and enable checkboxes if so
    @IBAction func RoundSelect(_ sender: Any) {
        if(Round.stringValue == "Grand Finals"){
            p1L.isHidden = false
            p2L.isHidden = false
        }
        else{
            p1L.isHidden = true
            p2L.isHidden = true
        }
    }
    
    
    //Check if doubles is current bracket.
    @IBAction func BracketSelect(_ sender: Any) {
        if(Bracket.stringValue == "Doubles Bracket"){
            p2ALabel.isHidden = false
            p2ATag.isHidden = false
            p2ACharacter.isHidden = false
            p2AColor.isHidden = false
            p2AImage.isHidden = false
            p3Label.isHidden = false
            p3Tag.isHidden = false
            p3Color.isHidden = false
            p3Image.isHidden = false
            p4Character.isHidden = false
            
            p2Color.title = "P4"
            p2Label.stringValue = "Player 4"
            temp1.0 = p1Character.stringValue
            if(!doubles) {
                p4Character.stringValue = p2Character.stringValue
                p2Character.stringValue = "Banjo & Kazooie"
            }
            temp2.0 = p4Character.stringValue
            doubles = true
            if(sponsorsOption > 0){
                p2ASponsor.isHidden = false
                p3Sponsor.isHidden = false
                s2AImage.isHidden = false
                s3Image.isHidden = false
            }
            twitterOption(TwitterOption)
            sponsorOption(sponsorsOption)
            flagOption(flagsOption)
        }
        else{
            doubles = false
            //print(p4Character.isHidden)
            if(!p4Character.isHidden){
                p2Label.stringValue = "Player 2"
                p2Character.stringValue = p4Character.stringValue
                p2Color.title = "P2"
                p2ATag.stringValue = ""
                p2ASponsor.stringValue = ""
                p3Tag.stringValue = ""
                p3Sponsor.stringValue = ""
                s2AImage.image = NSImage()
                s3Image.image = NSImage()
            }
            if(flagsOption == 1){
                p2Label.stringValue = "Player 2"
                p2Color.title = "P2"
                p1Color.title = "P1"
            }
            p2ALabel.isHidden = true
            p2ATag.isHidden = true
            p2ACharacter.isHidden = true
            p2AColor.isHidden = true
            p2AImage.isHidden = true
            p3Label.isHidden = true
            p3Tag.isHidden = true
            p3Color.isHidden = true
            p3Image.isHidden = true
            p4Character.isHidden = true
            //print(p4Character.isHidden)
            p2ASponsor.isHidden = true
            p3Sponsor.isHidden = true
            s2AImage.isHidden = true
            s3Image.isHidden = true
            p2ATwitter.isHidden = true
            p3Twitter.isHidden = true
            setupCharacters()
            if(temp1.0 != ""){
                p1Character.stringValue = temp1.0
                let i1 = NSImage.init(named:temp1.1)
                p1Image.image = i1
            }
            else{
                p1Character.stringValue = "Banjo & Kazooie"
                p1Image.image = NSImage.init(named: "Banjo & Kazooie1")
            }
            if(temp2.0 != ""){
                p2Character.stringValue = temp2.0
                let i2 = NSImage.init(named:temp2.1)
                p2Image.image = i2
            }
            else{
                p2Character.stringValue = "Banjo & Kazooie"
                p2Image.image = NSImage.init(named: "Banjo & Kazooie1")
            }
        }
    }
    
    
    //Allow user to select folder for storage and remember selection
    @IBAction func Output(_ sender: Any) {
        
        let url = NSOpenPanel().selectUrl
        if(url != nil){
            
            
            fileLocation = url
            let result = try? (context.fetch(requestL) as![NSManagedObject])
            for i in result!{
                context.delete(i)
                //print("thing deleted")
                do{
                    try context.save()
                }
                catch {
                    //print("Clear failed, \(error)")
                }
            }
            let entity = NSEntityDescription.entity(forEntityName: "FileLocation", in: context)
            let saveThis = NSManagedObject(entity: entity!, insertInto: context)
            saveThis.setValue(url!.absoluteString, forKey: "url")
            do{
                try context.save()
                //print("Location was saved!")
            }
            catch {
                //print("Update failed, \(error)")
            }
        }
    }
    
    //Save Character and image selection for player and store elements into text files.
    @IBAction func UpdateFiles(_ sender: Any) {
        let result = try? (context.fetch(requestP) as![NSManagedObject])
        print(p1IString)
        print(p2IString)
        //Store player selections for later re-use
        for i in result!{
            if(((i.value(forKey: "name") as? String)) != nil){
                var tag = ""
                tag = (i.value(forKey: "name") as! String)
                if(tag == p1Tag.stringValue){
                    if(!doubles || flagsOption == 0){
                        i.setValue(p1Character.stringValue, forKey: "character")
                        i.setValue(p1IString, forKey: "color")
                    }
                    if(sponsorsOption > 0){
                        i.setValue(p1Sponsor.stringValue, forKey: "sponsor")
                    }
                    if(TwitterOption > 0){
                        i.setValue(p1Twitter.stringValue, forKey: "twitter")
                    }
                }
                if(tag == p2Tag.stringValue){
                    if(!doubles || flagsOption == 0){
                        i.setValue(p2Character.stringValue, forKey: "character")
                        i.setValue(p2IString, forKey: "color")
                    }
                    else{
                        if(flagsOption == 0){
                            i.setValue(p4Character.stringValue, forKey: "character")
                        }
                    }
                    if(sponsorsOption > 0){
                        i.setValue(p2Sponsor.stringValue, forKey: "sponsor")
                    }
                    if(TwitterOption > 0){
                        i.setValue(p2Twitter.stringValue, forKey: "twitter")
                    }
                }
                if(tag == p2ATag.stringValue){
                    if(!doubles || flagsOption == 0){
                        i.setValue(p2ACharacter.stringValue, forKey: "character")
                        i.setValue(p2AIString, forKey: "color")
                    }
                    if(sponsorsOption > 0){
                        i.setValue(p2ASponsor.stringValue, forKey: "sponsor")
                    }
                    if(TwitterOption > 0){
                        i.setValue(p2ATwitter.stringValue, forKey: "twitter")
                    }
                }
                if(tag == p3Tag.stringValue){
                    if(!doubles || flagsOption == 0){
                        i.setValue(p2Character.stringValue, forKey: "character")
                        i.setValue(p3IString, forKey: "color")
                    }
                    if(sponsorsOption > 0){
                        i.setValue(p3Sponsor.stringValue, forKey: "sponsor")
                    }
                    if(TwitterOption > 0){
                        i.setValue(p3Twitter.stringValue, forKey: "twitter")
                    }
                }
                do{
                    try context.save()
                   // print("Tag was saved!")
                }
                catch {
                    //print("Update failed, \(error)")
                }
            }
        }
        
        //Create file Urls to be saved to
        let directoryURL = fileLocation!
        var fileURL = [URL]()
        fileURL.append(URL(fileURLWithPath: "p1Tag", relativeTo: directoryURL).appendingPathExtension("txt"))
        fileURL.append(URL(fileURLWithPath: "p2Tag", relativeTo: directoryURL).appendingPathExtension("txt"))
        fileURL.append(URL(fileURLWithPath: "p1Score", relativeTo: directoryURL).appendingPathExtension("txt"))
        fileURL.append(URL(fileURLWithPath: "p2Score", relativeTo: directoryURL).appendingPathExtension("txt"))
        fileURL.append(URL(fileURLWithPath: "Bracket", relativeTo: directoryURL).appendingPathExtension("txt"))
        fileURL.append(URL(fileURLWithPath: "Round", relativeTo: directoryURL).appendingPathExtension("txt"))
        
        //Create the strings for players or teams
        var string1 = p1Tag.stringValue
        var string2 = p2Tag.stringValue
        var string2A = p2ATag.stringValue
        var string3 = p3Tag.stringValue
        if(p1Sponsor.stringValue != "" && p1Sponsor.stringValue != "No Sponsor" && sponsorsOption == 1){
            string1 = "\(p1Sponsor.stringValue) | \(p1Tag.stringValue)"
        }
        if(p2Sponsor.stringValue != "" && p2Sponsor.stringValue != "No Sponsor" && sponsorsOption == 1){
            string2 = "\(p2Sponsor.stringValue) | \(p2Tag.stringValue)"
        }
        if(p2ASponsor.stringValue != "" && p2ASponsor.stringValue != "No Sponsor" && sponsorsOption == 1){
            string2A = "\(p2ASponsor.stringValue) | \(p2ATag.stringValue)"
        }
        if(p3Sponsor.stringValue != "" && p3Sponsor.stringValue != "No Sponsor" && sponsorsOption == 1){
            string3 = "\(p3Sponsor.stringValue) | \(p3Tag.stringValue)"
        }
        if(doubles){
            string1 = "\(string1) & \(string2A)"
            string2 = "\(string3) & \(string2)"
        }
        if(!p1L.isHidden && p1L.state.rawValue>0) {
            string1 = "(L) " + string1
        }
        if(!p2L.isHidden && p2L.state.rawValue>0){
            string2 += " (L)"
        }
        
        
        // Create data to be saved
        var myStrings = [string1, string2, p1Score.stringValue, p2Score.stringValue, Bracket.stringValue, Round.stringValue + " " + RoundNum.stringValue]
        
        //Add elements if certain items are filled
        if(p1Twitter.stringValue != ""){
            fileURL.append(URL(fileURLWithPath: "p1Twitter", relativeTo: directoryURL).appendingPathExtension("txt"))
            myStrings.append(p1Twitter.stringValue)
        }
        if(p2Twitter.stringValue != ""){
            var fileName = "p2Twitter"
            if(doubles){
                fileName = "p4Twitter"
            }
            fileURL.append(URL(fileURLWithPath: fileName, relativeTo: directoryURL).appendingPathExtension("txt"))
            myStrings.append(p2Twitter.stringValue)
        }
        if(p2ATwitter.stringValue != ""){
            fileURL.append(URL(fileURLWithPath: "p2Twitter", relativeTo: directoryURL).appendingPathExtension("txt"))
            myStrings.append(p2ATwitter.stringValue)
        }
        if(p3Twitter.stringValue != ""){
            fileURL.append(URL(fileURLWithPath: "p3Twitter", relativeTo: directoryURL).appendingPathExtension("txt"))
            myStrings.append(p3Twitter.stringValue)
        }
        if(c1tag.stringValue != ""){
            fileURL.append(URL(fileURLWithPath: "commentator1", relativeTo: directoryURL).appendingPathExtension("txt"))
            myStrings.append(c1tag.stringValue)
        }
        if(c2tag.stringValue != ""){
            fileURL.append(URL(fileURLWithPath: "commentator2", relativeTo: directoryURL).appendingPathExtension("txt"))
            myStrings.append(c2tag.stringValue)
        }
        
        
       
        //Save myStrings elements to corresponding .txt files
        for i in 0...fileURL.count-1 {
            guard let data = myStrings[i].data(using: .utf8) else {
                //print("Unable to convert string to data")
                return
            }// Save the data
            do {
                try data.write(to: fileURL[i])
                //print("File saved: \(fileURL[i].absoluteURL)")
            } catch {
                // Catch any errors
                //print("Failure")
                //print(error.localizedDescription)
            }
        }
        
        //Save images to png files
        let blankI = NSImage.init(named: "transparent-background-pattern")
        let picture1 = p1Image.image!
        let picture2 = p2Image.image!
        let picture2A = p2AImage.image!
        let picture3 = p3Image.image!
        var imageURL = fileLocation!.appendingPathComponent("p1Char.png")
        
        //Check for valid images and if sponsor images need to be saved too
        if let png = picture1.png {
            do {
                try png.write(to: imageURL)
                //print("PNG image saved")
            } catch {
                //print(error)
            }
            if(sponsorsOption > 0 && s1Image.image != nil){
                let sponsor1 = s1Image.image!
                imageURL = fileLocation!.appendingPathComponent("p1Sponsor.png")
                if let png = sponsor1.png {
                    do {
                        try png.write(to: imageURL)
                        //print("PNG image saved")
                    } catch {
                        //print(error)
                    }
                }
            }
            else if(sponsorsOption > 0){
                imageURL = fileLocation!.appendingPathComponent("p1Sponsor.png")
                if let png = blankI?.png {
                    do {
                        try png.write(to: imageURL)
                        //print("PNG image saved")
                    } catch {
                        //print(error)
                    }
                }
            }
        }
        if(!doubles){
            imageURL = fileLocation!.appendingPathComponent("p2Char.png")
            if let png = picture2.png {
                do {
                    try png.write(to: imageURL)
                    //print("PNG image saved")
                } catch {
                    //print(error)
                }
            }
            if(sponsorsOption > 0 && s2Image.image != nil){
                let sponsor2 = s2Image.image!
                imageURL = fileLocation!.appendingPathComponent("p2Sponsor.png")
                if let png = sponsor2.png {
                    do {
                        try png.write(to: imageURL)
                        //print("PNG image saved")
                    } catch {
                        //print(error)
                    }
                }
            }
            else if(sponsorsOption > 0){
                imageURL = fileLocation!.appendingPathComponent("p2Sponsor.png")
                if let png = blankI?.png {
                    do {
                        try png.write(to: imageURL)
                        //print("PNG image saved")
                    } catch {
                        //print(error)
                    }
                }
            }
        }
        else{
            imageURL = fileLocation!.appendingPathComponent("p2Char.png")
            if let png = picture2A.png {
                do {
                    try png.write(to: imageURL)
                    //print("PNG image saved")
                } catch {
                    //print(error)
                }
            }
            imageURL = fileLocation!.appendingPathComponent("p3Char.png")
            if let png = picture3.png {
                do {
                    try png.write(to: imageURL)
                    //print("PNG image saved")
                } catch {
                    //print(error)
                }
            }
            if(flagsOption == 0){
                imageURL = fileLocation!.appendingPathComponent("p4Char.png")
            }
            else {
                imageURL = fileLocation!.appendingPathComponent("p2Char.png")
            }
            if let png = picture2.png {
                do {
                    try png.write(to: imageURL)
                    //print("PNG image saved")
                } catch {
                    //print(error)
                }
            }
            if(sponsorsOption > 0 && s2AImage.image != nil){
                let sponsor2 = s2AImage.image!
                imageURL = fileLocation!.appendingPathComponent("p2Sponsor.png")
                if let png = sponsor2.png {
                    do {
                        try png.write(to: imageURL)
                        //print("PNG image saved")
                    } catch {
                        //print(error)
                    }
                }
            }
            else if(sponsorsOption > 0){
                imageURL = fileLocation!.appendingPathComponent("p2Sponsor.png")
                if let png = blankI?.png {
                    do {
                        try png.write(to: imageURL)
                        //print("PNG image saved")
                    } catch {
                        //print(error)
                    }
                }
            }
            if(sponsorsOption > 0 && s3Image.image != nil){
                let sponsor3 = s3Image.image!
                imageURL = fileLocation!.appendingPathComponent("p3Sponsor.png")
                if let png = sponsor3.png {
                    do {
                        try png.write(to: imageURL)
                        //print("PNG image saved")
                    } catch {
                        //print(error)
                    }
                }
            }
            else if(sponsorsOption > 0){
                imageURL = fileLocation!.appendingPathComponent("p3Sponsor.png")
                if let png = blankI?.png {
                    do {
                        try png.write(to: imageURL)
                        //print("PNG image saved")
                    } catch {
                        //print(error)
                    }
                }
            }
            if(sponsorsOption > 0 && s2Image.image != nil){
                let sponsor4 = s2Image.image!
                imageURL = fileLocation!.appendingPathComponent("p4Sponsor.png")
                if let png = sponsor4.png {
                    do {
                        try png.write(to: imageURL)
                        //print("PNG image saved")
                    } catch {
                        //print(error)
                    }
                }
            }
            else if(sponsorsOption > 0){
                imageURL = fileLocation!.appendingPathComponent("p4Sponsor.png")
                if let png = blankI?.png {
                    do {
                        try png.write(to: imageURL)
                        //print("PNG image saved")
                    } catch {
                        //print(error)
                    }
                }
            }
        }
    }
    
    //Swap players and their elements
    @IBAction func swap(_ sender: Any) {
        var tempS = ""
        var tempI = p1Image.image
        if(!doubles){ //Not currently doubles
            tempS = p1Tag.stringValue
            p1Tag.stringValue = p2Tag.stringValue
            p2Tag.stringValue = tempS
            tempS = p1Character.stringValue
            p1Character.stringValue = p2Character.stringValue
            p2Character.stringValue = tempS
            p1Image.image = p2Image.image
            p2Image.image = tempI
            tempS = p1Sponsor.stringValue
            p1Sponsor.stringValue = p2Sponsor.stringValue
            p2Sponsor.stringValue = tempS
            tempI = s1Image.image
            s1Image.image = s2Image.image
            s2Image.image = tempI
            tempS = p1Twitter.stringValue
            p1Twitter.stringValue = p2Twitter.stringValue
            p2Twitter.stringValue = tempS
            tempS = p1IString
            p1IString = p2IString
            p2IString = tempS
        }
        else{ //doubles is selected
            if(flagsOption == 0){ //flags disabled
                p2ACharacter.stringValue = p4Character.stringValue
                p4Character.stringValue = tempS
                tempI = p2AImage.image
                p2AImage.image = p2Image.image
                p2Image.image = tempI
                tempS = p1Character.stringValue
                p1Character.stringValue = p2Character.stringValue
                p2Character.stringValue = tempS
                p1Image.image = p3Image.image
                p3Image.image = tempI
                tempS = p1IString
                p1IString = p3IString
                p3IString = tempS
                tempS = p2IString
                p2IString = p2AIString
                p2AIString = tempS
            }
            else{ //flags enabled
                tempS = p1Character.stringValue
                p1Character.stringValue = p2Character.stringValue
                p2Character.stringValue = tempS
                p1Image.image = p2Image.image
                p2Image.image = tempI
                tempS = p1Sponsor.stringValue
            }
            
            tempS = p1Tag.stringValue
            p1Tag.stringValue = p3Tag.stringValue
            p3Tag.stringValue = tempS
            
            
            tempS = p2ATag.stringValue
            p2ATag.stringValue = p2Tag.stringValue
            p2Tag.stringValue = tempS
            tempS = p2ACharacter.stringValue
            
            
            tempS = p1Sponsor.stringValue
            p1Sponsor.stringValue = p3Sponsor.stringValue
            p3Sponsor.stringValue = tempS
            tempI = s1Image.image
            s1Image.image = s3Image.image
            s3Image.image = tempI
            tempS = p1Twitter.stringValue
            p1Twitter.stringValue = p3Twitter.stringValue
            p3Twitter.stringValue = tempS
            
            tempS = p2ASponsor.stringValue
            p2ASponsor.stringValue = p2Sponsor.stringValue
            p2Sponsor.stringValue = tempS
            tempI = s2AImage.image
            s2AImage.image = s2Image.image
            s2Image.image = tempI
            tempS = p2ATwitter.stringValue
            p2ATwitter.stringValue = p2Twitter.stringValue
            p2Twitter.stringValue = tempS
        }
    }
    
    //Respond to sponsor selection for player 1
    @IBAction func p1SponsorSelect(_ sender: Any) {
        if(!p1Sponsor.isHidden && (p1Sponsor.indexOfItem(withObjectValue: p1Sponsor.stringValue) < sponsorURLs.count)){
            s1Image.image = NSImage(contentsOf: sponsorURLs[p1Sponsor.indexOfItem(withObjectValue: p1Sponsor.stringValue)])
        }
        else {
            s1Image.image = NSImage()
        }
    }
    
    //Respond to sponsor selection for player 2
    @IBAction func p2SponsorSelect(_ sender: Any) {
        if(!p2Sponsor.isHidden && (p2Sponsor.indexOfItem(withObjectValue: p2Sponsor.stringValue) < sponsorURLs.count)){
            s2Image.image = NSImage(contentsOf: sponsorURLs[p2Sponsor.indexOfItem(withObjectValue: p2Sponsor.stringValue)])
        }
        else {
            s2Image.image = NSImage()
        }
    }
    
    //Respond to sponsor selection for player 2A
    @IBAction func p2ASponsorSelect(_ sender: Any) {
        if(!p2ASponsor.isHidden && (p2ASponsor.indexOfItem(withObjectValue: p2ASponsor.stringValue) < sponsorURLs.count)){
            s2AImage.image = NSImage(contentsOf: sponsorURLs[p2ASponsor.indexOfItem(withObjectValue: p2ASponsor.stringValue)])
        }
        else {
            s2AImage.image = NSImage()
        }
    }
    
    //Respond to sponsor selection for player 3
    @IBAction func p3SponsorSelect(_ sender: Any) {
        if(!p3Sponsor.isHidden && (p3Sponsor.indexOfItem(withObjectValue: p3Sponsor.stringValue) < sponsorURLs.count)){
            s3Image.image = NSImage(contentsOf: sponsorURLs[p3Sponsor.indexOfItem(withObjectValue: p3Sponsor.stringValue)])
        }
        else {
            s3Image.image = NSImage()
        }
    }
    
    
    
    //Prepare for segues to other ViewControllers with data to transfer when needed
    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        //Segue is somehow nil
        if(segue.identifier == nil) {
            //print("nil points")
        }
        else { //Send data with segue if needed
            if(segue.identifier! == "AddSegue"){
                if let dest = segue.destinationController as? AddViewController {
                    dest.delegate = self
                }
            }
            if(segue.identifier! == "RemoveSegue"){
                if let dest = segue.destinationController as? RemoveViewController {
                    dest.delegate = self
                }
            }
            if(segue.identifier! == "BracketSegue"){
                if let dest = segue.destinationController as? BracketController {
                    dest.delegate = self
                }
            }
            if(segue.identifier! == "RoundSegue"){
                if let dest = segue.destinationController as? RoundController {
                    dest.delegate = self
                }
            }
            if(segue.identifier! == "ImageSegue1"){
                if let images = segue.destinationController as? ImageController {

                    let passed = p1Character.stringValue

                    images.character = passed
                    images.player = "p1"
                    images.delegate = self
                }
            }
            if(segue.identifier! == "ImageSegue2"){
                if let images = segue.destinationController as? ImageController {
                    var passed = ""
                    if(!doubles){
                        passed = p2Character.stringValue
                    }
                    else{
                        passed = p4Character.stringValue
                    }
                    images.character = passed
                    images.player = "p2"
                    images.delegate = self
                }
            }
            if(segue.identifier! == "ImageSegue2A"){
                if let images = segue.destinationController as? ImageController {

                    let passed = p2ACharacter.stringValue

                    images.character = passed
                    images.player = "p2A"
                    images.delegate = self
                }
            }
            if(segue.identifier! == "ImageSegue3"){
                if let images = segue.destinationController as? ImageController {

                    let passed = p2Character.stringValue

                    images.character = passed
                    images.player = "p3"
                    images.delegate = self
                }
            }
            if(segue.identifier! == "OptionsSegue"){
                if let dest = segue.destinationController as? OptionsController {

                    let passed = [flagsOption, commentatorOption, sponsorsOption, TwitterOption]

                    dest.optionsArr = passed
                    dest.delegate = self
                }
            }
            if(segue.identifier! == "SponsorSegue"){
                if let dest = segue.destinationController as? SponsorController {
                    dest.delegate = self
                }
            }
        }
    }
    
    
    
    
    //Return Image selection for respective player
    func doSomethingWith(_ data1: NSImage,_ data2: String,_ data3: String) {
        
        //Color selection is for player 1
        if(data2 == "p1"){
            p1Image.image = data1
            p1IString = data3
        }
        
        //Color selection is for player 2
        if(data2 == "p2") {
            p2Image.image = data1
            p2IString = data3
        }
        
        //Color selection is for player 2A
        if(data2 == "p2A") {
            p2AImage.image = data1
            p2AIString = data3
        }
        
        //Color selection is for player 3
        if(data2 == "p3") {
            p3Image.image = data1
            p3IString = data3
        }
    }
    
    //Delegate functions to ensure menus reload after actions in other view controllers
    func reloadAdd(data: String) {
        loadMenus()
    }
    func reload2() {
        loadMenus()
    }
    func reload3() {
        loadMenus()
    }
    func reload4() {
        loadMenus()
    }
    func reloadSponsors(){
        loadSponsors()
    }
    
    //Commentator option is selected or deselected
    func commentatorOption(_ i: Int) {
        //print("I ran!")
        commentatorOption = i
        if(commentatorOption == 1){ // Reveal commentator items
            c1tag.isHidden = false
            c2tag.isHidden = false
            c1Label.isHidden = false
            c2Label.isHidden = false
        }
        else{ // Re-hide commentator items
            c1tag.isHidden = true
            c2tag.isHidden = true
            c1Label.isHidden = true
            c2Label.isHidden = true
        }
    }
    
    //Twitter option is selected or deselected
    func twitterOption(_ i: Int) {
        //print("I ran!")
        TwitterOption = i
        if(TwitterOption == 1){ //Reveal twitter items
            p1Twitter.isHidden = false
            p2Twitter.isHidden = false
            if(doubles){
                p2ATwitter.isHidden = false
                p3Twitter.isHidden = false
            }
        }
        else{ //Re-hide twitter items
            p1Twitter.isHidden = true
            p2Twitter.isHidden = true
            p2ATwitter.isHidden = true
            p3Twitter.isHidden = true
        }
    }
    
    //Sponsor option is selected or deselected
    func sponsorOption(_ i: Int) {
        //print("I ran!")
        sponsorsOption = i
        if(sponsorsOption > 0){ //Reveal sponsor items
            p1Sponsor.isHidden = false
            p2Sponsor.isHidden = false
            s1Image.isHidden = false
            s2Image.isHidden = false
            addSponsor.isHidden = false
            if(doubles){
                p2ASponsor.isHidden = false
                p3Sponsor.isHidden = false
                s2AImage.isHidden = false
                s3Image.isHidden = false
            }
        }
        else{ //Re-hide sponsor items
            p1Sponsor.isHidden = true
            p2Sponsor.isHidden = true
            s1Image.isHidden = true
            s2Image.isHidden = true
            addSponsor.isHidden = true
            p2ASponsor.isHidden = true
            p3Sponsor.isHidden = true
            s2AImage.isHidden = true
            s3Image.isHidden = true
        }
    }
    
    //Flag option is selected or deselected
    func flagOption(_ i: Int) {
        //print("I ran!")
        flagsOption = i
        if(flagsOption == 1){
            if(doubles){ //Setup and reveal flag items
                setupFlags()
                //p1Character.isHidden = true
                //p2Character.isHidden = true
                p2ACharacter.isHidden = true
                p4Character.isHidden = true
                p2AImage.isHidden = true
                p3Image.isHidden = true
                p2AColor.isHidden = true
                p3Color.isHidden = true
                //t1Flag.isHidden = false
               // t2Flag.isHidden = false
                p1Color.title = "T1"
                p2Color.title = "T2"
                p1Character.stringValue = "blueflag"
                p2Character.stringValue = "blueflag"
                p1Image.image = NSImage.init(named: "blueflag1")
                p2Image.image = NSImage.init(named: "blueflag1")
            }
        }
        else{
            if(doubles){ //Rehide flag items and return to normal
                setupCharacters()
                p1Character.isHidden = false
                p2Character.isHidden = false
                p2ACharacter.isHidden = false
                p4Character.isHidden = false
                p2AImage.isHidden = false
                p3Image.isHidden = false
                p2AColor.isHidden = false
                p3Color.isHidden = false
                p1Color.title = "P1"
                p2Color.title = "P4"
            }
            else{
                
                //Restore player characters from doubles mode
                if(temp1.0 != ""){
                    p1Character.stringValue = temp1.0
                    let i1 = NSImage.init(named:temp1.1)
                    p1Image.image = i1
                }
                else{
                    p1Character.stringValue = "Banjo & Kazooie"
                    p1Image.image = NSImage.init(named: "Banjo & Kazooie1")
                }
                if(temp2.0 != ""){
                    p2Character.stringValue = temp2.0
                    let i2 = NSImage.init(named:temp2.1)
                    p2Image.image = i2
                }
                else{
                    p2Character.stringValue = "Banjo & Kazooie"
                    p2Image.image = NSImage.init(named: "Banjo & Kazooie1")
                }
            }
        }
    }
    
    //Return Player Information
    func returnPlayer(_ tag: String, _ index: Int) -> (character: String, imgName: String, sponsor: String, twitter: String){
        //print(tag)
        var c = ""
        var iN = "Banjo & Kazooie1"
        var s = ""
        var t = ""
        let result = try? (context.fetch(requestP) as![NSManagedObject])
        if(tag != "" && result!.count > 0)
        {
            let result = try? (context.fetch(requestP) as![NSManagedObject])
            if(result?[index].value(forKey: "character") == nil){
            }
            else{
                //print("p1 loaded")
                if((result![index].value(forKey: "character") as? String) != nil){
                    c = (result![index].value(forKey: "character") as! String)
                }
                if((result![index].value(forKey: "color") as? String) != nil){
                    iN = result![index].value(forKey: "color") as! String
                }
                if((result![index].value(forKey: "sponsor") as? String) != nil){
                    s = result![index].value(forKey: "sponsor") as! String
                }
                if((result![index].value(forKey: "twitter") as? String) != nil){
                    t = result![index].value(forKey: "twitter") as! String
                }
            }
        }
        //print(c)
        //print(iN)
        return (c, iN, s, t)
    }
    
    //Load all menus with appropriate data
    func loadMenus(){
        //print("Menus Loaded")
        
        //Clear data in dropdowns before reloading with new data
        p1Tag.removeAllItems()
        p2Tag.removeAllItems()
        p2ATag.removeAllItems()
        p3Tag.removeAllItems()
        c1tag.removeAllItems()
        c2tag.removeAllItems()
        Round.removeAllItems()
        Bracket.removeAllItems()
        
        var tag = ""
        
        //Load player dropdowns items
        do {
            let result = try context.fetch(requestP)
            //print(result)
            for i in result as![NSManagedObject]{
                if(((i.value(forKey: "name") as? String)) == nil){
                    context.delete(i)
                    //print("thing deleted")
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
                    var tagArr = [String]()
                    tagArr.append(tag)
                    p1Tag.addItem(withObjectValue: tag)
                    p2Tag.addItem(withObjectValue: tag)
                    p2ATag.addItem(withObjectValue: tag)
                    p3Tag.addItem(withObjectValue: tag)
                    c1tag.addItem(withObjectValue: tag)
                    c2tag.addItem(withObjectValue: tag)
                }
            }
        }
        catch {
            //print("inventory retrieval failed \(error)")
        }
        
        //Load Brackets dropdown items
        requestB.returnsObjectsAsFaults = false
        do {
            let result = try context.fetch(requestB)
            for i in result as![NSManagedObject]{
                tag = (i.value(forKey: "bracket") as! String)
                //bracketType.addItem(withTitle: tag)
                Bracket.addItem(withObjectValue: tag)
            }
        }
        catch {
            //print("inventory retrieval failed \(error)")
        }
        
        //Load Rounds Dropdown Items
        requestR.returnsObjectsAsFaults = false
        do {
            let result = try context.fetch(requestR)
            for i in result as![NSManagedObject]{
                tag = (i.value(forKey: "round") as! String)
                //currentRound.addItem(withTitle: tag)
                Round.addItem(withObjectValue: tag)
            }
        }
        catch {
            //print("inventory retrieval failed \(error)")
        }
    }
    
    // Set the values for the character dropdowns.
    func setupCharacters() {
        
        //Store Character names in array
        var cN = [String]()
        cN.append("Banjo & Kazooie")
        cN.append("Bayonetta")
        cN.append("Bowser")
        cN.append("Bowser Jr")
        cN.append("Byleth")
        cN.append("Captain Falcon")
        cN.append("Chrom")
        cN.append("Cloud")
        cN.append("Corrin")
        cN.append("Daisy")
        cN.append("Dark Pit")
        cN.append("Dark Samus")
        cN.append("Diddy Kong")
        cN.append("Donkey Kong")
        cN.append("Dr. Mario")
        cN.append("Duck Hunt")
        cN.append("Falco")
        cN.append("Fox")
        cN.append("Ganondorf")
        cN.append("Greninja")
        cN.append("Hero")
        cN.append("Ice Climbers")
        cN.append("Ike")
        cN.append("Incineroar")
        cN.append("Inkling")
        cN.append("Isabelle")
        cN.append("Jigglypuff")
        cN.append("Joker")
        cN.append("Kazuya")
        cN.append("Ken")
        cN.append("King Dedede")
        cN.append("King K Rool")
        cN.append("Kirby")
        cN.append("Link")
        cN.append("Little Mac")
        cN.append("Lucario")
        cN.append("Lucas")
        cN.append("Lucina")
        cN.append("Luigi")
        cN.append("Mario")
        cN.append("Marth")
        cN.append("Megaman")
        cN.append("Metaknight")
        cN.append("Mewtwo")
        cN.append("Mii Brawler")
        cN.append("Mii Gunner")
        cN.append("Mii SwordFighter")
        cN.append("Min Min")
        cN.append("Mr. Game & Watch")
        cN.append("Mythra")
        cN.append("Ness")
        cN.append("Olimar")
        cN.append("Pac-Man")
        cN.append("Palutena")
        cN.append("Peach")
        cN.append("Pichu")
        cN.append("Pikachu")
        cN.append("Piranha Plant")
        cN.append("Pit")
        cN.append("Pokemon Trainer")
        cN.append("Pyra")
        cN.append("R.O.B.")
        cN.append("Richter")
        cN.append("Ridley")
        cN.append("Robin")
        cN.append("Rosalina")
        cN.append("Roy")
        cN.append("Ryu")
        cN.append("Samus")
        cN.append("Sephiroth")
        cN.append("Sheik")
        cN.append("Shulk")
        cN.append("Simon")
        cN.append("Snake")
        cN.append("Sonic")
        cN.append("Sora")
        cN.append("Steve")
        cN.append("Terry")
        cN.append("Toon Link")
        cN.append("Villager")
        cN.append("Wario")
        cN.append("Wii Fit Trainer")
        cN.append("Wolf")
        cN.append("Yoshi")
        cN.append("Young Link")
        cN.append("Zelda")
        cN.append("Zero Suit Samus")
        p1Character.removeAllItems()
        p2Character.removeAllItems()
        p2ACharacter.removeAllItems()
        p4Character.removeAllItems()
        
        //Store names in Character selections
        for name in cN{
            p1Character.addItem(withObjectValue: name)
            p2Character.addItem(withObjectValue: name)
            p2ACharacter.addItem(withObjectValue: name)
            p4Character.addItem(withObjectValue: name)
        }
    }
    
    // Load Sponsors
    func loadSponsors() {
        p1Sponsor.removeAllItems()
        p2Sponsor.removeAllItems()
        p2ASponsor.removeAllItems()
        p3Sponsor.removeAllItems()
        sponsorNames.removeAll()
        sponsorURLs.removeAll()
        
        
        var tag = ""
        let result = try? (context.fetch(requestS) as![NSManagedObject])
        for i in result!{
            if((((i.value(forKey: "name") as? String))==nil) || (((i.value(forKey: "images") as? String)==nil))){
                context.delete(i)
                //print("thing deleted")
                do{
                    try context.save()
                    //print("Name removed")
                }
                catch {
                    //print("Clear failed, \(error)")
                }
                continue
            }
            else{
                tag = (i.value(forKey: "name") as! String)
                //print(tag)
            }
            let imageURL = URL(string: ((i.value(forKey: "images") as? String)!))
            let image = NSImage(contentsOf: imageURL!)
            if(image == nil){
                context.delete(i)
                //print("thing deleted")
                do{
                    try context.save()
                    //print("Image removed")
                }
                catch {
                    //print("Clear failed, \(error)")
                }
            }
            else {
                p1Sponsor.addItem(withObjectValue: tag)
                p2Sponsor.addItem(withObjectValue: tag)
                p2ASponsor.addItem(withObjectValue: tag)
                p3Sponsor.addItem(withObjectValue: tag)
                sponsorNames.append(tag)
                sponsorURLs.append(imageURL!)
                //print(tag)
            }
            /*
            context.delete(i)
            do{
                try context.save()
                //print("content deleted")
            }
            catch {
                //print("Update failed, \(error)")
            }*/
        }
        p1Sponsor.addItem(withObjectValue: "No Sponsor")
        p2Sponsor.addItem(withObjectValue: "No Sponsor")
        p2ASponsor.addItem(withObjectValue: "No Sponsor")
        p3Sponsor.addItem(withObjectValue: "No Sponsor")
    }
    
    //Setup the Flags
    func setupFlags() {
        
        //Store Character names in array
        var cN = [String]()
        cN.append("blueflag")
        cN.append("greenflag")
        cN.append("redflag")
        cN.append("yellowflag")
        
        p1Character.removeAllItems()
        p2Character.removeAllItems()
        p2ACharacter.removeAllItems()
        p4Character.removeAllItems()
        
        //Store names in Character selections
        for name in cN{
            p1Character.addItem(withObjectValue: name)
            p2Character.addItem(withObjectValue: name)
            p2ACharacter.addItem(withObjectValue: name)
            p4Character.addItem(withObjectValue: name)
        }
    }
}
