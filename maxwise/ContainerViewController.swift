import UIKit

enum Screen {
    case expenses
}

protocol PresentationViewControllerDelegate {
    func show(screen: Screen)
}

class ContainerViewController: UIPageViewController {

    private lazy var cameraViewController: CameraViewController = {
        let cameraViewController = CameraViewController()
        cameraViewController.presentationDelegate = self
        return cameraViewController
    }()
    
    private lazy var expensesViewController = ExpensesParentViewController()
    
    private lazy var initialViewControllers = [cameraViewController,
                                               expensesViewController]
    
    init() {
        super.init(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource = self
        setViewControllers([cameraViewController], direction: .forward, animated: false, completion: nil)
    }
    
    
    func presentImagePicker(_ sender: Any) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = false
        picker.sourceType = .photoLibrary
        present(picker, animated: true, completion: nil)
    }
    
}

extension ContainerViewController: UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.originalImage] as? UIImage,
            let cgImage = image.cgImage else {
                return
        }
        
        let orientation = CGImagePropertyOrientation.init(image.imageOrientation)
        let textDetectionController = TextPickViewController(cgImage: cgImage,
                                                             orientation: orientation)
        dismiss(animated: true) { [weak self] in
            self?.present(textDetectionController,
                          animated: true,
                          completion: nil)
        }
        
    }
    
}

extension ContainerViewController: PresentationViewControllerDelegate {
    
    func show(screen: Screen) {
        let controllerToPresent: UIViewController
        switch screen {
        case .expenses:
            controllerToPresent = expensesViewController
        }

        setViewControllers([controllerToPresent],
                           direction: .forward,
                           animated: true,
                           completion: nil)
    }
    
}

extension ContainerViewController: UIPageViewControllerDataSource {
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        let index = initialViewControllers.firstIndex(of: viewController)
        
        guard let currentIndex = index, currentIndex > 0 else {
            return nil
        }
        
        return initialViewControllers[currentIndex - 1]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        let index = initialViewControllers.firstIndex(of: viewController)
        
        guard let currentIndex = index else {
            return nil
        }
        
        let newIndex = currentIndex + 1
        
        guard newIndex < initialViewControllers.count else {
            return nil
        }
        
        return initialViewControllers[newIndex]
    }

}
