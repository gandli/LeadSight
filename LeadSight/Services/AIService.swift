import Foundation

/// Simulated AI recognition service for multimodal evidence
enum AIService {
    
    // MARK: - Image Analysis
    
    static func analyzeImage(named imageName: String) -> StructuredData {
        // Simulate different recognition results based on context
        let scenarios: [StructuredData] = [
            StructuredData(
                ocrText: "中华（硬）条形码：6901028075268\n生产批次：2025-11-A3\n产地标识异常：与正品不符",
                transcription: nil,
                licensePlates: ["京A·88888"],
                faceMatches: [],
                objectTags: ["卷烟", "包装箱", "条形码", "仓库"],
                confidence: 0.92
            ),
            StructuredData(
                ocrText: "烟草专卖零售许可证\n证号：3301XXXX2024XXXX\n有效期至：2025-12-31",
                transcription: nil,
                licensePlates: [],
                faceMatches: [
                    FaceMatch(id: UUID(), name: "张某某", matchScore: 0.94, database: "重点人员库")
                ],
                objectTags: ["许可证", "店面", "柜台", "卷烟"],
                confidence: 0.88
            ),
            StructuredData(
                ocrText: nil,
                transcription: nil,
                licensePlates: ["沪C·12345", "苏A·67890"],
                faceMatches: [],
                objectTags: ["货车", "集装箱", "高速公路", "收费站"],
                confidence: 0.95
            )
        ]
        // Safely unwrap random element with fallback to first scenario
        return scenarios.randomElement() ?? scenarios[0]
    }
    
    // MARK: - Audio Analysis
    
    static func analyzeAudio() -> StructuredData {
        let transcriptions = [
            "……这批货是从云南那边过来的，大概有 200 条，都是'中华'和'芙蓉王'，你那边价格怎么说？……",
            "……老板说这个月不敢多进了，上次查得紧，先放到仓库那边，等风声过了再出……",
            "……证件？没有证件，我们都是散卖的，学校门口那条街生意好……"
        ]
        
        let keywords = [
            ["云南", "200条", "中华", "芙蓉王", "价格"],
            ["仓库", "查得紧", "风声"],
            ["没有证件", "散卖", "学校门口"]
        ]
        
        let idx = Int.random(in: 0..<transcriptions.count)
        return StructuredData(
            ocrText: nil,
            transcription: transcriptions[idx],
            licensePlates: [],
            faceMatches: [],
            objectTags: keywords[idx],
            confidence: 0.87
        )
    }
    
    // MARK: - Correlation Analysis
    
    struct Correlation: Identifiable {
        let id = UUID()
        let type: CorrelationType
        let description: String
        let matchedLeadIDs: [UUID]
        let confidence: Double
        
        enum CorrelationType: String {
            case licensePlate = "车牌关联"
            case faceMatch = "人脸关联"
            case geographic = "地理聚集"
            case timeline = "时间线关联"
            case supplyChain = "供应链关联"
            
            var systemImage: String {
                switch self {
                case .licensePlate: return "car.fill"
                case .faceMatch: return "person.viewfinder"
                case .geographic: return "map.fill"
                case .timeline: return "clock.arrow.2.circlepath"
                case .supplyChain: return "arrow.triangle.branch"
                }
            }
        }
    }
    
    static func findCorrelations(for lead: Lead, in allLeads: [Lead]) -> [Correlation] {
        var results: [Correlation] = []
        let otherLeads = allLeads.filter { $0.id != lead.id }
        
        // License plate correlation
        let leadPlates = Set(lead.evidences.flatMap { $0.structuredData?.licensePlates ?? [] })
        if !leadPlates.isEmpty {
            let matchedIDs = otherLeads.filter { other in
                let otherPlates = Set(other.evidences.flatMap { $0.structuredData?.licensePlates ?? [] })
                return !leadPlates.isDisjoint(with: otherPlates)
            }.map(\.id)
            if !matchedIDs.isEmpty {
                results.append(Correlation(
                    type: .licensePlate,
                    description: "车牌 \(leadPlates.joined(separator: ", ")) 在其他 \(matchedIDs.count) 条线索中出现",
                    matchedLeadIDs: matchedIDs,
                    confidence: 0.92
                ))
            }
        }
        
        // Face match correlation
        let leadFaces = Set(lead.evidences.flatMap { $0.structuredData?.faceMatches.map(\.name) ?? [] })
        if !leadFaces.isEmpty {
            let matchedIDs = otherLeads.filter { other in
                let otherFaces = Set(other.evidences.flatMap { $0.structuredData?.faceMatches.map(\.name) ?? [] })
                return !leadFaces.isDisjoint(with: otherFaces)
            }.map(\.id)
            if !matchedIDs.isEmpty {
                results.append(Correlation(
                    type: .faceMatch,
                    description: "人员 \(leadFaces.joined(separator: ", ")) 在其他线索中被识别",
                    matchedLeadIDs: matchedIDs,
                    confidence: 0.88
                ))
            }
        }
        
        // Geographic correlation (simulated)
        let nearbyIDs = otherLeads.prefix(2).map(\.id)
        if !nearbyIDs.isEmpty {
            results.append(Correlation(
                type: .geographic,
                description: "半径 5km 内发现 \(nearbyIDs.count) 条相关线索",
                matchedLeadIDs: Array(nearbyIDs),
                confidence: 0.75
            ))
        }
        
        // Supply chain (simulated)
        if lead.imageName == "truck" || lead.imageName == "package" {
            let chainIDs = otherLeads.filter { $0.imageName == "factory" || $0.imageName == "seller" }.map(\.id)
            if !chainIDs.isEmpty {
                results.append(Correlation(
                    type: .supplyChain,
                    description: "运输与制假/销售环节存在供应链关联",
                    matchedLeadIDs: chainIDs,
                    confidence: 0.83
                ))
            }
        }
        
        return results
    }
}
