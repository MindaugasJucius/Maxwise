import UIKit
import ExpenseKit

class ExpenseCategorySelectionViewController: UIViewController {

    enum Section {
        case addCategory
        case storedCategories
        
        enum Item: Hashable {
            case category(ExpenseCategory)
            case addCategory
        }
    }
    
    private let selectionFeedback = UISelectionFeedbackGenerator()
    
    @IBOutlet weak var tableView: UITableView!
    
    private let categorySelected: (ExpenseCategory) -> ()

    private var currentSnapshot: NSDiffableDataSourceSnapshot<Section, Section.Item>?
    private let categoryModelController = ExpenseCategoryModelController()
    
    private lazy var dataSource: UITableViewDiffableDataSource<Section, Section.Item> = {
        return UITableViewDiffableDataSource(tableView: tableView) { [weak self] (tableView, indexPath, item) -> UITableViewCell? in
            guard let self = self else {
                return nil
            }
  
            switch item {
            case .category(let category):
                return self.configureCategoryCell(
                    indexPath: indexPath,
                    tableView: tableView,
                    category: category
                )
            case .addCategory:
                return self.configureAddCategoryCell(
                    indexPath: indexPath,
                    tableView: tableView
                )
            }
        }
    }()
    
    init(categorySelected: @escaping (ExpenseCategory) -> ()) {
        self.categorySelected = categorySelected
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Expense categories"
        view.backgroundColor = UIColor.init(named: "background")
        configureTableView()
        dataSource.defaultRowAnimation = .fade
        
        categoryModelController.observeStoredExpenseCategories { [weak self] newStoredCategories in
            var snapshot = NSDiffableDataSourceSnapshot<Section, Section.Item>()
            snapshot.appendSections([.storedCategories])
            snapshot.appendItems(newStoredCategories.map { Section.Item.category($0) })
            snapshot.appendSections([.addCategory])
            snapshot.appendItems([.addCategory])
            self?.currentSnapshot = snapshot
            self?.dataSource.apply(snapshot)
        }
    }

    private func configureTableView() {
        let createCategoryCellNib = UINib.init(nibName: AddNewCategoryTableViewCell.nibName, bundle: nil)
        tableView.register(createCategoryCellNib, forCellReuseIdentifier: AddNewCategoryTableViewCell.nibName)
        let categoryCellNib = UINib.init(nibName: ExpenseCategoryTableViewCell.nibName, bundle: nil)
        tableView.register(categoryCellNib, forCellReuseIdentifier: ExpenseCategoryTableViewCell.nibName)
        tableView.rowHeight = 66
        tableView.dataSource = dataSource
        tableView.backgroundColor = .clear
        tableView.delegate = self
    }

    private func configureCategoryCell(indexPath: IndexPath, tableView: UITableView, category: ExpenseCategory) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ExpenseCategoryTableViewCell.nibName, for: indexPath)
        guard let expenseCategoryCell = cell as? ExpenseCategoryTableViewCell else {
            return cell
        }

        expenseCategoryCell.configure(category: category)
        return expenseCategoryCell
    }
    
    private func configureAddCategoryCell(indexPath: IndexPath, tableView: UITableView) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: AddNewCategoryTableViewCell.nibName, for: indexPath)
        guard let addCategoryCell = cell as? AddNewCategoryTableViewCell else {
            return cell
        }
        return addCategoryCell
    }
    
}

extension ExpenseCategorySelectionViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let snapshot = currentSnapshot else {
            return
        }
        switch snapshot.sectionIdentifiers[indexPath.section] {
        case .addCategory:
            let categoryCreationVC = CategoryCreationViewController(category: ExpenseCategory())
            present(categoryCreationVC, animated: true, completion: nil)
        case .storedCategories:
            let sectionItem = snapshot.itemIdentifiers(inSection: .storedCategories)[indexPath.row]
            switch sectionItem {
            case .addCategory:
                fatalError()
                // Never gonna happen
            case .category(let category):
                categorySelected(category)
                dismiss(animated: true, completion: nil)
            }
        }
        
        selectionFeedback.selectionChanged()
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}
