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
    //    var medicineModel: MedicineDataModel
    @State var overwriteMedicine: MedicineDataModel? // 編集対象のデータ
    @Environment(\.dismiss) var dismiss // モーダルを閉じるためのプロパティ
    
    @State private var medicineNameTextField = "" // 薬の名前
    @State private var stockTextField = "" // 在庫
    @State private var stock: Int? = 0// Int型で保持するプロパティ
    @State private var dosageTextField = "" // 服用量
    @State private var dosage: Int? = 0// Int型で保持するプロパティ
    @State private var newMemoTextEditor = "" // メモ
    @State private var dosingTimePicker: Date = Date() // 服用時間
    @State private var addDosingTimePicker = false // 服用時間追加ボタン
    @State private var predefinedUnits = ["錠", "個", "包", "mg", "ml"]
    @State private var selectedUnit: String = "錠" // Pickerで選択された値
    @State private var showingDatePickerSheet = false
    @State private var newDosingTime = Date()
    @State private var dosingTimeList: [Date] = []
    @State var image: UIImage?
    @State private var showImagePickerDialog = false
    @State private var showCamera: Bool = false
    @State private var showLibrary: Bool = false
    @State private var showUnitPicker: Bool = false
    @State private var showDosingTimeList: Bool = false
    
    private var allUnits: [String] {
        Array(Set(medicineDataModel.flatMap { $0.unitList })).sorted()
    }
    
    var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return formatter
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
                            //                            if let modelImageData = medicineModel.photoImage {
                            //                                image = UIImage(data: modelImageData)
                            //                                Image(uiImage: modelImageData)
                            //                                    .resizable()
                            //                                    .frame(width: 100, height: 100)
                            //                            } else {
                            //                                ZStack {
                            //                                    Rectangle()
                            //                                        .fill(Color.clear)
                            //                                        .frame(width: 100, height: 100)
                            //                                    Image(systemName: "pills.fill")
                            //                                        .font(.system(size: 60))
                            //                                        .foregroundColor(.gray)
                            //                                        .background(
                            //                                            Circle()
                            //                                                .fill(Color.blue.opacity(0.4))
                            //                                                .frame(width: 100, height: 100)
                            //                                        )
                            //                                }
                            //                            }
                            if let modelImageData = overwriteMedicine?.photoImage {
                                if let uiImage = UIImage(data: modelImageData) {
                                    Image(uiImage: uiImage)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 100, height: 100)
                                        .clipShape(Circle())
                                } else {
                                    // デコードに失敗した場合のフォールバック
                                    fallbackView()
                                }
                            } else {
                                fallbackView()
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
                            .onAppear {
                                medicineNameTextField = overwriteMedicine?.medicineName ?? ""
                            }
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
                        .onAppear {
                            if let dosage = overwriteMedicine?.dosage {
                                dosageTextField = "\(dosage)"
                            } else {
                                dosageTextField = "" // デフォルト値（空文字列）を設定
                            }
                        }
                    if allUnits.isEmpty {
                        unitEmpty()
                    } else {
                        Picker("単位を選択", selection: $selectedUnit) {
                            ForEach(allUnits, id: \.self) { unitText in
                                Text(unitText).tag(unitText)
                            }
                        }
                        .onAppear {
                            if let unit = overwriteMedicine?.unit {
                                selectedUnit = unit
                            } else if let firstUnit = allUnits.first {
                                selectedUnit = firstUnit
                            }
                        }
                    }
                }
                
                //MARK: 服用時間
                HStack {
                    HStack {
                        Text("服用時間")
                        
                        let maxDosingTimeCount = 5
                        
                        if dosingTimeList.count < maxDosingTimeCount {
                            Button(action: {
                                newDosingTime = Date()
                                showingDatePickerSheet = true
                            }) {
                                Image(systemName: "plus")
                            }
                        }
                    }
                    .sheet(isPresented: $showingDatePickerSheet) {
                        NavigationView {
                            VStack {
                                DatePicker(
                                    "Select Time",
                                    selection: $newDosingTime,
                                    displayedComponents: .hourAndMinute
                                )
                                .datePickerStyle(.wheel)
                                .labelsHidden()
                                .padding()
                                
                                Spacer()
                            }
                            .navigationTitle("Add New Dosing Time")
                            .navigationBarTitleDisplayMode(.inline)
                            .toolbar {
                                ToolbarItem(placement: .navigationBarLeading) {
                                    Button("Cancel") {
                                        showingDatePickerSheet = false
                                    }
                                }
                                ToolbarItem(placement: .navigationBarTrailing) {
                                    Button("Add") {
                                        addSelectedDosingTime()
                                        showingDatePickerSheet = false
                                        dosingTimeList.append(newDosingTime)
                                    }
                                }
                            }
                        }
                    }
                    Spacer()
                    if let overwriteMedicine = medicineDataModel.first(where: { $0.id == self.overwriteMedicine?.id }) {
                        let overwriteDosingTime = overwriteMedicine.dosingTime
                        ForEach(overwriteDosingTime, id: \.self) { time in
                            Text(time ?? Date(), formatter: dateFormatter)
                        }
                    } else {
                        ForEach(dosingTimeList, id: \.self) { time in
                            Text(time, formatter: dateFormatter)
                        }
                    }
                }
                .padding(.horizontal)
                
                //MARK: 在庫
                HStack {
                    Text("在庫")
                    TextField("", text: $stockTextField)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .multilineTextAlignment(.center)
                        .frame(width: 100)
                        .onChange(of: stockTextField) { newValue in
                            stock = Int(newValue) // 文字列を数値に変換
                        }
                        .onAppear {
                            if let dosage = overwriteMedicine?.stock {
                                stockTextField = "\(dosage)"
                            } else {
                                stockTextField = "" // デフォルト値（空文字列）を設定
                            }
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
                            .onAppear {
                                newMemoTextEditor = overwriteMedicine?.memo ?? ""
                            }
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
            .onAppear {
                for model in medicineDataModel {
                    print(model.unitList)
                }
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
                        Button(action: {
                            showDosingTimeList = true
                        }) {
                            Text("服用時間")
                        }
                    }
                }
            }
            .sheet(isPresented: $showUnitPicker) {
                ShowUnitPicker(units: $predefinedUnits)
            }
            .sheet(isPresented: $showDosingTimeList) {
                dosingTimeListView()
            }
        }
    }
    
    //MARK: メソッド
    func saveMedicineInfo() {
        let realm = try! Realm()
        try! realm.write {
            if let overwrite = overwriteMedicine?.thaw() {
                // 変更があるか確認
                let overwriteJpegImage = image?.jpegData(compressionQuality: 1.0)
                if overwrite.medicineName == medicineNameTextField &&
                    overwrite.dosage == dosage &&
                    overwrite.memo == newMemoTextEditor &&
                    overwrite.photoImage == overwriteJpegImage &&
                    overwrite.unit == selectedUnit &&
                    overwrite.stock == stock {
                    // 変更がない場合は保存せず終了
                    print("変更がないため保存しません")
                    return
                }
                
                // 既存データを更新
                overwrite.medicineName = medicineNameTextField
                overwrite.dosage = dosage
                overwrite.memo = newMemoTextEditor
                overwrite.photoImage = overwriteJpegImage
                overwrite.unit = selectedUnit
                overwrite.stock = stock
                overwrite.dosingTime.append(objectsIn: dosingTimeList)
            } else {
                // 新規データ作成
                let medicineDataModel = MedicineDataModel()
                let jpagImage = image?.jpegData(compressionQuality: 1.0)
                medicineDataModel.photoImage = jpagImage
                medicineDataModel.medicineName = medicineNameTextField
                medicineDataModel.dosage = dosage
                medicineDataModel.unit = selectedUnit
                medicineDataModel.stock = stock
                medicineDataModel.memo = newMemoTextEditor
                realm.add(medicineDataModel)
                medicineDataModel.dosingTime.append(objectsIn: dosingTimeList)
            }
        }
        dosingTimeList = []
    }
    
    private func addSelectedDosingTime() {
        let realm = try! Realm()
        try! realm.write {
            guard let liveMedicine = medicineDataModel.first?.thaw() else {
                print("Error: No valid MedicineDataModel object found.")
                return
            }
            liveMedicine.dosingTime.append(newDosingTime)
        }
    }
    
    private func fallbackView() -> some View {
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
    
    private func unitEmpty() -> some View {
        Button(action: {
            showUnitPicker.toggle()
        }) {
            Image(systemName: "plus")
        }
        .sheet(isPresented: $showUnitPicker) {
            ShowUnitPicker(units: $predefinedUnits)
        }
    }
    
    private func dosingTimeListView() -> some View {
        if let overwriteMedicine = medicineDataModel.first(where: { $0.id == self.overwriteMedicine?.id }) {
            let overwriteDosingTime = overwriteMedicine.dosingTime
            return AnyView(
                List {
                    ForEach(overwriteDosingTime, id: \.self) { time in
                        if let time = time {
                            Text(time, formatter: dateFormatter)
                        }
                    }
                    .onDelete { indexSet in
                        deleteDosingTime(at: indexSet)
                    }
                }
            )
        } else {
            return AnyView(Text("データがありません").foregroundColor(.gray))
        }
    }
    
    private func deleteDosingTime(at offsets: IndexSet) {
        guard let medicineToUpdate = overwriteMedicine?.thaw(), !medicineToUpdate.isInvalidated else {
            print("Error: overwriteMedicine is nil or invalidated.")
            return
        }
        
        guard let realm = medicineToUpdate.realm else {
            print("Error: Could not get Realm instance from medicine object. The object might not be managed by Realm, or it could be frozen in a way that realm is not accessible.")
            return
        }
        let validIndicesArray = offsets.filter { $0 < medicineToUpdate.dosingTime.count }
        
        let validOffsets = IndexSet(validIndicesArray)
        if validOffsets.isEmpty && !offsets.isEmpty {
            return
        }
        if validOffsets.count != offsets.count {
        }
        
        
        do {
            try realm.write {
                medicineToUpdate.dosingTime.remove(atOffsets: validOffsets)
            }
            print("Successfully committed realm.write. Final count after transaction: \(medicineToUpdate.dosingTime.count)")
        } catch {
            print("Error deleting dosing time: \(error.localizedDescription)")
        }
    }
}

//MARK: ShowUnitPicker
struct ShowUnitPicker: View {
    
    @ObservedResults(MedicineDataModel.self) var medicineDataModel
    @Environment(\.dismiss) var dismiss
    
    @State private var showAddDummyAlert = false
    @State private var newUnitTextField = ""
    @Binding var units: [String]
    
    private var allUnits: [String] {
        Array(Set(medicineDataModel.flatMap { $0.unitList })).sorted()
    }
    
    var body: some View {
        NavigationView {
            List {
                if allUnits.isEmpty {
                    Text("単位を追加してください")
                } else {
                    ForEach(allUnits, id: \.self) { unitName in
                        Text(unitName)
                    }
                    .onDelete(perform: deleteOrModifyUnit)
                }
            }
            .navigationTitle("単位を管理")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    HStack {
                        Button("追加") {
                            showAddDummyAlert.toggle()
                        }
                        .alert("", isPresented: $showAddDummyAlert) {
                            TextField("mg、本", text: $newUnitTextField)
                            Button("キャンセル", role: .cancel) {}
                            Button("保存") {
                                addNewUnitToDatabase()
                            }
                        }
                        EditButton()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) { Button("閉じる") { dismiss() } }
            }
        }
    }
    
    // 単位の削除または変更（非常に複雑な処理になる）
    private func deleteOrModifyUnit(at offsets: IndexSet) {
        let realm = try! Realm()
        for index in offsets {
            let unitNameToModify = allUnits[index]
            
            
            print("警告: 単位 '\(unitNameToModify)' を全ての薬から削除しますか？この操作は元に戻せません。")
            try! realm.write {
                let medicinesToUpdate = medicineDataModel.where {
                    $0.unitList.contains(unitNameToModify)
                }.thaw()
                
                if let medicinesToUpdate = medicinesToUpdate {
                    for medicine in medicinesToUpdate {
                        if let thawedMedicine = medicine.thaw() {
                            if let unitIndex = thawedMedicine.unitList.firstIndex(of: unitNameToModify) {
                                thawedMedicine.unitList.remove(at: unitIndex)
                                print("薬 '\(thawedMedicine.medicineName)' から単位 '\(unitNameToModify)' を削除しました。")
                            }
                        }
                    }
                } else {
                    print("単位 '\(unitNameToModify)' を含む薬が見つかりませんでした（解凍失敗）。")
                }
            }
        }
    }
    
    private func addNewUnitToDatabase() {
        let realm = try! Realm()
        let unitName = newUnitTextField.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if unitName.isEmpty {
            newUnitTextField = ""
            return
        }
        
        let model = MedicineDataModel()
        model.unitList.append(unitName)
        
        try! realm.write {
            realm.add(model)
        }
    }
}

#Preview {
    MedicineInfoView()
}
#Preview {
    MedicineListView()
}
