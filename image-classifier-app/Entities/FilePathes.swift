import Foundation

class FilePathes {
    
    private static var defaultBasePath: String = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].absoluteString
    private static var defaultSimilalityPath: String = defaultBasePath + "input/similality_list/"
    private static var imageFolderPath: URL? = nil
    
    // 画像フォルダのPathを指定します。
    class func setImageFolderPath(relativePath: URL){
        self.imageFolderPath = relativePath
    }
    
    // 画像フォルダのPathを取得します．
    class func getImageFolderPath() -> URL? {
        if let path = imageFolderPath {
            return path
        }
        return nil
    }
    
    // 類似度リストファイルのフォルダのPathを指定します。
    class func setSimilalityPath(relativePath: String) {
        self.defaultSimilalityPath = defaultBasePath + relativePath
    }
        
    // 類似度リストファイルのPathを取得します。
    class func getSimilalityDataPath(fileName: String = "data.json") -> URL? {
        if let filePath = URL(string: defaultSimilalityPath + fileName){
            return filePath
        }
        return nil
    }
}
