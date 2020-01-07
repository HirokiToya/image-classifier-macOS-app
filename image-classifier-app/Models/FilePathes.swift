import Foundation

class FilePathes {
    
    private static var defaultBasePath: String = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].absoluteString
    private static var inputDataFilePath: String = defaultBasePath + "input/"
    private static var imageFolderPath: URL? = nil
    
    // DocumentDirectoryのPathを取得します．
    class func getDefaultBasePath() -> URL?{
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last
    }
    
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
    // 4. wordnet_similarities.json // wup 修正版
    class func getSimilalityFilePath(fileName: String = "wordnet_similarities.json") -> URL? {
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
}
