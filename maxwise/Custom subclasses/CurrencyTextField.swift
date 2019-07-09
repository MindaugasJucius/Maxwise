import UIKit

class CurrencyTextField: UITextField {
    private static let maxDigitCount = 15
 
    private lazy var currencyFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.locale = Locale.current
        formatter.numberStyle = .currency
        return formatter
    }()

    var value: Double {
        get {
            return input()
        }
        set(newVal) {
            text = currencyFormatter.string(from: NSNumber(value: newVal))
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        addTarget(self, action: #selector(editingChanged), for: .editingChanged)
        keyboardType = .numberPad
        textAlignment = .left
        editingChanged()
    }
    
    @objc func editingChanged() {
        value = input()
    }

    private func input() -> Double {
        let sanitizedText = sanitized(input: text)

        guard let doubleValue = Double(sanitizedText.prefix(CurrencyTextField.maxDigitCount)) else {
            return 0.0
        }
        
        let divider = pow(Double(10), Double(currencyFormatter.maximumFractionDigits))
        text = currencyFormatter.string(from: (doubleValue / divider) as NSNumber)
        let divided = doubleValue / divider
        return divided
    }
    
    private func sanitized(input: String?) -> String {
        let characterSet = CharacterSet(charactersIn: "0123456789")
        if let unwrapped = input, !unwrapped.isEmpty {
            return unwrapped.components(separatedBy: characterSet.inverted).joined()
        } else {
            return "0"
        }
    }

}
