//
//  MedicineListView.swift
//  UlcerativeColitisApp
//
//  Created by Engineer MacBook Air on 2025/05/23.
//

import SwiftUI
import RealmSwift

enum MedicineViewPicker: String, CaseIterable {
    case allMedicine = "全て"
    case usualMedicine = "いつもの"
}

struct MedicineListView: View {
    
    @ObservedResults(MedicineDataModel.self) var medicineDataModel
    @ObservedResults(UsualMedicineModel.self) var usualMedicineModel
    
    @State private var targetGroup: UsualMedicineModel?
    @State private var editMode: EditMode = .inactive
    @State private var topTab: MedicineViewPicker = .allMedicine
    @State private var showMedicineList = false
    @State private var showUsualMedicineEditView = false
    @State private var newUsual = ""
    @State private var selectedItems: Set<ObjectId> = [] // 選択された項目のIDを保持
    
    var body: some View {
        NavigationStack {
            VStack {
                HStack {
                    ForEach(MedicineViewPicker.allCases, id: \.self) { picker in
                        Text(picker.rawValue)
                            .fontWeight(topTab == picker ? .bold : .regular)
                            .foregroundColor(topTab == picker ? .blue : .gray)
                            .padding()
                            .onTapGesture {
                                topTab = picker
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                    }
                }
                .background(Color(UIColor.systemGray5))
                //                .clipShape(Capsule())
                //                .padding(.vertical, 10)
                //                .padding(.horizontal, 10)
                
                // 選択されたタブに応じたコンテンツ
                if topTab == .allMedicine {
                    medicineListView()
                } else if topTab == .usualMedicine {
                    usualMedicineView()
                }
            }
            .navigationTitle("お薬")
            .toolbarBackground(Color.gray, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .navigationBarTitleDisplayMode(.inline)
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
    
    func medicineListView() -> some View {
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
                .listRowSeparator(.hidden) // リスト全体の区切り線を非表示
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
    }
    
    func medicineList() -> some View {
        VStack {
            Button(action: {
                
            }) {
                Image(systemName: "arrowshape.up")
            }
            List {
                if medicineDataModel.isEmpty {
                    // データが空の場合の表示
                    Text("お薬を登録してください")
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity, alignment: .center)
                } else {
                    // データが存在する場合のリスト
                    ForEach(medicineDataModel.filter { !$0.medicineName.isEmpty }, id: \.id) { medicine in
                        HStack {
                            Image(systemName: selectedItems.contains(medicine.id) ? "circle.fill" : "circle")
                                .font(.system(size: 15))
                            Text(medicine.medicineName)
                            Spacer()
                        }
                        .frame(maxWidth: .infinity) // HStackをリストの幅全体に広げる
                        .contentShape(Rectangle()) // タップ可能な領域を拡張
                        .onTapGesture {
                            toggleSelection(for: medicine.id)
                        }
                    }
                }
            }
        }
    }
    
    // 選択状態を切り替える
    private func toggleSelection(for id: ObjectId) {
        if selectedItems.contains(id) {
            selectedItems.remove(id)
        } else {
            selectedItems.insert(id)
        }
    }
    
    func usualMedicineView() -> some View {
        VStack {
            Button(action: {
                showUsualMedicineEditView.toggle()
            }) {
                Image(systemName: "plus")
            }
            .sheet(isPresented: $showUsualMedicineEditView) {
                usualMedicineViewEditView()
            }
            
            List {
                ForEach(usualMedicineModel, id: \.id) { list in
                    VStack {
                        Text(list.groupName)
                            .font(.title3)
                        Text(list.medicines.map { $0.medicineName }.joined(separator: "\n"))
                        .foregroundColor(.secondary)
                    }
                }
            }
        }
    }
    
    func saveUsualMedicineList() {
        let realm = try! Realm()
        
        let selectedMedicines = realm.objects(MedicineDataModel.self).filter("id IN %@", selectedItems)
        
        try! realm.write {
            let model = UsualMedicineModel()
            model.groupName = newUsual
            
            model.medicines.append(objectsIn: selectedMedicines)
            
            realm.add(model)
        }
        newUsual = ""
        selectedItems.removeAll()
    }
    
    func usualMedicineViewEditView() -> some View {
        VStack {
            Button(action: {
                saveUsualMedicineList()
                showUsualMedicineEditView = false
            }) {
                Image(systemName: "plus")
            }
            TextField("", text: $newUsual)
                .textFieldStyle(.roundedBorder)
            
            List {
                ForEach(medicineDataModel.filter { !$0.medicineName.isEmpty }, id: \.id) { medicine in
                    HStack {
                        Image(systemName: selectedItems.contains(medicine.id) ? "circle.fill" : "circle")
                            .font(.system(size: 15))
                        Text(medicine.medicineName)
                        Spacer()
                    }
                    .frame(maxWidth: .infinity) // HStackをリストの幅全体に広げる
                    .contentShape(Rectangle()) // タップ可能な領域を拡張
                    .onTapGesture {
                        toggleSelection(for: medicine.id)
                    }
                }
            }
        }
    }
}

#Preview {
    MedicineListView()
}



//func addSelectedMedicinesToGroup() {
//    // 編集対象のグループが存在しない場合は何もしない
//    guard let groupToUpdate = targetGroup else { return }
//    
//    let realm = try! Realm()
//    
//    // 選択されたIDに合致する、管理下のMedicineDataModelオブジェクトを取得
//    let selectedMedicines = realm.objects(MedicineDataModel.self)
//        .filter("id IN %@", selectedItems)
//    
//    try! realm.write {
//        // Realmが管理している最新のグループオブジェクトを取得
//        guard let thawedGroup = groupToUpdate.thaw() else {
//            // オブジェクトが削除されているなど、何らかの理由で取得できない場合は終了
//            return
//        }
//        
//        // 既存の薬リストをクリア
//        thawedGroup.medicines.removeAll()
//        // 新しく選択された薬リストを追加
//        thawedGroup.medicines.append(objectsIn: selectedMedicines)
//    }
//    }
