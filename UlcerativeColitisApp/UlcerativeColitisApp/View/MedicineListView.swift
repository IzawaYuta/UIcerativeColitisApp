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
        NavigationStack {
            VStack {
                ForEach(medicineDataModel, id: \.self) { list in
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.gray.gradient.secondary)
                            .frame(maxWidth: .infinity)
                            .frame(height: 70)
                        HStack {
                            Text(list.medicineName)
                            Text("\(list.dosage ?? 0)")
                            Text("\(list.stock ?? 0)")
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
    }
}

#Preview {
    MedicineListView()
}
