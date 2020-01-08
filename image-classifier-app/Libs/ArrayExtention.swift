
import Foundation

extension Array {
    func unique() -> [Self.Element] {
        return NSOrderedSet(array: self).array as! [Self.Element]
    }
}
