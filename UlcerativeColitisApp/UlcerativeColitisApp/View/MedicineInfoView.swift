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
    
    @State private var medicineNameTextField = ""
    
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
//                    Text("お薬の名前")
//                        .font(.callout)
                    TextField("お薬の名前", text: $medicineNameTextField)
                        .frame(width: 150, height: 50)
                        .padding(.bottom, 5) // テキストと線の間にスペースを追加
                        .overlay(
                            Rectangle()
                                .frame(height: 2) // 線の太さ
                                .foregroundColor(.gray) // 線の色
                                .padding(.top, -15), // 線をテキストフィールドの下に配置
                            alignment: .bottom
                        )

                }
            }
            VStack {
                Text("メモ")
            }
            HStack {
                Button("キャンセル", role: .cancel) {}
                    .foregroundColor(.primary)
                .background(
                    RoundedRectangle(cornerRadius: 15)
                        .frame(width: 150, height: 40)
                        .viewStyleView()
                )
                .padding(.horizontal)
                Spacer()
                Button(action: {
                    
                }) {
                    Text("保存")
                }
                .foregroundColor(.primary)
                .background(
                    RoundedRectangle(cornerRadius: 15)
                        .frame(width: 150, height: 40)
                        .viewStyleView()
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
