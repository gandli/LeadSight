import Foundation
import SwiftUI

struct Lead: Identifiable, Codable, Hashable {
    let id: UUID
    let title: String
    let location: String
    let timestamp: Date
    let content: String
    let reporter: String
    var status: LeadStatus  // Mutable to allow direct status updates
    let aiAnalysis: String?
    let imageName: String?
    var evidences: [Evidence]
    var relatedLeadIDs: [UUID]
    
    enum LeadStatus: String, Codable {
        case pending = "待处理"
        case investigating = "调查中"
        case resolved = "已解决"
        case archived = "已归档"
        
        var color: Color {
            switch self {
            case .pending: return .orange
            case .investigating: return .blue
            case .resolved: return .green
            case .archived: return .gray
            }
        }
    }
    
    /// Centralized icon logic based on imageName
    var systemImageName: String {
        switch imageName {
        case "factory": return "building.2.fill"
        case "maritime": return "ferry.fill"
        case "truck": return "truck.box.fill"
        case "package": return "shippingbox.fill"
        case "seller": return "person.badge.shield.checkmark.fill"
        default: return "doc.text.fill"
        }
    }
    
    /// All searchable text from evidence
    var searchableEvidenceText: String {
        evidences.compactMap { evidence in
            let parts = [
                evidence.structuredData?.ocrText,
                evidence.structuredData?.transcription,
                evidence.structuredData?.licensePlates.joined(separator: " "),
                evidence.structuredData?.objectTags.joined(separator: " ")
            ]
            return parts.compactMap { $0 }.joined(separator: " ")
        }.joined(separator: " ")
    }
}
