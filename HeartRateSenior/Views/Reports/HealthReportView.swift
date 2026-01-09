//
//  HealthReportView.swift
//  HeartRateSenior
//
//  Comprehensive health report view
//

import SwiftUI
import SwiftData
import Charts

struct HealthReportView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \HeartRateRecord.timestamp, order: .reverse) private var heartRateRecords: [HeartRateRecord]
    @Query(sort: \BloodPressureRecord.timestamp, order: .reverse) private var bloodPressureRecords: [BloodPressureRecord]
    @Query(sort: \BloodGlucoseRecord.timestamp, order: .reverse) private var bloodGlucoseRecords: [BloodGlucoseRecord]
    
    @State private var selectedPeriod: ReportPeriod = .month
    @State private var showingExportSheet = false
    
    enum ReportPeriod: String, CaseIterable {
        case week = "Weekly"
        case month = "Monthly"
        case quarter = "Quarterly"
        
        var days: Int {
            switch self {
            case .week: return 7
            case .month: return 30
            case .quarter: return 90
            }
        }
        
        var title: String {
            switch self {
            case .week: return "Weekly Report"
            case .month: return "Monthly Report"
            case .quarter: return "Quarterly Report"
            }
        }
    }
    
    private var cutoffDate: Date {
        Calendar.current.date(byAdding: .day, value: -selectedPeriod.days, to: Date()) ?? Date()
    }
    
    private var filteredHeartRates: [HeartRateRecord] {
        heartRateRecords.filter { $0.timestamp >= cutoffDate }
    }
    
    private var filteredBloodPressures: [BloodPressureRecord] {
        bloodPressureRecords.filter { $0.timestamp >= cutoffDate }
    }
    
    private var filteredBloodGlucoses: [BloodGlucoseRecord] {
        bloodGlucoseRecords.filter { $0.timestamp >= cutoffDate }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Period Selector
                    Picker("Report Period", selection: $selectedPeriod) {
                        ForEach(ReportPeriod.allCases, id: \.self) { period in
                            Text(period.rawValue).tag(period)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal)
                    
                    // Report Header
                    reportHeader
                    
                    // Heart Rate Summary
                    if !filteredHeartRates.isEmpty {
                        heartRateSummary
                    }
                    
                    // Blood Pressure Summary
                    if !filteredBloodPressures.isEmpty {
                        bloodPressureSummary
                    }
                    
                    // Blood Glucose Summary
                    if !filteredBloodGlucoses.isEmpty {
                        bloodGlucoseSummary
                    }
                    
                    // Empty State
                    if filteredHeartRates.isEmpty && filteredBloodPressures.isEmpty && filteredBloodGlucoses.isEmpty {
                        emptyStateView
                    }
                    
                    // Health Tips
                    healthTips
                }
                .padding(.vertical)
            }
            .navigationTitle("Health Report")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingExportSheet = true
                    }) {
                        Image(systemName: "square.and.arrow.up")
                            .font(.title3)
                    }
                }
            }
            .sheet(isPresented: $showingExportSheet) {
                ExportReportView(
                    period: selectedPeriod,
                    heartRates: filteredHeartRates,
                    bloodPressures: filteredBloodPressures,
                    bloodGlucoses: filteredBloodGlucoses
                )
            }
            .onAppear {
                // Track first view report event
                Task { @MainActor in
                    AppsFlyerManager.shared.trackViewReport()
                }
            }
        }
    }
    
    // MARK: - Report Header
    
    private var reportHeader: some View {
        VStack(spacing: 8) {
            Text(selectedPeriod.title)
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundColor(DesignSystem.Colors.textPrimary)
            
            Text(dateRangeString)
                .font(.system(size: 16, design: .rounded))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(16)
        .padding(.horizontal)
    }
    
    private var dateRangeString: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return "\(formatter.string(from: cutoffDate)) - \(formatter.string(from: Date()))"
    }
    
    // MARK: - Heart Rate Summary
    
    private var heartRateSummary: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "heart.fill")
                    .foregroundColor(DesignSystem.Colors.primaryRed)
                Text("Heart Rate")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                Spacer()
                Text("\(filteredHeartRates.count) readings")
                    .font(.system(size: 14, design: .rounded))
                    .foregroundColor(.secondary)
            }
            
            HStack(spacing: 16) {
                StatCard(
                    title: "Average",
                    value: "\(averageHeartRate)",
                    unit: "BPM",
                    color: DesignSystem.Colors.primaryRed
                )
                
                StatCard(
                    title: "Lowest",
                    value: "\(minHeartRate)",
                    unit: "BPM",
                    color: .blue
                )
                
                StatCard(
                    title: "Highest",
                    value: "\(maxHeartRate)",
                    unit: "BPM",
                    color: .orange
                )
            }
            
            // Mini Chart
            Chart(filteredHeartRates.suffix(20).reversed()) { record in
                LineMark(
                    x: .value("Date", record.timestamp),
                    y: .value("BPM", record.bpm)
                )
                .foregroundStyle(DesignSystem.Colors.primaryRed)
                .interpolationMethod(.catmullRom)
            }
            .chartYScale(domain: 40...140)
            .frame(height: 100)
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(16)
        .padding(.horizontal)
    }
    
    private var averageHeartRate: Int {
        guard !filteredHeartRates.isEmpty else { return 0 }
        return filteredHeartRates.reduce(0) { $0 + $1.bpm } / filteredHeartRates.count
    }
    
    private var minHeartRate: Int {
        filteredHeartRates.min(by: { $0.bpm < $1.bpm })?.bpm ?? 0
    }
    
    private var maxHeartRate: Int {
        filteredHeartRates.max(by: { $0.bpm < $1.bpm })?.bpm ?? 0
    }
    
    // MARK: - Blood Pressure Summary
    
    private var bloodPressureSummary: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "waveform.path.ecg")
                    .foregroundColor(.blue)
                Text("Blood Pressure")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                Spacer()
                Text("\(filteredBloodPressures.count) readings")
                    .font(.system(size: 14, design: .rounded))
                    .foregroundColor(.secondary)
            }
            
            HStack(spacing: 16) {
                StatCard(
                    title: "Avg Systolic",
                    value: "\(averageSystolic)",
                    unit: "mmHg",
                    color: .blue
                )
                
                StatCard(
                    title: "Avg Diastolic",
                    value: "\(averageDiastolic)",
                    unit: "mmHg",
                    color: .green
                )
            }
            
            // Classification breakdown
            classificationBreakdown
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(16)
        .padding(.horizontal)
    }
    
    private var averageSystolic: Int {
        guard !filteredBloodPressures.isEmpty else { return 0 }
        return filteredBloodPressures.reduce(0) { $0 + $1.systolic } / filteredBloodPressures.count
    }
    
    private var averageDiastolic: Int {
        guard !filteredBloodPressures.isEmpty else { return 0 }
        return filteredBloodPressures.reduce(0) { $0 + $1.diastolic } / filteredBloodPressures.count
    }
    
    private var classificationBreakdown: some View {
        let classifications = Dictionary(grouping: filteredBloodPressures) { $0.category }
        
        return VStack(alignment: .leading, spacing: 8) {
            Text("Classification Breakdown")
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundColor(.secondary)
            
            ForEach(BloodPressureCategory.allCases, id: \.self) { category in
                let count = classifications[category]?.count ?? 0
                if count > 0 {
                    HStack {
                        Circle()
                            .fill(categoryColor(category))
                            .frame(width: 10, height: 10)
                        Text(category.rawValue)
                            .font(.system(size: 14, design: .rounded))
                        Spacer()
                        Text("\(count)")
                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                    }
                }
            }
        }
    }
    
    private func categoryColor(_ category: BloodPressureCategory) -> Color {
        switch category {
        case .low: return .blue
        case .normal: return .green
        case .elevated: return .yellow
        case .hypertensionStage1: return .orange
        case .hypertensionStage2: return .red
        case .crisis: return .purple
        }
    }
    
    // MARK: - Blood Glucose Summary
    
    private var bloodGlucoseSummary: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "drop.fill")
                    .foregroundColor(.purple)
                Text("Blood Glucose")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                Spacer()
                Text("\(filteredBloodGlucoses.count) readings")
                    .font(.system(size: 14, design: .rounded))
                    .foregroundColor(.secondary)
            }
            
            HStack(spacing: 16) {
                StatCard(
                    title: "Average",
                    value: String(format: "%.0f", averageGlucose),
                    unit: "mg/dL",
                    color: .purple
                )
                
                StatCard(
                    title: "In Range",
                    value: "\(inRangePercentage)%",
                    unit: "70-100",
                    color: .green
                )
            }
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(16)
        .padding(.horizontal)
    }
    
    private var averageGlucose: Double {
        guard !filteredBloodGlucoses.isEmpty else { return 0 }
        return filteredBloodGlucoses.reduce(0.0) { $0 + $1.value } / Double(filteredBloodGlucoses.count)
    }
    
    private var inRangePercentage: Int {
        guard !filteredBloodGlucoses.isEmpty else { return 0 }
        let inRange = filteredBloodGlucoses.filter { $0.value >= 70 && $0.value <= 100 }.count
        return Int(Double(inRange) / Double(filteredBloodGlucoses.count) * 100)
    }
    
    // MARK: - Empty State
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "doc.text.magnifyingglass")
                .font(.system(size: 60))
                .foregroundColor(.secondary.opacity(0.5))
            
            Text("No Data for This Period")
                .font(.system(size: 20, weight: .semibold, design: .rounded))
                .foregroundColor(.secondary)
            
            Text("Start tracking your health\nto generate reports")
                .font(.system(size: 16, design: .rounded))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }
    
    // MARK: - Health Tips
    
    private var healthTips: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Health Tips")
                .font(.system(size: 20, weight: .bold, design: .rounded))
            
            TipCard(
                icon: "heart.circle.fill",
                title: "Regular Monitoring",
                description: "Check your heart rate at the same time each day for consistent tracking.",
                color: DesignSystem.Colors.primaryRed
            )
            
            TipCard(
                icon: "moon.fill",
                title: "Rest Before Measuring",
                description: "Sit quietly for 5 minutes before taking blood pressure readings.",
                color: .blue
            )
            
            TipCard(
                icon: "fork.knife",
                title: "Fasting Glucose",
                description: "For accurate fasting glucose, measure before eating in the morning.",
                color: .purple
            )
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(16)
        .padding(.horizontal)
    }
}

// MARK: - Stat Card

struct StatCard: View {
    let title: String
    let value: String
    let unit: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.system(size: 12, design: .rounded))
                .foregroundColor(.secondary)
            
            Text(value)
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundColor(color)
            
            Text(unit)
                .font(.system(size: 11, design: .rounded))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(color.opacity(0.1))
        .cornerRadius(12)
    }
}

// MARK: - Tip Card

struct TipCard: View {
    let icon: String
    let title: String
    let description: String
    let color: Color
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(color)
                .frame(width: 32)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(DesignSystem.Colors.textPrimary)
                
                Text(description)
                    .font(.system(size: 14, design: .rounded))
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(UIColor.tertiarySystemBackground))
        .cornerRadius(12)
    }
}

// MARK: - Export Report View

struct ExportReportView: View {
    @Environment(\.dismiss) private var dismiss
    
    let period: HealthReportView.ReportPeriod
    let heartRates: [HeartRateRecord]
    let bloodPressures: [BloodPressureRecord]
    let bloodGlucoses: [BloodGlucoseRecord]
    
    @State private var isExporting = false
    @State private var exportedURL: URL?
    @State private var showingShareSheet = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Image(systemName: "doc.richtext")
                    .font(.system(size: 60))
                    .foregroundColor(DesignSystem.Colors.primaryRed)
                
                Text("Export Health Report")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                
                Text("Generate a PDF report of your health data for the \(period.rawValue.lowercased()) period.")
                    .font(.system(size: 16, design: .rounded))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Report includes:")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(.secondary)
                    
                    if !heartRates.isEmpty {
                        Label("\(heartRates.count) heart rate readings", systemImage: "heart.fill")
                    }
                    if !bloodPressures.isEmpty {
                        Label("\(bloodPressures.count) blood pressure readings", systemImage: "waveform.path.ecg")
                    }
                    if !bloodGlucoses.isEmpty {
                        Label("\(bloodGlucoses.count) blood glucose readings", systemImage: "drop.fill")
                    }
                }
                .font(.system(size: 16, design: .rounded))
                .padding()
                .background(Color(UIColor.secondarySystemBackground))
                .cornerRadius(12)
                
                Spacer()
                
                Button(action: exportReport) {
                    HStack {
                        if isExporting {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Image(systemName: "square.and.arrow.up")
                        }
                        Text(isExporting ? "Generating..." : "Export PDF")
                    }
                    .font(.system(size: 20, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(DesignSystem.Colors.primaryRed)
                    .cornerRadius(16)
                }
                .disabled(isExporting)
                .padding(.horizontal)
            }
            .padding()
            .navigationTitle("Export")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showingShareSheet) {
                if let url = exportedURL {
                    ShareSheet(items: [url])
                }
            }
        }
    }
    
    private func exportReport() {
        isExporting = true
        
        // Generate PDF in background
        DispatchQueue.global(qos: .userInitiated).async {
            let pdfData = generatePDFReport()
            
            // Save to temp file
            let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("HealthReport_\(Date().ISO8601Format()).pdf")
            
            do {
                try pdfData.write(to: tempURL)
                
                DispatchQueue.main.async {
                    self.exportedURL = tempURL
                    self.isExporting = false
                    self.showingShareSheet = true
                }
            } catch {
                DispatchQueue.main.async {
                    self.isExporting = false
                }
            }
        }
    }
    
    private func generatePDFReport() -> Data {
        let pageWidth: CGFloat = 612
        let pageHeight: CGFloat = 792
        let margin: CGFloat = 50
        
        let pdfRenderer = UIGraphicsPDFRenderer(bounds: CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight))
        
        return pdfRenderer.pdfData { context in
            context.beginPage()
            
            var yPosition: CGFloat = margin
            
            // Title
            let titleAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 24, weight: .bold),
                .foregroundColor: UIColor.black
            ]
            
            let title = "Health Report - \(period.title)"
            title.draw(at: CGPoint(x: margin, y: yPosition), withAttributes: titleAttributes)
            yPosition += 40
            
            // Date range
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .medium
            let cutoffDate = Calendar.current.date(byAdding: .day, value: -period.days, to: Date()) ?? Date()
            let dateRange = "\(dateFormatter.string(from: cutoffDate)) - \(dateFormatter.string(from: Date()))"
            
            let subtitleAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 14),
                .foregroundColor: UIColor.gray
            ]
            dateRange.draw(at: CGPoint(x: margin, y: yPosition), withAttributes: subtitleAttributes)
            yPosition += 40
            
            // Heart Rate Section
            if !heartRates.isEmpty {
                yPosition = drawSection(
                    context: context,
                    title: "Heart Rate",
                    yPosition: yPosition,
                    margin: margin,
                    pageWidth: pageWidth
                )
                
                let avgHR = heartRates.reduce(0) { $0 + $1.bpm } / heartRates.count
                let minHR = heartRates.min(by: { $0.bpm < $1.bpm })?.bpm ?? 0
                let maxHR = heartRates.max(by: { $0.bpm < $1.bpm })?.bpm ?? 0
                
                let hrText = "Average: \(avgHR) BPM | Min: \(minHR) BPM | Max: \(maxHR) BPM | Readings: \(heartRates.count)"
                hrText.draw(at: CGPoint(x: margin, y: yPosition), withAttributes: subtitleAttributes)
                yPosition += 30
            }
            
            // Blood Pressure Section
            if !bloodPressures.isEmpty {
                yPosition = drawSection(
                    context: context,
                    title: "Blood Pressure",
                    yPosition: yPosition,
                    margin: margin,
                    pageWidth: pageWidth
                )
                
                let avgSys = bloodPressures.reduce(0) { $0 + $1.systolic } / bloodPressures.count
                let avgDia = bloodPressures.reduce(0) { $0 + $1.diastolic } / bloodPressures.count
                
                let bpText = "Average: \(avgSys)/\(avgDia) mmHg | Readings: \(bloodPressures.count)"
                bpText.draw(at: CGPoint(x: margin, y: yPosition), withAttributes: subtitleAttributes)
                yPosition += 30
            }
            
            // Blood Glucose Section
            if !bloodGlucoses.isEmpty {
                yPosition = drawSection(
                    context: context,
                    title: "Blood Glucose",
                    yPosition: yPosition,
                    margin: margin,
                    pageWidth: pageWidth
                )
                
                let avgGlucose = bloodGlucoses.reduce(0.0) { $0 + $1.value } / Double(bloodGlucoses.count)
                
                let bgText = String(format: "Average: %.0f mg/dL | Readings: %d", avgGlucose, bloodGlucoses.count)
                bgText.draw(at: CGPoint(x: margin, y: yPosition), withAttributes: subtitleAttributes)
                yPosition += 30
            }
            
            // Disclaimer
            yPosition = pageHeight - margin - 40
            let disclaimerAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 10),
                .foregroundColor: UIColor.gray
            ]
            let disclaimer = "Disclaimer: This report is for informational purposes only and is not intended for medical diagnosis."
            disclaimer.draw(at: CGPoint(x: margin, y: yPosition), withAttributes: disclaimerAttributes)
        }
    }
    
    private func drawSection(context: UIGraphicsPDFRendererContext, title: String, yPosition: CGFloat, margin: CGFloat, pageWidth: CGFloat) -> CGFloat {
        var y = yPosition
        
        let sectionAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 18, weight: .semibold),
            .foregroundColor: UIColor.black
        ]
        
        title.draw(at: CGPoint(x: margin, y: y), withAttributes: sectionAttributes)
        y += 25
        
        return y
    }
}

#Preview {
    HealthReportView()
        .modelContainer(for: [HeartRateRecord.self, BloodPressureRecord.self, BloodGlucoseRecord.self], inMemory: true)
}
