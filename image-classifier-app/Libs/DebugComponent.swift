import Foundation

class DebugComponent {
    
    func getTimeNow() -> String {
        let f = DateFormatter()
        f.dateStyle = .none
        f.timeStyle = .medium
        let now = Date()
        return f.string(from: now)
    }
}
