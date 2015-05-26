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
    
    var decimal = false
    
    var hello = "hello"
    
    var ans = false
    
    var userIsCurrentlyTypingNumber = false
    
    var brain = CalculatorBrain()
    
    @IBAction func appendDigit(sender: UIButton) {
        let digit = sender.currentTitle!
        
        if userIsCurrentlyTypingNumber {
            if (digit != "."){
                display.text = display.text! + digit
            }
            else if (decimal == false){
                display.text = display.text! + "."
                decimal = true
            }
        }
        else {
            if (digit == "."){
                display.text = "0."
                decimal = true
            }
            else{
               display.text = digit
            }
            userIsCurrentlyTypingNumber = true
        }
    }
    
    @IBAction func operate(sender: UIButton) {
        if userIsCurrentlyTypingNumber {
            enter()
        }
        if let operation = sender.currentTitle {
            laggingDisplay.text = laggingDisplay.text! + " " + sender.currentTitle!
            ans = true
            if let result = brain.performOperation(operation) {
                displayValue = result
            }
            else {
                displayValue = 0
            }
        }
    }
   
    @IBAction func enter() {
        userIsCurrentlyTypingNumber = false
        decimal = false
        if let result = brain.pushOperand(displayValue){
            displayValue = result
        }
        else {
            displayValue = 0
        }
    }
    
    @IBAction func Clear(sender: UIButton) {
        brain.clearOpStack()
        userIsCurrentlyTypingNumber = false
        ans = false
        decimal = false
        display.text = "0"
        laggingDisplay.text = " "
    }
    
    var displayValue : Double {
        get {
            return NSNumberFormatter().numberFromString(display.text!)!.doubleValue
        }
        set {
            if (laggingDisplay.text! == " "){
                laggingDisplay.text = "\(newValue)"
            }
            else{
                laggingDisplay.text = laggingDisplay.text! + " " + "\(newValue)"
            }
            if (ans == true){
                display.text = "\(newValue)"
                ans = false
            }
            else{
                display.text = "0"
            }
            userIsCurrentlyTypingNumber = false
        }
    }
}

