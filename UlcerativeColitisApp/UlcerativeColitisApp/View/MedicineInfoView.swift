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
//    @State private var unit: String = "錠" // 初期値を設定
    @State private var predefinedUnits = ["錠", "個", "包", "mg", "ml"]
    @State private var selectedUnit: String = "錠" // Pickerで選択された値 - INITIALIZE TO "錠"
//    @State private var newUnit = "" // 新しい単位を入力するテキストフィールドの値
//    @State private var isEditing = false // 編集モードのトグル
//    @State private var isPicker = false // 編集モードのトグル
    
    @State var image: UIImage?
    @State private var showImagePickerDialog = false
    @State private var showCamera: Bool = false
    @State private var showLibrary: Bool = false
    @State private var showUnitPicker: Bool = false
    
    private var allAvailableUnits: [String] {
        var orderedUnits = predefinedUnits
        let unitsFromDb = medicineDataModel.flatMap { $0.unit }
        let uniqueUnitsFromDb = Array(Set(unitsFromDb)) // Setで重複を排除し、Arrayに戻す
        
        let additionalUnits = uniqueUnitsFromDb
            .filter { !orderedUnits.contains($0) } // predefinedUnits に既に含まれているものは除外
        
        orderedUnits.append(contentsOf: additionalUnits)
        
        return orderedUnits
    }
    
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
                        ForEach(allAvailableUnits, id: \.self) { unitText in
                            Text(unitText).tag(unitText)
                        }
                    }
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
                ShowUnitPicker(units: $predefinedUnits)
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
                        ForEach(allAvailableUnits, id: \.self) { unitText in
                            Text(unitText).tag(unitText)
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
}

//MARK: ShowUnitPicker
struct ShowUnitPicker: View {
    
    @ObservedResults(MedicineDataModel.self) var medicineDataModel
    @Environment(\.dismiss) var dismiss
    @State private var isEditing = false
    @Binding var units: [String] // MedicineInfoView の predefinedUnits へのバインディング
    @State private var showAddAlert = false
    @State private var newUnitTextField: String = ""
    
    // 表示用の単位を計算するプロパティ: 事前定義された単位とDB内の単位を組み合わせる
    private var displayableUnits: [String] {
        let unitsFromDb = medicineDataModel.flatMap { $0.unit }
        // バインドされた 'units' (事前定義されたもの) とDBからの単位を組み合わせる
        return Array(Set(self.units + unitsFromDb)).sorted()
    }
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("編集可能な単位リスト")) {
                    if units.isEmpty && !isEditing {
                        Text("単位がありません。「追加」して新しい単位を登録してください。")
                            .foregroundColor(.secondary)
                    }
                    ForEach(units.indices, id: \.self) { index in
                        Text(units[index])
                    }
                    .onDelete(perform: deletePredefinedUnit)
                }
                if !unitsFromDbOnly.isEmpty {
                    Section(header: Text("データベースで使用中の単位 (参考)")) {
                        ForEach(unitsFromDbOnly, id: \.self) { dbUnit in
                            Text(dbUnit)
                        }
                    }
                }
            }
            .navigationTitle("単位リスト管理")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(isEditing ? "完了" : "編集") {
                        isEditing.toggle()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Text("閉じる")
                    }
                }
                ToolbarItemGroup(placement: .bottomBar) {
                    Spacer()
                    Button {
                        newUnitTextField = ""
                        showAddAlert.toggle()
                    } label: {
                        Label("新しい単位を追加", systemImage: "plus.circle.fill")
                    }
                    .disabled(isEditing == false && units.isEmpty == false)
                }
            }
            .environment(\.editMode, .constant(isEditing ? EditMode.active : EditMode.inactive))
            .alert("新しい単位を追加", isPresented: $showAddAlert) {
                TextField("例: ml, スプレー", text: $newUnitTextField)
                Button("キャンセル", role: .cancel) {}
                Button("追加") {
                    addPredefinedUnit()
                }
                .disabled(newUnitTextField.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
        }
    }
    
    // DBには存在するが、事前定義リストには含まれていない単位
    private var unitsFromDbOnly: [String] {
        let dbUnits = Set(medicineDataModel.flatMap { $0.unit })
        let predefined = Set(self.units)
        return Array(dbUnits.subtracting(predefined)) // predefined に含まれない dbUnits の要素を返す
    }
    
    // @Binding 'units' (事前定義リスト) から削除する
    private func deletePredefinedUnit(at offsets: IndexSet) {
        units.remove(atOffsets: offsets)
        print("事前定義リストから単位を削除しました。現在のリスト: \(units)")
    }
    
    // @Binding 'units' (事前定義リスト) に追加する
    private func addPredefinedUnit() {
        let realm = try! Realm()
        let unitToAdd = newUnitTextField.trimmingCharacters(in: .whitespacesAndNewlines)
        if !unitToAdd.isEmpty && !units.contains(unitToAdd) {
            // 重複した提案を避けるためにDBに既に存在するかどうかも確認するが、ここでは 'units' が管理対象の主要リスト
            let allCurrentDisplayUnits = Set(displayableUnits)
            if allCurrentDisplayUnits.contains(unitToAdd) {
                print("単位 '\(unitToAdd)' はすでに存在します。")
            }
            if !units.contains(unitToAdd) { // バインドされたリストに追加する前の最終チェック
                units.append(unitToAdd)
                print("新しい単位を事前定義リストに追加しました: \(unitToAdd)。現在のリスト: \(units)")
            }
        }
        newUnitTextField = ""
    }
}

#Preview {
    MedicineInfoView()
}
