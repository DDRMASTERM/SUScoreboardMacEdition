
//
//  SponsorController.swift
//  Mac Scoreboard
//
//  Created by J. Matthew Conover on 3/23/21.
//

import Cocoa
import CoreData

protocol SponsorDelegate : NSObjectProtocol{
    func reloadSponsors()
}

// Handle Folder selection
extension NSOpenPanel {
    var selectImages: [URL]? {
            title = "Select Images"
            allowsMultipleSelection = true
            canChooseDirectories = false
            canChooseFiles = true
            canCreateDirectories = false
            allowedFileTypes = ["jpg","png","pdf","pct", "bmp", "tiff"]  // to allow only images, just comment out this line to allow any file type to be selected
            return runModal() == .OK ? urls : nil
    }
}

class SponsorController: NSViewController {
    
    var index = 0
    var imageURLs = [URL]()
    
    weak var delegate : SponsorDelegate?
    let context = (NSApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Sponsors")
    let requestO = NSFetchRequest<NSFetchRequestResult>(entityName: "Options")
    
    @IBOutlet weak var sImage: NSImageView!
    @IBOutlet weak var iName: NSTextField!
    @IBOutlet weak var testImage: NSImageView!
    @IBOutlet weak var sponsorList: NSPopUpButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        testImage.image = NSImage()
        testImage.isHidden = true
        var tag = ""
        var tags = Set<String>()
        
        do {
            let resultO = try? (context.fetch(requestO) as![NSManagedObject])
            
            if (resultO!.isEmpty){
                let Options = Options(context: context)
                Options.c = 0
                Options.t = 0
                Options.f = 0
                Options.s = 0
                Options.si = 0
                do{
                    try context.save()
                    //print("Option saved!")
                }
                catch {
                    //print("Update failed, \(error)")
                }
            }
            for i in resultO!{
                
                if(((i.value(forKey: "si") as? Int)) == nil){
                    context.delete(i)
                    print("sponsorImages fail")
                }
                else{
                    if(i.value(forKey: "si") as! Int == 1){
                        if let url = NSOpenPanel().selectImages {
                            sImage.image = NSImage(contentsOf: url[0])
                            //print("file selected:", url[0].path)
                            imageURLs = url
                        } else {
                            //print("file selection was canceled")
                        }
                        var tag = ""
                        var image = NSImage()
                        let result = try? (context.fetch(request) as![NSManagedObject])
                        print(result)
                        
                        //Test if items are found properly
                        for i in result!{
                            if((((i.value(forKey: "name") as? String))==nil)){
                                context.delete(i)
                                print("thing deleted")
                                do{
                                    try context.save()
                                    continue
                                    //print("Name removed")
                                }
                                catch {
                                    //print("Clear failed, \(error)")
                                }
                            }
                            else{
                                tag = (i.value(forKey: "name") as! String)
                                //print(tag)
                            }
                            print((i.value(forKey: "images") as? String))
                            if (i.value(forKey: "images") as? String != nil){
                                let imageURL = URL(string: ((i.value(forKey: "images") as? String)!))
                                let image = NSImage(contentsOf: imageURL!)
                                testImage.image = image
                                //print(image)
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
                                    tag = imageURL!.absoluteString
                                    //print(tag)
                                }
                            }
                            /*
                            context.delete(i)
                            do{
                                try context.save()
                                print("content deleted")
                            }
                            catch {
                                print("Update failed, \(error)")
                            }*/
                        }
                    }
                    
                }
            }
        }
        catch {
            //print("inventory retrieval failed \(error)")
        }
        // Store URL Selected
        
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
        sponsorList.addItems(withTitles: Array(tags.sorted(by: { $0.lowercased() < $1.lowercased() })))
        
    }
    
    //Store image under a name
    @IBAction func addImage(_ sender: Any) {
        
        let entity = NSEntityDescription.entity(forEntityName: "Sponsors", in: context)
        let saveThis = NSManagedObject(entity: entity!, insertInto: context)
        saveThis.setValue(iName.stringValue, forKey: "name")
        
        print(iName.stringValue)
        
        /*if let imageData = saveImageView.image?.pngData() {
            DataBaseHelper.shareInstance.saveImage(data: imageData)
            
        }*/
        var image = ""
        print (index)
        if(imageURLs.count > index){
            image = imageURLs[index].absoluteString
            saveThis.setValue(image, forKey: "images")
        }
        //print(image)
        do{
            try context.save()
            //print("Tag was saved!")
        }
        catch {
            //print("Update failed, \(error)")
        }
        if(index < (imageURLs.count - 1)){
            index+=1
            sImage.image = NSImage(contentsOf: imageURLs[index])
        }
        if let delegate = delegate {
            delegate.reloadSponsors()
        }
    }
    @IBAction func removeSponsor(_ sender: Any) {
        var tag = ""
        if (sponsorList.titleOfSelectedItem==nil || sponsorList.indexOfSelectedItem == -1){
            
        }
        else{
            tag = sponsorList.titleOfSelectedItem!
            //print(tag)
            let index = sponsorList.indexOfSelectedItem
            sponsorList.removeItem(at: index)
            
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
                delegate.reloadSponsors()
            } else {
                //print("Delegate has fail")
            }
        }
    }
    
    @IBAction func UpdateLogo(_ sender: Any) {
        var tag = ""
        if (sponsorList.titleOfSelectedItem==nil || sponsorList.indexOfSelectedItem == -1){
            
        }
        else{
            if let url = NSOpenPanel().selectImages {
                sImage.image = NSImage(contentsOf: url[0])
                //print("file selection was canceled")
                
                var tag = sponsorList.titleOfSelectedItem!
                var image = NSImage(contentsOf: url[0])
                let result = try? (context.fetch(request) as![NSManagedObject])
                print(result)
                
                //Test if items are found properly
                for i in result!{
                    if((i.value(forKey: "name") as! String) == tag){
                        //print(i)
                        context.delete(i)
                        
                        let entity = NSEntityDescription.entity(forEntityName: "Sponsors", in: context)
                        let saveThis = NSManagedObject(entity: entity!, insertInto: context)
                        saveThis.setValue(iName.stringValue, forKey: "name")
                        
                        print(iName.stringValue)
                        
                        /*if let imageData = saveImageView.image?.pngData() {
                            DataBaseHelper.shareInstance.saveImage(data: imageData)
                            
                        }*/
                        print (index)
                        saveThis.setValue(tag, forKey: "name")
                        saveThis.setValue(url[0].absoluteString, forKey: "images")
                        //print(image)
                        do{
                            try context.save()
                            //print("Tag was saved!")
                        }
                        catch {
                            //print("Update failed, \(error)")
                        }
                    }
                }
            }
            if(index < (imageURLs.count - 1)){
                index+=1
                sImage.image = NSImage(contentsOf: imageURLs[index])
            }
            if let delegate = delegate {
                delegate.reloadSponsors()
            }
        }
    }
}
