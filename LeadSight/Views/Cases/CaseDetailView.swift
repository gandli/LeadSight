import SwiftUI

struct CaseDetailView: View {
    @Environment(DataStore.self) private var dataStore
    @Environment(CaseManager.self) private var caseManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var enforcementCase: EnforcementCase
    @State private var showingAddLead = false
    @State private var showingAddNote = false
    @State private var newNoteContent = ""
    
    private var leads: [Lead] {
        dataStore.leads.filter { enforcementCase.leadIDs.contains($0.id) }
    }
    
    private var totalEvidenceCount: Int {
        leads.reduce(0) { $0 + $1.evidences.count }
    }
    
    init(enforcementCase: EnforcementCase) {
        self._enforcementCase = State(initialValue: enforcementCase)
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header Card
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text(enforcementCase.caseNumber)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        Spacer()
                        Menu {
                            ForEach(EnforcementCase.CaseStatus.allCases, id: \.self) { status in
                                Button {
                                    caseManager.updateStatus(status, for: enforcementCase.id)
                                    enforcementCase.status = status
                                } label: {
                                    Label(status.rawValue, systemImage: status.systemImage)
                                }
                            }
                        } label: {
                            Label(enforcementCase.status.rawValue, systemImage: enforcementCase.status.systemImage)
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundStyle(.white)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 5)
                                .background(enforcementCase.status.color, in: Capsule())
                        }
                    }
                    
                    Text(enforcementCase.title)
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    HStack(spacing: 16) {
                        Label(enforcementCase.priority.rawValue, systemImage: enforcementCase.priority.systemImage)
                            .font(.subheadline)
                            .foregroundStyle(enforcementCase.priority.color)
                        
                        Label(enforcementCase.location, systemImage: "mappin.and.ellipse")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding()
                .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                .padding(.horizontal)
                
                // Statistics
                HStack(spacing: 12) {
                    StatCard(value: "\(leads.count)", label: "关联线索", icon: "list.bullet.rectangle", color: .blue)
                    StatCard(value: "\(totalEvidenceCount)", label: "证据文件", icon: "photo.on.rectangle", color: .green)
                    StatCard(value: "\(enforcementCase.notes.count)", label: "案件笔记", icon: "note.text", color: .orange)
                }
                .padding(.horizontal)
                
                // Description
                VStack(alignment: .leading, spacing: 8) {
                    Text("案件描述")
                        .font(.headline)
                    Text(enforcementCase.description)
                        .font(.body)
                        .foregroundStyle(.secondary)
                }
                .padding()
                .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                .padding(.horizontal)
                
                // Assigned Officers
                if !enforcementCase.assignedOfficers.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("办案人员")
                            .font(.headline)
                        
                        FlowLayout(items: enforcementCase.assignedOfficers) { officer in
                            HStack(spacing: 6) {
                                Image(systemName: "person.circle.fill")
                                    .foregroundStyle(.blue)
                                Text(officer)
                                    .font(.subheadline)
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(.blue.opacity(0.1), in: Capsule())
                        }
                    }
                    .padding()
                    .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .padding(.horizontal)
                }
                
                // Connected Leads
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Image(systemName: "link")
                            .foregroundStyle(.blue)
                        Text("关联线索")
                            .font(.headline)
                        Spacer()
                        Button {
                            showingAddLead = true
                        } label: {
                            Label("添加", systemImage: "plus.circle.fill")
                                .font(.caption)
                        }
                    }
                    
                    if leads.isEmpty {
                        HStack {
                            Spacer()
                            VStack(spacing: 8) {
                                Image(systemName: "tray")
                                    .font(.title)
                                    .foregroundStyle(.tertiary)
                                Text("暂无关联线索")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                        }
                        .padding(.vertical, 20)
                    } else {
                        ForEach(leads) { lead in
                            HStack {
                                NavigationLink(value: lead) {
                                    HStack(spacing: 12) {
                                        Image(systemName: lead.systemImageName)
                                            .foregroundStyle(lead.status.color)
                                            .frame(width: 36, height: 36)
                                            .background(lead.status.color.opacity(0.1), in: Circle())
                                        
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(lead.title)
                                                .font(.subheadline)
                                                .fontWeight(.medium)
                                            Text(lead.location)
                                                .font(.caption)
                                                .foregroundStyle(.secondary)
                                        }
                                        
                                        Spacer()
                                        
                                        Text(lead.status.rawValue)
                                            .font(.caption2)
                                            .foregroundStyle(.white)
                                            .padding(.horizontal, 6)
                                            .padding(.vertical, 2)
                                            .background(lead.status.color, in: Capsule())
                                    }
                                }
                                
                                Button {
                                    caseManager.removeLead(lead.id, from: enforcementCase.id)
                                    if let index = enforcementCase.leadIDs.firstIndex(of: lead.id) {
                                        enforcementCase.leadIDs.remove(at: index)
                                    }
                                } label: {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundStyle(.secondary)
                                }
                            }
                            .padding(.vertical, 8)
                        }
                    }
                }
                .padding()
                .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                .padding(.horizontal)
                
                // Case Notes
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Image(systemName: "note.text")
                            .foregroundStyle(.orange)
                        Text("案件笔记")
                            .font(.headline)
                        Spacer()
                        Button {
                            showingAddNote = true
                        } label: {
                            Label("添加", systemImage: "square.and.pencil")
                                .font(.caption)
                        }
                    }
                    
                    if enforcementCase.notes.isEmpty {
                        HStack {
                            Spacer()
                            VStack(spacing: 8) {
                                Image(systemName: "note.text.badge.plus")
                                    .font(.title)
                                    .foregroundStyle(.tertiary)
                                Text("暂无笔记")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                        }
                        .padding(.vertical, 20)
                    } else {
                        ForEach(enforcementCase.notes) { note in
                            NoteCard(note: note)
                        }
                    }
                }
                .padding()
                .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                .padding(.horizontal)
                
                // Timeline
                VStack(alignment: .leading, spacing: 12) {
                    Text("案件时间线")
                        .font(.headline)
                    
                    HStack {
                        VStack(alignment: .leading) {
                            Text("创建时间")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Text(enforcementCase.createdAt, style: .date)
                                .font(.subheadline)
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .trailing) {
                            Text("最后更新")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Text(enforcementCase.updatedAt, style: .relative)
                                .font(.subheadline)
                        }
                    }
                }
                .padding()
                .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                .padding(.horizontal)
            }
            .padding(.vertical)
        }
        .navigationTitle("案件详情")
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(for: Lead.self) { lead in
            LeadDetailView(lead: lead)
        }
        .sheet(isPresented: $showingAddLead) {
            AddLeadToCaseView(enforcementCase: $enforcementCase)
                .environment(caseManager)
                .presentationDetents([.medium])
        }
        .sheet(isPresented: $showingAddNote) {
            AddNoteView(enforcementCase: $enforcementCase)
                .environment(caseManager)
                .presentationDetents([.medium])
        }
    }
}

// MARK: - Stat Card

private struct StatCard: View {
    let value: String
    let label: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(color)
            Text(value)
                .font(.title)
                .fontWeight(.bold)
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}

// MARK: - Note Card

private struct NoteCard: View {
    let note: CaseNote
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(note.author)
                    .font(.caption)
                    .fontWeight(.semibold)
                Spacer()
                Text(note.timestamp, style: .time)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Text(note.content)
                .font(.subheadline)
        }
        .padding()
        .background(.fill.quaternary, in: RoundedRectangle(cornerRadius: 10, style: .continuous))
    }
}

// MARK: - Flow Layout

private struct FlowLayout: View {
    let items: [String]
    let content: (String) -> any View
    
    var body: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], alignment: .leading, spacing: 8) {
            ForEach(items, id: \.self) { item in
                AnyView(content(item))
            }
        }
    }
}

// MARK: - Add Lead to Case View

struct AddLeadToCaseView: View {
    @Environment(DataStore.self) private var dataStore
    @Environment(CaseManager.self) private var caseManager
    @Environment(\.dismiss) private var dismiss
    @Binding var enforcementCase: EnforcementCase
    
    @State private var searchText = ""
    
    private var availableLeads: [Lead] {
        dataStore.leads.filter { !enforcementCase.leadIDs.contains($0.id) }
    }
    
    private var filteredLeads: [Lead] {
        if searchText.isEmpty { return availableLeads }
        return availableLeads.filter {
            $0.title.localizedCaseInsensitiveContains(searchText) ||
            $0.content.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(filteredLeads) { lead in
                    Button {
                        caseManager.addLead(lead.id, to: enforcementCase.id)
                        enforcementCase.leadIDs.append(lead.id)
                        dismiss()
                    } label: {
                        HStack(spacing: 12) {
                            Image(systemName: lead.systemImageName)
                                .foregroundStyle(lead.status.color)
                                .frame(width: 36, height: 36)
                                .background(lead.status.color.opacity(0.1), in: Circle())
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text(lead.title)
                                    .font(.subheadline)
                                    .foregroundStyle(.primary)
                                Text(lead.location)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            
                            Spacer()
                            
                            Image(systemName: "plus.circle")
                                .foregroundStyle(.blue)
                        }
                    }
                }
            }
            .searchable(text: $searchText, prompt: "搜索线索")
            .navigationTitle("添加线索")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") { dismiss() }
                }
            }
        }
    }
}

// MARK: - Add Note View

struct AddNoteView: View {
    @Environment(CaseManager.self) private var caseManager
    @Environment(\.dismiss) private var dismiss
    @Binding var enforcementCase: EnforcementCase
    
    @State private var noteContent = ""
    @State private var author = "当前用户"
    
    var body: some View {
        NavigationStack {
            Form {
                Section("笔记内容") {
                    TextEditor(text: $noteContent)
                        .frame(minHeight: 100)
                }
                
                Section("记录人") {
                    TextField("姓名", text: $author)
                }
            }
            .navigationTitle("添加笔记")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") {
                        caseManager.addNote(noteContent, author: author, to: enforcementCase.id)
                        enforcementCase.notes.insert(
                            CaseNote(id: UUID(), content: noteContent, timestamp: Date(), author: author),
                            at: 0
                        )
                        dismiss()
                    }
                    .disabled(noteContent.isEmpty)
                }
            }
        }
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        CaseDetailView(enforcementCase: CaseManager().cases[0])
            .environment(DataStore())
            .environment(CaseManager())
    }
}