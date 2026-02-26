//
//  PregnancyAssessmentHistoryView.swift
//  HeartRateSenior
//

import SwiftUI
import SwiftData

struct PregnancyAssessmentHistoryView: View {
    @Environment(\.dismiss) private var dismiss
    @Query private var records: [PregnancyAssessmentRecord]
    @ObservedObject private var subscriptionManager = SubscriptionManager.shared
    @State private var showingSubscription = false
    
    private var sortedRecords: [PregnancyAssessmentRecord] {
        records.sorted(by: { $0.createdAt > $1.createdAt })
    }
    
    private var visibleRecords: [PregnancyAssessmentRecord] {
        if subscriptionManager.isPremium { return sortedRecords }
        return Array(sortedRecords.prefix(1))
    }
    
    var body: some View {
        NavigationStack {
            List {
                if sortedRecords.isEmpty {
                    VStack(spacing: 10) {
                        Text(pregnancyRawText("No history yet"))
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(Color(hex: "1a1a1a"))
                        Text(pregnancyRawText("Complete the self-check to save your first result."))
                            .font(.system(size: 14))
                            .foregroundColor(Color(hex: "888888"))
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 24)
                    .listRowSeparator(.hidden)
                } else {
                    ForEach(visibleRecords, id: \.id) { record in
                        PregnancyAssessmentHistoryRow(record: record)
                    }
                    
                    if !subscriptionManager.isPremium, sortedRecords.count > visibleRecords.count {
                        VStack(alignment: .leading, spacing: 10) {
                            Text(pregnancyRawText("Unlock full history"))
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(Color(hex: "1a1a1a"))
                            Text(pregnancyRawText("Upgrade to see all your previous assessments and retest dates."))
                                .font(.system(size: 13))
                                .foregroundColor(Color(hex: "777777"))
                            
                            Button {
                                HapticManager.shared.mediumImpact()
                                showingSubscription = true
                            } label: {
                                Text(pregnancyText(.upgrade))
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 44)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(AppColors.primaryRed)
                                    )
                            }
                            .buttonStyle(.plain)
                        }
                        .padding(.vertical, 10)
                        .listRowSeparator(.hidden)
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle(pregnancyRawText("Assessment History"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(pregnancyText(.close)) {
                        dismiss()
                    }
                }
            }
        }
        .fullScreenCover(isPresented: $showingSubscription) {
            SubscriptionView(isPresented: $showingSubscription)
        }
    }
}

private struct PregnancyAssessmentHistoryRow: View {
    let record: PregnancyAssessmentRecord
    
    private var levelTitle: String {
        switch record.probabilityLevelRaw {
        case "low": return pregnancyRawText("Low Probability")
        case "moderate": return pregnancyRawText("Moderate Probability")
        case "higher": return pregnancyRawText("Higher Probability")
        default: return pregnancyRawText("Result")
        }
    }
    
    private var levelColor: Color {
        switch record.probabilityLevelRaw {
        case "low": return Color(hex: "34c759")
        case "moderate": return Color(hex: "ff9500")
        case "higher": return AppColors.primaryRed
        default: return Color(hex: "999999")
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(levelTitle)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(Color(hex: "1a1a1a"))
                
                Spacer()
                
                Text(record.createdAt.formatted(date: .abbreviated, time: .shortened))
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(Color(hex: "888888"))
            }
            
            HStack(spacing: 10) {
                Text(pregnancyFormat(.scoreWithValueFormat, record.totalScore))
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(Color(hex: "666666"))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(
                        Capsule().fill(levelColor.opacity(0.12))
                    )
                
                if let retest = record.suggestedRetestDate {
                    Text(pregnancyFormat(.retestBadgeFormat, retest.formatted(date: .abbreviated, time: .omitted)))
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(Color(hex: "666666"))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(
                            Capsule().fill(Color(hex: "f0eeee"))
                        )
                }
            }
        }
        .padding(.vertical, 6)
    }
}
