import SwiftUI

struct CaseListView: View {
    @Environment(DataStore.self) private var dataStore
    @State private var caseManager = CaseManager()
    @State private var showingNewCase = false
    @State private var selectedStatus: EnforcementCase.CaseStatus?
    
    private var filteredCases: [EnforcementCase] {
        if let status = selectedStatus {
            return caseManager.cases.filter { $0.status == status }
        }
        return caseManager.cases
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
                        ForEach(EnforcementCase.CaseStatus.allCases, id: \.self) { status in
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
                
                // Cases List
                if filteredCases.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "folder.badge.questionmark")
                            .font(.system(size: 50))
                            .foregroundStyle(.tertiary)
                        Text("暂无案件")
                            .font(.headline)
                            .foregroundStyle(.secondary)
                        Button {
                            showingNewCase = true
                        } label: {
                            Label("创建案件", systemImage: "plus.circle.fill")
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List {
                        ForEach(filteredCases) { enforcementCase in
                            NavigationLink(value: enforcementCase) {
                                CaseRow(enforcementCase: enforcementCase, dataStore: dataStore)
                            }
                        }
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .navigationTitle("案件管理")
            .navigationDestination(for: EnforcementCase.self) { enforcementCase in
                CaseDetailView(enforcementCase: enforcementCase)
                    .environment(caseManager)
            }
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showingNewCase = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                    }
                }
            }
            .sheet(isPresented: $showingNewCase) {
                NewCaseView()
                    .environment(caseManager)
            }
        }
    }
}

// MARK: - Case Row

private struct CaseRow: View {
    let enforcementCase: EnforcementCase
    let dataStore: DataStore
    
    private var leads: [Lead] {
        dataStore.leads.filter { enforcementCase.leadIDs.contains($0.id) }
    }
    
    private var evidenceCount: Int {
        leads.reduce(0) { $0 + $1.evidences.count }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 8) {
                        Text(enforcementCase.caseNumber)
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundStyle(.secondary)
                        
                        Text(enforcementCase.priority.rawValue)
                            .font(.caption2)
                            .foregroundStyle(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(enforcementCase.priority.color, in: Capsule())
                    }
                    
                    Text(enforcementCase.title)
                        .font(.headline)
                        .lineLimit(1)
                }
                
                Spacer()
                
                Text(enforcementCase.status.rawValue)
                    .font(.caption)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(enforcementCase.status.color, in: Capsule())
            }
            
            HStack(spacing: 16) {
                Label("\(leads.count) 条线索", systemImage: "list.bullet.rectangle")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                Label("\(evidenceCount) 份证据", systemImage: "photo.on.rectangle")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                Spacer()
                
                Text(enforcementCase.updatedAt, style: .relative)
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
    CaseListView()
        .environment(DataStore())
}