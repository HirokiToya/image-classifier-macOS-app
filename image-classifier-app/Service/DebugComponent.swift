import Foundation

class DebugComponent {
    
    private static var isDebug = false
    
    class func startExperiment() {
        writeUserActionLog(data: "\(getTimeNow()) 【実験開始】")
        self.isDebug = true
    }
    
    class func endExperiment() {
        writeUserActionLog(data: "\(getTimeNow())【実験終了】")
        self.isDebug = false
    }
    
    class func startSelecting(num: Int) {
        if isDebug {
            writeUserActionLog(data: "\(getTimeNow()) 指定画像\(num)枚目選択開始")
        }
    }
    
    class func endSelecting(num: Int) {
        if isDebug {
            writeUserActionLog(data: "\(getTimeNow()) 指定画像\(num)枚目選択終了")
        }
    }
    
    class func setCluster(num: Int) {
        if isDebug {
            writeUserActionLog(data: "\(getTimeNow()) 表示枚数指定：\(num)枚")
        }
    }
    
    class func selectRepresentative(image: URL) {
        if isDebug {
            writeUserActionLog(data: "\(getTimeNow()) 代表画像選択：\(image)")
        }
    }
    
    class func changeRepresentativeImageOrder(tag: SortActionTag) {
        if isDebug {
            writeUserActionLog(data: "\(getTimeNow()) 代表画像並び順変更：\(tag)")
        }
    }
    
    class func changeClusteredImageOrder(tag: SortActionTag) {
        if isDebug {
            writeUserActionLog(data: "\(getTimeNow()) 画像並び順変更：\(tag)")
        }
    }
    
    class func changeTransrateState(tag: Bool) {
        if isDebug {
            if (tag){ writeUserActionLog(data: "\(getTimeNow()) 日本語") }
            else { writeUserActionLog(data: "\(getTimeNow()) 英語") }
        }
    }
    
    class func writeUserActionLog(data: String) {
        FileAccessor.writeFileData(fileName: "Logs/log_\(getToday()).txt", string: data)
    }
    
    class func writeSelectedImagesName(data: String) {
        FileAccessor.writeFileData(fileName: "Logs/selected_images_\(getToday()).txt", string: data)
    }
    
    class func getToday() -> String {
        let now = Date()
        return now.toYmdHyphen()
    }
    
    class func getTimeNow() -> String {
        let now = Date()
        return now.toYmdHmsHyphen()
    }
}
