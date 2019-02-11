import UIKit

class ExpensesViewController: UIViewController {

    private let viewModel = ExpensesViewModel()
    var expenses = [ExpensePresentationDTO]()
    
    @IBOutlet private weak var tableView: UITableView!

    init() {
        super.init(nibName: nil, bundle: nil)
        expenses = viewModel.expenseEntries()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let nib = UINib.init(nibName: "ExpenseTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "ExpenseTableViewCell")
        tableView.dataSource = self
        tableView.estimatedRowHeight = 105
        tableView.rowHeight = UITableView.automaticDimension
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none

        view.backgroundColor = UIColor.init(named: "background")
    }

    @IBAction func closeTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
}

extension ExpensesViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return expenses.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ExpenseTableViewCell", for: indexPath)
        guard let expenseCell = cell as? ExpenseTableViewCell else {
            return cell
        }
        
        expenseCell.configure(expenseDTO: expenses[indexPath.row])
        return expenseCell
    }
    
}
