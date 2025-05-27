//
//  Model.swift
//  UlcerativeColitisApp
//
//  Created by Engineer MacBook Air on 2025/04/28.
//

//import SwiftUI
import RealmSwift


class DateData: Object, Identifiable {
    @Persisted(primaryKey: true) var id: ObjectId
    @Persisted var date: Date // 保存する日付
    @Persisted var stoolsCount: Int = 0
}

//MARK: お薬情報
class MedicineDataModel: Object, Identifiable {
    @Persisted(primaryKey: true) var id: ObjectId
    @Persisted var medicineName: String // 名前
    @Persisted var photoImage: Data?
    @Persisted var stock: Int? // 在庫
    @Persisted var dosingTime: Date? // 服用時間
    @Persisted var dosage: Int? // 服用量
    @Persisted var unit: List<String> // 単位
    @Persisted var memo: String? // メモ
}

//MARK: 排便記録
class StoolRecordModel: Object, Identifiable {
    @Persisted(primaryKey: true) var id: ObjectId // 一意の識別子
    @Persisted var date: Date // 記録の日付
    @Persisted var times: Int // 便の回数
    @Persisted var stoolTimes: List<Date> // 便をした時間のリスト
    @Persisted var stoolTypes: List<Int> // 便の種類（1〜6の整数で管理）
    
    func readableStoolTypes() -> [String] {
        let typeDescriptions = [
            1: "硬便",
            2: "普通便",
            3: "軟便",
            4: "下痢",
            5: "便秘",
            6: "血便"
        ]
        return stoolTypes.compactMap { typeDescriptions[$0] }
    }
}

//MARK: メモ
class MemoModel: Object, Identifiable {
    @Persisted(primaryKey: true) var id: ObjectId // 一意の識別子
    @Persisted var date: Date // 日付
    @Persisted var memo: String = "" // メモ
}

//MARK: 潰瘍性大腸炎になって何日カウント
class UCCountModel: Object, Identifiable {
    @Persisted var id = UUID()
    @Persisted var date: Date? = Date()
}
