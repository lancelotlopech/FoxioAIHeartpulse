//
//  EmergencyContactsView.swift
//  HeartRateSenior
//
//  View for managing emergency contacts with SOS quick call
//

import SwiftUI
import SwiftData

struct EmergencyContactsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \EmergencyContact.createdAt) private var contacts: [EmergencyContact]
    @StateObject private var settingsManager = SettingsManager()
    
    @State private var showingAddContact = false
    @State private var selectedContact: EmergencyContact?
    @State private var showingAlertSettings = false
    
    // Primary contact for SOS
    private var primaryContact: EmergencyContact? {
        contacts.first(where: { $0.isPrimary }) ?? contacts.first
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(UIColor.systemBackground)
                    .ignoresSafeArea()
                
                if contacts.isEmpty {
                    emptyStateView
                } else {
                    ScrollView {
                        VStack(spacing: 20) {
                            // SOS Button
                            if let contact = primaryContact {
                                SOSButton(contact: contact)
                            }
                            
                            // Contacts List
                            contactsListSection
                            
                            // Alert Rules
                            alertRulesSection
                        }
                        .padding(.vertical, 16)
                    }
                }
            }
            .navigationTitle("Emergency")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingAddContact = true
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundColor(DesignSystem.Colors.primaryRed)
                    }
                }
            }
            .sheet(isPresented: $showingAddContact) {
                AddContactView()
            }
            .sheet(item: $selectedContact) { contact in
                AddContactView(editingContact: contact)
            }
        }
    }
    
    // MARK: - Empty State
    
    private var emptyStateView: some View {
        VStack(spacing: 24) {
            Image(systemName: "person.crop.circle.badge.plus")
                .font(.system(size: 80))
                .foregroundColor(DesignSystem.Colors.primaryRed.opacity(0.5))
            
            Text("No Emergency Contacts")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(DesignSystem.Colors.textPrimary)
            
            Text("Add contacts who should be\nnotified in case of emergency")
                .font(.system(size: 18, design: .rounded))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button(action: {
                showingAddContact = true
            }) {
                HStack {
                    Image(systemName: "plus.circle.fill")
                    Text("Add Contact")
                }
                .font(.system(size: 20, weight: .semibold, design: .rounded))
                .foregroundColor(.white)
                .padding(.horizontal, 32)
                .padding(.vertical, 16)
                .background(DesignSystem.Colors.primaryRed)
                .cornerRadius(16)
            }
            .padding(.top, 8)
        }
        .padding()
    }
    
    // MARK: - SOS Button
    
    struct SOSButton: View {
        let contact: EmergencyContact
        @State private var isPressed = false
        
        var body: some View {
            VStack(spacing: 12) {
                Button(action: {
                    // Direct call without confirmation
                    HapticManager.shared.heavyImpact()
                    if let url = contact.phoneURL {
                        UIApplication.shared.open(url)
                    }
                }) {
                    VStack(spacing: 8) {
                        Image(systemName: "sos")
                            .font(.system(size: 48, weight: .bold))
                        
                        Text("TAP TO CALL")
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                    }
                    .foregroundColor(.white)
                    .frame(width: 140, height: 140)
                    .background(
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [Color.red, Color.red.opacity(0.8)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .shadow(color: Color.red.opacity(0.5), radius: 15, x: 0, y: 8)
                    )
                    .scaleEffect(isPressed ? 0.95 : 1.0)
                }
                .buttonStyle(PlainButtonStyle())
                .simultaneousGesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { _ in
                            withAnimation(.easeInOut(duration: 0.1)) {
                                isPressed = true
                            }
                        }
                        .onEnded { _ in
                            withAnimation(.easeInOut(duration: 0.1)) {
                                isPressed = false
                            }
                        }
                )
                
                Text("Call \(contact.name)")
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(DesignSystem.Colors.textPrimary)
                
                Text(contact.formattedPhoneNumber)
                    .font(.system(size: 14, design: .rounded))
                    .foregroundColor(.secondary)
            }
            .padding(.vertical, 16)
        }
    }
    
    // MARK: - Contacts List
    
    private var contactsListSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Contacts")
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(DesignSystem.Colors.textPrimary)
                .padding(.horizontal, 20)
            
            VStack(spacing: 0) {
                ForEach(contacts) { contact in
                    ContactRowView(contact: contact) {
                        selectedContact = contact
                    } onDelete: {
                        deleteContact(contact)
                    } onCall: {
                        if let url = contact.phoneURL {
                            UIApplication.shared.open(url)
                        }
                    }
                    
                    if contact.id != contacts.last?.id {
                        Divider()
                            .padding(.leading, 76)
                    }
                }
            }
            .background(Color.white)
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 2)
            .padding(.horizontal, 20)
        }
    }
    
    // MARK: - Alert Rules Section
    
    private var alertRulesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Alert Rules")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(DesignSystem.Colors.textPrimary)
                
                Spacer()
            }
            .padding(.horizontal, 20)
            
            VStack(spacing: 16) {
                // Enable Toggle
                HStack {
                    ZStack {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.orange.opacity(0.15))
                            .frame(width: 36, height: 36)
                        
                        Image(systemName: "bell.badge.fill")
                            .font(.system(size: 18))
                            .foregroundColor(.orange)
                    }
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Enable Alerts")
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                            .foregroundColor(DesignSystem.Colors.textPrimary)
                        
                        Text("Notify contacts on abnormal readings")
                            .font(.system(size: 12, design: .rounded))
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Toggle("", isOn: $settingsManager.alertEnabled)
                        .tint(.orange)
                }
                
                if settingsManager.alertEnabled {
                    Divider()
                    
                    // Heart Rate Low
                    AlertThresholdRow(
                        icon: "heart.fill",
                        title: "Heart Rate Low",
                        value: $settingsManager.alertHeartRateLow,
                        unit: "BPM",
                        range: 30...70,
                        color: Color(red: 0.3, green: 0.5, blue: 0.9)
                    )
                    
                    // Heart Rate High
                    AlertThresholdRow(
                        icon: "heart.fill",
                        title: "Heart Rate High",
                        value: $settingsManager.alertHeartRateHigh,
                        unit: "BPM",
                        range: 100...180,
                        color: DesignSystem.Colors.primaryRed
                    )
                    
                    Divider()
                    
                    // Info
                    HStack(spacing: 8) {
                        Image(systemName: "info.circle.fill")
                            .font(.system(size: 14))
                            .foregroundColor(.blue)
                        
                        Text("Contacts marked with \"Notify on Abnormal\" will receive alerts when readings exceed these thresholds.")
                            .font(.system(size: 12, design: .rounded))
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding(16)
            .background(Color.white)
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 2)
            .padding(.horizontal, 20)
        }
    }
    
    // MARK: - Helper Methods
    
    private func deleteContact(_ contact: EmergencyContact) {
        modelContext.delete(contact)
        HapticManager.shared.mediumImpact()
    }
}

// MARK: - Alert Threshold Row

struct AlertThresholdRow: View {
    let icon: String
    let title: String
    @Binding var value: Int
    let unit: String
    let range: ClosedRange<Int>
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 14))
                    .foregroundColor(color)
                
                Text(title)
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(DesignSystem.Colors.textPrimary)
                
                Spacer()
                
                Text("\(value) \(unit)")
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundColor(color)
            }
            
            Slider(
                value: Binding(
                    get: { Double(value) },
                    set: { value = Int($0) }
                ),
                in: Double(range.lowerBound)...Double(range.upperBound),
                step: 5
            )
            .tint(color)
        }
    }
}

// MARK: - Contact Row View

struct ContactRowView: View {
    let contact: EmergencyContact
    let onEdit: () -> Void
    let onDelete: () -> Void
    let onCall: () -> Void
    
    var body: some View {
        HStack(spacing: 14) {
            // Avatar
            ZStack {
                Circle()
                    .fill(contact.isPrimary ? DesignSystem.Colors.primaryRed.opacity(0.15) : Color.blue.opacity(0.15))
                    .frame(width: 50, height: 50)
                
                Text(contact.name.prefix(1).uppercased())
                    .font(.system(size: 20, weight: .semibold, design: .rounded))
                    .foregroundColor(contact.isPrimary ? DesignSystem.Colors.primaryRed : .blue)
            }
            
            // Info
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Text(contact.name)
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundColor(DesignSystem.Colors.textPrimary)
                    
                    if contact.isPrimary {
                        Text("PRIMARY")
                            .font(.system(size: 9, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(DesignSystem.Colors.primaryRed)
                            .cornerRadius(4)
                    }
                }
                
                Text(contact.formattedPhoneNumber)
                    .font(.system(size: 13, design: .rounded))
                    .foregroundColor(.secondary)
                
                if !contact.relationship.isEmpty {
                    Text(contact.relationship)
                        .font(.system(size: 11, design: .rounded))
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            // Quick Actions
            HStack(spacing: 12) {
                if contact.notifyOnAbnormal {
                    Image(systemName: "bell.fill")
                        .font(.system(size: 12))
                        .foregroundColor(.orange)
                }
                
                Button(action: onCall) {
                    ZStack {
                        Circle()
                            .fill(Color.green.opacity(0.15))
                            .frame(width: 36, height: 36)
                        
                        Image(systemName: "phone.fill")
                            .font(.system(size: 14))
                            .foregroundColor(.green)
                    }
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .contentShape(Rectangle())
        .onTapGesture {
            onEdit()
        }
        .contextMenu {
            Button(action: onCall) {
                Label("Call", systemImage: "phone.fill")
            }
            
            Button(action: onEdit) {
                Label("Edit", systemImage: "pencil")
            }
            
            Button(role: .destructive, action: onDelete) {
                Label("Delete", systemImage: "trash")
            }
        }
    }
}

// MARK: - Add Contact View

struct AddContactView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    var editingContact: EmergencyContact?
    var isEditing: Bool { editingContact != nil }
    
    @State private var name: String = ""
    @State private var selectedCountryCode: CountryCode = .us
    @State private var phoneNumber: String = ""
    @State private var relationship: String = ""
    @State private var isPrimary: Bool = false
    @State private var notifyOnAbnormal: Bool = true
    
    @State private var showingDeleteConfirmation = false
    
    var body: some View {
        NavigationStack {
            Form {
                // Contact Info Section
                Section {
                    TextField("Name", text: $name)
                        .font(.system(size: 18, design: .rounded))
                        .textContentType(.name)
                    
                    // Phone with Country Code
                    HStack(spacing: 0) {
                        // Country Code Picker
                        Menu {
                            ForEach(CountryCode.allCases, id: \.self) { code in
                                Button(action: { selectedCountryCode = code }) {
                                    Text(code.displayName)
                                }
                            }
                        } label: {
                            HStack(spacing: 4) {
                                Text(selectedCountryCode.displayName)
                                    .font(.system(size: 16, design: .rounded))
                                Image(systemName: "chevron.down")
                                    .font(.system(size: 10))
                            }
                            .foregroundColor(DesignSystem.Colors.textPrimary)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(Color(UIColor.secondarySystemBackground))
                            .cornerRadius(8)
                        }
                        
                        TextField("Phone Number", text: $phoneNumber)
                            .font(.system(size: 18, design: .rounded))
                            .textContentType(.telephoneNumber)
                            .keyboardType(.phonePad)
                            .padding(.leading, 12)
                    }
                } header: {
                    Text("Contact Information")
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                }
                
                // Relationship Section
                Section {
                    Picker("Relationship", selection: $relationship) {
                        Text("Select...").tag("")
                        ForEach(ContactRelationship.allCases, id: \.self) { rel in
                            Label(rel.rawValue, systemImage: rel.icon).tag(rel.rawValue)
                        }
                    }
                    .font(.system(size: 18, design: .rounded))
                } header: {
                    Text("Relationship")
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                }
                
                // Settings Section
                Section {
                    Toggle("Primary Contact", isOn: $isPrimary)
                        .font(.system(size: 18, design: .rounded))
                        .tint(DesignSystem.Colors.primaryRed)
                    
                    Toggle("Notify on Abnormal Readings", isOn: $notifyOnAbnormal)
                        .font(.system(size: 18, design: .rounded))
                        .tint(.orange)
                } header: {
                    Text("Settings")
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                } footer: {
                    Text("Primary contact appears in SOS button. Notification setting allows SMS alerts for abnormal health readings.")
                        .font(.system(size: 12, design: .rounded))
                }
                
                // Delete Button
                if isEditing {
                    Section {
                        Button(role: .destructive) {
                            showingDeleteConfirmation = true
                        } label: {
                            HStack {
                                Spacer()
                                Text("Delete Contact")
                                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                                Spacer()
                            }
                        }
                    }
                }
            }
            .navigationTitle(isEditing ? "Edit Contact" : "Add Contact")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .font(.system(size: 17, design: .rounded))
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveContact()
                    }
                    .font(.system(size: 17, weight: .semibold, design: .rounded))
                    .foregroundColor(DesignSystem.Colors.primaryRed)
                    .disabled(!isFormValid)
                }
            }
            .alert("Delete Contact", isPresented: $showingDeleteConfirmation) {
                Button("Delete", role: .destructive) {
                    deleteContact()
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Are you sure you want to delete this contact?")
            }
            .onAppear {
                loadExistingContact()
            }
        }
    }
    
    private var isFormValid: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty &&
        phoneNumber.filter { $0.isNumber }.count >= 7
    }
    
    private func loadExistingContact() {
        guard let contact = editingContact else { return }
        
        name = contact.name
        phoneNumber = contact.phoneNumber
        relationship = contact.relationship
        isPrimary = contact.isPrimary
        notifyOnAbnormal = contact.notifyOnAbnormal
        
        // Try to match country code
        if let code = CountryCode.allCases.first(where: { $0.dialCode == contact.countryCode }) {
            selectedCountryCode = code
        }
    }
    
    private func saveContact() {
        if let existing = editingContact {
            existing.name = name
            existing.countryCode = selectedCountryCode.dialCode
            existing.phoneNumber = phoneNumber
            existing.relationship = relationship
            existing.isPrimary = isPrimary
            existing.notifyOnAbnormal = notifyOnAbnormal
        } else {
            let contact = EmergencyContact(
                name: name,
                countryCode: selectedCountryCode.dialCode,
                phoneNumber: phoneNumber,
                relationship: relationship,
                isPrimary: isPrimary,
                notifyOnAbnormal: notifyOnAbnormal
            )
            modelContext.insert(contact)
        }
        
        HapticManager.shared.success()
        dismiss()
    }
    
    private func deleteContact() {
        guard let contact = editingContact else { return }
        modelContext.delete(contact)
        HapticManager.shared.warning()
        dismiss()
    }
}

#Preview {
    EmergencyContactsView()
        .modelContainer(for: EmergencyContact.self, inMemory: true)
}
