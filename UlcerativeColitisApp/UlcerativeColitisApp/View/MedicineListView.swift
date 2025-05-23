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
            ForEach(medicineDataModel, id: \.self) { list in
                HStack {
                    Text(list.medicineName)
                    Text("\(list.dosage ?? 0)")
                    Text("\(list.stock ?? 1)")
                    Text(list.memo ?? "")
                }
            }
        }
    }
}

#Preview {
    MedicineListView()
}
