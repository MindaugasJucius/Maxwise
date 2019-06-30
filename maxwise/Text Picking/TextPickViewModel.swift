import UIKit

enum Result<Type, Error> {
    case success(Type)
    case error(Error)
}

class TextPickViewModel {
    
    enum RecognitionError: Error {
        case noImage
        case noNumber
        case noRecognizedValue
    }
    
    private let digitRecognizer = DigitRecognizer()
    
    func performRecognition(in image: UIImage?, completion: @escaping (Result<String, RecognitionError>) -> ()) {
        guard let image = image else {
            completion(.error(.noImage))
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
        
    private func convertRecognizedString(value: String?) -> Result<String, RecognitionError> {
        guard let value = value else {
            return .error(.noRecognizedValue)
        }

        let trimmedResult = value.replacingOccurrences(of: " ", with: "")
                                 .trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)

        return .success(trimmedResult)
    }
    
}
