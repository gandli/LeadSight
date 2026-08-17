import SwiftUI

struct LeadAggregationView: View {
    @Environment(DataStore.self) private var dataStore
    @State private var leadManager = LeadManager()
    @State private var showingNewAggregation = false
    @State private var selectedStatus: EnforcementLead.LeadAggregationStatus?
    
    private var filteredAggregations: [EnforcementLead] {
        if let status = selectedStatus {
            return leadManager.aggregations.filter { $0.status == status }
        }
        return leadManager.aggregations
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Status Filter
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        StatusFilterChip(label: "全部", isSelected: selectedStatus == nil) {
                            selectedStatus = nil
                        }
                        ForEach(EnforcementLead.LeadAggregationStatus.allCases, id: \.self) { status in
                            StatusFilterChip(
                                label: status.rawValue,
                                icon: status.systemImage,
                                color: status.color,
                                isSelected: selectedStatus == status
                            ) {
                                selectedStatus = status
                            }
                        }
                    }
                    .padding()
                }
                .background(.bar)
                
                // Lead Aggregations List
                if filteredAggregations.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "folder.badge.questionmark")
                            .font(.system(size: 50))
                            .foregroundStyle(.tertiary)
                        Text("暂无线索聚合")
                            .font(.headline)
                            .foregroundStyle(.secondary)
                        Button {
                            showingNewAggregation = true
                        } label: {
                            Label("创建聚合", systemImage: "plus.circle.fill")
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List {
                        ForEach(filteredAggregations) { enforcementLead in
                            NavigationLink(value: enforcementLead) {
                                LeadAggregationRow(enforcementLead: enforcementLead, dataStore: dataStore)
                            }
                        }
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .navigationTitle("线索聚合")
            .navigationDestination(for: EnforcementLead.self) { enforcementLead in
                LeadAnalysisView(enforcementLead: enforcementLead)
                    .environment(leadManager)
            }
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showingNewAggregation = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                    }
                }
            }
            .sheet(isPresented: $showingNewAggregation) {
                NewAggregationView()
                    .environment(leadManager)
            }
        }
    }
}

// MARK: - Lead Aggregation Row

private struct LeadAggregationRow: View {
    let enforcementLead: EnforcementLead
    let dataStore: DataStore
    
    private var leads: [Lead] {
        dataStore.leads.filter { enforcementLead.leadIDs.contains($0.id) }
    }
    
    private var evidenceCount: Int {
        leads.reduce(0) { $0 + $1.evidences.count }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 8) {
                        Text(enforcementLead.leadNumber)
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundStyle(.secondary)
                        
                        Text(enforcementLead.priority.rawValue)
                            .font(.caption2)
                            .foregroundStyle(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(enforcementLead.priority.color, in: Capsule())
                    }
                    
                    Text(enforcementLead.title)
                        .font(.headline)
                        .lineLimit(1)
                }
                
                Spacer()
                
                Text(enforcementLead.status.rawValue)
                    .font(.caption)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(enforcementLead.status.color, in: Capsule())
            }
            
            HStack(spacing: 16) {
                Label("\(leads.count) 条线索", systemImage: "list.bullet.rectangle")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                Label("\(evidenceCount) 份证据", systemImage: "photo.on.rectangle")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                Spacer()
                
                Text(enforcementLead.updatedAt, style: .relative)
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Status Filter Chip

private struct StatusFilterChip: View {
    let label: String
    var icon: String?
    var color: Color = .blue
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                if let icon {
                    Image(systemName: icon)
                        .font(.caption2)
                }
                Text(label)
                    .font(.subheadline)
                    .fontWeight(isSelected ? .semibold : .regular)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .foregroundStyle(isSelected ? .white : .primary)
            .background(
                isSelected ? AnyShapeStyle(color) : AnyShapeStyle(.fill.quaternary),
                in: Capsule()
            )
        }
    }
}

// MARK: - Preview

#Preview {
    LeadAggregationView()
        .environment(DataStore())
}