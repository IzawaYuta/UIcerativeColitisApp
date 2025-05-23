//
//  MedicineInfoView.swift
//  UlcerativeColitisApp
//
//  Created by Engineer MacBook Air on 2025/05/01.
//

import SwiftUI
import RealmSwift

struct MedicineInfoView: View {
    
    @ObservedResults(MedicineDataModel.self) var medicineDataModel
    @Environment(\.dismiss) var dismiss // モーダルを閉じるためのプロパティ
    
    @State private var medicineNameTextField = "" // 薬の名前
    @State private var stockTextField = "" // 在庫
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
    
    var body: some View {
        VStack(spacing: 40) {
            VStack(spacing: 10) {
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
                    if image != nil {
                        Button("削除") {
                            self.image = nil
                        }
                    }
                    
                    if image == nil {
                        Button("", systemImage: "arrow.trianglehead.2.clockwise.rotate.90") {
                            showImagePickerDialog = true
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
                Button(action: {
                    isPicker.toggle()
                }) {
                    Image(systemName: "plus")
                }
                .sheet(isPresented: $isPicker) {
                    VStack {
                        Text("単位を選択してください")
                            .font(.headline)
                            .padding()
                        
                        Picker("単位を選択", selection: $selectedUnit) {
                            ForEach(units, id: \.self) { unit in
                                Text(unit).tag(unit)
                            }
                        }
                        .labelsHidden() // ラベルを非表示
                        .pickerStyle(WheelPickerStyle())
                        .frame(height: 200)
                        
                        Button(action: {
                            isPicker = false // Pickerを閉じる
                        }) {
                            Text("完了")
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.green)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                                .padding(.top)
                        }
                    }
                }
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
            
            HStack {
                Text("在庫")
                TextField("", text: $stockTextField)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .multilineTextAlignment(.center)
                    .frame(width: 100)
                Text("錠")
            }
            .padding()
            
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
            HStack {
                Button("キャンセル", role: .cancel) {
                    dismiss()
                    stockTextField = ""
                    dosageTextField = ""
                    newMemoTextEditor = ""
                    medicineNameTextField = ""
                }
                .foregroundColor(.primary)
                .background(
                    RoundedRectangle(cornerRadius: 15)
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 150, height: 40)
                )
                Spacer()
                    .frame(width: 130)
                Button(action: {
                    saveMedicineInfo()
                    dismiss()
                }) {
                    Text("保存")
                }
                .foregroundColor(.primary)
                .background(
                    RoundedRectangle(cornerRadius: 15)
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 150, height: 40)
                )
                .padding(.horizontal)
            }
            Spacer()
        }
        .padding()
    }
    
    func saveMedicineInfo() {
        let realm = try! Realm()
        try! realm.write {
            let medicineDataModel = MedicineDataModel()
            medicineDataModel.medicineName = medicineNameTextField
            medicineDataModel.dosage = dosage
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

#Preview {
    MedicineInfoView()
}
