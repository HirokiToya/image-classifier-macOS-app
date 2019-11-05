import Foundation

class FilePathes {
    
    private static var basePath: String = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].absoluteString
    private static var imagesPath: String = basePath + "input/images/"
    private static var similalityPath: String = basePath + "input/similality_list/"
    
    // 画像フォルダのPathを指定します。
    class func setImagesPath(relativePath: String){
        self.imagesPath = basePath + relativePath
    }
    
    // 画像フォルダのPathをStringで取得します。
    class func getImagesDirPath() -> String {
        return imagesPath
    }
    
    // 画像フォルダのPathをURL？で取得します。
    class func getImagesDirPath() -> URL? {
        if let filePath = URL(string: imagesPath){
            return filePath
        }
        return nil
    }
    
    // 類似度リストファイルのフォルダのPathを指定します。
    class func setSimilalityPath(relativePath: String) {
        self.similalityPath = basePath + relativePath
    }
    
    // 類似度リストファイルのPathをStringで取得します。
    class func getSimilalityDataPath(fileName: String = "data.json") -> String {
        return similalityPath + fileName
    }
    
    // 類似度リストファイルのPathをURL？で取得します。
    class func getSimilalityDataPath(fileName: String = "data.json") -> URL? {
        if let filePath = URL(string: similalityPath + fileName){
            return filePath
        }
        return nil
    }
    
    // 類似度リストファイルのフォルダのPathをStringで取得します。
    class func getSimilalityDirPath() -> String {
        return similalityPath
    }
    
    // 類似度リストファイルのフォルダのPathをURL？で取得します。
    class func getSimilalityDirPath() -> URL? {
        if let filePath = URL(string: similalityPath){
            return filePath
        }
        return nil
    }
}
