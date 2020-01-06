import Foundation

class DebugComponent {
    
    private var startSelectingTime: Date? = nil
    private var endSelectingTime: Date? = nil
    
    private var experimentTrialCount = 0 {
        didSet {
            if(experimentTrialCount > 3) {
                experimentTrialCount = 0
            }
        }
    }
    
    func startExperiment() {
        writeUserActionLog(data: "\(getTimeNow()) ----------------------実験開始----------------------")
    }
    
    func endExperiment() {
        writeUserActionLog(data: "\(getTimeNow()) ----------------------実験終了----------------------")
    }
    
    func getExperimentTrialCount() -> Int {
        return experimentTrialCount
    }
    
    func incrementExperimentTrialCount() {
        experimentTrialCount += 1
    }
    
    func startSelecting() {
        let now = Date()
        startSelectingTime = now
        if let time = startSelectingTime {
            writeUserActionLog(data: "\(time) 画像選択開始")
        }
    }
    
    func endSelecting() {
        let now = Date()
        endSelectingTime = now
        if let time = endSelectingTime {
            writeUserActionLog(data: "\(time) 画像選択終了")
        }
    }
    
    func writeUserActionLog(data: String) {
        FileAccessor.writeFileData(fileName: "Logs/log_\(getToday()).txt", string: data)
    }
    
    func writeSelectedImagesName(data: String) {
        FileAccessor.writeFileData(fileName: "Logs/selected_images_\(getToday()).txt", string: data)
    }
    
    func getToday() -> String {
        let now = Date()
        return now.toYmdHyphen()
    }
    
    func getTimeNow() -> String {
        let now = Date()
        return now.toYmdHmsHyphen()
    }
}
