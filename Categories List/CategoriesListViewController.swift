import UIKit
import ExpenseKit

class CategoriesListViewController: UIViewController {
    
    static let backgroundDecorationElementKind = "section-background-element-kind"
    
    @IBOutlet private weak var collectionView: UICollectionView!

    private let viewModel: CategoriesListViewModel
    
    private let choseToDeleteCategory: (String) -> ()
    private let choseToEditCategory: (String) -> ()
    private let choseToViewExpensesForCategory: (ExpenseCategoryStatsDTO, Date) -> ()
    
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
            section.orthogonalScrollingBehavior = .paging
            return section
        }
        let configuration = UICollectionViewCompositionalLayoutConfiguration()
        configuration.scrollDirection = .horizontal
        layout.configuration = configuration
        
        return layout
    }()
    
    private lazy var dataSource = UICollectionViewDiffableDataSource<Date, ExpenseCategoryStatsDTO>(
        collectionView: collectionView,
        cellProvider: { [weak self] (collectionView, indexPath, categoryDTO) -> UICollectionViewCell? in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CategoryListCollectionViewCell.nibName,
                                                          for: indexPath)
            guard let categoryListCell = cell as? CategoryListCollectionViewCell else {
                return cell
            }
            categoryListCell.update(for: categoryDTO)
            
            guard let sectionIdentifier = self?.viewModel.currentSnapshot?.sectionIdentifiers[indexPath.section],
                let itemsInSection = self?.viewModel.currentSnapshot?.numberOfItems(inSection: sectionIdentifier) else {
                return categoryListCell
            }
                
            let isLastCell = indexPath.item + 1 == itemsInSection
            
            if itemsInSection == 1 {
                categoryListCell.roundEverything()
            } else if isLastCell {
                categoryListCell.roundBottom()
            } else if indexPath.item == 0 {
                categoryListCell.roundTop()
            }
            return categoryListCell
        }
    )
    
    init(viewModel: CategoriesListViewModel,
         choseToViewExpensesForCategory: @escaping (ExpenseCategoryStatsDTO, Date) -> (),
         choseToEditCategory: @escaping (String) -> (),
         choseToDeleteCategory: @escaping (String) -> ()) {
        self.viewModel = viewModel
        self.choseToViewExpensesForCategory = choseToViewExpensesForCategory
        self.choseToDeleteCategory = choseToDeleteCategory
        self.choseToEditCategory = choseToEditCategory
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
        collectionView.allowsSelection = true

        viewModel.shouldHighlightCell = { [weak self] dto in
            self?.highlight(cellDTO: dto)
        }
        
        viewModel.shouldScrollToSection = { [weak self] index in
            self?.scroll(to: index, animated: true)
        }
        
        viewModel.updateToSnapshot = { [weak self] snapshot, index in
            guard let self = self else {
                return
            }
            let firstTimeApplyingSnapshot = self.viewModel.currentSnapshot == nil
            self.viewModel.currentSnapshot = snapshot
            self.dataSource.apply(snapshot, animatingDifferences: !firstTimeApplyingSnapshot) { [weak self] in
                if let newSelectionIndex = index {
                    self?.scroll(to: newSelectionIndex, animated: false)
                }
            }

        }
    }
    
    private func highlight(cellDTO: ExpenseCategoryStatsDTO) {
        guard let indexPath = dataSource.indexPath(for: cellDTO) else {
            return
        }

        self.collectionView.scrollToItem(at: indexPath, at: .centeredVertically, animated: false)

        guard let categoryListCell = self.collectionView.cellForItem(at: indexPath) as? CategoryListCollectionViewCell else {
            return
        }
        categoryListCell.highlightCell()
    }
        
    private func performAnimation() {
        let animator = UIViewPropertyAnimator(duration: 0.3, curve: .easeInOut)

        collectionView.visibleCells.forEach { cell in
            guard let categoryListCell = cell as? CategoryListCollectionViewCell else {
                return
            }

            categoryListCell.setWidth()
            animator.addAnimations({
                categoryListCell.layoutIfNeeded()
            }, delayFactor: 0.3)
        }
        animator.startAnimation(afterDelay: 0.2)
    }
    
    private func scroll(to section: Int, animated: Bool) {
        let xOffset = collectionView.bounds.width * CGFloat(section)
        let visibleRect = CGRect.init(x: xOffset,
                    y: 0,
                    width: collectionView.bounds.width,
                    height: collectionView.bounds.height)
        collectionView.scrollRectToVisible(visibleRect, animated: animated)
        performAnimation()
    }
    
}

extension CategoriesListViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let categoryStatsDTO = dataSource.itemIdentifier(for: indexPath),
            let sectionIdentifier = viewModel.currentSnapshot?.sectionIdentifier(containingItem: categoryStatsDTO) else {
            return
        }
                
        choseToViewExpensesForCategory(categoryStatsDTO, sectionIdentifier)
    }
    
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        guard let visibleItem = collectionView.indexPathsForVisibleItems.first else {
            print("no visible item after category list ended scrolling")
            return
        }

        viewModel.listSectionSelectionChanged(visibleItem.section)
        performAnimation()
    }

    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        return UIContextMenuConfiguration(identifier: indexPath as NSIndexPath, previewProvider: nil) { [weak self] suggestedActions in

            guard let categoryStatsDTO = self?.dataSource.itemIdentifier(for: indexPath) else {
                return nil
            }
            
            let edit = UIAction(title: "Edit category", image: UIImage(systemName: "square.and.pencil")) { action in
                self?.choseToEditCategory(categoryStatsDTO.categoryID)
            }
            
            let delete = UIAction(title: "Remove category", image: UIImage(systemName: "trash"), attributes: .destructive) { action in
                self?.choseToDeleteCategory(categoryStatsDTO.categoryID)
            }
            
            return UIMenu(title: "", children: [edit, delete])
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, previewForHighlightingContextMenuWithConfiguration configuration: UIContextMenuConfiguration) -> UITargetedPreview? {
        return targetedPreview(for: configuration)
    }
    
    func collectionView(_ collectionView: UICollectionView, previewForDismissingContextMenuWithConfiguration configuration: UIContextMenuConfiguration) -> UITargetedPreview? {
        return targetedPreview(for: configuration)
    }
    
    func targetedPreview(for configuration: UIContextMenuConfiguration) -> UITargetedPreview? {
        guard let indexPath = configuration.identifier as? IndexPath else {
            return nil
        }

        guard let categoryListCell = collectionView.cellForItem(at: indexPath) as? CategoryListCollectionViewCell else {
            return nil
        }

        let parameters = UIPreviewParameters.init()
        parameters.backgroundColor = .clear
        
        let preview = UITargetedPreview.init(view: categoryListCell.targetedPreviewView, parameters: parameters)
        return preview
    }
    
}
