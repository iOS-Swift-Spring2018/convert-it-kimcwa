//
//  ViewController.swift
//  ConvertIt
//
//  Created by Bryan Kim on 3/1/18.
//  Copyright © 2018 Bryan Kim. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    struct Formula {
        var conversionString: String
        var formula: (Double) -> Double
    }
    
    @IBOutlet weak var userInput: UITextField!
    @IBOutlet weak var fromUnitsLabel: UILabel!
    @IBOutlet weak var resultLabel: UILabel!
    @IBOutlet weak var formulaPicker: UIPickerView!
    @IBOutlet weak var decimalSegmentControl: UISegmentedControl!
    @IBOutlet weak var signSegment: UISegmentedControl!
    
    
    
    let formulasArray = [Formula(conversionString: "miles to kilometers", formula: {$0 / 0.62137}), // $0 represents inputValue
                        Formula(conversionString: "kilometers to miles", formula: {$0 * 0.62137}),
                        Formula(conversionString: "feet to meters", formula: {$0 / 3.2808}),
                        Formula(conversionString: "yards to meters", formula: {$0 / 1.0936}),
                        Formula(conversionString: "meters to feet", formula: {$0 * 3.2808}),
                        Formula(conversionString: "meters to yards", formula: {$0 * 1.0936}),
                        Formula(conversionString: "inches to cm", formula: {$0 / 0.3937}),
                        Formula(conversionString: "cm to inches", formula: {$0 * 0.3937}),
                        Formula(conversionString: "fahrenheit to celsius", formula: {($0 - 32) * (5/9)}),
                        Formula(conversionString: "celsius to fahrenheit", formula: {($0 * (9/5)) + (32)}),
                        Formula(conversionString: "quarts to liters", formula: {$0 / 1.05669}),
                        Formula(conversionString: "liters to quarts", formula: {$0 * 1.05669})
                         ]

    var fromUnits = ""
    var toUnits = ""
    var conversionString = ""
    
    //MARK:- class methods
    override func viewDidLoad() {
        super.viewDidLoad()
        formulaPicker.dataSource = self
        formulaPicker.delegate = self
        conversionString = formulasArray[formulaPicker.selectedRow(inComponent: 0)].conversionString // this line makes sure at the very beginning the first conversion works without having to move the picker. Because at the very beginning, we have not chosen a formulasArray[row]. THis code gets the first one it's on.
        userInput.becomeFirstResponder()
        signSegment.isHidden = true
    }
    
    func calculateConversion() {
        guard let inputValue = Double(userInput.text!) else {
            if userInput.text != "" {
                showAlert(title: "Cannot Convert Value", message: "\(userInput.text!) is not a valid number.")
            }
            return
        }
         var outputValue = formulasArray[formulaPicker.selectedRow(inComponent: 0)].formula(inputValue)
        
//        switch conversionString {
//        case "miles to kilometers":
//            outputValue = inputValue / 0.62137
//        case "kilometers to miles":
//            outputValue = inputValue * 0.62137
//        case "feet to meters":
//            outputValue = inputValue / 3.2808
//        case "yards to meters":
//            outputValue = inputValue / 1.0936
//        case"meters to feet":
//            outputValue = inputValue * 3.2808
//        case "meters to yards":
//            outputValue = inputValue * 1.0936
//        case "inches to cm":
//            outputValue = inputValue / 0.3937
//        case"cm to inches":
//            outputValue = inputValue * 0.3937
//        case"fahrenheit to celsius":
//            outputValue = (inputValue - 32) * (5/9)
//        case"celsius to fahrenheit":
//            outputValue = (inputValue * (9/5)) + (32)
//        case"quarts to liters":
//            outputValue = inputValue / 1.05669
//        case"liters to quarts":
//            outputValue = inputValue * 1.05669
//        default:
//            showAlert(title: "Unexpected Error", message: "Notify Developer that \"\(conversionString)\" could not be identified")
//        }
        
        let formatString = (decimalSegmentControl.selectedSegmentIndex < decimalSegmentControl.numberOfSegments - 1 ? "%.\(decimalSegmentControl.selectedSegmentIndex+1)f" : "%f")
        let outputString = String(format: formatString, outputValue)
            resultLabel.text = "\(inputValue) \(fromUnits) = \(outputString) \(toUnits)"
    }
    
    func showAlert(title: String, message: String) {
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(defaultAction)
        present(alertController, animated: true, completion: nil)
    }
    
    //MARK:- IBActions
    
    @IBAction func userInputChanged(_ sender: UITextField) {
        resultLabel.text = ""
        if userInput.text?.first == "-" {
            signSegment.selectedSegmentIndex = 1
        } else {
            signSegment.selectedSegmentIndex = 0
        }
    }
    
    @IBAction func convertButtonPressed(_ sender: UIButton) {
        calculateConversion()
    }
    
    @IBAction func decimalSelected(_ sender: UISegmentedControl) {
        calculateConversion()
    }
    
    @IBAction func signSegmentSelected(_ sender: UISegmentedControl) {
        if signSegment.selectedSegmentIndex == 0 {
            userInput.text = userInput.text?.replacingOccurrences(of: "-", with: "")
        } else {
            userInput.text = "-" + userInput.text!
        }
        if userInput.text != "-" {
            calculateConversion()
        }
    }
    
}

//MARK:- pickerView Extension
extension ViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int { // number of columns. There is only one column for ours
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int { // number of rows, or number of elements in array
        return formulasArray.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return formulasArray[row].conversionString
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        conversionString = formulasArray[row].conversionString
        
        if conversionString.lowercased().contains("celsius".lowercased()) {
            signSegment.isHidden = false
        } else {
            signSegment.isHidden = true
            userInput.text = userInput.text?.replacingOccurrences(of: "-", with: "") // if the last output value had a negative value, we are resetting it here.
            signSegment.selectedSegmentIndex = 0
        }
        
        let unitsArray = formulasArray[row].conversionString.components(separatedBy: " to ")
        fromUnits = unitsArray[0] //  unit in row that converting from (first one)
        toUnits = unitsArray[1] // unit in row that converting to (second one)
        fromUnitsLabel.text = fromUnits
        calculateConversion()
    }
    
}
