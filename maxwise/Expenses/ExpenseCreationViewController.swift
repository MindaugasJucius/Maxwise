import UIKit

class ExpenseCreationViewController: UIViewController {

    @IBOutlet private weak var textField: UITextField!
    @IBOutlet private weak var collectionView: UICollectionView!
    
    private let venues: [Venue]
    private var recognizedText: String
    
    init(recognizedText: String, venues: [Venue]) {
        self.venues = venues
        self.recognizedText = recognizedText
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textField.text = recognizedText
        
        let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout
        flowLayout?.scrollDirection = .horizontal
        flowLayout?.estimatedItemSize = CGSize(width: 150, height: 80)
        collectionView.backgroundColor = .clear
        collectionView.dataSource = self
        let venueCellNib = UINib(nibName: VenueCollectionViewCell.nibName, bundle: nil)
        collectionView.register(venueCellNib,
                                forCellWithReuseIdentifier: VenueCollectionViewCell.nibName)
    }

}

extension ExpenseCreationViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return venues.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: VenueCollectionViewCell.nibName,
            for: indexPath
        )
        guard let venueCell = cell as? VenueCollectionViewCell else {
            return cell
        }
        venueCell.update(venue: venues[indexPath.row])
        return venueCell
    }
    
}
