//
//  MedicineInfoView.swift
//  UlcerativeColitisApp
//
//  Created by Engineer MacBook Air on 2025/05/01.
//

import SwiftUI
import RealmSwift

//MARK: お薬情報画面
struct MedicineInfoView: View {
    
    @ObservedResults(MedicineDataModel.self) var medicineDataModel
    @Environment(\.dismiss) var dismiss // モーダルを閉じるためのプロパティ
    
    @State private var medicineNameTextField = "" // 薬の名前
    @State private var stockTextField = "" // 在庫
    @State private var stock: Int? = nil// Int型で保持するプロパティ
    @State private var dosageTextField = "" // 服用量
    @State private var dosage: Int? = nil// Int型で保持するプロパティ
    @State private var newMemoTextEditor = "" // メモ
    @State private var dosingTimePicker: Date = Date() // 服用時間
    @State private var addDosingTimePicker = false // 服用時間追加ボタン
    @State private var unit: String = "錠" // 初期値を設定
    @State private var units = ["錠", "mg", "ml", "カプセル", "包", "滴", "g", "単位"] // Pickerの選択肢
    @State private var selectedUnit = "錠" // Pickerで選択された値
    @State private var newUnit = "" // 新しい単位を入力するテキストフィールドの値
    @State private var isEditing = false // 編集モードのトグル
    @State private var isPicker = false // 編集モードのトグル
    
    @State var image: UIImage?
    @State private var showImagePickerDialog = false
    @State private var showCamera: Bool = false
    @State private var showLibrary: Bool = false
    @State private var showUnitPicker: Bool = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 40) {
                VStack(spacing: 10) {
                    //MARK: お薬の画像
                    VStack(alignment: .center, spacing: 10) {
                        if let image = image {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 100, height: 100)
                                .clipShape(Circle()) // 画像を丸くする
                        } else {
                            ZStack {
                                Rectangle()
                                    .fill(Color.clear)
                                    .frame(width: 100, height: 100)
                                Image(systemName: "pills.fill")
                                    .font(.system(size: 60))
                                    .foregroundColor(.gray)
                                    .background(
                                        Circle()
                                            .fill(Color.blue.opacity(0.4))
                                            .frame(width: 100, height: 100)
                                    )
                            }
                        }
                    }
                    .fullScreenCover(isPresented: $showCamera) {
                        CameraCaptureView(image: $image)
                            .ignoresSafeArea()
                    }
                    .sheet(isPresented: $showLibrary, content: {
                        PhotoLibraryPickerView(image: $image)
                            .ignoresSafeArea()
                    })
                    .confirmationDialog(
                        "",
                        isPresented: $showImagePickerDialog,
                        titleVisibility: .hidden
                    ) {
                        Button {
                            showCamera = true
                        } label: {
                            Text("カメラで撮る")
                        }
                        Button {
                            showLibrary = true
                        } label: {
                            Text("アルバムから選ぶ")
                        }
                        Button("キャンセル", role: .cancel) {
                            showImagePickerDialog = false
                        }
                    }
                    
                    //MARK: お薬の名前
                    VStack {
                        TextField("お薬の名前", text: $medicineNameTextField)
                            .frame(width: 150, height: 50)
                            .multilineTextAlignment(.center)
                            .padding(.bottom, 5)
                            .overlay(
                                Rectangle()
                                    .frame(height: 2)
                                    .foregroundColor(.gray)
                                    .padding(.top, -15),
                                
                                alignment: .bottom
                            )
                    }
                }
                
                //MARK: 服用量
                HStack {
                    Text("服用量")
                    TextField("", text: $dosageTextField)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.center)
                        .frame(width: 100)
                        .onChange(of: dosageTextField) { newValue in
                            dosage = Int(newValue) // 文字列を数値に変換
                        }
                    Picker("単位を選択", selection: $selectedUnit) {
//                        ForEach(Array(Set(medicineDataModel.map { $0.unit })), id: \.self) { unit in
//                            Text(unit)// 選択肢として表示
//                        }
                        ForEach(Array(Set(medicineDataModel.flatMap { $0.unit })), id: \.self) { unit in
                            Text(unit)
                        }
                    }
                    //                    Button(action: {
                    //                        isPicker.toggle()
                    //                    }) {
                    //                        Image(systemName: "plus")
                    //                    }
                    //                    .sheet(isPresented: $isPicker) {
                    //                        VStack {
                    //                            Text("単位を選択してください")
                    //                                .font(.headline)
                    //                                .padding()
                    //
                    //                            Picker("単位を選択", selection: $selectedUnit) {
                    //                                ForEach(units, id: \.self) { unit in
                    //                                    Text(unit).tag(unit)
                    //                                }
                    //                            }
                    //                            .labelsHidden() // ラベルを非表示
                    //                            .pickerStyle(WheelPickerStyle())
                    //                            .frame(height: 200)
                    //
                    //                            Button(action: {
                    //                                isPicker = false // Pickerを閉じる
                    //                            }) {
                    //                                Text("完了")
                    //                                    .padding()
                    //                                    .frame(maxWidth: .infinity)
                    //                                    .background(Color.green)
                    //                                    .foregroundColor(.white)
                    //                                    .cornerRadius(8)
                    //                                    .padding(.top)
                    //                            }
                    //                        }
                    //                    }
                    //                VStack(spacing: 20) {
                    //                    // Picker
                    //                    Picker("単位を選択", selection: $selectedUnit) {
                    //                        ForEach(units, id: \.self) { unit in
                    //                            Text(unit).tag(unit)
                    //                        }
                    //                    }
                    //                    .pickerStyle(WheelPickerStyle())
                    //                    .frame(height: 150)
                    //
                    //                    // 編集ボタン
                    //                    Button(action: {
                    //                        isEditing.toggle()
                    //                    }) {
                    //                        Text(isEditing ? "完了" : "編集")
                    //                            .padding()
                    //                            .frame(maxWidth: .infinity)
                    //                            .background(isEditing ? Color.green : Color.blue)
                    //                            .foregroundColor(.white)
                    //                            .cornerRadius(8)
                    //                    }
                    //
                    //                    // 編集モードのUI
                    //                    if isEditing {
                    //                        VStack(spacing: 10) {
                    //                            // 新しい単位を追加する部分
                    //                            HStack {
                    //                                TextField("新しい単位を追加", text: $newUnit)
                    //                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    //                                    .padding(.horizontal)
                    //
                    //                                Button(action: {
                    //                                    addUnit()
                    //                                }) {
                    //                                    Text("追加")
                    //                                        .padding(.horizontal)
                    //                                        .padding(.vertical, 8)
                    //                                        .background(Color.blue)
                    //                                        .foregroundColor(.white)
                    //                                        .cornerRadius(8)
                    //                                }
                    //                                .disabled(newUnit.isEmpty) // 空の場合はボタンを無効化
                    //                            }
                    //
                    //                            // 単位リスト（削除可能）
                    //                            List {
                    //                                ForEach(units, id: \.self) { unit in
                    //                                    Text(unit)
                    //                                }
                    //                                .onDelete(perform: deleteUnit) // スワイプで削除可能
                    //                            }
                    //                            .frame(height: 200) // リストの高さを調整
                    //                        }
                    //                    }
                    //                }
                }
                
                //MARK: 服用時間
                HStack {
                    Text("服用時間")
                    Button(action: {
                        addDosingTimePicker.toggle()
                    }) {
                        Image(systemName: "plus")
                    }
                    if addDosingTimePicker {
                        DatePicker("服用時間", selection: $dosingTimePicker, displayedComponents: .hourAndMinute)
                            .labelsHidden()
                    }
                }
                
                //MARK: 在庫
                HStack {
                    Text("在庫")
                    TextField("", text: $stockTextField)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .multilineTextAlignment(.center)
                        .frame(width: 100)
                        .onChange(of: dosageTextField) { newValue in
                            stock = Int(newValue) // 文字列を数値に変換
                        }
                    Text(selectedUnit)
                }
                .padding()
                
                //MARK: メモ
                ZStack(alignment: .topLeading) {
                    TextEditor(text: $newMemoTextEditor)
                        .frame(maxWidth: .infinity)
                        .frame(height: 100)
                        .border(.gray)
                    
                    if newMemoTextEditor.isEmpty {
                        Text("メモ")
                            .foregroundColor(Color(.placeholderText))
                            .padding(.vertical, 5)
                            .padding(.horizontal, 5)
                            .allowsHitTesting(false)
                    }
                }
                .padding()
                
                //MARK: キャンセル・保存ボタン
                HStack {
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 150, height: 40)
                        Text("キャンセル")
                    }
                    .onTapGesture {
                        dismiss()
                        stockTextField = ""
                        dosageTextField = ""
                        newMemoTextEditor = ""
                        medicineNameTextField = ""
                    }
                    Spacer()
                        .frame(width: 45)
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 150, height: 40)
                        Text("保存")
                    }
                    .onTapGesture {
                        if medicineNameTextField.isEmpty {
                        } else {
                            saveMedicineInfo()
                        }
                        dismiss()
                    }
                }
                .padding(.horizontal)
                Spacer()
            }
            .padding()
            
            //MARK: ツールバー
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu("編集") {
                        Button(action: {
                            if image != nil {
                                self.image = nil
                            }
                            
                            if image == nil {
                                showImagePickerDialog = true
                            }
                        }) {
                            Text("画像を変更")
                        }
                        
                        Button(action: {
                            showUnitPicker = true
                        }) {
                            Text("お薬の単位を変更")
                        }
                    }
                }
            }
            .sheet(isPresented: $showUnitPicker) {
                ShowUnitPicker(selectedUnit: $selectedUnit, units: units)
            }
            
            .sheet(isPresented: $showUnitPicker) {
                VStack {
                    HStack {
                        Button("キャンセル", role: .cancel) {
                            showUnitPicker = false
                        }
                        Spacer()
                        Button(action: {
                            
                        }) {
                            Text("編集")
                        }
                    }
                    .padding()
                    Picker("単位を選択", selection: $selectedUnit) {
                        ForEach(units, id: \.self) { list in
                            Text(list)
                        }
                    }
                    .pickerStyle(WheelPickerStyle())
                    .presentationDetents([.height(200)])
                }
            }
        }
    }
    
    //MARK: メソッド
    func saveMedicineInfo() {
        let realm = try! Realm()
        try! realm.write {
            let medicineDataModel = MedicineDataModel()
            medicineDataModel.medicineName = medicineNameTextField
            medicineDataModel.dosage = dosage
            medicineDataModel.stock = stock
            medicineDataModel.memo = newMemoTextEditor
            realm.add(medicineDataModel)
        }
    }
    
    private func addUnit() {
        if !newUnit.isEmpty && !units.contains(newUnit) {
            units.append(newUnit)
            newUnit = "" // 入力フィールドをリセット
        }
    }
    
    // 単位を削除
    private func deleteUnit(at offsets: IndexSet) {
        units.remove(atOffsets: offsets)
    }
}

struct ShowUnitPicker: View {
    
    @ObservedResults(MedicineDataModel.self) var medicineDataModel
    @Binding var selectedUnit: String
    @State var units: [String]
    @State private var showAddAlert = false
    @State private var newUnit: String = ""
    
    var body: some View {
        List {
            Section {
                ForEach(uniqueUnits, id: \.self) { list in
                    Text(list)
                }
                .onDelete(perform: deleteUnit)
            } header: {
                HStack {
                    EditButton()
                    Spacer()
                    Button(action: {
                        showAddAlert.toggle()
                    }) {
                        Text("追加")
                    }
                    .alert("お薬の単位", isPresented: $showAddAlert) {
                        TextField("錠", text: $newUnit)
                        Button("キャンセル", role: .cancel) {}
                        Button(action: {
                            addUnit()
                        }) {
                            Text("追加")
                        }
                    }
                }
            }
        }
    }
    
    private var uniqueUnits: [String] {
        Array(Set(medicineDataModel.flatMap { $0.unit })).sorted()
    }
    
    private func deleteUnit(at offsets: IndexSet) {
        for index in offsets {
            let unitToDelete = uniqueUnits[index]
            let realm = try! Realm()
            
            // 解凍したオブジェクトを使用する
            let thawedModels = medicineDataModel.thaw()
            
            try! realm.write {
                // 凍結解除されたデータモデルを使用して更新
                thawedModels?
                    .filter { $0.unit.contains(unitToDelete) }
                    .forEach { model in
                        realm.delete(model)
                }
            }
        }
    }

    
    private func addUnit() {
        if !newUnit.isEmpty {
            let realm = try! Realm()
            try! realm.write {
                let newMedicine = MedicineDataModel()
                newMedicine.unit.append(newUnit)
                realm.add(newMedicine)
            }
            newUnit = ""
        }
    }
}

#Preview {
    MedicineInfoView()
}
#Preview {
    ShowUnitPicker(selectedUnit: .constant(""), units: ["あ", "い"])
}
