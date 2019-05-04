import UIKit

class ExpenseCreationViewController: UIViewController {

    @IBOutlet private weak var textField: UITextField!
    @IBOutlet private weak var collectionView: UICollectionView!
    
    private let nearbyPlaces: [NearbyPlace]
    private let viewModel: ExpenseCreationViewModel
    
    init(viewModel: ExpenseCreationViewModel) {
        self.nearbyPlaces = viewModel.nearbyPlaces
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textField.text = viewModel.formattedValue
        
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
        var selectedPlace: NearbyPlace? = nil
        if let selectedIndexPath = collectionView.indexPathsForSelectedItems?.first {
            selectedPlace = nearbyPlaces[selectedIndexPath.row]
        }
     
        viewModel.performModelCreation(selectedPlace: selectedPlace)
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
