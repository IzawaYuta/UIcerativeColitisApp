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
//        NavigationStack {
//            VStack {
//                ForEach(medicineDataModel, id: \.self) { list in
//                    ZStack {
//                        RoundedRectangle(cornerRadius: 10)
//                            .fill(Color.gray.gradient.secondary)
//                            .frame(maxWidth: .infinity)
//                            .frame(height: 70)
//                        HStack {
//                            Text(list.medicineName)
//                            Text("\(list.dosage ?? 0)")
//                            Text("\(list.stock ?? 0)")
//                        }
//                    }
//                    .padding(.horizontal)
//                }
//                Spacer()
//            }
//            .padding(.vertical)
//            .environment(\.editMode, $editMode)
//            .toolbar {
//                ToolbarItem(placement: .navigationBarTrailing) {
//                    Text(editMode.isEditing ? "終了" : "編集")
//                        .onTapGesture {
//                            if editMode.isEditing {
//                                editMode = .inactive
//                            } else {
//                                editMode = .active
//                            }
//                        }
//                }
//            }
//        }
        NavigationStack {
            List {
                ForEach(medicineDataModel, id: \.self) { list in
                    HStack {
                        Text(list.medicineName)
                        Spacer()
                        Text("\(list.dosage ?? 0)")
                        Spacer()
                        Text("\(list.stock ?? 0)")
                    }
                    .listRowSeparatorTint(.clear)
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
