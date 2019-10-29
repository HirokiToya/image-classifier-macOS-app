
import Foundation

enum ClientError : Error {
    case connectionError(Error)
    case responseParseError(Error)
    case apiError(Error)
    case encodingError(Error)
    case noResponseError(Error?)
}
