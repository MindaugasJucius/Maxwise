import UIKit

enum Screen {
    case expenses
    case expenseCreation(CGImage, CGImagePropertyOrientation, CGPoint)
    case camera
}

protocol PresentationViewControllerDelegate {
    func show(screen: Screen)
}

class ContainerViewController: UIPageViewController {

    //private lazy var cameraViewController = CameraViewController(presentationDelegate: self)
    private lazy var expensesViewController = ExpensesParentViewController()
    private lazy var expenseCreationParentViewController = ExpenseCreationParentViewController()
    
    private lazy var imagePicker: UIImagePickerController = {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = false
        picker.sourceType = .photoLibrary
        return picker
    }()
    
    private lazy var initialViewControllers: [UIViewController] = [expensesViewController]
    
    init() {
        super.init(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        definesPresentationContext = true
        dataSource = self
        setViewControllers(initialViewControllers, direction: .forward, animated: false, completion: nil)
        addNavigationView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let viewModel = ExpenseCreationViewModel(recognizedDouble: 14.0, nearbyPlaces: [])
        let expenseCreationVC = ExpenseCreationViewController(viewModel: viewModel)
        present(expenseCreationVC, animated: false, completion: nil)
    }
    
    private func addNavigationView() {

        let navigationView = NavigationView { [weak self] in
            self?.show(screen: .camera)
        }
        navigationView.move(to: view)
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
        
        dismiss(animated: true) { [weak self] in
            //self?.show(screen: .expenseCreation(cgImage, orientation))
        }
        
    }
    
}

extension ContainerViewController: PresentationViewControllerDelegate {
    
    func show(screen: Screen) {
        switch screen {
        case .expenses:
            setViewControllers([expensesViewController],
                               direction: .forward,
                               animated: true,
                               completion: nil)
        case .expenseCreation(let capturedImage, let orientation, let tapLocation):
            let parentFlowVC = expenseCreationParentViewController.initialFlowViewController(capturedImage: capturedImage,
                                                                                             orientation: orientation,
                                                                                             tapLocation: tapLocation)
            present(parentFlowVC, animated: true, completion: nil)
        case .camera:
            present(expenseCreationParentViewController.showExpenseCreation(), animated: true, completion: nil)

        }
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
