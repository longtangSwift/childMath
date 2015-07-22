//
//  MathBrain.swift
//  YiSzenMath
//
//  Created by CT MacBook Pro on 7/19/15.
//  Copyright © 2015 CT MacBook Pro. All rights reserved.
//

import Foundation

class MathBrain{
    private let randX: LinearCongruentialGenerator = LinearCongruentialGenerator()
    private var rand: Int{get {return Int(randX.random(12))+1}}
    private var go: Bool = false
    private var AnsArr = [(num1: Int, num2: Int, op: String, correct: Int, times: [Int])]()
    private var reDoArr = [(num1: Int, num2: Int, op: String)]()
    private var adjustStr = ""
    func formProblem (operations: String)-> (num1: Int, num2: Int, op: String) {
        var opArr = Array(operations.characters)
        var num1: Int = rand
        var num2: Int = rand
        //we don't want these numbers to be 1 more the 27% of the time
        while num1 == 1 && randX.random(100) > 6{num1 = rand}
        while num2 == 1 && randX.random(100) > 4{num2 = rand}
        let index = Int(randX.random(operations.characters.count))
        let op = "\(opArr[index])"
        if op == "D" {num1 *= num2}
        while op == "S" && num1 == num2 {num2 = rand} //make sure we don't get 1-1
        return (num1: num1,    num2: num2,    op: op)
    }
    
    //the formProblem() forms based on No 1's and No 1 / 1, but the send problem looks at a weighted parameter of past wrong questions

    //The viewController will be talking to this one to get the problem
    func sendProblem (operations: String) -> (num1: Int, num2: Int, op: String){
        var i = 0; var num1 = 0; var num2 = 0; var op = ""
        while i++ < 1000{
            let x = formProblem(operations)
            num1 = x.num1
            num2 = x.num2
            op = x.op
            if shouldWeGo(num1, num2: num2, op: op){break}
        }
        return (num1: num1, num2: num2, op: op)
    }
    
    func sendProblem (reDo: Bool) -> (num1: Int, num2: Int, op: String){
        var num1 = 0; var num2 = 0; var op = ""
        let count = reDoArr.count
        if count > 0 {
            let x = reDoArr.removeLast()
            num1 = x.num1; num2 = x.num2; op = x.op
        }else{op = "Done"} //use 'Done' as proxy communication; need immediate receiver and get rid of the "Done" in the tree of data
        return (num1: num1, num2: num2, op: op)
    }
    
    //- looks at if we should go with this problem
    func shouldWeGo(num1: Int, num2: Int, op: String)->Bool{
        let showProbability = 11; //we only have a low chance of showing any one problem
        var adjust1 = 0; var adjust2 = 0
        for i in reDoArr{
            if i.num1 == num1 && i.num2 == num2 && i.op == op {print("Wow! We hit an adjuster!"); adjust1 += 76; adjustStr += "."}
        }
        if num1 != num2 && num2 > 7 && num1 > 6 {adjust2 += 2}
        if randX.random(100) < (showProbability + adjust1 + adjust2) {return true}
        return false
    }
    
    func checkAnswer(userAnswer: String, problem: (num1: Int, num2: Int, op: String, time: Double)) -> Bool{
        var correctTF = false
        var answer = 0
        let userAnsInt = NSNumberFormatter().numberFromString(userAnswer)?.integerValue ?? 99999999
        let num1 = problem.num1; let num2 = problem.num2; let op = problem.op
        switch op{
        case "D": answer = performOperation(num1, num2){$0 / $1}
        case "A": answer = performOperation(num1, num2){$0 + $1}
        case "M": answer = performOperation(num1, num2){$0 * $1}
        case "S": answer = performOperation(num1, num2){$0 - $1}
            default: break
        }
        if userAnsInt == answer {correctTF = true}
        else{reDoArr.append((num1,num2,op)); print("reDo= \(reDoArr)")}
        return correctTF
    }
    func performOperation(n1: Int, _ n2: Int, op: (Int, Int) -> Int) -> Int{
        return op(n1, n2)
    }
    func reportAdjustStr() -> String {return adjustStr}
}
