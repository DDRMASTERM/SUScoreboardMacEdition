//
//  ImageController.swift
//  Mac Scoreboard
//
//  Created by J. Matthew Conover on 3/8/21.
//

import Cocoa

//Return selected image
protocol ImageDelegate : NSObjectProtocol{
    func doSomethingWith(_ data1: NSImage,_ data2: String,_ data3: String)
}

class ImageController: NSViewController {
    var character = ""
    var player = ""
    weak var delegate : ImageDelegate?
    var cArray = [String]()
    @IBOutlet weak var i1: NSButton!
    @IBOutlet weak var i2: NSButton!
    @IBOutlet weak var i3: NSButton!
    @IBOutlet weak var i4: NSButton!
    @IBOutlet weak var i5: NSButton!
    @IBOutlet weak var i6: NSButton!
    @IBOutlet weak var i7: NSButton!
    @IBOutlet weak var i8: NSButton!
    
    //Display images for character selection
    override func viewDidLoad() {
        super.viewDidLoad()
        //print(character)
        //print(player)
        for i in 1...8{
            cArray.append(character + "\(i)")
        }
        let img1 = NSImage.init(named: cArray[0])
        let img2 = NSImage.init(named: cArray[1])
        let img3 = NSImage.init(named: cArray[2])
        let img4 = NSImage.init(named: cArray[3])
        let img5 = NSImage.init(named: cArray[4])
        let img6 = NSImage.init(named: cArray[5])
        let img7 = NSImage.init(named: cArray[6])
        let img8 = NSImage.init(named: cArray[7])
        i1.image = img1
        i2.image = img2
        i3.image = img3
        i4.image = img4
        i5.image = img5
        i6.image = img6
        i7.image = img7
        i8.image = img8
    }
    
    //Return selected images to MainViewController
    @IBAction func i1Clicked(_ sender: Any) {
        if let delegate = delegate{
            delegate.doSomethingWith(i1.image!, player, cArray[0])
            //print("run?")
        }
    }
    @IBAction func i2Clicked(_ sender: Any) {
        if let delegate = delegate{
            delegate.doSomethingWith(i2.image!, player, cArray[1])
        }
    }
    @IBAction func i3Clicked(_ sender: Any) {
        if let delegate = delegate{
            delegate.doSomethingWith(i3.image!, player, cArray[2])
        }
    }
    @IBAction func i4Clicked(_ sender: Any) {
        if let delegate = delegate{
            delegate.doSomethingWith(i4.image!, player, cArray[3])
        }
    }
    @IBAction func i5Clicked(_ sender: Any) {
        if let delegate = delegate{
            delegate.doSomethingWith(i5.image!, player, cArray[4])
        }
    }
    @IBAction func i6Clicked(_ sender: Any) {
        if let delegate = delegate{
            delegate.doSomethingWith(i6.image!, player, cArray[5])
        }
    }
    @IBAction func i7Clicked(_ sender: Any) {
        if let delegate = delegate{
            delegate.doSomethingWith(i7.image!, player, cArray[6])
        }
    }
    @IBAction func i8Clicked(_ sender: Any) {
        if let delegate = delegate{
            delegate.doSomethingWith(i8.image!, player, cArray[7])
        }
    }
    
    
    
}
