//
//  EmergencyContactsView.swift
//  HeartRateSenior
//
//  View for managing emergency contacts
//

import SwiftUI
import SwiftData

struct EmergencyContactsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \EmergencyContact.createdAt) private var contacts: [EmergencyContact]
    
    @State private var showingAddContact = false
    @State private var selectedContact: EmergencyContact?
    @State private var showingCallConfirmation = false
    @State private var contactToCall: EmergencyContact?
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(UIColor.systemBackground)
                    .ignoresSafeArea()
                
                if contacts.isEmpty {
                    emptyStateView
                } else {
                    contactsList
                }
            }
            .navigationTitle("Emergency Contacts")
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
            .alert("Call \(contactToCall?.name ?? "")?", isPresented: $showingCallConfirmation) {
                Button("Call", role: .none) {
                    if let contact = contactToCall, let url = contact.phoneURL {
                        UIApplication.shared.open(url)
                    }
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This will open your phone app to call \(contactToCall?.formattedPhoneNumber ?? "").")
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
    
    // MARK: - Contacts List
    
    private var contactsList: some View {
        List {
            // Quick Call Section
            Section {
                ForEach(contacts.filter { $0.isPrimary }) { contact in
                    QuickCallCard(contact: contact) {
                        contactToCall = contact
                        showingCallConfirmation = true
                    }
                }
            } header: {
                if contacts.contains(where: { $0.isPrimary }) {
                    Text("Primary Contact")
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                }
            }
            
            // All Contacts Section
            Section {
                ForEach(contacts) { contact in
                    ContactRow(contact: contact)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            selectedContact = contact
                        }
                        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                            Button(role: .destructive) {
                                deleteContact(contact)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                            
                            Button {
                                contactToCall = contact
                                showingCallConfirmation = true
                            } label: {
                                Label("Call", systemImage: "phone.fill")
                            }
                            .tint(.green)
                        }
                        .swipeActions(edge: .leading) {
                            Button {
                                sendSMS(to: contact)
                            } label: {
                                Label("Message", systemImage: "message.fill")
                            }
                            .tint(.blue)
                        }
                }
            } header: {
                Text("All Contacts")
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
            }
            
            // Info Section
            Section {
                VStack(alignment: .leading, spacing: 8) {
                    Label("Abnormal Reading Alerts", systemImage: "exclamationmark.triangle.fill")
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundColor(.orange)
                    
                    Text("Contacts with notifications enabled will receive an SMS alert when abnormal health readings are detected.")
                        .font(.system(size: 14, design: .rounded))
                        .foregroundColor(.secondary)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Alert thresholds:")
                            .font(.system(size: 12, weight: .medium, design: .rounded))
                            .foregroundColor(.secondary)
                        Text("• Heart Rate: <\(HealthAlertThresholds.heartRateLow) or >\(HealthAlertThresholds.heartRateHigh) BPM")
                        Text("• Blood Pressure: ≥\(HealthAlertThresholds.systolicHigh)/\(HealthAlertThresholds.diastolicHigh) mmHg")
                        Text("• Blood Glucose: <\(Int(HealthAlertThresholds.glucoseLow)) or >\(Int(HealthAlertThresholds.glucoseHigh)) mg/dL")
                    }
                    .font(.system(size: 12, design: .rounded))
                    .foregroundColor(.secondary)
                }
                .padding(.vertical, 8)
            }
        }
        .listStyle(.insetGrouped)
    }
    
    // MARK: - Helper Methods
    
    private func deleteContact(_ contact: EmergencyContact) {
        modelContext.delete(contact)
        HapticManager.shared.mediumImpact()
    }
    
    private func sendSMS(to contact: EmergencyContact) {
        if let url = contact.smsURL {
            UIApplication.shared.open(url)
        }
    }
}

// MARK: - Quick Call Card

struct QuickCallCard: View {
    let contact: EmergencyContact
    let onCall: () -> Void
    
    var body: some View {
        HStack(spacing: 16) {
            // Avatar
            ZStack {
                Circle()
                    .fill(DesignSystem.Colors.primaryRed.opacity(0.15))
                    .frame(width: 60, height: 60)
                
                Text(contact.name.prefix(1).uppercased())
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(DesignSystem.Colors.primaryRed)
            }
            
            // Info
            VStack(alignment: .leading, spacing: 4) {
                Text(contact.name)
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(DesignSystem.Colors.textPrimary)
                
                if !contact.relationship.isEmpty {
                    Text(contact.relationship)
                        .font(.system(size: 14, design: .rounded))
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            // Call Button
            Button(action: onCall) {
                ZStack {
                    Circle()
                        .fill(.green)
                        .frame(width: 56, height: 56)
                    
                    Image(systemName: "phone.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.white)
                }
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, 8)
    }
}

// MARK: - Contact Row

struct ContactRow: View {
    let contact: EmergencyContact
    
    var body: some View {
        HStack(spacing: 16) {
            // Avatar
            ZStack {
                Circle()
                    .fill(Color.blue.opacity(0.15))
                    .frame(width: 50, height: 50)
                
                Text(contact.name.prefix(1).uppercased())
                    .font(.system(size: 20, weight: .semibold, design: .rounded))
                    .foregroundColor(.blue)
            }
            
            // Info
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(contact.name)
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                        .foregroundColor(DesignSystem.Colors.textPrimary)
                    
                    if contact.isPrimary {
                        Image(systemName: "star.fill")
                            .font(.system(size: 12))
                            .foregroundColor(.orange)
                    }
                }
                
                Text(contact.formattedPhoneNumber)
                    .font(.system(size: 14, design: .rounded))
                    .foregroundColor(.secondary)
                
                if !contact.relationship.isEmpty {
                    Text(contact.relationship)
                        .font(.system(size: 12, design: .rounded))
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            // Notification indicator
            if contact.notifyOnAbnormal {
                Image(systemName: "bell.fill")
                    .font(.system(size: 14))
                    .foregroundColor(.orange)
            }
            
            Image(systemName: "chevron.right")
                .font(.system(size: 14))
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 8)
    }
}

// MARK: - Add Contact View

struct AddContactView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    var editingContact: EmergencyContact?
    var isEditing: Bool { editingContact != nil }
    
    @State private var name: String = ""
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
                    
                    TextField("Phone Number", text: $phoneNumber)
                        .font(.system(size: 18, design: .rounded))
                        .textContentType(.telephoneNumber)
                        .keyboardType(.phonePad)
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
                    Text("Primary contact will be shown prominently for quick calling. Notification setting allows SMS alerts for abnormal health readings.")
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
        phoneNumber.filter { $0.isNumber }.count >= 10
    }
    
    private func loadExistingContact() {
        guard let contact = editingContact else { return }
        
        name = contact.name
        phoneNumber = contact.phoneNumber
        relationship = contact.relationship
        isPrimary = contact.isPrimary
        notifyOnAbnormal = contact.notifyOnAbnormal
    }
    
    private func saveContact() {
        if let existing = editingContact {
            existing.name = name
            existing.phoneNumber = phoneNumber
            existing.relationship = relationship
            existing.isPrimary = isPrimary
            existing.notifyOnAbnormal = notifyOnAbnormal
        } else {
            let contact = EmergencyContact(
                name: name,
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
