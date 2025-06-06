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
                ForEach(medicineDataModel.filter{ !$0.medicineName.isEmpty }, id: \.id) { list in
                    NavigationLink(destination: MedicineInfoView(overwriteMedicine: list)) {
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
                .onDelete(perform: deleteMedicine)
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
//            .onAppear {
//                print(medicineDataModel.count)
//            }
        }
    }
    
    private func deleteMedicine(at offsets: IndexSet) {
        let filtered = medicineDataModel.filter { !$0.medicineName.isEmpty }
        let realm = try! Realm()
        try! realm.write {
            offsets.map { filtered[$0] }.forEach { item in
                if let obj = realm.object(ofType: MedicineDataModel.self, forPrimaryKey: item.id) {
                    realm.delete(obj)
                }
            }
        }
    }
}

#Preview {
    MedicineListView()
}
