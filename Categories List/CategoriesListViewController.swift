import UIKit
import ExpenseKit

class CategoriesListViewController: UIViewController {
    
    static let backgroundDecorationElementKind = "section-background-element-kind"
    
    @IBOutlet private weak var collectionView: UICollectionView!

    enum Section {
        case main
    }
    
    private lazy var layout: UICollectionViewCompositionalLayout = {
        let layout = UICollectionViewCompositionalLayout { (section, environment) -> NSCollectionLayoutSection? in
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                                  heightDimension: .fractionalHeight(1))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                                   heightDimension: .absolute(50))
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
            
            let contentInsets = NSDirectionalEdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16)
            
            let section = NSCollectionLayoutSection.init(group: group)
            section.contentInsets = contentInsets
            
            let sectionBackgroundDecoration = NSCollectionLayoutDecorationItem.background(
                elementKind: CategoriesListViewController.backgroundDecorationElementKind
            )
            sectionBackgroundDecoration.contentInsets = contentInsets
            section.decorationItems = [sectionBackgroundDecoration]

            return section
        }

        layout.register(
            SectionBackgroundDecorationView.self,
            forDecorationViewOfKind: CategoriesListViewController.backgroundDecorationElementKind
        )
        
        return layout
    }()
    
    private lazy var dataSource = UICollectionViewDiffableDataSource<Section, Int>(
        collectionView: collectionView,
        cellProvider: { (collectionView, indexPath, smth) -> UICollectionViewCell? in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
            cell.backgroundColor = .blue
            return cell
        }
    )

    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.setCollectionViewLayout(layout, animated: false)
        collectionView.dataSource = dataSource
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        var snapshot = NSDiffableDataSourceSnapshot<Section, Int>.init()
        snapshot.appendSections([.main])
        snapshot.appendItems(Array(0...10))
        dataSource.apply(snapshot)
    }

    func update(for categories: [ExpenseCategory]) {
        
    }
    
}
