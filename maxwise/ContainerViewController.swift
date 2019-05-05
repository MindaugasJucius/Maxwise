import UIKit

enum Screen {
    case expenses
    case imageAnalysis(CGImage, CGImagePropertyOrientation)
    case expenseCreation(Double, UIImage)
}

protocol PresentationViewControllerDelegate {
    func show(screen: Screen)
}

class ContainerViewController: UIPageViewController {

    private lazy var cameraViewController = CameraViewController(presentationDelegate: self)
    private lazy var expensesViewController = ExpensesParentViewController()

    private lazy var imagePicker: UIImagePickerController = {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = false
        picker.sourceType = .photoLibrary
        return picker
    }()
    
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
        addNavigationView()
    }
    
    private func addNavigationView() {
        let navigationView = NavigationView(
            leftButtonTapped: { [unowned self] in
                self.present(self.imagePicker, animated: true, completion: nil)
            },
            rightButtonTapped: { [unowned self] in
                self.show(screen: .expenses)
            }
        )
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
        let textDetectionController = TextPickViewController(cgImage: cgImage,
                                                             orientation: orientation,
                                                             presentationDelegate: self)
        dismiss(animated: true) { [weak self] in
            self?.present(textDetectionController,
                          animated: true,
                          completion: nil)
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
        case .imageAnalysis(let cgImage, let orientation):
            let textDetectionController = TextPickViewController(cgImage: cgImage,
                                                                 orientation: orientation,
                                                                 presentationDelegate: self)
            present(textDetectionController, animated: true, completion: nil)
        case .expenseCreation(let recognizedDouble, let image):
            let icon = Icon.init(iconPrefix: "d", suffix: "d")
            let category = Category.init(id: "sd",
                                         name: "weu",
                                         pluralName: "weus",
                                         shortName: "w",
                                         icon: icon,
                                         primary: true)
            let location = Location.init(address: nil, lat: nil, lng: nil, labeledLatLngs: nil, distance: nil, postalCode: nil, cc: nil, city: nil, state: nil, country: nil, formattedAddress: nil)
            let venue1 = Venue(id: "1", name: "Donky donk", location: location, categories: [category], verified: true, referralID: "d", hasPerk: false)
            let venue2 = Venue(id: "2", name: "Donky donkdonk", location: location, categories: [category], verified: true, referralID: "d", hasPerk: false)
            let venue3 = Venue(id: "2", name: "Donky donkdonkdonkdonk", location: location, categories: [category], verified: true, referralID: "d", hasPerk: false)
            let testVenues: [Venue] = [venue1, venue2, venue3]

            let viewModel = ExpenseCreationViewModel(recognizedDouble: recognizedDouble,
                                                     image: image,
                                                     nearbyPlaces: testVenues.map(NearbyPlace.init))

            let expenseCreationViewController = ExpenseCreationViewController(viewModel: viewModel)
            presentedViewController?.present(expenseCreationViewController, animated: true, completion: nil)
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
