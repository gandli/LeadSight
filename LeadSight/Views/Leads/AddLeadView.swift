import SwiftUI

struct AddLeadView: View {
    @Environment(DataStore.self) private var dataStore
    @Environment(\.dismiss) private var dismiss
    
    @State private var title = ""
    @State private var location = ""
    @State private var content = ""
    @State private var reporter = ""
    @State private var status: Lead.LeadStatus = .pending
    @State private var stage: EnforcementStage = .outboundSolicitation
    
    enum EnforcementStage: String, CaseIterable {
        case outboundSolicitation = "上门兜售"
        case vehicleTransport = "专车运假"
        case logisticsDelivery = "物流寄递"
        case maritimeSmuggling = "海运走私"
        case productionDen = "制假窝点"
        
        var imageName: String {
            switch self {
            case .outboundSolicitation: return "seller"
            case .vehicleTransport: return "truck"
            case .logisticsDelivery: return "package"
            case .maritimeSmuggling: return "maritime"
            case .productionDen: return "factory"
            }
        }
    }
    
    private var isFormValid: Bool {
        !title.trimmingCharacters(in: .whitespaces).isEmpty &&
        !location.trimmingCharacters(in: .whitespaces).isEmpty &&
        !content.trimmingCharacters(in: .whitespaces).isEmpty &&
        !reporter.trimmingCharacters(in: .whitespaces).isEmpty
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("线索信息") {
                    TextField("标题", text: $title)
                    TextField("地点", text: $location)
                    TextField("报告人", text: $reporter)
                }
                
                Section("线索详情") {
                    TextEditor(text: $content)
                        .frame(minHeight: 100)
                }
                
                Section("分类") {
                    Picker("执法环节", selection: $stage) {
                        ForEach(EnforcementStage.allCases, id: \.self) { stage in
                            Text(stage.rawValue).tag(stage)
                        }
                    }
                    
                    Picker("状态", selection: $status) {
                        ForEach([Lead.LeadStatus.pending, .investigating, .resolved, .archived], id: \.self) { s in
                            Text(s.rawValue).tag(s)
                        }
                    }
                }
            }
            .navigationTitle("新增线索")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("提交") {
                        let newLead = Lead(
                            id: UUID(),
                            title: title.trimmingCharacters(in: .whitespaces),
                            location: location.trimmingCharacters(in: .whitespaces),
                            timestamp: Date(),
                            content: content.trimmingCharacters(in: .whitespacesAndNewlines),
                            reporter: reporter.trimmingCharacters(in: .whitespaces),
                            status: status,
                            aiAnalysis: nil,
                            imageName: stage.imageName,
                            evidences: [],
                            relatedLeadIDs: []
                        )
                        dataStore.addLead(newLead)
                        dismiss()
                    }
                    .disabled(!isFormValid)
                    .fontWeight(.semibold)
                }
            }
        }
    }
}

#Preview {
    AddLeadView()
        .environment(DataStore())
}
