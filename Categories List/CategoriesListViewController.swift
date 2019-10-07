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
                                                   heightDimension: .absolute(65))
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
    
    private lazy var dataSource = UICollectionViewDiffableDataSource<Section, ExpenseCategoryStatsDTO>(
        collectionView: collectionView,
        cellProvider: { (collectionView, indexPath, smth) -> UICollectionViewCell? in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CategoryListCollectionViewCell.nibName,
                                                          for: indexPath)
            guard let categoryListCell = cell as? CategoryListCollectionViewCell else {
                return cell
            }
            categoryListCell.update(for: smth)
            return categoryListCell
        }
    )

    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.setCollectionViewLayout(layout, animated: false)
        collectionView.dataSource = dataSource
        let nib = UINib(nibName: CategoryListCollectionViewCell.nibName, bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: CategoryListCollectionViewCell.nibName)
        collectionView.backgroundColor = UIColor.init(named: "background")
    }

    func update(for categories: [ExpenseCategoryStatsDTO]) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, ExpenseCategoryStatsDTO>.init()
        snapshot.appendSections([.main])
        snapshot.appendItems(categories)
        dataSource.apply(snapshot)
//        dataSource.apply(<#T##snapshot: NSDiffableDataSourceSnapshot<CategoriesListViewController.Section, ExpenseCategoryStatsDTO>##NSDiffableDataSourceSnapshot<CategoriesListViewController.Section, ExpenseCategoryStatsDTO>#>, animatingDifferences: <#T##Bool#>, completion: <#T##(() -> Void)?##(() -> Void)?##() -> Void#>)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.performAnimation()
        }
    }
    
    private func performAnimation() {
        let animator = UIViewPropertyAnimator.init(duration: 0.3, curve: .easeInOut)
        
        collectionView.visibleCells.forEach { cell in
            guard let categoryListCell = cell as? CategoryListCollectionViewCell else {
                return
            }
            categoryListCell.setWidth()
            animator.addAnimations({
                categoryListCell.layoutIfNeeded()
            }, delayFactor: 0.1)
        }
        animator.startAnimation()
    }
    
}
