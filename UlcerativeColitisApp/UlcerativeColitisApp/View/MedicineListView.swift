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
                self.targetGroup = nil
                showUsualMedicineEditView.toggle()
            }) {
                Image(systemName: "plus")
            }
            
            List {
                ForEach(usualMedicineModel) { list in
                    Button(action: {
                        self.targetGroup = list
                        self.showUsualMedicineEditView.toggle()
                    }) {
                        HStack {
                            VStack(alignment: .leading) {
                                Text(list.groupName)
                                    .font(.title3)
                                Text(list.medicines.map { $0.medicineName }.joined(separator: "\n"))
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray.opacity(0.5))
                        }
                        .contentShape(Rectangle()) // 行全体をタップ可能に
                    }
                    .buttonStyle(.plain) // Buttonのデフォルトスタイルを無効化
                }
                .onDelete(perform: deleteMedicine) // 削除機能を追加
            }
        }
        .sheet(isPresented: $showUsualMedicineEditView) {
            NavigationView {
                usualMedicineViewEditView()
            }
        }
    }
    
//    func deleteUsualMedicine(at offsets: IndexSet) {
//        // 削除対象のオブジェクトのIDリストを取得
//        let idsToDelete = offsets.map { usualMedicineModel[$0].id }
//        
//        let realm = try! Realm()
//        
//        try! realm.write {
//            // 取得したIDを使って、データベースから削除対象のオブジェクトを再度検索
//            let groupsToDelete = realm.objects(UsualMedicineModel.self).filter("id IN %@", idsToDelete)
//            
//            // ★★★ 最も重要なステップ ★★★
//            // オブジェクトを削除する前に、そのオブジェクトが持つ薬のリストへの参照をクリアします。
//            // これにより、カスケード削除（連鎖削除）が防がれ、MedicineDataModelはデータベースに残り続けます。
//            for group in groupsToDelete {
//                group.medicines.removeAll()
//            }
//            
//            // 参照をクリアした後、グループオブジェクト本体を削除します。
//            realm.delete(groupsToDelete)
//        }
//    }
    
//    private func deleteUsualMedicineGroup(at offsets: IndexSet) {
//        try? Realm().write {
//            offsets.map { usualMedicineModel[$0] }.forEach { group in
//                if let groupToDelete = group.thaw() { // スレッド間で安全にオブジェクトを扱うためthaw()を推奨
//                    Realm.Configuration.defaultConfiguration.realm?.delete(groupToDelete)
//                }
//            }
//        }
//    }
    func saveUsualMedicineList() {
        let realm = try! Realm()
        
        // 選択されたIDからMedicineDataModelオブジェクトのリストを取得
        let selectedMedicines = realm.objects(MedicineDataModel.self).filter("id IN %@", selectedItems)
        
        try! realm.write {
            if let groupToEdit = targetGroup, let thawedGroup = groupToEdit.thaw() {
                // 【編集モード】既存のグループを更新
                thawedGroup.groupName = newUsual
                thawedGroup.medicines.removeAll()
                thawedGroup.medicines.append(objectsIn: selectedMedicines)
            } else {
                // 【新規作成モード】新しいグループを作成
                let model = UsualMedicineModel()
                model.groupName = newUsual
                model.medicines.append(objectsIn: selectedMedicines)
                realm.add(model)
            }
        }
        newUsual = ""
        selectedItems.removeAll()
        targetGroup = nil
    }
    
    func usualMedicineViewEditView() -> some View {
        VStack {
            Button(action: {
                saveUsualMedicineList()
                showUsualMedicineEditView = false
            }) {
                Image(systemName: "circle")
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
                    .frame(maxWidth: .infinity) 
                    .contentShape(Rectangle()) // タップ可能な領域を拡張
                    .onTapGesture {
                        toggleSelection(for: medicine.id)
                    }
                    .onAppear {
                        newUsual = targetGroup?.groupName ?? ""
                        selectedItems = Set(targetGroup?.medicines.map { $0.id } ?? [])
                    }
                }
            }
        }
    }
}

#Preview {
    MedicineListView()
}
