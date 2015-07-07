//
//  ViewController.swift
//  Calculator2
//
//  Created by Haining Wang on 6/23/15.
//  Copyright (c) 2015 usDream. All rights reserved.
//

import UIKit

class ViewController: UIViewController
{
    @IBOutlet weak var display: UILabel! // always automatically unwrapped it.
    
    var userIsInTheMiddleOfTypingANumber = false
    
    var brain = CalculatorBrain()
    
    @IBOutlet weak var historyDisplay: UILabel!
    
    @IBAction func appendDigit(sender: UIButton) {
        // create a local constant variable
        let digit = sender.currentTitle!
        if userIsInTheMiddleOfTypingANumber {
            if digit != "." ||  display.text!.rangeOfString(".") == nil{
                display.text = display.text! + digit
            }
        } else {
            display.text = digit
            userIsInTheMiddleOfTypingANumber = true
        }
    }
    
    @IBAction func operate(sender: UIButton) {
        if userIsInTheMiddleOfTypingANumber {
            enter()
        }
        if let operation = sender.currentTitle{
            let result = brain.performOperation(operation)
            displayValue = result
            historyDisplay.text! = "\(brain)"
           /* if let result = brain.performOperation(operation) {
                displayValue = result
                historyDisplay.text! = "\(brain)"
            } else {
                displayValue = 0
                
            }
            */
        }
    }

    @IBAction func enter() {
        userIsInTheMiddleOfTypingANumber = false
        if displayValue != nil {
            let result = brain.pushOperand(displayValue!)
            displayValue = result
            historyDisplay.text! = "\(brain)"
        }
        /* if let result = brain.pushOperand(displayValue!) {
            displayValue = result
            historyDisplay.text! = brain.history()
        } else {
            displayValue = 0
        }*/
    }
    
    
    @IBAction func clear() {
        brain.reset()
        display.text = "0"
        historyDisplay.text = " "
        
    }
    
    // computed properties
    var displayValue: Double?{
        get {
            return NSNumberFormatter().numberFromString(display.text!)!.doubleValue
        }
        set {
            if newValue != nil {
                display.text = "\(newValue!)"
                userIsInTheMiddleOfTypingANumber = false
            } else {
                display.text = "0"
                historyDisplay.text! = "\(brain)"
            }
        }
    }
    
    @IBAction func setValueM() {
        userIsInTheMiddleOfTypingANumber = false
        let result = brain.setVariableValues(displayValue)
        displayValue = result
        
    }
    @IBAction func appendM(sender: UIButton) {
        if userIsInTheMiddleOfTypingANumber {
            enter()
        }
        if let operation = sender.currentTitle{
            let result = brain.performOperation(operation)
            displayValue = result
            historyDisplay.text! = "\(brain)"
        }
    }
}

