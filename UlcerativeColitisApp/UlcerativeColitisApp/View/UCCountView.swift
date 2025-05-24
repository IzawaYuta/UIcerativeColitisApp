//
//  UCCountView.swift
//  UlcerativeColitisApp
//
//  Created by Engineer MacBook Air on 2025/05/24.
//

import SwiftUI

struct UCCountView: View {
    
    @State private var date: Date = Date()
    @State private var daysDifference: Int?
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 18)
                .fill(Color.white)
                .shadow(color: .black, radius: 10)
                .frame(width: 300, height: 300)
            
            VStack {
                Text("潰瘍性大腸炎になって")
                    .foregroundColor(.gray)
                Text("\(daysDifference ?? 0)")
                DatePicker("", selection: $date, displayedComponents: .date)
                    .labelsHidden()
                    .onChange(of: date) { newDate in
                        calculateDaysDifference(from: newDate)
                    }
            }
        }
    }
    
    private func calculateDaysDifference(from date: Date) {
        let calendar = Calendar.current
        let today = Date()
        
        if let difference = calendar.dateComponents([.day], from: date, to: today).day {
            daysDifference = difference + 1
        } else {
            daysDifference = nil
        }
    }
}

#Preview {
    UCCountView()
}
