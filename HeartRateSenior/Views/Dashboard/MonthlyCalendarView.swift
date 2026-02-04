//
//  MonthlyCalendarView.swift
//  HeartRateSenior
//
//  Monthly Calendar (Heatmap Style) component for Dashboard
//

import SwiftUI

// MARK: - Monthly Calendar View (Heatmap Style)
struct MonthlyCalendarView: View {
    let heartRateRecords: [HeartRateRecord]
    let bloodPressureRecords: [BloodPressureRecord]
    let bloodGlucoseRecords: [BloodGlucoseRecord]
    let onDateTapped: (Date) -> Void
    
    @State private var currentMonth = Date()
    
    private let calendar = Calendar.current
    private let weekdays = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
    
    var body: some View {
        VStack(spacing: 16) {
            // Month Header
            HStack {
                Text(monthYearString)
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundColor(AppColors.textPrimary)
                
                Spacer()
                
                NavigationLink(destination: HistoryView()) {
                    HStack(spacing: 4) {
                        Text("Full History")
                            .font(.system(size: 14, weight: .medium))
                        Image(systemName: "chevron.right")
                            .font(.system(size: 12, weight: .semibold))
                    }
                    .foregroundColor(AppColors.primaryRed)
                }
            }
            
            // Weekday Headers
            HStack(spacing: 0) {
                ForEach(weekdays, id: \.self) { day in
                    Text(day)
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundColor(AppColors.textSecondary)
                        .frame(maxWidth: .infinity)
                }
            }
            
            // Calendar Grid
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 4), count: 7), spacing: 8) {
                ForEach(daysInMonth, id: \.self) { date in
                    if let date = date {
                        DayCell(
                            date: date,
                            hasData: hasDataOnDate(date),
                            isToday: calendar.isDateInToday(date),
                            onTap: { onDateTapped(date) }
                        )
                    } else {
                        Color.clear
                            .frame(height: 36)
                    }
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 4)
        )
    }
    
    private var monthYearString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: currentMonth)
    }
    
    private var daysInMonth: [Date?] {
        let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: currentMonth))!
        let range = calendar.range(of: .day, in: .month, for: startOfMonth)!
        
        let firstWeekday = calendar.component(.weekday, from: startOfMonth)
        var days: [Date?] = Array(repeating: nil, count: firstWeekday - 1)
        
        for day in range {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: startOfMonth) {
                days.append(date)
            }
        }
        
        return days
    }
    
    private func hasDataOnDate(_ date: Date) -> Bool {
        let hasHR = heartRateRecords.contains { calendar.isDate($0.timestamp, inSameDayAs: date) }
        let hasBP = bloodPressureRecords.contains { calendar.isDate($0.timestamp, inSameDayAs: date) }
        let hasBG = bloodGlucoseRecords.contains { calendar.isDate($0.timestamp, inSameDayAs: date) }
        return hasHR || hasBP || hasBG
    }
}

// MARK: - Day Cell
struct DayCell: View {
    let date: Date
    let hasData: Bool
    let isToday: Bool
    let onTap: () -> Void
    
    private let calendar = Calendar.current
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 2) {
                Text("\(calendar.component(.day, from: date))")
                    .font(.system(size: 14, weight: isToday ? .bold : .regular, design: .rounded))
                    .foregroundColor(isToday ? .white : AppColors.textPrimary)
                
                if hasData {
                    Circle()
                        .fill(isToday ? Color.white : AppColors.primaryRed)
                        .frame(width: 6, height: 6)
                } else {
                    Color.clear.frame(width: 6, height: 6)
                }
            }
            .frame(width: 36, height: 36)
            .background(
                Circle()
                    .fill(isToday ? AppColors.primaryRed : Color.clear)
            )
        }
        .disabled(date > Date())
        .opacity(date > Date() ? 0.3 : 1)
    }
}
