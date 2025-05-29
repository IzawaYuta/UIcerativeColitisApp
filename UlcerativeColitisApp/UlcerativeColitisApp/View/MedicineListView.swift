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
    
    @State private var editMode: EditMode = .inactive
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(medicineDataModel, id: \.self) { list in
                    NavigationLink(destination: MedicineInfoView(medicineModel: list)) {
                        HStack {
                            Text(list.medicineName)
                            Spacer()
                            Text("\(list.dosage ?? 0)")
                            Spacer()
                            Text("\(list.stock ?? 0)")
                        }
                        .listRowSeparatorTint(.clear)
                    }
                }
                .padding(.horizontal)
                .frame(height: 60)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.cyan.gradient.secondary)
                )
            }
            .listStyle(.inset)
            .padding(.horizontal)
            .navigationTitle("お薬")
        }
    }
}

#Preview {
    MedicineListView()
}
