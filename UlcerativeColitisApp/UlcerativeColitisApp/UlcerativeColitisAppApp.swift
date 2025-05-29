//
//  UlcerativeColitisAppApp.swift
//  UlcerativeColitisApp
//
//  Created by Engineer MacBook Air on 2025/04/27.
//

import SwiftUI
import RealmSwift

@main
struct UlcerativeColitisAppApp: App {
    
    init() {
        insertInitialDataIfNeeded()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
    
    func insertInitialDataIfNeeded() {
        let defaults = UserDefaults.standard
        
        // 初期データが挿入済みか確認
        if !defaults.bool(forKey: "isInitialDataInserted") {
            let realm = try! Realm()
            try! realm.write {
                let model = MedicineDataModel()
                model.unit.append(objectsIn: ["錠", "個"])
                realm.add(model)
            }
            
            // データ挿入済みを記録
            defaults.set(true, forKey: "isInitialDataInserted")
        }
    }
}
