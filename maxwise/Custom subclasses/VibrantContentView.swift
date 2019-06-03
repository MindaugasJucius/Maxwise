import UIKit


class VibrantContentView: UIView {

    struct Configuration {
        enum CornerAppearance {
            case rounded
            case circular
        }
        
        var cornerStyle: CornerAppearance
        var blurEffectStyle: UIBlurEffect.Style
    }
    
    private(set) var contentView: UIView?

    var configuration: Configuration? {
        didSet {
            guard let configuration = configuration else {
                return
            }
            apply(configuration: configuration)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        guard let configuration = configuration else {
            return
        }
        switch configuration.cornerStyle {
        case .circular:
            layer.cornerRadius = frame.height / 2
        case .rounded:
            layer.cornerRadius = 6
        }

    }
    
    private func apply(configuration: Configuration) {
        translatesAutoresizingMaskIntoConstraints = false
        layer.masksToBounds = true
        
        let blurEffect = UIBlurEffect(style: configuration.blurEffectStyle)
        let vibrancyEffect = UIVibrancyEffect(blurEffect: blurEffect)
        let vibrancyEffectView = UIVisualEffectView(effect: vibrancyEffect)
        
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(blurEffectView)
        blurEffectView.fill(in: self)
        
        blurEffectView.contentView.addSubview(vibrancyEffectView)
        vibrancyEffectView.translatesAutoresizingMaskIntoConstraints = false
        vibrancyEffectView.fill(in: blurEffectView.contentView)
        
        contentView = vibrancyEffectView.contentView
    }
}
