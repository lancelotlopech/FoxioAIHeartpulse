//
//  DashboardView.swift
//  HeartRateSenior
//
//  Main dashboard - 1:1 matching HTML design
//

import SwiftUI
import SwiftData

// MARK: - Identifiable Date Wrapper
struct IdentifiableDate: Identifiable {
    let id = UUID()
    let date: Date
}

struct DashboardView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \HeartRateRecord.timestamp, order: .reverse) private var heartRateRecords: [HeartRateRecord]
    @Query(sort: \BloodPressureRecord.timestamp, order: .reverse) private var bloodPressureRecords: [BloodPressureRecord]
    @Query(sort: \BloodGlucoseRecord.timestamp, order: .reverse) private var bloodGlucoseRecords: [BloodGlucoseRecord]
    @Query(sort: \WeightRecord.timestamp, order: .reverse) private var weightRecords: [WeightRecord]
    @Query(sort: \OxygenRecord.timestamp, order: .reverse) private var oxygenRecords: [OxygenRecord]
    
    @StateObject private var subscriptionManager = SubscriptionManager.shared
    @StateObject private var settingsManager = SettingsManager()
    
    @State private var showingBloodPressureInput = false
    @State private var showingBloodGlucoseInput = false
    @State private var showingWeightInput = false
    @State private var showingOxygenInput = false
    @State private var showingEmergencyContacts = false
    @State private var selectedDate: IdentifiableDate? = nil
    @State private var showingHIVAwareness = false
    @State private var showingPregnancyCenter = false
    @State private var showingArticlesList = false
    @State private var showingHistory = false
    @State private var showingSubscription = false
    @State private var selectedArticle: Article? = nil
    
    // 状态标签计算
    private var bpStatus: (text: String, color: Color)? {
        guard let bp = bloodPressureRecords.first else { return nil }
        if bp.systolic < 120 && bp.diastolic < 80 { return ("Normal", Color(red: 0.13, green: 0.55, blue: 0.13)) }
        if bp.systolic < 130 { return ("Elevated", Color(red: 0.8, green: 0.6, blue: 0.0)) }
        return ("High", Color.red)
    }
    
    private var glucoseStatus: (text: String, color: Color)? {
        guard let bg = bloodGlucoseRecords.first else { return nil }
        if bg.value < 5.6 { return ("Normal", Color(red: 0.13, green: 0.55, blue: 0.13)) }
        if bg.value < 7.0 { return ("Elevated", Color(red: 0.8, green: 0.6, blue: 0.0)) }
        return ("High", Color.red)
    }
    
    private var weightStatus: (text: String, color: Color)? {
        guard weightRecords.first != nil else { return nil }
        return ("Good", Color(red: 0.13, green: 0.55, blue: 0.13))
    }
    
    private var oxygenStatus: (text: String, color: Color)? {
        guard let ox = oxygenRecords.first else { return nil }
        return ("\(ox.spo2)%", Color(red: 0.13, green: 0.55, blue: 0.13))
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 22) {
                    // 1. Header
                    ModernHeaderView(
                        userName: settingsManager.userName,
                        showProBadge: !subscriptionManager.isPremium && PaywallConfiguration.showProBadgeInDashboard,
                        onProTap: {
                            HapticManager.shared.lightImpact()
                            showingSubscription = true
                        },
                        onEmergencyTap: {
                            HapticManager.shared.heavyImpact()
                            showingEmergencyContacts = true
                        }
                    )
                    .padding(.horizontal, 24)
                    .padding(.top, 8)
                    
                    // 1.5 Upgrade Banner (非会员显示)
                    if !subscriptionManager.isPremium {
                        UpgradeBannerView(
                            onTap: {
                                HapticManager.shared.mediumImpact()
                                showingSubscription = true
                            },
                            onClose: {}
                        )
                        .padding(.horizontal, 24)
                    }
                    
                    // 2. Week Calendar Strip (可滚动, 回溯1个月)
                    WeekCalendarStripView(
                        heartRateRecords: heartRateRecords,
                        bloodPressureRecords: bloodPressureRecords,
                        bloodGlucoseRecords: bloodGlucoseRecords,
                        onDateTapped: { date in
                            HapticManager.shared.selectionChanged()
                            if subscriptionManager.isPremium {
                                selectedDate = IdentifiableDate(date: date)
                            } else {
                                showingSubscription = true
                            }
                        },
                        onViewMoreHistory: {
                            showingHistory = true
                        }
                    )
                    .padding(.horizontal, 24)
                    
                    // 3. Heart Rate Card
                    ModernHeartRateCard(
                        lastRecord: heartRateRecords.first,
                        onMeasureTap: {
                            HapticManager.shared.mediumImpact()
                            NotificationCenter.default.post(name: NSNotification.Name("SwitchToMeasureTab"), object: nil)
                        }
                    )
                    .padding(.horizontal, 24)
                    
                    // 4. Quick Record (2x2 Grid)
                    VStack(spacing: 16) {
                        QuickRecordTitleView()
                            .padding(.horizontal, 24)
                        
                        VStack(spacing: 16) {
                            HStack(spacing: 16) {
                                CompactHealthCard(
                                    icon: "gauge.medium",
                                    title: "Blood Pressure",
                                    lastValue: bloodPressureRecords.first?.displayString,
                                    unit: "mmHg",
                                    color: Color(hex: "#F2994A"),
                                    iconBgColor: Color(hex: "#F2994A"),
                                    iconCircleBgColor: Color(hex: "#FBE3D3"),
                                    statusText: bpStatus?.text,
                                    statusColor: bpStatus?.color ?? .green,
                                    onAddTap: {
                                        HapticManager.shared.mediumImpact()
                                        if subscriptionManager.isPremium {
                                            showingBloodPressureInput = true
                                        } else {
                                            showingSubscription = true
                                        }
                                    }
                                )
                                
                                CompactHealthCard(
                                    icon: "drop.fill",
                                    title: "Blood Glucose",
                                    lastValue: bloodGlucoseRecords.first.map { String(format: "%.1f", $0.value) },
                                    unit: "mmol/L",
                                    color: Color(hex: "#4A90E2"),
                                    iconBgColor: Color(hex: "#4A90E2"),
                                    iconCircleBgColor: Color(hex: "#DDEBFF"),
                                    statusText: glucoseStatus?.text,
                                    statusColor: glucoseStatus?.color ?? .green,
                                    onAddTap: {
                                        HapticManager.shared.mediumImpact()
                                        if subscriptionManager.isPremium {
                                            showingBloodGlucoseInput = true
                                        } else {
                                            showingSubscription = true
                                        }
                                    }
                                )
                            }
                            
                            HStack(spacing: 16) {
                                CompactHealthCard(
                                    icon: "scalemass.fill",
                                    title: "Weight",
                                    lastValue: weightRecords.first.map { String(format: "%.0f", $0.weight) },
                                    unit: "kg",
                                    color: Color(hex: "#9B51E0"),
                                    iconBgColor: Color(hex: "#9B51E0"),
                                    iconCircleBgColor: Color(hex: "#E9DDFB"),
                                    statusText: weightStatus?.text,
                                    statusColor: weightStatus?.color ?? .green,
                                    onAddTap: {
                                        HapticManager.shared.mediumImpact()
                                        if subscriptionManager.isPremium {
                                            showingWeightInput = true
                                        } else {
                                            showingSubscription = true
                                        }
                                    }
                                )
                                
                                CompactHealthCard(
                                    icon: "wind",
                                    title: "Blood Oxygen",
                                    lastValue: oxygenRecords.first.map { "\($0.spo2)" },
                                    unit: "%",
                                    color: Color(hex: "#2DCEB4"),
                                    iconBgColor: Color(hex: "#2DCEB4"),
                                    iconCircleBgColor: Color(hex: "#D7F4ED"),
                                    statusText: oxygenStatus?.text,
                                    statusColor: oxygenStatus?.color ?? .green,
                                    onAddTap: {
                                        HapticManager.shared.mediumImpact()
                                        if subscriptionManager.isPremium {
                                            showingOxygenInput = true
                                        } else {
                                            showingSubscription = true
                                        }
                                    }
                                )
                            }
                        }
                        .padding(.horizontal, 24)
                    }
                    
                    // 5. Self Check (并排2列)
                    VStack(spacing: 16) {
                        SelfCheckTitleView()
                            .padding(.horizontal, 24)
                        
                        HStack(spacing: 16) {
                            ImageBasedSelfCheckCard(
                                imageName: "HIV",
                                title: "HIV Awareness",
                                subtitle: "Prevention, testing & early care steps",
                                iconName: "cross.case.fill",
                                gradientColor: Color(red: 0.6, green: 0.1, blue: 0.1),
                                onTap: {
                                    HapticManager.shared.lightImpact()
                                    if subscriptionManager.isPremium {
                                        showingHIVAwareness = true
                                    } else {
                                        showingSubscription = true
                                    }
                                }
                            )
                            
                            ImageBasedSelfCheckCard(
                                imageName: "Pregnancy",
                                title: "Pregnancy",
                                subtitle: "Weekly guide & health monitoring",
                                iconName: "figure.stand",
                                gradientColor: Color(red: 0.6, green: 0.1, blue: 0.3),
                                onTap: {
                                    HapticManager.shared.lightImpact()
                                    if subscriptionManager.isPremium {
                                        showingPregnancyCenter = true
                                    } else {
                                        showingSubscription = true
                                    }
                                }
                            )
                        }
                        .padding(.horizontal, 24)
                    }
                    
                    // 6. Health Articles
                    VStack(spacing: 16) {
                        HealthArticlesTitleView(onSeeAllTap: {
                            showingArticlesList = true
                        })
                        .padding(.horizontal, 24)
                        
                        // 2列 + 1个横跨
                        VStack(spacing: 16) {
                            HStack(spacing: 16) {
                                ArticleImageCard(
                                    imageName: "3",
                                    tag: "Wellness",
                                    tagColor: AppColors.primaryRed,
                                    title: "Heart Rate Variability Explained",
                                    height: 192,
                                    onTap: {
                                        selectedArticle = ArticleData.articles.first { $0.id == 3 }
                                    }
                                )
                                
                                ArticleImageCard(
                                    imageName: "4",
                                    tag: "Guide",
                                    tagColor: .blue,
                                    title: "Home BP Monitoring Tips",
                                    height: 192,
                                    onTap: {
                                        selectedArticle = ArticleData.articles.first { $0.id == 4 }
                                    }
                                )
                            }
                            
                            ArticleImageCard(
                                imageName: "5",
                                tag: "Lifestyle",
                                tagColor: .purple,
                                title: "Understanding Heart Rhythms & Meditation",
                                height: 160,
                                onTap: {
                                    selectedArticle = ArticleData.articles.first { $0.id == 5 }
                                }
                            )
                        }
                        .padding(.horizontal, 24)
                    }
                    
                    // 7. Disclaimer Footer
                    DashboardDisclaimerFooter()
                        .padding(.horizontal, 24)
                        .padding(.top, 8)
                    
                    Spacer(minLength: 100)
                }
            }
            .background(Color(red: 0.973, green: 0.976, blue: 0.984).ignoresSafeArea())
            .navigationBarHidden(true)
            .fullScreenCover(isPresented: $showingBloodPressureInput) {
                BloodPressureInputView()
            }
            .fullScreenCover(isPresented: $showingBloodGlucoseInput) {
                BloodGlucoseInputView()
            }
            .fullScreenCover(isPresented: $showingWeightInput) {
                WeightInputView()
            }
            .fullScreenCover(isPresented: $showingOxygenInput) {
                OxygenInputView()
            }
            .sheet(isPresented: $showingEmergencyContacts) {
                EmergencyContactsView()
            }
            .sheet(item: $selectedDate) { identifiableDate in
                DayDetailView(
                    date: identifiableDate.date,
                    heartRateRecords: heartRateRecords.filter { Calendar.current.isDate($0.timestamp, inSameDayAs: identifiableDate.date) },
                    bloodPressureRecords: bloodPressureRecords.filter { Calendar.current.isDate($0.timestamp, inSameDayAs: identifiableDate.date) },
                    bloodGlucoseRecords: bloodGlucoseRecords.filter { Calendar.current.isDate($0.timestamp, inSameDayAs: identifiableDate.date) }
                )
            }
            .fullScreenCover(isPresented: $showingArticlesList) {
                ArticlesListView()
            }
            .sheet(isPresented: $showingHistory) {
                HistoryView()
            }
            .fullScreenCover(isPresented: $showingHIVAwareness) {
                HIVCenterView()
            }
            .fullScreenCover(isPresented: $showingPregnancyCenter) {
                PregnancyCenterView()
            }
            .fullScreenCover(isPresented: $showingSubscription) {
                SubscriptionView()
            }
            .fullScreenCover(item: $selectedArticle) { article in
                NavigationStack {
                    ArticleDetailView(article: article)
                }
            }
        }
    }
}

#Preview {
    DashboardView()
        .modelContainer(for: [HeartRateRecord.self, BloodPressureRecord.self, BloodGlucoseRecord.self], inMemory: true)
}
