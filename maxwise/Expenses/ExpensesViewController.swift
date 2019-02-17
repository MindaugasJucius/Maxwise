import UIKit

class ExpensesViewController: UIViewController {

    private let expensesStatsViewController = ExpensesStatsViewController()
    
    private let viewModel: ExpensesViewModel
    private var expenses = [ExpensePresentationDTO]()

    @IBOutlet private weak var tableView: UITableView!

    init(viewModel: ExpensesViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        expenses = viewModel.expenseEntries()
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
    }
    
    private func configureTableView() {
        let cellNib = UINib.init(nibName: ExpenseTableViewCell.nibName, bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: ExpenseTableViewCell.nibName)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.estimatedRowHeight = 85
        tableView.estimatedSectionHeaderHeight = 60
        tableView.rowHeight = UITableView.automaticDimension
        tableView.sectionHeaderHeight = UITableView.automaticDimension
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
    }

    @IBAction func closeTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
}

extension ExpensesViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return expensesStatsViewController.view
    }
    
}

extension ExpensesViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return expenses.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ExpenseTableViewCell.nibName, for: indexPath)
        guard let expenseCell = cell as? ExpenseTableViewCell else {
            return cell
        }
        
        expenseCell.configure(expenseDTO: expenses[indexPath.row])
        return expenseCell
    }
    
}
