import Foundation

class FilePathes {
    
    private static var defaultBasePath: String = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].absoluteString
    private static var inputDataFilePath: String = defaultBasePath + "input/"
    private static var outputDataFilePath: String = "/Users/toyahiroki/Library/Containers/jp.com.example.image-classifier-app/Data/Documents/output/"
    private static var imageFolderPath: URL? = nil
    
    // 画像フォルダのPathを指定します．
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
    
    // 類似度リストファイルのPathを取得します．
    // 1. lexvec_similarity.json
    // 2. wordnet_path_similarity.json
    // 3. wordnet_wup_similarity.json
    class func getSimilalityFilePath(fileName: String = "wordnet_wup_similarity.json") -> URL? {
        if let filePath = URL(string: inputDataFilePath + fileName){
            return filePath
        }
        return nil
    }
    
    // 翻訳ファイルのPathを取得します．
    class func getTranslationFilePath(fileName: String = "translation_list.json") -> URL? {
        if let filePath = URL(string: inputDataFilePath + fileName){
            return filePath
        }
        return nil
    }
    
    // outputフォルダのPathを取得します．
    class func getOutputDataFilePath(fileName: String = "") -> String {
        return outputDataFilePath + fileName
    }
}
