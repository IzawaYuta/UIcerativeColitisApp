//
//  MedicineListView.swift
//  UlcerativeColitisApp
//
//  Created by Engineer MacBook Air on 2025/05/23.
//

import SwiftUI
import RealmSwift

struct MedicineListView: View {
    
    @ObservedResults(MedicineDataModel.self) var medicineDataModel
    
    var body: some View {
        List {
            ForEach(medicineDataModel) { list in
                Text(list.medicineName)
            }
        }
    }
}

#Preview {
    MedicineListView()
}
