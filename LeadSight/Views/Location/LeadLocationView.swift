import SwiftUI
import MapKit

// MARK: - Location Model

struct LocationInfo: Identifiable, Codable, Hashable {
    let id: UUID
    var name: String
    var latitude: Double
    var longitude: Double
    var address: String?
    var timestamp: Date
    
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    var region: MKCoordinateRegion {
        MKCoordinateRegion(
            center: coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        )
    }
}

// MARK: - Lead Location View

struct LeadLocationView: View {
    @Environment(DataStore.self) private var dataStore
    let lead: Lead
    
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 30.2741, longitude: 120.1551),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    @State private var selectedLead: Lead?
    @State private var showingDirections = false
    
    private var nearbyLeads: [Lead] {
        // Simulate nearby leads based on location
        dataStore.leads.filter { $0.id != lead.id }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Map
            Map(coordinateRegion: $region, annotationItems: nearbyLeads + [lead]) { item in
                MapAnnotation(coordinate: coordinateForLead(item)) {
                    LeadMapAnnotation(lead: item, isSelected: item.id == lead.id)
                        .onTapGesture {
                            selectedLead = item
                        }
                }
            }
            .ignoresSafeArea(edges: .top)
            
            // Info Panel
            VStack(alignment: .leading, spacing: 16) {
                // Current Lead Info
                HStack(spacing: 12) {
                    Image(systemName: lead.systemImageName)
                        .font(.title2)
                        .foregroundStyle(.white)
                        .frame(width: 50, height: 50)
                        .background(lead.status.color, in: Circle())
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(lead.title)
                            .font(.headline)
                            .lineLimit(1)
                        Text(lead.location)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    
                    Spacer()
                }
                
                // Actions
                HStack(spacing: 12) {
                    Button {
                        // Open in Maps
                        let coordinate = coordinateForLead(lead)
                        let placemark = MKPlacemark(coordinate: coordinate)
                        let mapItem = MKMapItem(placemark: placemark)
                        mapItem.name = lead.title
                        mapItem.openInMaps()
                    } label: {
                        Label("导航", systemImage: "location.fill")
                            .font(.subheadline)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                    }
                    .buttonStyle(.bordered)
                    
                    Button {
                        showingDirections = true
                    } label: {
                        Label("路线规划", systemImage: "arrow.triangle.turn.up.right.diamond.fill")
                            .font(.subheadline)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                    }
                    .buttonStyle(.borderedProminent)
                }
                
                // Nearby Info
                if !nearbyLeads.isEmpty {
                    Divider()
                    
                    HStack {
                        Image(systemName: "mappin.and.ellipse")
                            .foregroundStyle(.blue)
                        Text("附近 \(nearbyLeads.count) 条相关线索")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        Spacer()
                        Button("查看") {
                            // Show nearby leads
                        }
                        .font(.caption)
                    }
                }
            }
            .padding()
            .background(.regularMaterial)
        }
        .navigationTitle("位置信息")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingDirections) {
            DirectionsView(lead: lead)
                .presentationDetents([.medium])
        }
    }
    
    private func coordinateForLead(_ lead: Lead) -> CLLocationCoordinate2D {
        // Generate consistent coordinates based on lead ID
        let hash = abs(lead.id.hashValue)
        let lat = 30.0 + Double(hash % 100) / 1000
        let lon = 120.0 + Double((hash / 100) % 100) / 1000
        return CLLocationCoordinate2D(latitude: lat, longitude: lon)
    }
}

// MARK: - Map Annotation

private struct LeadMapAnnotation: View {
    let lead: Lead
    let isSelected: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                Circle()
                    .fill(isSelected ? lead.status.color : lead.status.color.opacity(0.8))
                    .frame(width: isSelected ? 36 : 30, height: isSelected ? 36 : 30)
                    .shadow(color: lead.status.color.opacity(0.3), radius: isSelected ? 8 : 4)
                
                Image(systemName: lead.systemImageName)
                    .font(isSelected ? .body : .caption)
                    .foregroundStyle(.white)
            }
            
            // Pin tail
            Triangle()
                .fill(isSelected ? lead.status.color : lead.status.color.opacity(0.8))
                .frame(width: 10, height: 6)
                .offset(y: -2)
        }
        .animation(.spring(response: 0.3), value: isSelected)
    }
}

private struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.closeSubpath()
        return path
    }
}

// MARK: - Directions View

struct DirectionsView: View {
    @Environment(\.dismiss) private var dismiss
    let lead: Lead
    
    @State private var startLocation = ""
    @State private var selectedMode = "driving"
    
    private let modes = [
        ("driving", "驾车", "car.fill"),
        ("walking", "步行", "figure.walk"),
        ("transit", "公交", "bus.fill")
    ]
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                // Mode Selection
                HStack(spacing: 12) {
                    ForEach(modes, id: \.0) { mode in
                        ModeButton(
                            icon: mode.2,
                            label: mode.1,
                            isSelected: selectedMode == mode.0
                        ) {
                            selectedMode = mode.0
                        }
                    }
                }
                
                // Location Info
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Image(systemName: "circle.fill")
                            .font(.caption)
                            .foregroundStyle(.green)
                        TextField("起点（当前位置）", text: $startLocation)
                            .textFieldStyle(.roundedBorder)
                    }
                    
                    HStack {
                        Image(systemName: "mappin")
                            .font(.caption)
                            .foregroundStyle(.red)
                        Text(lead.location)
                            .font(.subheadline)
                    }
                    .padding(.horizontal, 8)
                }
                .padding()
                .background(.fill.quaternary, in: RoundedRectangle(cornerRadius: 12))
                
                // Estimated Info
                HStack(spacing: 24) {
                    VStack {
                        Text("预计时间")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text("~15分钟")
                            .font(.title3)
                            .fontWeight(.semibold)
                    }
                    
                    VStack {
                        Text("距离")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text("3.2 km")
                            .font(.title3)
                            .fontWeight(.semibold)
                    }
                }
                .padding()
                .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
                
                Spacer()
                
                // Start Navigation
                Button {
                    dismiss()
                } label: {
                    Label("开始导航", systemImage: "location.fill")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()
            .navigationTitle("路线规划")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") { dismiss() }
                }
            }
        }
    }
}

private struct ModeButton: View {
    let icon: String
    let label: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.title2)
                Text(label)
                    .font(.caption)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .foregroundStyle(isSelected ? .white : .primary)
            .background(
                isSelected ? AnyShapeStyle(.blue) : AnyShapeStyle(.fill.quaternary),
                in: RoundedRectangle(cornerRadius: 12)
            )
        }
    }
}

// MARK: - Location Overview (for Home)

struct LocationOverviewView: View {
    @Environment(DataStore.self) private var dataStore
    
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 30.2741, longitude: 120.1551),
        span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
    )
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "map")
                    .foregroundStyle(.blue)
                Text("线索地图")
                    .font(.headline)
                Spacer()
                NavigationLink(value: "map") {
                    Text("全屏")
                        .font(.caption)
                }
            }
            
            ZStack {
                Map(coordinateRegion: $region, annotationItems: dataStore.leads) { lead in
                    MapAnnotation(coordinate: coordinateForLead(lead)) {
                        SmallMapPin(color: lead.status.color)
                    }
                }
                .frame(height: 180)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                
                // Overlay gradient
                LinearGradient(
                    colors: [.clear, .regularMaterial.opacity(0.3)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            }
            
            HStack {
                ForEach(Lead.LeadStatus.allCases, id: \.self) { status in
                    HStack(spacing: 4) {
                        Circle()
                            .fill(status.color)
                            .frame(width: 8, height: 8)
                        Text("\(dataStore.leads.filter { $0.status == status }.count)")
                            .font(.caption)
                    }
                }
            }
        }
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
    
    private func coordinateForLead(_ lead: Lead) -> CLLocationCoordinate2D {
        let hash = abs(lead.id.hashValue)
        let lat = 30.0 + Double(hash % 100) / 1000
        let lon = 120.0 + Double((hash / 100) % 100) / 1000
        return CLLocationCoordinate2D(latitude: lat, longitude: lon)
    }
}

private struct SmallMapPin: View {
    let color: Color
    
    var body: some View {
        Circle()
            .fill(color)
            .frame(width: 12, height: 12)
            .shadow(color: color.opacity(0.3), radius: 2)
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        LeadLocationView(lead: DataStore().leads[0])
            .environment(DataStore())
    }
}