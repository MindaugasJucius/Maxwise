import UIKit

class CategoriesParentViewController: UINavigationController {

    lazy var createCategoryButton: UIButton = {
        let button = UIButton.init(type: .system)
        let image = UIImage(systemName: "plus.circle.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 25))
        button.setImage(image, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationBar.prefersLargeTitles = true
        viewControllers = [CategoriesStatisticsViewController()]
        navigationBar.addSubview(createCategoryButton)
        let constraints = [
            navigationBar.rightAnchor.constraint(equalTo: createCategoryButton.rightAnchor, constant: 25),
            navigationBar.bottomAnchor.constraint(equalTo: createCategoryButton.bottomAnchor, constant: 10),
            createCategoryButton.widthAnchor.constraint(equalToConstant: 35),
            createCategoryButton.heightAnchor.constraint(equalTo: createCategoryButton.widthAnchor)
        ]
        NSLayoutConstraint.activate(constraints)
    }
    
}
