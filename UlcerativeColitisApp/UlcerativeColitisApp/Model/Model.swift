//
//  Model.swift
//  UlcerativeColitisApp
//
//  Created by Engineer MacBook Air on 2025/04/28.
//

import SwiftUI
import RealmSwift


class DateData: Object, Identifiable {
    @Persisted(primaryKey: true) var id: ObjectId
    @Persisted var date: Date // 保存する日付
    @Persisted var stoolsCount: Int = 0
}

// お薬情報
class MedicineDataModel: Object, Identifiable {
    @Persisted(primaryKey: true) var id: ObjectId
    @Persisted var medicineName: String // 名前
    @Persisted var photoImage: Data?
    @Persisted var stock: Int? // 在庫
    @Persisted var dosingTime: Date? // 服用時間
    @Persisted var dosage: Int? // 服用量
    @Persisted var unit: String // 単位
    @Persisted var memo: String? // メモ
}
