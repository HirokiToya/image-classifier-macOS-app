import Foundation

class CategoryEvaluationModel {
    
    let categotyAttributes:[CategoryAttribute]
    
    init(attributes: [CategoryAttribute]) {
        self.categotyAttributes = attributes
    }
    
    func getEvaluation(representativeSceneId: Int) -> Double {
        
        struct CategoryFomulaAttribute {
            let baseSceneId: Int
            let count: Int
        }
        
        let representativeCategoryImages = categotyAttributes.filter({ $0.representativeSceneId == representativeSceneId && $0.scenePriority })
        var baseCategoryImages: [CategoryAttribute]
        var categoryFomulaAttributes: [CategoryFomulaAttribute] = []
        
        for sceneId in 0...364 {
            baseCategoryImages = representativeCategoryImages.filter({
                Int($0.predictionResult.scenePredictions[0].labelId) == sceneId
            })
            
            if(baseCategoryImages.count > 0) {
                categoryFomulaAttributes.append(CategoryFomulaAttribute(baseSceneId: sceneId, count: baseCategoryImages.count))
            }
        }
        
        for attr in categoryFomulaAttributes {
            print("sceneId:\(attr.baseSceneId) 枚数:\(attr.count)")
        }
        
        var totalDenominator: Double  = 0.0 // 分母の合計値
        var totalMolecule: Double = 0.0 // 分子の合計値
        
        for attr1 in categoryFomulaAttributes {
            for attr2 in categoryFomulaAttributes {
                if let similality = SimilalityRepositories.getSimilality(id1: attr1.baseSceneId, id2: attr2.baseSceneId) {
                    if(attr1.baseSceneId > attr2.baseSceneId) {
                        totalDenominator += Double(attr1.count + attr2.count)
                        totalMolecule += similality * Double(attr1.count + attr2.count)
                        print("id1:\(attr1.baseSceneId) id2:\(attr2.baseSceneId) 類似度:\(similality)")
                    }
                }
            }
        }
        
        print("\(totalMolecule) / \(totalDenominator)")
        
        if(totalDenominator == 0.0) {
            // カテゴリが混合していない場合，評価値は1.0
            return 1.0
        } else {
            return totalMolecule / totalDenominator
        }
    }
}
