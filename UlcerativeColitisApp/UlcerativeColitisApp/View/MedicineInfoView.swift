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
    
    @State private var medicineNameTextField = "" // 薬の名前
    @State private var stockTextField = "" // 在庫
    @State private var dosageTextField = "" // 服用量
    @State private var newMemoTextEditor = "" // メモ
    @State private var dosingTimePicker: Date = Date() // 服用時間
    @State private var addDosingTimePicker = false // 服用時間追加ボタン
    @State private var unit = 1 // 単位
    
    @State var image: UIImage?
    @State private var showImagePickerDialog = false
    @State private var showCamera: Bool = false
    @State private var showLibrary: Bool = false
    
    var body: some View {
        VStack(spacing: 20) {
            HStack(spacing: 50) {
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
                    .frame(width: 100)
                Picker("単位", selection: $unit) {
                    Text("Picker")
                }
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
                Button("キャンセル", role: .cancel) {}
                    .foregroundColor(.primary)
                .background(
                    RoundedRectangle(cornerRadius: 15)
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 150, height: 40)
                )
                Spacer()
                    .frame(width: 130)
                Button(action: {
                    
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
}

#Preview {
    MedicineInfoView()
}
