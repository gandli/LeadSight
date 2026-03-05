import SwiftUI

struct NewCaseView: View {
    @Environment(CaseManager.self) private var caseManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var title = ""
    @State private var caseNumber = ""
    @State private var description = ""
    @State private var location = ""
    @State private var priority: EnforcementCase.CasePriority = .medium
    
    private var isValid: Bool {
        !title.isEmpty && !caseNumber.isEmpty && !description.isEmpty
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("案件标题", text: $title)
                    TextField("案件编号 (如: TY-2025-0001)", text: $caseNumber)
                } header: {
                    Text("基本信息")
                }
                
                Section {
                    TextField("案件描述", text: $description, axis: .vertical)
                        .lineLimit(3...6)
                } header: {
                    Text("案件描述")
                }
                
                Section {
                    TextField("案发地点", text: $location)
                } header: {
                    Text("地点信息")
                }
                
                Section {
                    Picker("优先级", selection: $priority) {
                        ForEach(EnforcementCase.CasePriority.allCases, id: \.self) { p in
                            Label(p.rawValue, systemImage: p.systemImage)
                                .tag(p)
                        }
                    }
                    .pickerStyle(.navigationLink)
                } header: {
                    Text("优先级")
                }
            }
            .navigationTitle("新建案件")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("创建") {
                        _ = caseManager.createCase(
                            title: title,
                            caseNumber: caseNumber,
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
    NewCaseView()
        .environment(CaseManager())
}