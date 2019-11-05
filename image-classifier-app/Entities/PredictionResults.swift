import Foundation

struct PredictionResult {
    var imagePath = ""
    var scenePredictions: [ScenePrediction] = []
    var resnetPredictions: [ResnetPrediction] = []
}

struct ScenePrediction {
    var labelId = ""
    var label = ""
    var probability: Double = 0.0
}

struct ResnetPrediction {
    var labelId = ""
    var label = ""
    var probability: Double = 0.0
}
