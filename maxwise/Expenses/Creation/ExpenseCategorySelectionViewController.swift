import UIKit
import ExpenseKit

class ExpenseCategorySelectionViewController: UIViewController {

    private let selectionFeedback = UISelectionFeedbackGenerator()
    
    @IBOutlet weak var tableView: UITableView!
    
    private let categorySelected: (ExpenseCategory) -> ()
    
    private var currentCategories: [ExpenseCategory] = []
    private let categoryModelController = ExpenseCategoryModelController()
    
    private lazy var dataSource: UITableViewDiffableDataSource<String, ExpenseCategory> = {
        return UITableViewDiffableDataSource(tableView: tableView) { [weak self] (tableView, indexPath, category) -> UITableViewCell? in
            guard let self = self else {
                return nil
            }
            
            let cell = tableView.dequeueReusableCell(withIdentifier: ExpenseCategoryTableViewCell.nibName, for: indexPath)
            guard let expenseCategoryCell = cell as? ExpenseCategoryTableViewCell else {
                return cell
            }
            expenseCategoryCell.configure(category: self.currentCategories[indexPath.row])
            return expenseCategoryCell
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
            self?.currentCategories = newStoredCategories
            var snapshot = NSDiffableDataSourceSnapshot<String, ExpenseCategory>()
            snapshot.appendSections([""])
            snapshot.appendItems(newStoredCategories)
            self?.dataSource.apply(snapshot)
        }
    }

    func configureTableView() {
        let cellNib = UINib.init(nibName: ExpenseCategoryTableViewCell.nibName, bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: ExpenseCategoryTableViewCell.nibName)
        tableView.rowHeight = 65
        tableView.dataSource = dataSource
        tableView.backgroundColor = .clear
        tableView.delegate = self
    }

}

extension ExpenseCategorySelectionViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedCategory = currentCategories[indexPath.row]
        categorySelected(selectedCategory)
        selectionFeedback.selectionChanged()
        dismiss(animated: true, completion: nil)
    }
    
}
