//
//  EmojiTextField.swift
//  maxwise
//
//  Created by Mindaugas Jucius on 9/8/19.
//  Copyright © 2019 Mindaugas Jucius. All rights reserved.
//

import UIKit

class EmojiTextField: UITextField {

    override var textInputMode: UITextInputMode? {
        for mode in UITextInputMode.activeInputModes {
            if mode.primaryLanguage == "emoji" {
                return mode
            }
        }
        return nil
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        delegate = self
    }
    
}

extension EmojiTextField: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let trimmed = string.trimmingCharacters(in: .whitespacesAndNewlines)
        if let firstChar = trimmed.first {
            textField.text = String(firstChar)
        } else {
            textField.text = ""
        }
        return false
    }
    
}
