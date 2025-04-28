//
//  Model.swift
//  UlcerativeColitisApp
//
//  Created by Engineer MacBook Air on 2025/04/28.
//

import SwiftUI
import RealmSwift

// データモデル
class DateData: Object, Identifiable {
    @Persisted(primaryKey: true) var id: ObjectId
    @Persisted var date: Date // 保存する日付
    @Persisted var note: String // 保存するメモ
}
