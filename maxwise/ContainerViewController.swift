import UIKit

class ContainerViewController: UIPageViewController {

    private let initialViewControllers = [CameraViewController(),
                                          ExpensesParentViewController()]
    
    init() {
        super.init(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource = self
        setViewControllers([initialViewControllers[0]], direction: .forward, animated: false, completion: nil)
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
