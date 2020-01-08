import Foundation

class CategoryEvaluationModel {
    
    struct CategoryFomulaAttribute {
        let baseSceneId: Int
        let count: Int
    }
        
    // 代表画像sceneIdに統合されたカテゴリ連合のカテゴリ評価値を返します．
    func evaluateCategory(categotyAttributes: [CategoryAttribute],
                          representativeSceneId: Int) -> Double {
        
        let representativeCategoryImages = categotyAttributes.filter({
            $0.representativeSceneId == representativeSceneId && $0.scenePriority
        })
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
        
//        for attr in categoryFomulaAttributes {
//            print("sceneId:\(attr.baseSceneId) 枚数:\(attr.count)")
//        }
        
        var totalDenominator: Double  = 0.0 // 分母の合計値
        var totalMolecule: Double = 0.0 // 分子の合計値
        
        for attr1 in categoryFomulaAttributes {
            for attr2 in categoryFomulaAttributes {
                if let similality = SimilalityRepositories.getRewitedSimilality(labelId1: attr1.baseSceneId,
                                                                                labelId2: attr2.baseSceneId,
                                                                                coefficient: 1.0) {
                    if(attr1.baseSceneId > attr2.baseSceneId) {
                        totalDenominator += Double(attr1.count + attr2.count)
                        totalMolecule += similality * Double(attr1.count + attr2.count)
//                        print("id1:\(attr1.baseSceneId) id2:\(attr2.baseSceneId) 類似度:\(similality)")
                    }
                }
            }
        }
        
//        print("\(totalMolecule) / \(totalDenominator)")
        
        if(totalDenominator == 0.0) {
            // カテゴリが混合していない場合，評価値は1.0
            return 1.0
        } else {
            return totalMolecule / totalDenominator
        }
    }
    
    // カテゴリ連合同士を比較してそのカテゴリ評価値を返します．
    func evaluateCategories(categotyAttributes: [CategoryAttribute],
                          fromRepresentativeSceneId: Int,
                          toRepresentativeSceneId: Int) -> Double {
        // 統合するカテゴリ連合
        var fromCategories = categotyAttributes.filter({
            $0.representativeSceneId == fromRepresentativeSceneId && $0.scenePriority
        })
        
        // 統合されるカテゴリ連合
        let toCategories = categotyAttributes.filter({
            $0.representativeSceneId == toRepresentativeSceneId && $0.scenePriority
        })
        
        for (index, _) in fromCategories.enumerated() {
            fromCategories[index].representativeSceneId = toRepresentativeSceneId
        }
//        print("カテゴリ擬似統合")
//        print("カテゴリ[\(fromRepresentativeSceneId)] \(fromCategories.count)枚 >> カテゴリ[\(toRepresentativeSceneId)] \(toCategories.count)枚")
        
        let newCategories = fromCategories + toCategories
        
        return evaluateCategory(categotyAttributes: newCategories, representativeSceneId: toRepresentativeSceneId)
    }
}
