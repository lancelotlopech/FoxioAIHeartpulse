//
//  BackupRestoreView.swift
//  HeartRateSenior
//
//  View for data backup and restore
//

import SwiftUI
import SwiftData
import UniformTypeIdentifiers

struct BackupRestoreView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var syncManager = CloudSyncManager.shared
    
    @State private var showingExportSheet = false
    @State private var showingImportPicker = false
    @State private var showingImportConfirmation = false
    @State private var showingSuccessAlert = false
    @State private var showingErrorAlert = false
    
    @State private var exportedURL: URL?
    @State private var importURL: URL?
    @State private var importResult: ImportResult?
    @State private var errorMessage: String?
    
    var body: some View {
        List {
            // Cloud Status Section
            Section {
                HStack {
                    Image(systemName: syncManager.isCloudAvailable ? "icloud.fill" : "icloud.slash")
                        .font(.system(size: 24))
                        .foregroundColor(syncManager.isCloudAvailable ? .blue : .secondary)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("iCloud Status")
                            .font(.system(size: 18, weight: .semibold, design: .rounded))
                        
                        Text(syncManager.isCloudAvailable ? "Connected" : "Not Available")
                            .font(.system(size: 14, design: .rounded))
                            .foregroundColor(syncManager.isCloudAvailable ? .green : .secondary)
                    }
                    
                    Spacer()
                    
                    if syncManager.isCloudAvailable {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                    }
                }
                .padding(.vertical, 8)
            } header: {
                Text("Cloud Storage")
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
            }
            
            // Export Section
            Section {
                Button(action: exportData) {
                    HStack {
                        Image(systemName: "square.and.arrow.up")
                            .font(.system(size: 20))
                            .foregroundColor(.blue)
                            .frame(width: 32)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Export Data")
                                .font(.system(size: 18, weight: .semibold, design: .rounded))
                                .foregroundColor(DesignSystem.Colors.textPrimary)
                            
                            Text("Save all health data to a file")
                                .font(.system(size: 14, design: .rounded))
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        if syncManager.isSyncing {
                            ProgressView()
                        } else {
                            Image(systemName: "chevron.right")
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .disabled(syncManager.isSyncing)
                .padding(.vertical, 8)
            } header: {
                Text("Backup")
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
            } footer: {
                Text("Export creates a JSON file containing all your health records, reminders, and emergency contacts.")
                    .font(.system(size: 12, design: .rounded))
            }
            
            // Import Section
            Section {
                Button(action: {
                    showingImportPicker = true
                }) {
                    HStack {
                        Image(systemName: "square.and.arrow.down")
                            .font(.system(size: 20))
                            .foregroundColor(.green)
                            .frame(width: 32)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Import Data")
                                .font(.system(size: 18, weight: .semibold, design: .rounded))
                                .foregroundColor(DesignSystem.Colors.textPrimary)
                            
                            Text("Restore from a backup file")
                                .font(.system(size: 14, design: .rounded))
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .foregroundColor(.secondary)
                    }
                }
                .disabled(syncManager.isSyncing)
                .padding(.vertical, 8)
            } header: {
                Text("Restore")
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
            } footer: {
                Text("Import will add data from the backup file. Existing records will not be deleted.")
                    .font(.system(size: 12, design: .rounded))
            }
            
            // Last Sync Info
            if let lastSync = syncManager.lastSyncDate {
                Section {
                    HStack {
                        Image(systemName: "clock.arrow.circlepath")
                            .foregroundColor(.secondary)
                        
                        Text("Last Activity")
                            .font(.system(size: 16, design: .rounded))
                        
                        Spacer()
                        
                        Text(lastSync, style: .relative)
                            .font(.system(size: 14, design: .rounded))
                            .foregroundColor(.secondary)
                    }
                } header: {
                    Text("History")
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                }
            }
            
            // Data Info Section
            Section {
                VStack(alignment: .leading, spacing: 12) {
                    Label("What's included in backup:", systemImage: "info.circle.fill")
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundColor(.blue)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        DataTypeRow(icon: "heart.fill", title: "Heart Rate Records", color: .red)
                        DataTypeRow(icon: "waveform.path.ecg", title: "Blood Pressure Records", color: .blue)
                        DataTypeRow(icon: "drop.fill", title: "Blood Glucose Records", color: .purple)
                        DataTypeRow(icon: "bell.fill", title: "Reminders", color: .orange)
                        DataTypeRow(icon: "person.2.fill", title: "Emergency Contacts", color: .green)
                    }
                }
                .padding(.vertical, 8)
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Backup & Restore")
        .navigationBarTitleDisplayMode(.large)
        .sheet(isPresented: $showingExportSheet) {
            if let url = exportedURL {
                ShareSheet(items: [url])
            }
        }
        .fileImporter(
            isPresented: $showingImportPicker,
            allowedContentTypes: [.json],
            allowsMultipleSelection: false
        ) { result in
            handleImportResult(result)
        }
        .alert("Import Data?", isPresented: $showingImportConfirmation) {
            Button("Import", role: .none) {
                performImport()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This will add all records from the backup file to your current data.")
        }
        .alert("Import Successful", isPresented: $showingSuccessAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            if let result = importResult {
                Text("Imported \(result.totalCount) records:\n• \(result.heartRateCount) heart rate\n• \(result.bloodPressureCount) blood pressure\n• \(result.bloodGlucoseCount) blood glucose\n• \(result.reminderCount) reminders\n• \(result.contactCount) contacts")
            }
        }
        .alert("Error", isPresented: $showingErrorAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(errorMessage ?? "An unknown error occurred.")
        }
    }
    
    // MARK: - Export
    
    private func exportData() {
        Task {
            do {
                let url = try await syncManager.exportAllData(modelContext: modelContext)
                await MainActor.run {
                    exportedURL = url
                    showingExportSheet = true
                    HapticManager.shared.success()
                }
            } catch {
                await MainActor.run {
                    errorMessage = error.localizedDescription
                    showingErrorAlert = true
                    HapticManager.shared.error()
                }
            }
        }
    }
    
    // MARK: - Import
    
    private func handleImportResult(_ result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            if let url = urls.first {
                importURL = url
                showingImportConfirmation = true
            }
        case .failure(let error):
            errorMessage = error.localizedDescription
            showingErrorAlert = true
        }
    }
    
    private func performImport() {
        guard let url = importURL else { return }
        
        // Start accessing security-scoped resource
        guard url.startAccessingSecurityScopedResource() else {
            errorMessage = "Unable to access the selected file."
            showingErrorAlert = true
            return
        }
        
        defer { url.stopAccessingSecurityScopedResource() }
        
        Task {
            do {
                let result = try await syncManager.importData(from: url, modelContext: modelContext)
                await MainActor.run {
                    importResult = result
                    showingSuccessAlert = true
                    HapticManager.shared.success()
                }
            } catch {
                await MainActor.run {
                    errorMessage = error.localizedDescription
                    showingErrorAlert = true
                    HapticManager.shared.error()
                }
            }
        }
    }
}

// MARK: - Data Type Row

struct DataTypeRow: View {
    let icon: String
    let title: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundColor(color)
                .frame(width: 20)
            
            Text(title)
                .font(.system(size: 14, design: .rounded))
                .foregroundColor(.secondary)
        }
    }
}

#Preview {
    NavigationStack {
        BackupRestoreView()
    }
    .modelContainer(for: [HeartRateRecord.self, BloodPressureRecord.self, BloodGlucoseRecord.self], inMemory: true)
}
