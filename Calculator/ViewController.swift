//
//  ViewController.swift
//  Calculator
//
//  Created by Mario Youssef on 2015-03-27.
//  Copyright (c) 2015 Mario Youssef. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var display: UILabel!

    @IBOutlet weak var laggingDisplay: UILabel!
    
    var userIsCurrentlyTypingNumber = false
    
    var brain = CalculatorBrain()
    
    @IBAction func appendDigit(sender: UIButton) {
        let digit = sender.currentTitle!
        
        if userIsCurrentlyTypingNumber {
            if (digit == "." && display.text!.rangeOfString(".") != nil) { return }
            else if (digit == "0" && display.text == "0") { return }
            else if (digit != "." && display.text == "0") {
                display.text = digit
            }
            else {
                display.text = display.text! + digit
            }
        }
        else {
            if (digit == "."){
                display.text = "0."
            }
            else{
                display.text = digit
            }
            userIsCurrentlyTypingNumber = true
            laggingDisplay.text = brain.description != "?" ? brain.description : ""
        }
    }
    
    @IBAction func operate(sender: UIButton) {
        if userIsCurrentlyTypingNumber {
            enter()
        }
        if let operation = sender.currentTitle {
            if let result = brain.performOperation(operation) {
                displayValue = result
            }
            else {
                displayValue = nil
                Clear()
            }
        }
    }
   
    @IBAction func enter() {
        userIsCurrentlyTypingNumber = false
        if let result = brain.pushOperand(displayValue!){
            displayValue = result
        }
        else {
            displayValue = nil
            Clear()
        }
    }
    
    @IBAction func Clear() {
        brain = CalculatorBrain()
        userIsCurrentlyTypingNumber = false
        displayValue = nil
        display.text = "0"
        laggingDisplay.text = ""
    }
    
    var displayValue : Double? {
        get {
            if let displayText = display.text{
                if let displayNumber = NSNumberFormatter().numberFromString(displayText) {
                    return displayNumber.doubleValue
                }
            }
            return nil
        }
        set {
            if (newValue != nil){
                display.text = "\(newValue!)"
            }
            else{
                display.text = "0"
            }
            userIsCurrentlyTypingNumber = false
            laggingDisplay.text = brain.description + "="
        }
    }
}

