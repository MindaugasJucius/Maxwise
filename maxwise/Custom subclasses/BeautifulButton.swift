import UIKit

import UIKit

protocol KoelButtonColorable {
    var textColor: UIColor { get set }
    var backgroundColor: CGColor { get set }
    var shadowColor: CGColor { get set }
}

private struct KoelButtonColors: KoelButtonColorable {
    var textColor: UIColor
    var backgroundColor: CGColor
    var shadowColor: CGColor
}

protocol KoelButtonAppearance {
    var transform: CATransform3D { get }
    var shadowOffset: CGSize { get }
    var shadowOpacity: Float { get }
    var shadowRadius: CGFloat { get }
    var dimmingViewOpacity: Float { get }
    var colors: KoelButtonColorable { get set }
}

private struct KoelButtonDefaultAppearance: KoelButtonAppearance {
    
    let transform: CATransform3D
    let shadowOffset: CGSize
    let shadowOpacity: Float
    let shadowRadius: CGFloat
    let dimmingViewOpacity: Float
    var colors: KoelButtonColorable
    
    init(buttonColors: KoelButtonColorable) {
        transform = CATransform3DIdentity
        shadowOffset = CGSize(width: 0, height: 4)
        shadowOpacity = 0.4
        shadowRadius = 4
        colors = buttonColors
        dimmingViewOpacity = 0
    }
}

struct KoelButtonEndAppearance: KoelButtonAppearance {
    let transform: CATransform3D
    let shadowOffset: CGSize
    let shadowOpacity: Float
    let shadowRadius: CGFloat
    let dimmingViewOpacity: Float
    var colors: KoelButtonColorable
    
    init(buttonColors: KoelButtonColorable) {
        transform = CATransform3DMakeScale(0.98, 0.98, 1)
        shadowOffset = CGSize(width: 0, height: 2)
        shadowOpacity = 0.7 
        shadowRadius = 2
        colors = buttonColors
        dimmingViewOpacity = 0.5
    }
}

private let AnimationDuration = 0.15
private let CornerRadius: CGFloat = 6

class BeautifulButton: UIButton {
    
    private var currentAppearance: KoelButtonAppearance!
    
    private var startAppearance: KoelButtonAppearance!
    private var endAppearance: KoelButtonAppearance!
    private var disabledAppearance: KoelButtonAppearance!
    
    private lazy var dimmingView: UIView = { this in
        let view = UIView(frame: .zero)
        this.addSubview(view)
        view.backgroundColor = UIColor.white.withAlphaComponent(0.8)
        view.layer.cornerRadius = CornerRadius
        view.isUserInteractionEnabled = false
        view.translatesAutoresizingMaskIntoConstraints = false
        
        let constraints = [
            view.leftAnchor.constraint(equalTo: this.leftAnchor),
            view.topAnchor.constraint(equalTo: this.topAnchor),
            this.rightAnchor.constraint(equalTo: view.rightAnchor),
            this.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ]
        NSLayoutConstraint.activate(constraints)
        
        return view
    }(self)
    
    override var isEnabled: Bool {
        didSet {
            if !isEnabled {
                animate(toAppearanceState: disabledAppearance)
            } else {
                animate(toAppearanceState: startAppearance)
            }
        }
    }
    
    init() {
        super.init(frame: .zero)
        initialConfiguration()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func updateAppearances(backgroundColor: UIColor, textColor: UIColor) {
        let disabledColors = KoelButtonColors(textColor: .lightGray,
                                              backgroundColor: backgroundColor.cgColor,
                                              shadowColor: backgroundColor.cgColor)
        
        let buttonColors = KoelButtonColors(textColor: .white,
                                            backgroundColor: backgroundColor.cgColor,
                                            shadowColor: backgroundColor.cgColor)
        
        let disabledAppearance = KoelButtonDefaultAppearance(buttonColors: disabledColors)
        let startAppearance = KoelButtonDefaultAppearance(buttonColors: buttonColors)
        let endAppearance = KoelButtonEndAppearance(buttonColors: buttonColors)
        
        if self.isEnabled {
            self.currentAppearance = startAppearance
        } else {
            self.currentAppearance = disabledAppearance
        }
        
        self.startAppearance = startAppearance
        self.endAppearance = endAppearance
        self.disabledAppearance = disabledAppearance
        
        configure(withAppearance: self.currentAppearance)
    }
    
    private func initialConfiguration() {
        translatesAutoresizingMaskIntoConstraints = false
        titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        
        layer.cornerRadius = CornerRadius
        layer.cornerCurve = .continuous

        layer.masksToBounds = false
        
        addTarget(self, action: #selector(dragEnter), for: .touchDragEnter)
        addTarget(self, action: #selector(touchDown), for: .touchDown)
        
        addTarget(self, action: #selector(touchUpInside), for: .touchUpInside)
        addTarget(self, action: #selector(dragExit), for: .touchDragExit)
    }
    
    @objc func touchUpInside() {
        animate(toAppearanceState: startAppearance)
    }
    
    @objc func dragExit() {
        animate(toAppearanceState: startAppearance)
    }
    
    @objc func touchDown() {
        animate(toAppearanceState: endAppearance)
    }
    
    @objc func dragEnter() {
        animate(toAppearanceState: endAppearance)
    }
    
    /// Edit model layer after animation
    private func configure(withAppearance appearance: KoelButtonAppearance) {
        layer.transform = appearance.transform
        layer.shadowRadius = appearance.shadowRadius
        layer.shadowOffset = appearance.shadowOffset
        layer.shadowOpacity = appearance.shadowOpacity
        layer.shadowColor = appearance.colors.shadowColor
        layer.backgroundColor = appearance.colors.backgroundColor
        setTitleColor(appearance.colors.textColor, for: .normal)
        dimmingView.layer.opacity = appearance.dimmingViewOpacity
    }
    
    private func animate(toAppearanceState appearance: KoelButtonAppearance) {
        // Shadow transformations
        let shadowOffsetAnimation = CABasicAnimation(keyPath: "shadowOffset")
        
        shadowOffsetAnimation.fromValue = currentAppearance.shadowOffset
        shadowOffsetAnimation.toValue = appearance.shadowOffset
        
        let shadowOpacityAnimation = CABasicAnimation(keyPath: "shadowOpacity")
        shadowOpacityAnimation.fromValue = currentAppearance.shadowOpacity
        shadowOpacityAnimation.toValue = appearance.shadowOpacity
        
        let shadowRadiusAnimation = CABasicAnimation(keyPath: "shadowRadius")
        shadowRadiusAnimation.fromValue = currentAppearance.shadowRadius
        shadowRadiusAnimation.toValue = appearance.shadowRadius
        
        let shadowColorAnimation = CABasicAnimation(keyPath: "shadowColor")
        shadowColorAnimation.fromValue = currentAppearance.colors.shadowColor
        shadowColorAnimation.toValue = appearance.colors.shadowColor
        
        let shadowGroup = CAAnimationGroup()
        shadowGroup.animations = [shadowOffsetAnimation,
                                  shadowOpacityAnimation,
                                  shadowRadiusAnimation,
                                  shadowColorAnimation]
        shadowGroup.duration = AnimationDuration
        
        // Button's view animations
        let backgroundColorAnimation = CABasicAnimation(keyPath: "backgroundColor")
        backgroundColorAnimation.fromValue = currentAppearance.colors.backgroundColor
        backgroundColorAnimation.toValue = appearance.colors.backgroundColor
        
        let transformAnimation = CABasicAnimation(keyPath: "transform")
        transformAnimation.fromValue = currentAppearance.transform
        transformAnimation.toValue = appearance.transform
        
        let group = CAAnimationGroup()
        group.animations = [transformAnimation, shadowGroup, backgroundColorAnimation]
        group.duration = AnimationDuration
        layer.add(group, forKey: nil)
        
        // Dimming view animations
        let dimmingViewOpacityAnimation = CABasicAnimation(keyPath: "opacity")
        dimmingViewOpacityAnimation.fromValue = currentAppearance.dimmingViewOpacity
        dimmingViewOpacityAnimation.toValue = appearance.dimmingViewOpacity
        
        dimmingView.layer.add(dimmingViewOpacityAnimation, forKey: nil)
        
        currentAppearance = appearance
        configure(withAppearance: appearance)
    }
    
}
