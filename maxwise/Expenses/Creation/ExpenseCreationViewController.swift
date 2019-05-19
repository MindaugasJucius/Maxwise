import UIKit
import AMTagListView

class ExpenseCreationViewController: UIViewController {

    @IBOutlet private weak var textField: UITextField!
    @IBOutlet private weak var collectionView: UICollectionView!
    
    @IBOutlet private weak var tagListView: AMTagListView!
    private weak var selectedTag: AMTagView?
    
    private let nearbyPlaces: [NearbyPlace]
    private let viewModel: ExpenseCreationViewModel
    
    init(viewModel: ExpenseCreationViewModel) {
        self.nearbyPlaces = viewModel.nearbyPlaces
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .overCurrentContext
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textField.text = viewModel.formattedValue
        configureCollectionView()
        configureTagListView()
    }
    
    private func configureTagListView() {
        viewModel.categories.forEach { category in
            let tagView = AMTagView(frame: .zero)
            tagView.applyDeselectedStyle()
            tagView.categoryID = category.id
            tagView.tagText = category.title as NSString
            tagListView.addTagView(tagView)
        }
        
        tagListView.setTapHandler { [weak self] tagView in
            self?.selectedTag?.applyDeselectedStyle()
            tagView?.applySelectedStyle()
            self?.selectedTag = tagView
        }
        
        tagListView.scrollDirection = .horizontal
    }
    
    private func configureCollectionView() {
        let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout
        flowLayout?.scrollDirection = .horizontal
        flowLayout?.estimatedItemSize = CGSize(width: 150, height: 80)
        collectionView.backgroundColor = .clear
        collectionView.dataSource = self
        collectionView.allowsSelection = true
        let venueCellNib = UINib(nibName: VenueCollectionViewCell.nibName, bundle: nil)
        collectionView.register(venueCellNib,
                                forCellWithReuseIdentifier: VenueCollectionViewCell.nibName)
        collectionView.alwaysBounceHorizontal = true
    }
    
    @IBAction func closeButtonTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

    @IBAction func addExpenseTapped(_ sender: Any) {
        guard let tagView = selectedTag,
            let categoryID = tagView.categoryID else {
            return
        }

        guard let selectedCategory = viewModel.categories.filter({ $0.id == categoryID }).first else {
            return
        }
        
        var selectedPlace: NearbyPlace? = nil
        if let selectedIndexPath = collectionView.indexPathsForSelectedItems?.first {
            selectedPlace = nearbyPlaces[selectedIndexPath.row]
        }
     
        viewModel.performModelCreation(selectedPlace: selectedPlace,
                                       seletedCategory: selectedCategory)
    }
}

extension ExpenseCreationViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return nearbyPlaces.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: VenueCollectionViewCell.nibName,
            for: indexPath
        )
        guard let venueCell = cell as? VenueCollectionViewCell else {
            return cell
        }
        venueCell.update(venue: nearbyPlaces[indexPath.row])
        return venueCell
    }
    
}

extension AMTagView {
    
    var categoryID: String? {
        get {
            return userInfo["id"] as? String
        }
        set {
            userInfo = ["id": newValue as Any]
        }
    }
    
    
    func applySelectedStyle() {
        tagColor = .gray
        innerTagColor = .gray
    }
    
    func applyDeselectedStyle() {
        tagColor = .lightGray
        innerTagColor = .lightGray
    }
    
}
