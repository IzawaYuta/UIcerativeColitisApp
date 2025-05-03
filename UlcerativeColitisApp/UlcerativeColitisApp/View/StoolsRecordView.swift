//
//  StoolsRecordView.swift
//  UlcerativeColitisApp
//
//  Created by Engineer MacBook Air on 2025/04/30.
//

import SwiftUI
import RealmSwift

struct StoolsRecordView: View {
    
    @State private var isSelected = false
    @State private var date = Date()
    
    var body: some View {
        VStack(spacing: 50) {
            HStack(spacing: 40) {
                VStack(spacing: 22) {
                    Image("1")
                        .foregroundColor(.black)
                        .background(
                            Circle()
                                .fill(Color.white)
                                .frame(width: 50, height: 50)
                        )
                        .overlay {
                            Circle()
                                .stroke(isSelected ? Color.yellow : Color.gray,lineWidth: 4)
                                .frame(width: 50, height: 50)
                        }
                        .onTapGesture {
                            withAnimation {
                                isSelected.toggle()
                            }
                        }
                    Text("硬便")
                        .font(.system(size: 12))
                }
                VStack(spacing: 22) {
                    Image("2")
                        .foregroundColor(.black)
                        .background(
                            Circle()
                                .fill(Color.white)
                                .frame(width: 50, height: 50)
                        )
                        .overlay {
                            Circle()
                                .stroke(isSelected ? Color.yellow : Color.gray,lineWidth: 4)
                                .frame(width: 50, height: 50)
                        }
                        .onTapGesture {
                            withAnimation {
                                isSelected.toggle()
                            }
                        }
                    Text("普通便")
                        .font(.system(size: 12))
                }
                VStack(spacing: 22) {
                    Image("3")
                        .foregroundColor(.black)
                        .background(
                            Circle()
                                .fill(Color.white)
                                .frame(width: 50, height: 50)
                        )
                        .overlay {
                            Circle()
                                .stroke(isSelected ? Color.yellow : Color.gray,lineWidth: 4)
                                .frame(width: 50, height: 50)
                        }
                        .onTapGesture {
                            withAnimation {
                                isSelected.toggle()
                            }
                        }
                    Text("軟便")
                        .font(.system(size: 12))
                }
                VStack(spacing: 22) {
                    Image("4")
                        .foregroundColor(.black)
                        .background(
                            Circle()
                                .fill(Color.white)
                                .frame(width: 50, height: 50)
                        )
                        .overlay {
                            Circle()
                                .stroke(isSelected ? Color.yellow : Color.gray,lineWidth: 4)
                                .frame(width: 50, height: 50)
                        }
                        .onTapGesture {
                            withAnimation {
                                isSelected.toggle()
                            }
                        }
                    Text("下痢")
                        .font(.system(size: 12))
                }
                VStack(spacing: 22) {
                    Image("5")
                        .foregroundColor(.black)
                        .background(
                            Circle()
                                .fill(Color.white)
                                .frame(width: 50, height: 50)
                        )
                        .overlay {
                            Circle()
                                .stroke(isSelected ? Color.yellow : Color.gray,lineWidth: 4)
                                .frame(width: 50, height: 50)
                        }
                        .onTapGesture {
                            withAnimation {
                                isSelected.toggle()
                            }
                        }
                    Text("便秘")
                        .font(.system(size: 12))
                }
                VStack(spacing: 22) {
                    Image("6")
                        .foregroundColor(.black)
                        .background(
                            Circle()
                                .fill(Color.white)
                                .frame(width: 50, height: 50)
                        )
                        .overlay {
                            Circle()
                                .stroke(isSelected ? Color.yellow : Color.gray,lineWidth: 4)
                                .frame(width: 50, height: 50)
                        }
                        .onTapGesture {
                            withAnimation {
                                isSelected.toggle()
                            }
                        }
                    Text("血便")
                        .font(.system(size: 12))
                }
            }
            HStack {
                DatePicker("時間", selection: $date, displayedComponents: .hourAndMinute)
                    .labelsHidden()
                    .pickerStyle(.menu)
                Text("追加")
                    .foregroundColor(.blue)
                    .frame(width: 100, height: 50)
                    .background(
                        RoundedRectangle(cornerRadius: 13)
                            .fill(Color.green)
                    )
                    .onTapGesture {
                        
                    }
            }
        }
    }
    
    private func saveStool(date: Date, stoolType: Int) {
        let realm = try! Realm()
        let record = StoolRecordModel()
        record.date = date
        record.stoolTypes.append(stoolType)
        
        try! realm.write {
            realm.add(record)
        }
        print("\(record)")
    }
}

#Preview {
    StoolsRecordView()
}
