import UIKit

class VibrantContentView: UIView {
    
    private let blurEffect = UIBlurEffect(style: .prominent)
    private lazy var vibrancyEffect = UIVibrancyEffect(blurEffect: blurEffect)
    private lazy var vibrancyEffectView = UIVisualEffectView(effect: vibrancyEffect)
    
    var contentView: UIView {
        return vibrancyEffectView.contentView
    }
    
    init() {
        super.init(frame: .zero)
        configure()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configure()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = frame.height / 2
    }
    
    private func configure() {
        translatesAutoresizingMaskIntoConstraints = false
        layer.masksToBounds = true
        
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(blurEffectView)
        blurEffectView.fill(in: self)
        
        blurEffectView.contentView.addSubview(vibrancyEffectView)
        vibrancyEffectView.translatesAutoresizingMaskIntoConstraints = false
        vibrancyEffectView.fill(in: blurEffectView.contentView)
//        vibrancyEffectView.contentView.addSubview(contentView)
//        contentView.fill(in: vibrancyEffectView.contentView)
    }
}
