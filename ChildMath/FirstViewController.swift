//
//  ViewController.swift
//  YiSzenMath
//
//  Created by CT MacBook Pro on 7/19/15.
//  Copyright © 2015 CT MacBook Pro. All rights reserved.
//

import UIKit
let theDocumentsFolderForSavingFiles = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String

let theFilename = "/theUserFile.txt"

let thePathToThefile = theDocumentsFolderForSavingFiles.stringByAppendingString(theFilename)

class FirstViewController: UIViewController {
    
    func saveData(){
        var theStringWeSave = "adskfa .;"
        theStringWeSave += theStringWeSave
        
        let fileManager = NSFileManager.defaultManager()
        if (!fileManager.fileExistsAtPath(thePathToThefile)){
            do{
                let fileToBeWritten = try theStringWeSave.writeToFile(thePathToThefile, atomically: true, encoding: NSUTF8StringEncoding)
                print("we wrote and fileToBeWritten is \(fileToBeWritten)")
                //print(fileToBeWritten)
            }catch{print(error)}
        }else{print("file already exists")}

    }
    
    
    
    
    let math: MathBrain = MathBrain()
    lazy var problem: (num1: Int, num2: Int, op: String) = (6,9,"M")
    private var time1: NSTimeInterval = 1
    private var time2: NSTimeInterval = 1
    private var iterationsOriginal = 104
    private lazy var iterations = 1
    private var reDo = false //turn this on after all is done
    private let randX: LinearCongruentialGenerator = LinearCongruentialGenerator()
    private var maze: String{
        get{
            let array = ["⏌","⏋","⎾","⏋","⏌","⎯","⏅","⏌","⏋","⎾","⏋","⏌","⎯","⏌","⏋","⎾","⏋","⏌","⎯","⏌","⏋","⎾","⏋","⏌","⎯"]
            var i:Int {get{return (Int(randX.random(array.count)))}}
            return array[i]
        }
    }
    
    @IBOutlet weak var DisplayScreen1: UILabel!
    @IBOutlet weak var DisplayScreen2: UILabel!
    @IBOutlet weak var DisplayScreen3: UILabel!
    @IBOutlet weak var DisplayBottom1: UILabel!
    @IBOutlet weak var DisplayBottom2: UILabel!
    @IBOutlet weak var DisplayBottom3: UILabel!
    @IBOutlet weak var DivisionLabel: UILabel!
    @IBOutlet weak var AdditionLabel: UILabel!
    @IBOutlet weak var MultiplicationLabel: UILabel!
    @IBOutlet weak var SubstractionLabel: UILabel!
    @IBOutlet weak var HitLabel: UILabel!
    @IBAction func NumberButtonTheUserPresses(sender: UIButton) {
        let Digit = sender.currentTitle!
        DisplayScreen2.text? += Digit
    }
    override func viewDidLoad() {
        reDo = false
        iterations = iterationsOriginal //sets the counting reference
        showProgress()
        displayProblem()
        DisplayScreen3.text = ""
        NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "interval", userInfo: nil, repeats: true)
    }
    

    @IBAction func Enter(sender: UIButton){
        var str = ""
        if let txt = DisplayScreen2.text{
            str = txt
            time2 = (NSDate(timeIntervalSinceNow: 1)).timeIntervalSinceReferenceDate
            let time = time2 - time1
            let correct = math.checkAnswer(str, problem: (problem.num1, problem.num2, problem.op, time))
            if correct {DisplayScreen2.text = ""; DisplayScreen3.text = DisplayScreen3.text! + "😃"; displayProblem(); showProgress(); NSTimer.scheduledTimerWithTimeInterval(5, target:self, selector: "pauseThreeCorrect", userInfo: nil, repeats: false)}
            else {
                DisplayBottom3.text = DisplayScreen1.text!
                DisplayScreen1.text = "We'll come back to it"
                NSTimer.scheduledTimerWithTimeInterval(3, target: self, selector: "pauseThree", userInfo: nil, repeats: false)
            }
        }
    }

    
    @IBAction func BackSpace(sender: UIButton) {
        if let txt = DisplayScreen2.text{
            var x = txt
            if x.characters.count > 0 {
                x.removeAtIndex(x.endIndex.predecessor())
            }
            DisplayScreen2.text = x
        }
    }
    @IBAction func OperaterChoiceButton(sender: UIButton) {
        switch sender.currentTitle!{
        case "Div": if DivisionLabel.text != "✔️" {DivisionLabel.text = "✔️"} else {DivisionLabel.text = " "}
        case "Add": if AdditionLabel.text != "✔️" {AdditionLabel.text = "✔️"} else {AdditionLabel.text = " "}
        case "Mul": if MultiplicationLabel.text != "✔️" {MultiplicationLabel.text = "✔️"} else {MultiplicationLabel.text = " "}
        case "Sub": if SubstractionLabel.text != "✔️" {SubstractionLabel.text = "✔️"} else {SubstractionLabel.text = " "}
        default: break
        }
    }
    @IBAction func Neg(sender: UIButton) {
        var sign = ""
        var str = ""
        var x = Array("".characters)
        if let txt = DisplayScreen2.text {
            x = Array(txt.characters)
            if x.count == 0 {sign = "-"}
            if x.count > 0 && x[0] != "-" {
                sign = "-"
            }else{if x.count>0{x.removeAtIndex(0)}}
        }
        for i in x{str += "\(i)"}
        DisplayScreen2.text = sign + str
    }
    func gatherOperations () -> String{
        var dams = ""
        if DivisionLabel.text == "✔️"{dams += "D"}
        if AdditionLabel.text == "✔️"{dams += "A"}
        if MultiplicationLabel.text == "✔️"{dams += "M"}
        if SubstractionLabel.text == "✔️"{dams += "S"}
        if dams == "" {dams = "DAMS"}
        return dams
    }
    
    
    func getOperationSymbol(operation: String) -> String{
        var x = ""
        switch operation{
            case "D": x = "➗"
            case "A": x = "➕"
            case "M": x = "✖️"
            case "S": x = "➖"
        default: x = " Error; Try Again"
        }
        return x
    }
    
    func displayProblem(){
        let operation = gatherOperations()
        problem = math.sendProblem(operation)
        if reDo {problem = math.sendProblem(reDo)} //during reDo, we just get it
        if problem.op == "Done" {congrats(reDo); problem.op = "M"; return} //return is like break // "Done" is just a cheap proxy communication, so get rid of it before it causes problems.
        let opStr = getOperationSymbol(problem.2)
        DisplayScreen1.text = "\(problem.0) \(opStr) \(problem.1)"
        time1 = (NSDate(timeIntervalSinceNow: 1)).timeIntervalSinceReferenceDate
    }
    func showProgress(){
        if reDo {return} //reDo means we are going over old problems.
        var str = ""; var st2 = "";
        let count1 = iterations / 3
        let count2 = (iterationsOriginal - iterations) / 3
        for _ in 0 ... count1 {str += maze}
        for _ in 0 ... count2 {st2 += "🐹"}
        if iterations-- < 1 {congrats(); str = ""; reDo = true}
        DisplayBottom1.text = "🌽" + str + st2
        HitLabel.text = math.reportAdjustStr()
    }
    
    func interval(){
        time2 = (NSDate(timeIntervalSinceNow: 1)).timeIntervalSinceReferenceDate
        let time = time2 - time1
        DisplayBottom2.text = "\(Int(time))"
    }
    
    func pauseThree(){
        DisplayScreen1.text = ""
        DisplayScreen2.text = ""
        //waiting 3 seconds before coming to this func.
        displayProblem()
        
    }
    func pauseTen(){
        DisplayScreen1.text = ""
        DisplayScreen2.text = ""
        DisplayScreen3.text = ""
        //waiting 3 seconds before coming to this func.
        displayProblem()
    }
    //fade off the Singular smilefaces.
    func pauseThreeCorrect(){
        var txt = DisplayScreen3.text!
        if txt.characters.count > 0 {
            txt.removeAtIndex(txt.endIndex.predecessor()) }
        DisplayScreen3.text = txt + ""
    }
    func congrats(){
        DisplayScreen3.text = "WOW WOW WOW! CONGRATS!"
        DisplayScreen2.text = "Your RAT got CORN!! YUM YUM"
        DisplayScreen1.text = "U R the GOD of food!; Need Go Over Old Questions"
        iterations=iterationsOriginal
        NSTimer.scheduledTimerWithTimeInterval(5, target: self, selector: "pauseTen", userInfo: nil, repeats: false)
    }
    func congrats(redo: Bool){
        DisplayScreen3.text = "SuPER!!  CONGRATS!"
        DisplayScreen2.text = "You R truly Done"
        DisplayScreen1.text = "U R the GOD of food!; Reset for More"
        DisplayBottom3.text = "🌽🐹🐹🐹🐹🐹You can show Your MomDad; U R Great! 🌽🐹🐹🐹🐹🐹"
        iterations=iterationsOriginal
        reDo = false
    }

        
    @IBAction func Reset(sender: UIButton) {
        viewDidLoad() //starts all over.
    }
}

