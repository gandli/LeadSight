import SwiftUI

// MARK: - Search Filters

struct LeadSearchFilters: Equatable {
    var query: String = ""
    var status: Lead.LeadStatus?
    var imageName: String?
    var dateRange: DateRange?
    
    enum DateRange: String, CaseIterable {
        case today = "今天"
        case thisWeek = "本周"
        case thisMonth = "本月"
        case all = "全部"
        
        var predicate: (Date) -> Bool {
            let calendar = Calendar.current
            let now = Date()
            switch self {
            case .today:
                return { calendar.isDateInToday($0) }
            case .thisWeek:
                return { calendar.isDate($0, equalTo: now, toGranularity: .weekOfYear) }
            case .thisMonth:
                return { calendar.isDate($0, equalTo: now, toGranularity: .month) }
            case .all:
                return { _ in true }
            }
        }
    }
    
    static func == (lhs: LeadSearchFilters, rhs: LeadSearchFilters) -> Bool {
        lhs.query == rhs.query &&
        lhs.status == rhs.status &&
        lhs.imageName == rhs.imageName &&
        lhs.dateRange == rhs.dateRange
    }
}

// MARK: - Enhanced Lead List View

struct LeadSearchView: View {
    @Environment(DataStore.self) private var dataStore
    @Environment(\.dismiss) private var dismiss
    @State private var filters = LeadSearchFilters()
    @State private var showingFilters = false
    
    private var filteredLeads: [Lead] {
        var results = dataStore.leads
        
        // Text search
        if !filters.query.isEmpty {
            let query = filters.query.lowercased()
            results = results.filter { lead in
                lead.title.lowercased().contains(query) ||
                lead.content.lowercased().contains(query) ||
                lead.location.lowercased().contains(query) ||
                lead.reporter.lowercased().contains(query) ||
                lead.searchableEvidenceText.lowercased().contains(query)
            }
        }
        
        // Status filter
        if let status = filters.status {
            results = results.filter { $0.status == status }
        }
        
        // Stage filter
        if let imageName = filters.imageName {
            results = results.filter { $0.imageName == imageName }
        }
        
        // Date filter
        if let dateRange = filters.dateRange {
            results = results.filter { dateRange.predicate($0.timestamp) }
        }
        
        return results
    }
    
    private var activeFiltersCount: Int {
        var count = 0
        if filters.status != nil { count += 1 }
        if filters.imageName != nil { count += 1 }
        if filters.dateRange != nil && filters.dateRange != .all { count += 1 }
        return count
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Search Bar
                HStack(spacing: 12) {
                    HStack(spacing: 8) {
                        Image(systemName: "magnifyingglass")
                            .foregroundStyle(.secondary)
                        TextField("搜索线索、证据内容...", text: $filters.query)
                            .textFieldStyle(.plain)
                        if !filters.query.isEmpty {
                            Button {
                                filters.query = ""
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                    .background(.fill.quaternary, in: RoundedRectangle(cornerRadius: 10))
                    
                    Button {
                        showingFilters = true
                    } label: {
                        ZStack(alignment: .topTrailing) {
                            Image(systemName: "slider.horizontal.3")
                                .font(.title3)
                            if activeFiltersCount > 0 {
                                Circle()
                                    .fill(.red)
                                    .frame(width: 8, height: 8)
                                    .offset(x: 4, y: -4)
                            }
                        }
                    }
                }
                .padding()
                .background(.bar)
                
                // Active Filters
                if activeFiltersCount > 0 {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            if let status = filters.status {
                                FilterPill(label: status.rawValue, icon: "checkmark.circle.fill") {
                                    filters.status = nil
                                }
                            }
                            if let imageName = filters.imageName {
                                FilterPill(label: stageDisplayName(imageName), icon: imageNameIcon(imageName)) {
                                    filters.imageName = nil
                                }
                            }
                            if let dateRange = filters.dateRange, dateRange != .all {
                                FilterPill(label: dateRange.rawValue, icon: "calendar") {
                                    filters.dateRange = nil
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    .padding(.bottom, 8)
                    .background(.bar)
                }
                
                // Results
                if filteredLeads.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 50))
                            .foregroundStyle(.tertiary)
                        Text("未找到匹配的线索")
                            .font(.headline)
                            .foregroundStyle(.secondary)
                        Text("尝试调整搜索条件")
                            .font(.subheadline)
                            .foregroundStyle(.tertiary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List {
                        Section {
                            Text("找到 \(filteredLeads.count) 条线索")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        
                        Section("搜索结果") {
                            ForEach(filteredLeads) { lead in
                                NavigationLink(value: lead) {
                                    LeadRow(lead: lead)
                                }
                            }
                        }
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .navigationTitle("搜索")
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(for: Lead.self) { lead in
                LeadDetailView(lead: lead)
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("关闭") { dismiss() }
                }
            }
            .sheet(isPresented: $showingFilters) {
                FilterSheet(filters: $filters)
                    .presentationDetents([.medium])
            }
        }
    }
    
    private func stageDisplayName(_ imageName: String) -> String {
        switch imageName {
        case "factory": return "制假窝点"
        case "maritime": return "海运走私"
        case "truck": return "专车运假"
        case "package": return "物流寄递"
        case "seller": return "上门兜售"
        default: return imageName
        }
    }
    
    private func imageNameIcon(_ imageName: String) -> String {
        switch imageName {
        case "factory": return "building.2.fill"
        case "maritime": return "ferry.fill"
        case "truck": return "truck.box.fill"
        case "package": return "shippingbox.fill"
        case "seller": return "person.badge.shield.checkmark.fill"
        default: return "doc.text.fill"
        }
    }
}

// MARK: - Filter Pill

private struct FilterPill: View {
    let label: String
    let icon: String
    let onRemove: () -> Void
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.caption2)
            Text(label)
                .font(.caption)
            Button {
                onRemove()
            } label: {
                Image(systemName: "xmark")
                    .font(.caption2)
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .foregroundStyle(.white)
        .background(.blue, in: Capsule())
    }
}

// MARK: - Filter Sheet

private struct FilterSheet: View {
    @Binding var filters: LeadSearchFilters
    
    var body: some View {
        NavigationStack {
            Form {
                Section("线索状态") {
                    Picker("状态", selection: $filters.status) {
                        Text("全部").tag(nil as Lead.LeadStatus?)
                        ForEach([Lead.LeadStatus.pending, .investigating, .resolved, .archived], id: \.self) { status in
                            Label(status.rawValue, systemImage: "circle.fill")
                                .tag(status as Lead.LeadStatus?)
                        }
                    }
                    .pickerStyle(.navigationLink)
                }
                
                Section("执法环节") {
                    Picker("环节", selection: $filters.imageName) {
                        Text("全部").tag(nil as String?)
                        Label("制假窝点", systemImage: "building.2.fill").tag("factory" as String?)
                        Label("海运走私", systemImage: "ferry.fill").tag("maritime" as String?)
                        Label("专车运假", systemImage: "truck.box.fill").tag("truck" as String?)
                        Label("物流寄递", systemImage: "shippingbox.fill").tag("package" as String?)
                        Label("上门兜售", systemImage: "person.badge.shield.checkmark.fill").tag("seller" as String?)
                    }
                    .pickerStyle(.navigationLink)
                }
                
                Section("时间范围") {
                    Picker("时间", selection: $filters.dateRange) {
                        ForEach(LeadSearchFilters.DateRange.allCases, id: \.self) { range in
                            Text(range.rawValue).tag(range)
                        }
                    }
                    .pickerStyle(.segmented)
                }
            }
            .navigationTitle("筛选条件")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("完成") {}
                }
            }
        }
    }
}

#Preview {
    LeadSearchView()
        .environment(DataStore())
}