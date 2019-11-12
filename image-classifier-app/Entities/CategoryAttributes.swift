import Foundation

struct CategoryAttribute {
    var predictionResult: PredictionResult
    var sceneClusteredId: Int // クラスタリング後どのシーン識別IDに分類されたか
    var objectClusteredId: String // クラスタリング後どの物体識別IDに分類されたか
    var scenePriority: Bool = true //　シーン識別IDを優先する
}
