import Foundation
import SwiftUI

// MARK: - Enforcement Lead Model
// 线索聚合：聚合多条相关线索形成的卷宗

struct EnforcementLead: Identifiable, Codable, Hashable {
    let id: UUID
    var title: String
    var leadNumber: String  // 线索编号，如 TY-2025-0001
    var status: LeadAggregationStatus
    var priority: LeadPriority
    var createdAt: Date
    var updatedAt: Date
    var leadIDs: [UUID]
    var description: String
    var assignedOfficers: [String]
    var location: String
    var notes: [LeadNote]
    
    enum LeadAggregationStatus: String, Codable, CaseIterable {
        case active = "进行中"
        case pending = "待跟进"
        case closed = "已结档"
        case archived = "已归档"
        
        var color: Color {
            switch self {
            case .active: return .blue
            case .pending: return .orange
            case .closed: return .green
            case .archived: return .gray
            }
        }
        
        var systemImage: String {
            switch self {
            case .active: return "folder.fill"
            case .pending: return "clock.fill"
            case .closed: return "checkmark.seal.fill"
            case .archived: return "archivebox.fill"
            }
        }
    }
    
    enum LeadPriority: String, Codable, CaseIterable {
        case critical = "紧急"
        case high = "高优先级"
        case medium = "中优先级"
        case low = "低优先级"
        
        var color: Color {
            switch self {
            case .critical: return .red
            case .high: return .orange
            case .medium: return .blue
            case .low: return .gray
            }
        }
        
        var systemImage: String {
            switch self {
            case .critical: return "flame.fill"
            case .high: return "exclamationmark.triangle.fill"
            case .medium: return "flag.fill"
            case .low: return "minus.circle.fill"
            }
        }
    }
    
    /// Computed property for evidence count
    var evidenceCount: Int {
        // This will be computed from DataStore
        0
    }
}

// MARK: - Lead Note

struct LeadNote: Identifiable, Codable, Hashable {
    let id: UUID
    let content: String
    let timestamp: Date
    let author: String
}

// MARK: - Lead Manager
// 线索聚合管理器：管理线索聚合的创建、关联和状态

@Observable
class LeadManager {
    var aggregations: [EnforcementLead] = []
    
    init() {
        // Sample lead aggregations
        let sharedLeadIDs = [
            UUID(uuidString: "00000000-0000-0000-0000-000000000001")!,
            UUID(uuidString: "00000000-0000-0000-0000-000000000002")!
        ]
        
        self.aggregations = [
            EnforcementLead(
                id: UUID(),
                title: "特大制假窝点专项打击",
                leadNumber: "TY-2025-0001",
                status: .active,
                priority: .critical,
                createdAt: Date().addingTimeInterval(-86400 * 7),
                updatedAt: Date(),
                leadIDs: sharedLeadIDs,
                description: "接群众举报，某废弃厂房存在大规模制假烟活动，涉及多个省市。",
                assignedOfficers: ["张三", "李四"],
                location: "郊区工业园",
                notes: [
                    LeadNote(id: UUID(), content: "已确认生产设备型号，正在追踪设备来源。", timestamp: Date().addingTimeInterval(-86400), author: "张三"),
                    LeadNote(id: UUID(), content: "嫌疑人行踪已锁定，准备收网。", timestamp: Date().addingTimeInterval(-3600), author: "李四")
                ]
            ),
            EnforcementLead(
                id: UUID(),
                title: "跨境走私香烟链条案",
                leadNumber: "TY-2025-0002",
                status: .active,
                priority: .high,
                createdAt: Date().addingTimeInterval(-86400 * 3),
                updatedAt: Date().addingTimeInterval(-86400),
                leadIDs: [UUID()],
                description: "海关联动，发现多批次走私香烟，正在追查上下游链条。",
                assignedOfficers: ["王五"],
                location: "自贸区4号码头",
                notes: []
            ),
            EnforcementLead(
                id: UUID(),
                title: "物流寄递渠道专项整治",
                leadNumber: "TY-2025-0003",
                status: .pending,
                priority: .medium,
                createdAt: Date().addingTimeInterval(-86400 * 14),
                updatedAt: Date().addingTimeInterval(-86400 * 5),
                leadIDs: [],
                description: "针对快递网点代收烟草违法行为进行集中整治。",
                assignedOfficers: ["赵六"],
                location: "全市快递网点",
                notes: []
            )
        ]
    }
    
    func createAggregation(title: String, leadNumber: String, priority: EnforcementLead.LeadPriority, description: String, location: String) -> EnforcementLead {
        let newAggregation = EnforcementLead(
            id: UUID(),
            title: title,
            leadNumber: leadNumber,
            status: .pending,
            priority: priority,
            createdAt: Date(),
            updatedAt: Date(),
            leadIDs: [],
            description: description,
            assignedOfficers: [],
            location: location,
            notes: []
        )
        aggregations.insert(newAggregation, at: 0)
        return newAggregation
    }
    
    func addLead(_ leadID: UUID, to aggregationID: UUID) {
        if let index = aggregations.firstIndex(where: { $0.id == aggregationID }) {
            if !aggregations[index].leadIDs.contains(leadID) {
                aggregations[index].leadIDs.append(leadID)
                aggregations[index].updatedAt = Date()
            }
        }
    }
    
    func removeLead(_ leadID: UUID, from aggregationID: UUID) {
        if let index = aggregations.firstIndex(where: { $0.id == aggregationID }) {
            aggregations[index].leadIDs.removeAll { $0 == leadID }
            aggregations[index].updatedAt = Date()
        }
    }
    
    func addNote(_ content: String, author: String, to aggregationID: UUID) {
        if let index = aggregations.firstIndex(where: { $0.id == aggregationID }) {
            let note = LeadNote(id: UUID(), content: content, timestamp: Date(), author: author)
            aggregations[index].notes.insert(note, at: 0)
            aggregations[index].updatedAt = Date()
        }
    }
    
    func updateStatus(_ status: EnforcementLead.LeadAggregationStatus, for aggregationID: UUID) {
        if let index = aggregations.firstIndex(where: { $0.id == aggregationID }) {
            aggregations[index].status = status
            aggregations[index].updatedAt = Date()
        }
    }
    
    func aggregationForLead(_ leadID: UUID) -> EnforcementLead? {
        aggregations.first { $0.leadIDs.contains(leadID) }
    }
}