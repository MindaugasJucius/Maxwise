import UIKit

extension UIViewController {
    func showAlert(for alert: String) {
        let alertController = UIAlertController(title: nil, message: alert, preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(alertAction)
        present(alertController, animated: true, completion: nil)
    }
    
    func showAlert(title: String,
                   message: String,
                   ok: @escaping (UIAlertAction) -> (),
                   cancel: @escaping (UIAlertAction) -> ()) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAlertAction = UIAlertAction(title: "OK", style: .default, handler: ok)
        let cancelAlertAction = UIAlertAction(title: "Cancel", style: .cancel, handler: cancel)
        alertController.addAction(okAlertAction)
        alertController.addAction(cancelAlertAction)
        present(alertController, animated: true, completion: nil)
    }
}
