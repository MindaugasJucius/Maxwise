import UIKit

enum RecognitionResult {
    case success(Double)
    case error
}

class TextPickViewModel {
    
    private let digitRecognizer = DigitRecognizer()
    
    private lazy var formatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.locale = Locale.current
        formatter.numberStyle = .decimal
        return formatter
    }()
    
    func performRecognition(in image: UIImage?, completion: @escaping (RecognitionResult) -> ()) {
        guard let image = image else {
            completion(.error)
            return
        }
        
        digitRecognizer.recognize(image: image) { [weak self] result in
            guard let self = self else {
                return
            }
            print("Full recognition string: \(String(describing: result))")
            completion(self.convertRecognizedString(value: result))
        }
    }
    
    private func convertRecognizedString(value: String?) -> RecognitionResult {
        guard let value = value else {
            return .error
        }

        let trimmedResult = value.replacingOccurrences(of: " ", with: "")
                                 .trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        
        guard let doubleValue = formatter.number(from: trimmedResult)?.doubleValue else {
            return .error
        }
        
        return .success(doubleValue)
    }
    
}
