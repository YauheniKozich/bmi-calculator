//
//  ViewController.swift
//  bmi-calculator
//
//  Created by Yauheni Kozich on 19.11.20.
//

import UIKit
import Combine

class ViewController: UIViewController {
    
    private let notificationCenter = NotificationCenter.default
    
    @IBOutlet weak var heightTextField: UITextField!
    @IBOutlet weak var weightTextField: UITextField!
    @IBOutlet weak var resultLabel: UILabel!
    private var subscribers = Set<AnyCancellable>()
    @Published private var height: Double?
    @Published private var weight: Double?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        observeTextField()
    }
    
    private func observeTextField() {
        notificationCenter.publisher(for: UITextField.textDidChangeNotification, object: heightTextField).sink {
            guard let textField = $0.object as? UITextField,
                  let text = textField.text,
                  !text.isEmpty,
                  let height = Double(text) else {
                self.height = nil
                return}
            
            self.height = height
        }.store(in: &subscribers)
        
        notificationCenter.publisher(for: UITextField.textDidChangeNotification, object: weightTextField).sink {
            guard let textField = $0.object as? UITextField,
                  let text = textField.text,
                  !text.isEmpty,
                  let weight = Double(text) else {
                self.weight = nil
                return}
            
            self.weight = weight
        }.store(in: &subscribers)
        Publishers.CombineLatest($weight, $height).sink { [weak self] (weight, height) in
            guard let this = self else {return}
            guard let weight = weight, let height = height else {
                this.resultLabel.text = ""
                return}
            let result = this.calculateBMI(weight: weight, height: height)
            
            switch result {
            case 10...16:
                this.resultLabel.text = "Выраженный дефицит массы тела"
            case 16...18.5:
                this.resultLabel.text = "Недостаточная масса тела"
            case 18.5...25:
                this.resultLabel.text = "Норма"
            case 25...30:
                this.resultLabel.text = "Избыточная масса тела"
            case 30...35:
                this.resultLabel.text = "Ожирение"
            case 35...40:
                this.resultLabel.text = "Ожирение резкое"
            case 40:
                this.resultLabel.text = "Очень резкое ожирение"
            default:
                this.resultLabel.text = "Не верные данные"
            }
            
        }.store(in: &subscribers)
    }
    
    private func calculateBMI(weight: Double ,height: Double) -> Double {
        return weight / (height*2)
    }
    
}

