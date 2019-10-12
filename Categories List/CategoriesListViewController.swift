import UIKit
import ExpenseKit

class CategoriesListViewController: UIViewController {
    
    static let backgroundDecorationElementKind = "section-background-element-kind"
    
    @IBOutlet private weak var collectionView: UICollectionView!

    private let viewModel: CategoriesListViewModel
    
    private lazy var layout: UICollectionViewCompositionalLayout = {
        let layout = UICollectionViewCompositionalLayout { (section, environment) -> NSCollectionLayoutSection? in
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                                  heightDimension: .fractionalHeight(1))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                                   heightDimension: .absolute(65))
            let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
            
            let contentInsets = NSDirectionalEdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16)
            
            let section = NSCollectionLayoutSection.init(group: group)
            section.contentInsets = contentInsets
            
            let sectionBackgroundDecoration = NSCollectionLayoutDecorationItem.background(
                elementKind: CategoriesListViewController.backgroundDecorationElementKind
            )
            sectionBackgroundDecoration.contentInsets = contentInsets
            section.decorationItems = [sectionBackgroundDecoration]
            section.orthogonalScrollingBehavior = .paging
            return section
        }
        let configuration = UICollectionViewCompositionalLayoutConfiguration()
        configuration.scrollDirection = .horizontal
        layout.configuration = configuration
        layout.register(
            SectionBackgroundDecorationView.self,
            forDecorationViewOfKind: CategoriesListViewController.backgroundDecorationElementKind
        )
        
        return layout
    }()
    
    private lazy var dataSource = UICollectionViewDiffableDataSource<Date, ExpenseCategoryStatsDTO>(
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
    
    init(viewModel: CategoriesListViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.setCollectionViewLayout(layout, animated: false)
        collectionView.dataSource = dataSource
        collectionView.delegate = self
        let nib = UINib(nibName: CategoryListCollectionViewCell.nibName, bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: CategoryListCollectionViewCell.nibName)
        collectionView.backgroundColor = UIColor.init(named: "background")
        collectionView.isPagingEnabled = true

        viewModel.updateToSnapshot = { [weak self] snapshot in
            guard let self = self else {
                return
            }
            self.dataSource.apply(snapshot)
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
    
    func scroll(to section: Int) {
        let xOffset = collectionView.bounds.width * CGFloat(section)
        let visibleRect = CGRect.init(x: xOffset,
                    y: 0,
                    width: collectionView.bounds.width,
                    height: collectionView.bounds.height)
        collectionView.scrollRectToVisible(visibleRect, animated: true)
        performAnimation()
    }
    
}

extension CategoriesListViewController: UICollectionViewDelegate {
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        guard let visibleItem = collectionView.indexPathsForVisibleItems.first else {
            print("no visible item after category list ended scrolling")
            return
        }

        viewModel.listSelectionChanged(visibleItem.section)
        performAnimation()
    }
    
}
