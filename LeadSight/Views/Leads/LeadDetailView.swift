import SwiftUI

struct LeadDetailView: View {
    @Environment(DataStore.self) private var dataStore
    @Environment(LeadManager.self) private var leadManager
    let lead: Lead
    @State private var showingCollector = false
    @State private var showingCorrelationGraph = false
    @State private var showingLocationView = false
    
    var relatedAggregation: EnforcementLead? {
        leadManager.aggregationForLead(lead.id)
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Media Section
                ZStack {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(.fill.quaternary)
                        .frame(height: 200)
                    
                    VStack(spacing: 8) {
                        Image(systemName: "photo.fill")
                            .font(.system(size: 50))
                            .foregroundStyle(.secondary)
                        Text("现场图片_4829.jpg")
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                    }
                }
                .padding(.horizontal)
                
                // Status Badge + Info Section
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(lead.status.rawValue)
                            .font(.caption)
                            .fontWeight(.semibold)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .foregroundStyle(.white)
                            .background(lead.status.color, in: Capsule())
                        
                        if let relatedAggregation = relatedAggregation {
                            NavigationLink(value: relatedAggregation) {
                                Text("聚合: \(relatedAggregation.leadNumber)")
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .foregroundStyle(.white)
                                    .background(.purple, in: Capsule())
                            }
                        }
                        
                        Spacer()
                    }
                    
                    Text(lead.title)
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    HStack {
                        Text(lead.reporter)
                        Text("•")
                        Text(lead.timestamp, style: .date)
                    }
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                }
                .padding(.horizontal)
                
                // AI Summary
                if let analysis = lead.aiAnalysis {
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Image(systemName: "sparkles")
                                .foregroundStyle(.blue)
                            Text("AI 分析摘要")
                                .font(.headline)
                        }
                        
                        Text(analysis)
                            .font(.body)
                            .foregroundStyle(.primary)
                            .padding()
                            .background(.blue.opacity(0.08), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                    }
                    .padding(.horizontal)
                }
                
                // Content section
                VStack(alignment: .leading, spacing: 10) {
                    Text("线索详情")
                        .font(.headline)
                    Text(lead.content)
                        .font(.body)
                }
                .padding(.horizontal)
                
                // Location with Map Button
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Text("位置信息")
                            .font(.headline)
                        Spacer()
                        Button {
                            showingLocationView = true
                        } label: {
                            Label("地图", systemImage: "map.fill")
                                .font(.caption)
                        }
                    }
                    HStack {
                        Image(systemName: "mappin.and.ellipse")
                            .foregroundStyle(.red)
                        Text(lead.location)
                            .font(.body)
                    }
                }
                .padding(.horizontal)
                
                Divider().padding(.horizontal)
                
                // Evidence Gallery
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Image(systemName: "photo.on.rectangle.angled")
                            .foregroundStyle(.blue)
                        Text("证据 (\(lead.evidences.count))")
                            .font(.headline)
                        Spacer()
                        Button {
                            showingCollector = true
                        } label: {
                            Label("采集", systemImage: "plus.circle.fill")
                                .font(.subheadline)
                        }
                    }
                    
                    EvidenceGalleryView(evidences: lead.evidences)
                }
                .padding(.horizontal)
                
                Divider().padding(.horizontal)
                
                // AI Correlation with Graph Button
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Image(systemName: "brain.head.profile.fill")
                            .foregroundStyle(.purple)
                        Text("AI 智能关联")
                            .font(.headline)
                        Spacer()
                        Button {
                            showingCorrelationGraph = true
                        } label: {
                            Label("图谱", systemImage: "network")
                                .font(.caption)
                        }
                    }
                    
                    AICorrelationView(lead: lead)
                }
                .padding(.horizontal)
                
                Divider().padding(.horizontal)
                
                // Action Buttons
                VStack(spacing: 12) {
                    if lead.status == .pending {
                        Button {
                            dataStore.updateLeadStatus(lead.id, to: .investigating)
                        } label: {
                            Label("标记为调查中", systemImage: "magnifyingglass")
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.blue)
                    }
                    
                    if lead.status == .pending || lead.status == .investigating {
                        Button {
                            dataStore.updateLeadStatus(lead.id, to: .resolved)
                        } label: {
                            Label("标记为已解决", systemImage: "checkmark.circle.fill")
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.green)
                    }
                    
                    if lead.status != .archived {
                        Button {
                            dataStore.updateLeadStatus(lead.id, to: .archived)
                        } label: {
                            Label("归档", systemImage: "archivebox")
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                        }
                        .buttonStyle(.bordered)
                    }
                }
                .padding(.horizontal)
                .padding(.top, 8)
                
                Spacer()
            }
            .padding(.vertical)
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(for: Evidence.self) { evidence in
            EvidenceDetailView(evidence: evidence)
        }
        .navigationDestination(for: EnforcementLead.self) { enforcementLead in
            LeadAnalysisView(enforcementLead: enforcementLead)
                .environment(leadManager)
        }
        .sheet(isPresented: $showingCollector) {
            EvidenceCollectorView(leadID: lead.id)
        }
        .sheet(isPresented: $showingCorrelationGraph) {
            NavigationStack {
                CorrelationGraphView(lead: lead)
            }
            .presentationDetents([.large])
        }
        .sheet(isPresented: $showingLocationView) {
            NavigationStack {
                LeadLocationView(lead: lead)
            }
            .presentationDetents([.large])
        }
    }
}

#Preview {
    NavigationStack {
        LeadDetailView(lead: DataStore().leads[0])
            .environment(DataStore())
            .environment(LeadManager())
    }
}