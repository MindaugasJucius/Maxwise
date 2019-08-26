import UIKit
import ExpenseKit

class ExpenseCategorySelectionViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    private let categories: [ExpenseCategory]
    private let categorySelected: (ExpenseCategory) -> ()
    
    private lazy var dataSource: UITableViewDiffableDataSource<String, ExpenseCategory> = {
        return UITableViewDiffableDataSource(tableView: tableView) { [weak self] (tableView, indexPath, category) -> UITableViewCell? in
            guard let self = self else {
                return nil
            }
            
            let cell = tableView.dequeueReusableCell(withIdentifier: ExpenseCategoryTableViewCell.nibName, for: indexPath)
            guard let expenseCategoryCell = cell as? ExpenseCategoryTableViewCell else {
                return cell
            }
            expenseCategoryCell.configure(category: self.categories[indexPath.row])
            return expenseCategoryCell
        }
    }()
    
    init(categories: [ExpenseCategory], categorySelected: @escaping (ExpenseCategory) -> ()) {
        self.categories = categories
        self.categorySelected = categorySelected
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Categories"
        view.backgroundColor = UIColor.init(named: "background")

        let cellNib = UINib.init(nibName: ExpenseCategoryTableViewCell.nibName, bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: ExpenseCategoryTableViewCell.nibName)
        tableView.estimatedRowHeight = 67
        tableView.rowHeight = UITableView.automaticDimension
        tableView.dataSource = dataSource
        tableView.backgroundColor = .clear
        tableView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let snapshot = NSDiffableDataSourceSnapshot<String, ExpenseCategory>()
        snapshot.appendSections([""])
        snapshot.appendItems(categories)
        dataSource.apply(snapshot)
    }

}

extension ExpenseCategorySelectionViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedCategory = categories[indexPath.row]
        categorySelected(selectedCategory)
    }
    
}