//
//  SettingsItemView.swift
//  CardManagementSDKSwiftSample
//
//  Created by Aleksei Kiselev on 17.11.2023.
//

import UIKit

class SettingsItemView: UIView {
    let label = UILabel()
    let textField = UITextField()
    private let handler: ((String?) -> Void)?
    
    required init(title: String, value: String?, handler: ((String?) -> Void)? = nil) {
        self.handler = handler
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        
        let stack = UIStackView()
        addSubview(stack)
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.spacing = 8
        stack.alignment = .center
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: self.topAnchor),
            stack.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            stack.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: self.trailingAnchor),
        ])
        
        stack.addArrangedSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = title
        label.numberOfLines = 0
        label.widthAnchor.constraint(equalTo: stack.widthAnchor, multiplier: 0.3).isActive = true
        label.setContentCompressionResistancePriority(.required, for: .horizontal)
        
        stack.addArrangedSubview(textField)
        textField.borderStyle = .roundedRect
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.delegate = self
        textField.placeholder = title
        textField.text = value
        textField.heightAnchor.constraint(equalToConstant: 32).isActive = true
    }
    
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension SettingsItemView: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let text = textField.text, let textRange = Range(range, in: text) {
            let updatedText = text.replacingCharacters(in: textRange, with: string)
            handler?(updatedText)
        } else {
            handler?(string)
        }
        return true
    }
}
