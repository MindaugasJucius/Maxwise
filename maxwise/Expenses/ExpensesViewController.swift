import UIKit

class ExpensesDataSource: UITableViewDiffableDataSource<Date, ExpensePresentationDTO> {
    
    // No other way to provide custom behaviour to data source methods
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
}

class ExpensesViewController: UIViewController {
    
    private let viewModel: ExpensesViewModel
    private var expenseGroups = [(Date, [ExpensePresentationDTO])]()
    
    private lazy var dataSource: ExpensesDataSource = {
        return ExpensesDataSource(tableView: tableView) { [weak self] (tableView, indexPath, expenseEntryDTO) in
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
    
    lazy var noExpensesView = NoExpensesView()
    
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
        view.backgroundColor = UIColor.init(named: "background")
        
        viewModel.toggleNoExpensesView = { [weak self] show in
            self?.toggleNoExpensesView(show: show)
        }
        
        viewModel.observeExpenseEntries { [weak self] groupedExpenses in
            self?.expenseGroups = groupedExpenses
            var snapshot = NSDiffableDataSourceSnapshot<Date, ExpensePresentationDTO>()
            snapshot.appendSections(groupedExpenses.map { $0.0 })
            
            groupedExpenses.forEach { (key, value) in
                snapshot.appendItems(value, toSection: key)
            }
            self?.dataSource.apply(snapshot)
        }
        
        noExpensesView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(noExpensesView)
        noExpensesView.fillInSuperview()
    }
    
    private func toggleNoExpensesView(show: Bool) {
        noExpensesView.alpha = show ? 1 : 0
    }
    
    private func configureTableView() {
        let cellNib = UINib.init(nibName: ExpenseTableViewCell.nibName, bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: ExpenseTableViewCell.nibName)

        let headerNib = UINib.init(nibName: ExpensesSectionHeaderView.nibName, bundle: nil)
        tableView.register(headerNib,
                           forHeaderFooterViewReuseIdentifier: ExpensesSectionHeaderView.nibName)
        tableView.dataSource = dataSource
        dataSource.defaultRowAnimation = .fade

        tableView.allowsSelection = true
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
        viewModel.delete(expense: expenseDTO) { [weak self] result in
            switch result {
            case .success:
                completion(true)
            case .failure(let error):
                self?.showAlert(for: error.localizedDescription)
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
        let action = UIContextualAction.init(style: .destructive, title: nil) { [weak self] (action, view, completion) in
            self?.deleteExpense(at: indexPath, completion: completion)
        }
        action.image = UIImage.init(systemName: "trash")
        return UISwipeActionsConfiguration.init(actions: [action])
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let expenseCreationViewModel = ExpenseCreationViewModel()
        
        guard let expenseDTO = dataSource.itemIdentifier(for: indexPath),
            let expenseToEdit = expenseCreationViewModel.entry(from: expenseDTO.id) else {
            return
        }

        let expenseCreationViewController = ExpenseCreationViewController.init(
            viewModel: expenseCreationViewModel,
            expenseToEdit: expenseToEdit
        )
        
        present(expenseCreationViewController, animated: true, completion: nil)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
