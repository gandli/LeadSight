import SwiftUI

// MARK: - Correlation Graph View

struct CorrelationGraphView: View {
    @Environment(DataStore.self) private var dataStore
    let lead: Lead
    
    private var correlations: [AIService.Correlation] {
        AIService.findCorrelations(for: lead, in: dataStore.leads)
    }
    
    private var connectedLeads: [Lead] {
        let allIDs = correlations.flatMap { $0.matchedLeadIDs }
        return dataStore.leads.filter { allIDs.contains($0.id) }
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Graph Title
                HStack {
                    Image(systemName: "network")
                        .font(.title2)
                        .foregroundStyle(.purple)
                    Text("关联图谱")
                        .font(.title2)
                        .fontWeight(.bold)
                    Spacer()
                    Text("\(connectedLeads.count) 条关联")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(.purple.opacity(0.1), in: Capsule())
                }
                .padding(.horizontal)
                
                // Interactive Graph
                ZStack {
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(.regularMaterial)
                        .frame(height: 320)
                    
                    CorrelationGraphCanvas(
                        centerNode: lead,
                        connectedNodes: connectedLeads,
                        correlations: correlations
                    )
                }
                .padding(.horizontal)
                
                // Correlation Types Summary
                VStack(alignment: .leading, spacing: 12) {
                    Text("关联类型")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    ForEach(correlations) { correlation in
                        CorrelationTypeRow(correlation: correlation)
                    }
                }
                
                // Connected Leads List
                if !connectedLeads.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("关联线索")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        ForEach(connectedLeads) { connectedLead in
                            NavigationLink(value: connectedLead) {
                                ConnectedLeadRow(lead: connectedLead, correlations: correlations)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
            .padding(.vertical)
        }
        .navigationTitle("关联分析")
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(for: Lead.self) { lead in
            LeadDetailView(lead: lead)
        }
    }
}

// MARK: - Graph Canvas

private struct CorrelationGraphCanvas: View {
    let centerNode: Lead
    let connectedNodes: [Lead]
    let correlations: [AIService.Correlation]
    
    @State private var selectedNode: Lead?
    @State private var animationPhase: Double = 0
    
    var body: some View {
        GeometryReader { geometry in
            let centerX = geometry.size.width / 2
            let centerY = geometry.size.height / 2
            let radius: CGFloat = min(geometry.size.width, geometry.size.height) * 0.32
            
            ZStack {
                // Connection Lines
                ForEach(Array(connectedNodes.enumerated()), id: \.element.id) { index, node in
                    let angle = Angle.degrees(Double(index) / Double(connectedNodes.count) * 360 - 90 + animationPhase)
                    let endX = centerX + radius * cos(angle.radians)
                    let endY = centerY + radius * sin(angle.radians)
                    
                    Path { path in
                        path.move(to: CGPoint(x: centerX, y: centerY))
                        path.addLine(to: CGPoint(x: endX, y: endY))
                    }
                    .stroke(
                        LinearGradient(
                            colors: [.purple.opacity(0.6), .purple.opacity(0.2)],
                            startPoint: .init(x: centerX / geometry.size.width, y: centerY / geometry.size.height),
                            endPoint: .init(x: endX / geometry.size.width, y: endY / geometry.size.height)
                        ),
                        style: StrokeStyle(lineWidth: 2, dash: [5, 3])
                    )
                }
                
                // Connected Nodes
                ForEach(Array(connectedNodes.enumerated()), id: \.element.id) { index, node in
                    let angle = Angle.degrees(Double(index) / Double(connectedNodes.count) * 360 - 90 + animationPhase)
                    let nodeX = centerX + radius * cos(angle.radians)
                    let nodeY = centerY + radius * sin(angle.radians)
                    
                    ConnectedNodeView(lead: node, isSelected: selectedNode?.id == node.id)
                        .position(x: nodeX, y: nodeY)
                        .onTapGesture {
                            withAnimation(.spring(response: 0.3)) {
                                selectedNode = node
                            }
                        }
                }
                
                // Center Node
                CenterNodeView(lead: centerNode)
                    .position(x: centerX, y: centerY)
                    .onTapGesture {
                        withAnimation(.spring(response: 0.3)) {
                            selectedNode = nil
                        }
                    }
            }
        }
        .onAppear {
            withAnimation(.linear(duration: 60).repeatForever(autoreverses: false)) {
                animationPhase = 360
            }
        }
    }
}

// MARK: - Center Node

private struct CenterNodeView: View {
    let lead: Lead
    
    var body: some View {
        VStack(spacing: 4) {
            ZStack {
                Circle()
                    .fill(.blue)
                    .frame(width: 70, height: 70)
                    .shadow(color: .blue.opacity(0.3), radius: 10)
                
                Image(systemName: lead.systemImageName)
                    .font(.title)
                    .foregroundStyle(.white)
            }
            
            Text(lead.title)
                .font(.caption)
                .fontWeight(.semibold)
                .lineLimit(1)
                .frame(width: 100)
        }
    }
}

// MARK: - Connected Node

private struct ConnectedNodeView: View {
    let lead: Lead
    let isSelected: Bool
    
    var body: some View {
        VStack(spacing: 4) {
            ZStack {
                Circle()
                    .fill(isSelected ? .purple : .purple.opacity(0.7))
                    .frame(width: isSelected ? 56 : 50, height: isSelected ? 56 : 50)
                    .shadow(color: .purple.opacity(isSelected ? 0.5 : 0.2), radius: isSelected ? 8 : 4)
                
                Image(systemName: lead.systemImageName)
                    .font(.subheadline)
                    .foregroundStyle(.white)
            }
            .scaleEffect(isSelected ? 1.1 : 1.0)
            
            Text(lead.title)
                .font(.caption2)
                .lineLimit(2)
                .multilineTextAlignment(.center)
                .frame(width: 80)
                .foregroundStyle(isSelected ? .primary : .secondary)
        }
        .animation(.spring(response: 0.3), value: isSelected)
    }
}

// MARK: - Correlation Type Row

private struct CorrelationTypeRow: View {
    let correlation: AIService.Correlation
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: correlation.type.systemImage)
                .font(.title3)
                .foregroundStyle(.purple)
                .frame(width: 36, height: 36)
                .background(.purple.opacity(0.1), in: Circle())
            
            VStack(alignment: .leading, spacing: 2) {
                Text(correlation.type.rawValue)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                Text(correlation.description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
            
            Spacer()
            
            Text("\(Int(correlation.confidence * 100))%")
                .font(.caption)
                .fontWeight(.bold)
                .foregroundStyle(.white)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(.purple, in: Capsule())
        }
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
        .padding(.horizontal)
    }
}

// MARK: - Connected Lead Row

private struct ConnectedLeadRow: View {
    let lead: Lead
    let correlations: [AIService.Correlation]
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: lead.systemImageName)
                .font(.title3)
                .foregroundStyle(lead.status.color)
                .frame(width: 44, height: 44)
                .background(lead.status.color.opacity(0.1), in: Circle())
            
            VStack(alignment: .leading, spacing: 2) {
                Text(lead.title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .lineLimit(1)
                
                HStack(spacing: 8) {
                    Text(lead.location)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                    
                    Text(lead.status.rawValue)
                        .font(.caption2)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(lead.status.color, in: Capsule())
                }
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
        .padding(.horizontal)
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        CorrelationGraphView(lead: DataStore().leads[0])
            .environment(DataStore())
    }
}