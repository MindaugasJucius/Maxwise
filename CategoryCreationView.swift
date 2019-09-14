import UIKit
import ExpenseKit

class CategoryCreationView: UIView {

    let selectionFeedback = UISelectionFeedbackGenerator()
    let notificationFeedback = UINotificationFeedbackGenerator()
    
    private let expenseCategory: ExpenseCategory
    private let colors: [Color]
    private let preselectedColor: Color?
    private let changedColorSelection: (Color) -> Void
    
    @IBOutlet private weak var titleTextField: UITextField!
    @IBOutlet private weak var categoryEmojiTextFieldContainer: UIView!
    @IBOutlet private weak var categoryEmojiTextField: UITextField!
    @IBOutlet private weak var colorSelectionCollectionView: UICollectionView!
    
    init(expenseCategory: ExpenseCategory,
         colors: [Color],
         selectedColor: Color?,
         changedColorSelection: @escaping (Color) -> Void) {
        self.changedColorSelection = changedColorSelection
        self.expenseCategory = expenseCategory
        self.preselectedColor = selectedColor
        
        if let selectedColor = selectedColor {
            self.colors = [selectedColor] + colors
        } else {
            self.colors = colors
        }
        
        super.init(frame: .zero)
        loadNib()
        configure(expenseCategory: expenseCategory)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure(expenseCategory: ExpenseCategory) {
        categoryEmojiTextField.layer.applyBorder()
        
        categoryEmojiTextFieldContainer.layer.cornerRadius = 6
        
        layer.masksToBounds = true
        layer.applyShadow(color: .tertiaryLabel)
        
        titleTextField.backgroundColor = .systemBackground
        titleTextField.becomeFirstResponder()
        titleTextField.layer.applyBorder()
        titleTextField.layer.borderColor = UIColor.clear.cgColor
        titleTextField.textColor = .label
        titleTextField.placeholder = "Category title"
        titleTextField.autocapitalizationType = .words
        titleTextField.addTarget(self, action: #selector(resetErrorStates), for: .editingChanged)
        titleTextField.delegate = self
        
        if !expenseCategory.isEmpty() {
            titleTextField.text = expenseCategory.title
            categoryEmojiTextField.text = expenseCategory.emojiValue
        }
        configureCollectionView()
    }
    
    private func loadNib() {
        let nib = Bundle.main.loadNibNamed(CategoryCreationView.nibName, owner: self, options: nil)
        guard let contentView = nib?.first as? UIView else {
            fatalError("view in nib not found")
        }
        addSubview(contentView)
        contentView.fill(in: self)
        
        contentView.layer.cornerCurve = .continuous
        contentView.layer.cornerRadius = 6
        contentView.backgroundColor = UIColor.systemBackground
    }

    func isCategoryDataValid() -> Bool {
        guard let titleText = titleTextField.text, !titleText.isEmpty else {
            titleTextField.layer.borderColor = UIColor.red.cgColor
            notificationFeedback.notificationOccurred(.error)
            return false
        }
        notificationFeedback.notificationOccurred(.success)
        return true
    }
    
    @objc private func resetErrorStates() {
        titleTextField.layer.borderColor = UIColor.clear.cgColor
    }
    
    private func configureCollectionView() {
        let layout = UICollectionViewCompositionalLayout { (section, environment) -> NSCollectionLayoutSection? in
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                        heightDimension: .fractionalWidth(1))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            
            let groupSize = NSCollectionLayoutSize(widthDimension: .absolute(35),
                                                   heightDimension: .absolute(35))

            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 1)
            
            let section = NSCollectionLayoutSection(group: group)
            section.orthogonalScrollingBehavior = .paging
            section.interGroupSpacing = 10
            return section
        }
        
        let layoutConfiguration = UICollectionViewCompositionalLayoutConfiguration()
        layoutConfiguration.scrollDirection = .vertical
        layout.configuration = layoutConfiguration
        
        colorSelectionCollectionView.setCollectionViewLayout(layout, animated: false)
        
        let cellNib = UINib(nibName: ColorCollectionViewCell.nibName,
                            bundle: nil)
        colorSelectionCollectionView.register(cellNib,
                                              forCellWithReuseIdentifier: ColorCollectionViewCell.nibName)
        colorSelectionCollectionView.dataSource = self
        colorSelectionCollectionView.delegate = self
        colorSelectionCollectionView.allowsSelection = true
        
        if let preselectedColor = preselectedColor,
            let index = colors.firstIndex(of: preselectedColor) {
            colorSelectionCollectionView.selectItem(at: .init(item: index, section: 0),
                                                    animated: false,
                                                    scrollPosition: .left)
            changedColorSelection(preselectedColor)
            update(for: preselectedColor)
        }
    }
    
    private func update(for color: Color) {
        guard let uiColor = color.uiColor else {
            return
        }
        categoryEmojiTextField.layer.applyBorder()
        categoryEmojiTextField.backgroundColor = uiColor.withAlphaComponent(0.1)
        categoryEmojiTextField.layer.borderColor = uiColor.cgColor
        categoryEmojiTextFieldContainer.layer.applyShadow(color: uiColor)

        categoryEmojiTextField.tintColor = uiColor
        titleTextField.tintColor = uiColor
    }
}

extension CategoryCreationView: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectionFeedback.selectionChanged()
        let color = colors[indexPath.row]
        changedColorSelection(color)
        update(for: color)
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        let color = colors[indexPath.row]
        return !color.taken
    }
    
}

extension CategoryCreationView: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return colors.count
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ColorCollectionViewCell.nibName,
                                                      for: indexPath)
        guard let colorCell = cell as? ColorCollectionViewCell else {
            return cell
        }
        let color = colors[indexPath.row]
        
        colorCell.configure(forColor: color)
        return colorCell
    }
    
}

extension CategoryCreationView: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else {
            return true
        }

        if (text + string).count > 30 {
            return false
        }
        
        return true
    }
    
}
