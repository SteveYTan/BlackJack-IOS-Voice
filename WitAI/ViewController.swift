//
//  ViewController.swift
//  WitAI
//
//  Created by Julian Abentheuer on 10.01.15.
//  Copyright (c) 2015 Aaron Abentheuer. All rights reserved.
//

import UIKit

class ViewController: UIViewController, WitDelegate {
    
    @IBOutlet weak var labelView2: UILabel!
    //var labelView : UILabel?
    var witButton : WITMicButton?
    
    let socket = SocketIOClient(socketURL: "http://192.168.1.199:5000")
    
    
    var hand = [String]()
    var text = ""
    var comphand = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        print("testing")
        
        // set the WitDelegate object
        Wit.sharedInstance().delegate = self
        
        // create the button
        let screen : CGRect = UIScreen.mainScreen().bounds
        let w : CGFloat = 100
        let rect : CGRect = CGRectMake(screen.size.width/2 - w/2, 60, w, 100)
        
        witButton = WITMicButton(frame: rect)
        self.view.addSubview(witButton!)
        
        // create the label
//        labelView = UILabel(frame: CGRectMake(0, 200, screen.size.width, 50))
////        labelView!.center = CGPointMake(190, 460)
//        labelView!.textAlignment = .Center
        //labelView!.text = "intent"
        //labelView2.text = "intent"
//        labelView!.textColor = UIColor.blackColor()
//        labelView!.sizeToFit()
//        self.view.addSubview(labelView!)
        
        
        socket.connect()
        socket.on("connect"){ data, ack in
            print("ios yo")
            
        }
        socket.on("toIOShit"){ data, ack in
            if let d = data{
                print("test here")
                print(d)
                print("seperate")
                print(d[0])
                let outer = d[0] as! [String]
                self.hand.append(outer[0] )
                
                let e = " You were dealt " + (outer[0] ) + "  Your total is now  " + String(outer[1])
                
            
                
                
                self.Speech(e)
            }
        }
        socket.on("toIOShitbust"){ data, ack in
            if let d = data{
                
                print(d)
                self.hand.append(d[0] as! String)
                let e = "You were dealt " + (d[0] as! String) + "  and you have busted"
                
                
                
                
                self.Speech(e)
            }
        }
        
        socket.on("toIOSstaybust"){ data, ack in
            if let d = data{
            let outer = d[0] as! [[String]]
                print(outer)
                
                
                var e = "The computer was dealt "
                
                for (var i = 1; i < outer[0].count; i++){
                    e += "" + (outer[0][i] as String)
                }
                
                e += " The computer total is " + (outer[1][0] as String) + " The computer has busted! You win!"
                
                self.Speech(e)
                
                
            }
        }

        socket.on("toIOSstaywin"){ data, ack in
            
            if let d = data{
                let outer = d[0] as! [[String]]
                print(outer)
                
                
                var e = "The computer was dealt "
                
                for (var i = 1; i < outer[0].count; i++){
                    e += "" + (outer[0][i] as String)
                }
                
                e += " The computer total is " + (outer[1][0] as String) + " Your total is " +  (outer[2][0] as String) + "You win"
                
                self.Speech(e)
                
                
            }
            
        }
        socket.on("toIOSstaylose"){ data, ack in
            if let d = data{
                let outer = d[0] as! [[String]]
                print(outer)
                
                
                var e = "The computer was dealt "
                
                for (var i = 1; i < outer[0].count; i++){
                    e += "" + (outer[0][i] as String)
                }
                
                e += " The computer total is " + (outer[1][0] as String) + " Your total is " +  (outer[2][0] as String) + "You lost "
                
                self.Speech(e)
                
                
            }

            
        }
        
        
        socket.on("toIOSstart"){ data, ack in
            if let d = data{
                print("pleasework")
                print(d[0])
                let outer = d[0] as! [[String]]
                self.hand = outer[0]
                self.comphand = outer[1]
                
                
                self.SpeechStart()
            }
        }
        
        
        socket.on("toIOSstaydraw"){ data, ack in
                    if let d = data{
                        let outer = d[0] as! [[String]]
                        print(outer)
        
        
                        var e = "The computer was dealt "
        
                        for (var i = 1; i < outer[0].count; i++){
                            e += "" + (outer[0][i] as String)
                        }
        
                        e += " The computer total is " + (outer[1][0] as String) + " You have tied! its a draw!"
        
                        self.Speech(e)
                        
                        
                    }
        
                }
        
            
       }
    func witDidGraspIntent(outcomes: [AnyObject]!, messageId: String!, customData: AnyObject!, error e: NSError!) {
        if ((e) != nil) {
            print("\(e.localizedDescription)")
            return
        }
        
        let outcomes : NSArray = outcomes!
        let firstOutcome : NSDictionary = outcomes.objectAtIndex(0) as! NSDictionary
        let intent : String = firstOutcome.objectForKey("intent")as! String
        labelView2.text = intent
//        labelView!.textAlignment = NSTextAlignment.Right
//        labelView!.sizeToFit()
        
        
        if (intent == "bet") {
            betAmount();
        }
        
        if (intent == "show_my_hand") {
            
            if (hand.count == 0){
                SpeechEmpty()
            }
            
            else{
            self.text = "You hand is "
                
            for (var i = 0; i < hand.count; i++){
                if i == hand.count-1{
                    self.text += " and "
                }
                
                self.text += " " + hand[i]
                
                
            }
            
            }
        
            
            Speech();
        }
        if (intent == "start_game") {
            print("i am starting")
            socket.emit("fromIOSstart")
            
            
        }
        if( intent == "draw") {
            socket.emit("fromIOShit")
        }
        if (intent == "stand") {
            socket.emit("fromIOSstay")
        }
        if (intent == "computer_s_hand") {
            Speech("The computers hand is" + String(comphand[0]))
        }
    
        
    }
    
    //---text to speech -----///
    
    var currentlanguage = "en-AU"
    
    func Speech() {
        let string = text 
        let utterance = AVSpeechUtterance(string: string)
        
        
        utterance.voice = AVSpeechSynthesisVoice(language: currentlanguage)
        utterance.rate = 0.1
        
        let synthesizer = AVSpeechSynthesizer()
        synthesizer.speakUtterance(utterance)
        view.endEditing(true)
        
    }
    func Speech(Thing: String) {
        let string = Thing
        let utterance = AVSpeechUtterance(string: string)
        
        
        utterance.voice = AVSpeechSynthesisVoice(language: currentlanguage)
        utterance.rate = 0.1
        utterance.volume = 1.0
//        utterance.volume = 2.0
        
        let synthesizer = AVSpeechSynthesizer()
        synthesizer.speakUtterance(utterance)
        view.endEditing(true)
        
    }
    
    
    func SpeechEmpty() {
        let string = "Your hand is empty."
        let utterance = AVSpeechUtterance(string: string)
        
        
        utterance.voice = AVSpeechSynthesisVoice(language: currentlanguage)
        utterance.rate = 0.1
        utterance.volume = 2.0
        
        
        let synthesizer = AVSpeechSynthesizer()
        synthesizer.speakUtterance(utterance)
        view.endEditing(true)
        
    }
    
    func SpeechStart() {
        var sstring = "Your hand is."
        
        for (var i = 0; i < hand.count; i++){
            if i == hand.count-1{
                sstring += " and "
            }
            
            sstring += " " + hand[i]
            
            
        }
        
        
        
        
        
        
        sstring += "..    ..  The house has a " + comphand[0]
        
        
        
        
        
        
        
        let utterance = AVSpeechUtterance(string: sstring)
        
        
        utterance.voice = AVSpeechSynthesisVoice(language: currentlanguage)
        utterance.rate = 0.1
        
        utterance.volume = 2.0
             //  utterance.volume = 1.0

        
        let synthesizer = AVSpeechSynthesizer()
        synthesizer.speakUtterance(utterance)
        view.endEditing(true)
        
    

    }

    
    
    func betAmount() {
        //        let string = customText.text!
        let string = "You have just bet 50 gold coins"
        let utterance = AVSpeechUtterance(string: string)
        
        utterance.voice = AVSpeechSynthesisVoice(language: currentlanguage)
        utterance.rate = 0.1
        
        let synthesizer = AVSpeechSynthesizer()
        synthesizer.speakUtterance(utterance)
        view.endEditing(true)
        
    }
    
    //---text to speech -----///

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

