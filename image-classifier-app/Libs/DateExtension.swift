import Foundation

extension Date {
    func toFormattedString(_ pattern: String) -> String{
        let f = DateFormatter()
        f.dateFormat = pattern
        f.calendar = Calendar(identifier: .gregorian)
        f.locale = Locale.enUS
        return f.string(from: self)
    }
    
    func toYmdHmsHyphen() -> String{
        return toFormattedString("yyyy-MM-dd HH:mm:ss")
    }
    
    func toYmdHyphen() -> String {
        return toFormattedString("yyyy-MM-dd")
    }
}

extension Locale {
    
    static var enUS: Locale {
        get { return Locale(identifier: "en_US") }
    }
    
    static var jaJP: Locale {
        get { return Locale(identifier: "ja_JP") }
    }
}
