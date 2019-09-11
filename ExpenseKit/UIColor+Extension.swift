import UIKit

enum UIColorInputError: Error {    
    case unableToOutputHexStringForWideDisplayColor
}

extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    convenience init(hex: Int) {
        let red: Int, green: Int, blue: Int, alpha: Int

        red   = ((hex & 0xff0000) >> 16)
        green = ((hex & 0x00ff00) >>  8)
        blue  = ((hex & 0x0000ff) >>  0)
        alpha = 255
        
        self.init(
            red: CGFloat(red) / 255.0,
            green: CGFloat(green) / 255.0,
            blue: CGFloat(blue) / 255.0,
            alpha: CGFloat(alpha) / 255.0
        )
    }
    
    public convenience init?(hex: String) {
        let r, g, b: CGFloat
        
        if hex.hasPrefix("#") {
            let start = hex.index(hex.startIndex, offsetBy: 1)
            let hexColor = String(hex[start...])
            
            if hexColor.count == 6 {
                let scanner = Scanner(string: hexColor)
                var hexNumber: UInt64 = 0
                
                if scanner.scanHexInt64(&hexNumber) {
                    r = CGFloat((hexNumber & 0xff0000) >> 16) / 255
                    g = CGFloat((hexNumber & 0x00ff00) >> 8) / 255
                    b = CGFloat(hexNumber & 0x0000ff) / 255
                    
                    self.init(red: r, green: g, blue: b, alpha: 1)
                    return
                }
            }
        }
        
        return nil
    }
    
    public func hexStringThrows(_ includeAlpha: Bool = true) throws -> String  {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        self.getRed(&r, green: &g, blue: &b, alpha: &a)
        
        guard r >= 0 && r <= 1 && g >= 0 && g <= 1 && b >= 0 && b <= 1 else {
            throw UIColorInputError.unableToOutputHexStringForWideDisplayColor
        }
        
        if (includeAlpha) {
            return String(format: "#%02X%02X%02X%02X",
                          Int(round(r * 255)), Int(round(g * 255)),
                          Int(round(b * 255)), Int(round(a * 255)))
        } else {
            return String(format: "#%02X%02X%02X", Int(round(r * 255)),
                          Int(round(g * 255)), Int(round(b * 255)))
        }
    }
    
}

extension UIColor {
    
    public static var confirmationGreen: UIColor {
        return .init(red: 146, green: 230, blue: 54)
    }
    
    
    public static var tealBlue: UIColor {
        return .init(red: 90, green: 200, blue: 250)
    }

    public static var pink: UIColor {
        return .init(red: 255, green: 45, blue: 85)
    }
    
}

extension UIColor {
    
    // Green / Sea
    static let flatTurquoise    = UIColor(hex: 0x1ABC9C)
    static let flatGreenSea     = UIColor(hex: 0x16A085)
    // Green
    static let flatEmerald      = UIColor(hex: 0x2ECC71)
    static let flatNephritis    = UIColor(hex: 0x27AE60)
    // Blue
    static let flatPeterRiver   = UIColor(hex: 0x3498DB)
    static let flatBelizeHole   = UIColor(hex: 0x2980B9)
    // Purple
    static let flatAmethyst     = UIColor(hex: 0x9B59B6)
    static let flatWisteria     = UIColor(hex: 0x8E44AD)
    // Dark blue
    static let flatWetAsphalt   = UIColor(hex: 0x34495E)
    static let flatMidnightBlue = UIColor(hex: 0x2C3E50)
    // Yellow
    static let flatSunFlower   = UIColor(hex: 0xF1C40F)
    static let flatOrange      = UIColor(hex: 0xF39C12)
    // Orange
    static let flatCarrot      = UIColor(hex: 0xE67E22)
    static let flatPumpkin     = UIColor(hex: 0xD35400)
    // Red
    static let flatAlizarin    = UIColor(hex: 0xE74C3C)
    static let flatPomegranate = UIColor(hex: 0xC0392B)
    // White
    static let flatClouds   = UIColor(hex: 0xECF0F1)
    static let flatSilver   = UIColor(hex: 0xBDC3C7)
    // Gray
    static let flatAsbestos = UIColor(hex: 0x7F8C8D)
    static let flatConcrete = UIColor(hex: 0x95A5A6)
    
    static let palette: [UIColor] = [
        flatTurquoise
        ,flatGreenSea
        ,flatEmerald
        ,flatNephritis
        ,flatPeterRiver
        ,flatBelizeHole
        ,flatAmethyst
        ,flatWisteria
        ,flatWetAsphalt
        ,flatMidnightBlue
        ,flatSunFlower
        ,flatOrange
        ,flatCarrot
        ,flatPumpkin
        ,flatAlizarin
        ,flatPomegranate
        ,flatClouds
        ,flatSilver
        ,flatAsbestos
        ,flatConcrete
    ]
}

/// Dutch Palette
/// https://flatuicolors.com/palette/nl
extension UIColor {
    
    // Yellow / Red
    static let flatSunflower = UIColor(hex: 0xFFC312)
    static let flatRadianYellow = UIColor(hex: 0xF79F1F)
    static let flatPuffinsBull = UIColor(hex: 0xEE5A24)
    static let flatRedPigment = UIColor(hex: 0xEA2027)
    // Green
    static let flatEnergos = UIColor(hex: 0xC4E538)
    static let flatAndroidGreen = UIColor(hex: 0xA3CB38)
    static let flatPixelatedGrass = UIColor(hex: 0x009432)
    static let flatTurkishAqua = UIColor(hex: 0x006266)
    // Blue
    static let flatBlueMartina = UIColor(hex: 0x12CBC4)
    static let flatMediterraneanSea = UIColor(hex: 0x1289A7)
    static let flatMerchantMarineBlue = UIColor(hex: 0x0652DD)
    static let flat20000LeaguesUnderTheSea = UIColor(hex: 0x1B1464)
    // Rose / Purpule
    static let flatLavenderRose = UIColor(hex: 0xFDA7DF)
    static let flatLavenderTea = UIColor(hex: 0xD980FA)
    static let flatForgottenPurple = UIColor(hex: 0x9980FA)
    static let flatCircumorbitalRing = UIColor(hex: 0x5758BB)
    // Rose / Red
    static let flatBaraRed = UIColor(hex: 0xED4C67)
    static let flatVeryBerry = UIColor(hex: 0xB53471)
    static let flatHollyhock = UIColor(hex: 0x833471)
    static let flatMargentaPurple = UIColor(hex: 0x6F1E51)
}
