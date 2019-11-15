import Foundation

struct CategoryAttribute {
    var predictionResult: PredictionResult
    var sceneClusteredId: Int // 初期値：labelId 変更後：カテゴリ統合されたlabelId
    var objectClusteredName: String // 初期値：labelId 変更後：自身のlabelName
    var scenePriority: Bool = true //　カテゴリ分割された場合にfalseになります．
}
