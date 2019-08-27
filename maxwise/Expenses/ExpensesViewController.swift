import UIKit

class ExpensesViewController: UIViewController {

    private let expensesStatsViewController = ExpensesStatsViewController()
    
    private let viewModel: ExpensesViewModel
    private var expenseGroups = [(Date, [ExpensePresentationDTO])]()
    
    private lazy var dataSource: UITableViewDiffableDataSource<Date, ExpensePresentationDTO> = {
        return UITableViewDiffableDataSource(tableView: tableView) { [weak self] (tableView, indexPath, expenseEntryDTO) in
            guard let self = self else {
                return nil
            }
            
            let cell = tableView.dequeueReusableCell(withIdentifier: ExpenseTableViewCell.nibName, for: indexPath)
            guard let expenseCell = cell as? ExpenseTableViewCell else {
                return cell
            }
            
            expenseCell.configure(expenseDTO: expenseEntryDTO)
            return expenseCell
        }
    }()
    
    @IBOutlet private weak var tableView: UITableView!

    init(viewModel: ExpensesViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()
        title = "Expenses"
        view.backgroundColor = UIColor.init(named: "background")
        addChild(expensesStatsViewController)

        viewModel.observeExpenseEntries { [weak self] groupedExpenses in
            self?.expenseGroups = groupedExpenses
            let snapshot = NSDiffableDataSourceSnapshot<Date, ExpensePresentationDTO>()
            snapshot.appendSections(groupedExpenses.map { $0.0 })
            
            groupedExpenses.forEach { (key, value) in
                snapshot.appendItems(value, toSection: key)
            }
            self?.dataSource.apply(snapshot)
        }
        
        viewModel.amountSpentChanged = { [weak self] amount in
            self?.expensesStatsViewController.amount = amount
        }
    }
    
    private func configureTableView() {
        let cellNib = UINib.init(nibName: ExpenseTableViewCell.nibName, bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: ExpenseTableViewCell.nibName)

        let headerNib = UINib.init(nibName: ExpensesSectionHeaderView.nibName, bundle: nil)
        tableView.register(headerNib,
                           forHeaderFooterViewReuseIdentifier: ExpensesSectionHeaderView.nibName)
        tableView.dataSource = dataSource
        dataSource.defaultRowAnimation = .fade
        tableView.delegate = self
        tableView.estimatedRowHeight = 67
        tableView.estimatedSectionHeaderHeight = 60
        tableView.rowHeight = UITableView.automaticDimension
        tableView.sectionHeaderHeight = UITableView.automaticDimension
        tableView.backgroundColor = .clear
    }
    
    func deleteExpense(at indexPath: IndexPath, completion: @escaping (Bool) -> Void) {
        guard let expenseDTO = dataSource.itemIdentifier(for: indexPath) else {
            completion(false)
            return
        }
        viewModel.delete(expense: expenseDTO) { result in
            switch result {
            case .success:
                completion(true)
            case .failure(let error):
                print(error.localizedDescription)
                completion(false)
            }
        }
    }
    
}

extension ExpensesViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let sectionView = tableView.dequeueReusableHeaderFooterView(withIdentifier: ExpensesSectionHeaderView.nibName)
        guard let sectionHeader = sectionView as? ExpensesSectionHeaderView else {
            return sectionView
        }
        let group = expenseGroups[section]
        let text = viewModel.expenseGroupSectionDescription(from: group.0)
        sectionHeader.configure(title: text)
        return sectionHeader
    }

    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let action = UIContextualAction.init(style: .destructive, title: "Delete") { [weak self] (action, view, completion) in
            self?.deleteExpense(at: indexPath, completion: completion)
        }
        return UISwipeActionsConfiguration.init(actions: [action])
    }
}
