import SwiftUI

struct LeadListView: View {
    @Environment(DataStore.self) private var dataStore
    @Environment(LeadManager.self) private var leadManager
    @State private var searchText = ""
    @State private var showingAddLead = false
    @State private var showingAdvancedSearch = false
    @State private var selectedStatus: Lead.LeadStatus?
    
    private var filteredLeads: [Lead] {
        var results = dataStore.leads
        
        // Text search
        if !searchText.isEmpty {
            results = results.filter { lead in
                lead.title.localizedCaseInsensitiveContains(searchText) ||
                lead.location.localizedCaseInsensitiveContains(searchText) ||
                lead.reporter.localizedCaseInsensitiveContains(searchText) ||
                lead.searchableEvidenceText.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        // Status filter
        if let status = selectedStatus {
            results = results.filter { $0.status == status }
        }
        
        return results
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Status Filter Chips
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        StatusChip(label: "全部", count: dataStore.leads.count, isSelected: selectedStatus == nil) {
                            selectedStatus = nil
                        }
                        
                        ForEach(Lead.LeadStatus.allCases, id: \.self) { status in
                            let count = dataStore.leads.filter { $0.status == status }.count
                            if count > 0 {
                                StatusChip(
                                    label: status.rawValue,
                                    count: count,
                                    color: status.color,
                                    isSelected: selectedStatus == status
                                ) {
                                    selectedStatus = status
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                }
                .background(.bar)
                
                // Lead List
                List {
                    Section {
                        Text("共 \(filteredLeads.count) 条线索")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    
                    ForEach(filteredLeads) { lead in
                        NavigationLink(value: lead) {
                            EnhancedLeadRow(lead: lead, leadManager: leadManager)
                        }
                    }
                    .onDelete { offsets in
                        dataStore.deleteLead(at: offsets)
                    }
                }
                .listStyle(.insetGrouped)
            }
            .navigationTitle("线索")
            .navigationDestination(for: Lead.self) { lead in
                LeadDetailView(lead: lead)
            }
            .searchable(text: $searchText, prompt: "搜索零售户、证号或稽查地点")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    HStack(spacing: 12) {
                        Button {
                            showingAdvancedSearch = true
                        } label: {
                            Image(systemName: "slider.horizontal.3")
                        }
                        
                        Button {
                            showingAddLead = true
                        } label: {
                            Image(systemName: "plus.circle.fill")
                                .symbolRenderingMode(.hierarchical)
                        }
                    }
                }
            }
            .sheet(isPresented: $showingAddLead) {
                AddLeadView()
            }
            .sheet(isPresented: $showingAdvancedSearch) {
                LeadSearchView()
            }
        }
    }
}

// MARK: - Status Chip

private struct StatusChip: View {
    let label: String
    let count: Int
    var color: Color = .blue
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Text(label)
                    .font(.subheadline)
                    .fontWeight(isSelected ? .semibold : .regular)
                Text("(\(count))")
                    .font(.caption)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .foregroundStyle(isSelected ? .white : .primary)
            .background(
                isSelected ? AnyShapeStyle(color) : AnyShapeStyle(.fill.quaternary),
                in: Capsule()
            )
        }
    }
}

// MARK: - Enhanced Lead Row

private struct EnhancedLeadRow: View {
    let lead: Lead
    let leadManager: LeadManager
    
    var relatedAggregation: EnforcementLead? {
        leadManager.aggregationForLead(lead.id)
    }
    
    var body: some View {
        HStack(spacing: 12) {
            // Icon
            ZStack {
                Circle()
                    .fill(lead.status.color.opacity(0.15))
                    .frame(width: 52, height: 52)
                
                Image(systemName: lead.systemImageName)
                    .font(.title3)
                    .foregroundStyle(lead.status.color)
            }
            
            // Content
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 8) {
                    Text(lead.title)
                        .font(.headline)
                        .lineLimit(1)
                    
                    if let relatedAggregation = relatedAggregation {
                        Text(relatedAggregation.leadNumber)
                            .font(.caption2)
                            .foregroundStyle(.white)
                            .padding(.horizontal, 5)
                            .padding(.vertical, 2)
                            .background(.purple, in: Capsule())
                    }
                }
                
                HStack(spacing: 8) {
                    Text(lead.location)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                    
                    Text("•")
                        .foregroundStyle(.tertiary)
                    
                    Text(lead.timestamp, style: .relative)
                        .font(.subheadline)
                        .foregroundStyle(.tertiary)
                }
                
                HStack(spacing: 12) {
                    Label("\(lead.evidences.count)", systemImage: "photo.fill")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    if let aiAnalysis = lead.aiAnalysis {
                        HStack(spacing: 2) {
                            Image(systemName: "sparkles")
                            Text("AI")
                        }
                        .font(.caption)
                        .foregroundStyle(.blue)
                    }
                    
                    Text(lead.status.rawValue)
                        .font(.caption2)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(lead.status.color, in: Capsule())
                }
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    LeadListView()
        .environment(DataStore())
        .environment(LeadManager())
}