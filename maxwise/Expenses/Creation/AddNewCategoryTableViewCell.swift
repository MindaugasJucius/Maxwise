import UIKit

class AddNewCategoryTableViewCell: UITableViewCell {

    @IBOutlet weak var plusImageView: UIImageView!
    @IBOutlet weak var label: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        label.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        label.textColor = tintColor
        label.text = "New category"

        let selectionView = UIView()
        selectionView.backgroundColor = tintColor.withAlphaComponent(0.2)
        selectedBackgroundView = selectionView
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
