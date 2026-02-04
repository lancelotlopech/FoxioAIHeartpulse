//
//  DashboardView.swift
//  HeartRateSenior
//
//  Main dashboard with health overview - Health Score, Calendar, Quick Records
//

import SwiftUI
import SwiftData

struct DashboardView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \HeartRateRecord.timestamp, order: .reverse) private var heartRateRecords: [HeartRateRecord]
    @Query(sort: \BloodPressureRecord.timestamp, order: .reverse) private var bloodPressureRecords: [BloodPressureRecord]
    @Query(sort: \BloodGlucoseRecord.timestamp, order: .reverse) private var bloodGlucoseRecords: [BloodGlucoseRecord]
    @Query(sort: \WeightRecord.timestamp, order: .reverse) private var weightRecords: [WeightRecord]
    @Query(sort: \OxygenRecord.timestamp, order: .reverse) private var oxygenRecords: [OxygenRecord]
    
    @StateObject private var subscriptionManager = SubscriptionManager.shared
    
    @State private var showingBloodPressureInput = false
    @State private var showingBloodGlucoseInput = false
    @State private var showingWeightInput = false
    @State private var showingOxygenInput = false
    @State private var showingEmergencyContacts = false
    @State private var selectedDate: Date? = nil
    @State private var showingDayDetail = false
    @State private var selectedTabForMeasure = 1
    @State private var showUpgradeBanner = PaywallConfiguration.showUpgradeBanner
    
    var body: some View {
        ZStack {
            NavigationStack {
                ScrollView {
                    VStack(spacing: 16) {
                        // 1. Header with Emergency Button & Pro Badge
                        HeaderView(
                            onEmergencyTap: {
                                HapticManager.shared.heavyImpact()
                                showingEmergencyContacts = true
                            },
                            onProTap: {
                                HapticManager.shared.mediumImpact()
                                NotificationCenter.default.post(name: NSNotification.Name("ShowSubscription"), object: nil)
                            },
                            isPremium: subscriptionManager.isPremium
                        )
                        .padding(.horizontal, 20)
                        .padding(.top, 10)
                        
                        // 2. Upgrade Banner (非订阅用户可见)
                        if !subscriptionManager.isPremium && showUpgradeBanner {
                            UpgradeBannerView(
                                onTap: {
                                    HapticManager.shared.mediumImpact()
                                    NotificationCenter.default.post(name: NSNotification.Name("ShowSubscription"), object: nil)
                                },
                                onClose: {
                                    withAnimation(.easeOut(duration: 0.3)) {
                                        showUpgradeBanner = false
                                    }
                                }
                            )
                            .padding(.horizontal, 20).transition(.asymmetric(
                                insertion: .move(edge: .top).combined(with: .opacity),
                                removal: .move(edge: .top).combined(with: .opacity)
                            ))
                        }
                        
                        // 3. Big Heart Rate Measure Button (核心功能)
                        BigMeasureButtonCard(
                            lastRecord: heartRateRecords.first,
                            onMeasureTap: {
                                HapticManager.shared.mediumImpact()
                                // Navigate to Measure tab
                                NotificationCenter.default.post(name: NSNotification.Name("SwitchToMeasureTab"), object: nil)
                            }
                        )
                        .padding(.horizontal, 20)
                        .padding(.bottom, -4) // 减少与 Health Score 间距
                        
                        // 4. Health Score Ring (暂时隐藏)
                        // HealthScoreRingView(
                        //     heartRateRecords: heartRateRecords,
                        //     bloodPressureRecords: bloodPressureRecords,
                        //     bloodGlucoseRecords: bloodGlucoseRecords
                        // )
                        // .padding(.horizontal, 20)
                        
                        // 5. Monthly Calendar (Heatmap Style)
                        MonthlyCalendarView(
                            heartRateRecords: heartRateRecords,
                            bloodPressureRecords: bloodPressureRecords,
                            bloodGlucoseRecords: bloodGlucoseRecords,
                            onDateTapped: { date in
                                HapticManager.shared.selectionChanged()
                                selectedDate = date
                                showingDayDetail = true
                            }
                        )
                        .padding(.horizontal, 20)
                        
                        // 6. Quick Record Cards (Horizontal List)
                        VStack(spacing: 12) {
                            Text("Quick Record")
                                .font(.system(size: 22, weight: .bold, design: .rounded))
                                .foregroundColor(AppColors.textPrimary).frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 20)
                            
                            VStack(spacing: 12) {
                                // Blood Pressure
                                NavigationLink(destination: BloodPressureHistoryView()) {
                                    HorizontalRecordCardView(
                                        icon: "heart.text.square.fill",
                                        title: "Blood Pressure",
                                        lastValue: bloodPressureRecords.first?.displayString,
                                        color: .blue,
                                        onAddTap: {
                                            HapticManager.shared.mediumImpact()
                                            showingBloodPressureInput = true
                                        },
                                        coverImage: "pressure"
                                    )
                                }
                                .buttonStyle(PlainButtonStyle())
                                
                                // Blood Glucose
                                NavigationLink(destination: BloodGlucoseHistoryView()) {
                                    HorizontalRecordCardView(
                                        icon: "drop.fill",
                                        title: "Blood Glucose",
                                        lastValue: bloodGlucoseRecords.first.map { "\(Int($0.value)) mg/dL" },
                                        color: .purple,
                                        onAddTap: {
                                            HapticManager.shared.mediumImpact()
                                            showingBloodGlucoseInput = true
                                        },
                                        coverImage: "heavy"
                                    )
                                }
                                .buttonStyle(PlainButtonStyle())
                                
                                // Weight
                                NavigationLink(destination: WeightHistoryView()) {
                                    HorizontalRecordCardView(
                                        icon: "scalemass.fill",
                                        title: "Weight",
                                        lastValue: weightRecords.first.map { String(format: "%.1f kg", $0.weight) },
                                        color: .orange,
                                        onAddTap: {
                                            HapticManager.shared.mediumImpact()
                                            showingWeightInput = true
                                        },
                                        coverImage: "weight"
                                    )
                                }
                                .buttonStyle(PlainButtonStyle())
                                
                                // Blood Oxygen
                                NavigationLink(destination: OxygenHistoryView()) {
                                    HorizontalRecordCardView(
                                        icon: "lungs.fill",
                                        title: "Blood Oxygen",
                                        lastValue: oxygenRecords.first.map { "\($0.spo2)%" },
                                        color: .cyan,
                                        onAddTap: {
                                            HapticManager.shared.mediumImpact()
                                            showingOxygenInput = true
                                        },
                                        coverImage: "oxygen"
                                    )
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                            .padding(.horizontal, 20)
                        }
                        
                        // 7. Health Knowledge Articles Section
                        DashboardArticlesSection()
                        
                        // Footer: Disclaimer & References
                        DisclaimerFooterView()
                            .padding(.horizontal, 20)
                            .padding(.top, 20)
                        
                        Spacer(minLength: 100)
                    }
                }
                .background(AppColors.background.ignoresSafeArea())
                .navigationBarHidden(true)
                .sheet(isPresented: $showingBloodPressureInput) {
                    BloodPressureInputView()
                }
                .sheet(isPresented: $showingBloodGlucoseInput) {
                    BloodGlucoseInputView()
                }
                .sheet(isPresented: $showingWeightInput) {
                    WeightInputView()
                }
                .sheet(isPresented: $showingOxygenInput) {
                    OxygenInputView()
                }
                .sheet(isPresented: $showingEmergencyContacts) {
                    EmergencyContactsView()
                }
                .sheet(isPresented: $showingDayDetail) {
                    if let date = selectedDate {
                        DayDetailView(
                            date: date,
                            heartRateRecords: heartRateRecords.filter { Calendar.current.isDate($0.timestamp, inSameDayAs: date) },
                            bloodPressureRecords: bloodPressureRecords.filter { Calendar.current.isDate($0.timestamp, inSameDayAs: date) },
                            bloodGlucoseRecords: bloodGlucoseRecords.filter { Calendar.current.isDate($0.timestamp, inSameDayAs: date) }
                        )
                    }
                }
            }
        }
    }
}

#Preview {
    DashboardView()
        .modelContainer(for: [HeartRateRecord.self, BloodPressureRecord.self, BloodGlucoseRecord.self], inMemory: true)
}
