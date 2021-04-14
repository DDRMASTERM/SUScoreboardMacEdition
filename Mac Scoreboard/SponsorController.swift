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
    
    let context = (NSApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Sponsors")
    
    @IBOutlet weak var sImage: NSImageView!
    @IBOutlet weak var iName: NSTextField!
    @IBOutlet weak var testImage: NSImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Store URL Selected
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
            
            
            
            if((((i.value(forKey: "name") as? String))==nil) || (((i.value(forKey: "images") as? String)==nil))){
                context.delete(i)
                //print("thing deleted")
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
        }
        //print(image)
        
        
    }
}
