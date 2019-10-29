import Foundation

enum Result<T, Error: Swift.Error> {
    case success(T)
    case failture(Error)
    
    init(value: T) {
        self = .success(value)
    }
    
    init(error: Error) {
        self = .failture(error)
    }
}
