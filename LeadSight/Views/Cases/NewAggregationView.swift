import SwiftUI

struct NewAggregationView: View {
    @Environment(LeadManager.self) private var leadManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var title = ""
    @State private var leadNumber = ""
    @State private var description = ""
    @State private var location = ""
    @State private var priority: EnforcementLead.LeadPriority = .medium
    
    private var isValid: Bool {
        !title.isEmpty && !leadNumber.isEmpty && !description.isEmpty
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("聚合标题", text: $title)
                    TextField("线索编号 (如: TY-2025-0001)", text: $leadNumber)
                } header: {
                    Text("基本信息")
                }
                
                Section {
                    TextField("线索描述", text: $description, axis: .vertical)
                        .lineLimit(3...6)
                } header: {
                    Text("线索描述")
                }
                
                Section {
                    TextField("相关地点", text: $location)
                } header: {
                    Text("地点信息")
                }
                
                Section {
                    Picker("优先级", selection: $priority) {
                        ForEach(EnforcementLead.LeadPriority.allCases, id: \.self) { p in
                            Label(p.rawValue, systemImage: p.systemImage)
                                .tag(p)
                        }
                    }
                    .pickerStyle(.navigationLink)
                } header: {
                    Text("优先级")
                }
            }
            .navigationTitle("新建线索聚合")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("创建") {
                        _ = leadManager.createAggregation(
                            title: title,
                            leadNumber: leadNumber,
                            priority: priority,
                            description: description,
                            location: location
                        )
                        dismiss()
                    }
                    .disabled(!isValid)
                }
            }
        }
    }
}

#Preview {
    NewAggregationView()
        .environment(LeadManager())
}