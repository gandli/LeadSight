import Foundation
import Observation
import SwiftUI

// MARK: - Codable Extensions for Data Models
extension Lead: Codable {
    enum CodingKeys: String, CodingKey {
        case id, title, location, timestamp, content, reporter, status, aiAnalysis, imageName, evidences, relatedLeadIDs
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        location = try container.decode(String.self, forKey: .location)
        timestamp = try container.decode(Date.self, forKey: .timestamp)
        content = try container.decode(String.self, forKey: .content)
        reporter = try container.decode(String.self, forKey: .reporter)
        status = try container.decode(Lead.LeadStatus.self, forKey: .status)
        aiAnalysis = try container.decodeIfPresent(String.self, forKey: .aiAnalysis) ?? ""
        imageName = try container.decodeIfPresent(String.self, forKey: .imageName) ?? ""
        evidences = try container.decode([Evidence].self, forKey: .evidences)
        relatedLeadIDs = try container.decode([UUID].self, forKey: .relatedLeadIDs)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(title, forKey: .title)
        try container.encode(location, forKey: .location)
        try container.encode(timestamp, forKey: .timestamp)
        try container.encode(content, forKey: .content)
        try container.encode(reporter, forKey: .reporter)
        try container.encode(status, forKey: .status)
        try container.encode(aiAnalysis, forKey: .aiAnalysis)
        try container.encode(imageName, forKey: .imageName)
        try container.encode(evidences, forKey: .evidences)
        try container.encode(relatedLeadIDs, forKey: .relatedLeadIDs)
    }
}

extension Evidence: Codable {}
extension StructuredData: Codable {}
extension FaceMatch: Codable {}

// MARK: - DataStore with Persistence
@Observable
class DataStore {
    static let shared = DataStore()
    private static let leadsKey = "LeadsData"
    private static let warningsKey = "WarningsData"
    
    var leads: [Lead] = []
    var warnings: [Warning] = []
    
    init() {
        // Load data from persistent storage if available
        loadData()
        
        // If no data was loaded, initialize with mock data
        if leads.isEmpty && warnings.isEmpty {
            setupMockData()
        }
    }
    
    // MARK: - Data Loading and Saving
    private func loadData() {
        if let leadsData = UserDefaults.standard.data(forKey: Self.leadsKey),
           let decodedLeads = try? JSONDecoder().decode([Lead].self, from: leadsData) {
            leads = decodedLeads
        }
        
        if let warningsData = UserDefaults.standard.data(forKey: Self.warningsKey),
           let decodedWarnings = try? JSONDecoder().decode([Warning].self, from: warningsData) {
            warnings = decodedWarnings
        }
    }
    
    private func saveData() {
        if let leadsData = try? JSONEncoder().encode(leads) {
            UserDefaults.standard.set(leadsData, forKey: Self.leadsKey)
        }
        
        if let warningsData = try? JSONEncoder().encode(warnings) {
            UserDefaults.standard.set(warningsData, forKey: Self.warningsKey)
        }
    }
    
    // MARK: - Mock Data Setup
    private func setupMockData() {
        // Shared evidence data for correlation
        let sharedPlate = "京A·88888"
        let sharedFace = FaceMatch(id: UUID(), name: "张某某", matchScore: 0.94, database: "重点人员库")
        
        // Mock data covering the 5 key stages of Tobacco Enforcement
        self.leads = [
            Lead(id: UUID(), title: "发现特大制假窝点", location: "郊区废弃厂房", timestamp: Date(), content: "红外扫描发现异常热源，疑似卷烟制造设备运行中。", reporter: "情报中心", status: .pending, aiAnalysis: "制假窝点：高频电力波动，有浓重烟叶气味。", imageName: "factory", evidences: [
                Evidence(id: UUID(), type: .photo, timestamp: Date(), rawContent: "factory_thermal.jpg", structuredData: StructuredData(ocrText: "中华（硬）条形码：6901028075268\n生产批次：2025-11-A3\n产地标识异常", transcription: nil, licensePlates: [sharedPlate], faceMatches: [sharedFace], objectTags: ["制假设备", "烟叶", "包装箱", "条形码"], confidence: 0.92)),
                Evidence(id: UUID(), type: .audio, timestamp: Date().addingTimeInterval(-300), rawContent: "factory_audio.m4a", structuredData: StructuredData(ocrText: nil, transcription: "这批货是从云南那边过来的，大概有 200 条，都是中华和芙蓉王。", licensePlates: [], faceMatches: [], objectTags: ["云南", "200条", "中华", "芙蓉王"], confidence: 0.87)),
                Evidence(id: UUID(), type: .text, timestamp: Date().addingTimeInterval(-600), rawContent: "现场勘查记录：厂房内发现卷烟制造设备 3 台，成品假烟约 500 条。", structuredData: nil)
            ], relatedLeadIDs: []),
            
            Lead(id: UUID(), title: "海运渠道走私香烟", location: "自贸区 4 号码头", timestamp: Date().addingTimeInterval(-1800), content: "集装箱报关项为'日用品'，但重量感应异常，疑似夹带走私烟。", reporter: "海关联动", status: .investigating, aiAnalysis: "海运走私：X光扫描发现规则矩形堆叠。", imageName: "maritime", evidences: [
                Evidence(id: UUID(), type: .photo, timestamp: Date().addingTimeInterval(-1800), rawContent: "xray_scan.jpg", structuredData: StructuredData(ocrText: "集装箱编号：MSCU-7284619\n报关号：2025SH003847", transcription: nil, licensePlates: ["沪C·12345"], faceMatches: [], objectTags: ["集装箱", "X光", "矩形堆叠", "码头"], confidence: 0.95)),
                Evidence(id: UUID(), type: .video, timestamp: Date().addingTimeInterval(-2100), rawContent: "dock_surveillance.mp4", structuredData: StructuredData(ocrText: nil, transcription: nil, licensePlates: ["沪C·12345", "苏A·67890"], faceMatches: [sharedFace], objectTags: ["货船", "小艇", "码头", "夜间作业"], confidence: 0.88))
            ], relatedLeadIDs: []),
            
            Lead(id: UUID(), title: "专车运假拦截提示", location: "G15 高速收费站", timestamp: Date().addingTimeInterval(-3600), content: "目标车辆已进入拦截区，此前多次绕行避开检查站。", reporter: "路网系统", status: .investigating, aiAnalysis: "专车运假：轨迹高度重合，属于典型非法转运路径。", imageName: "truck", evidences: [
                Evidence(id: UUID(), type: .photo, timestamp: Date().addingTimeInterval(-3600), rawContent: "toll_camera.jpg", structuredData: StructuredData(ocrText: nil, transcription: nil, licensePlates: [sharedPlate, "浙B·55555"], faceMatches: [], objectTags: ["厢式货车", "收费站", "车牌"], confidence: 0.96)),
                Evidence(id: UUID(), type: .audio, timestamp: Date().addingTimeInterval(-3900), rawContent: "intercept_radio.m4a", structuredData: StructuredData(ocrText: nil, transcription: "目标车辆已过第三个收费站，预计 15 分钟后到达拦截点。", licensePlates: [], faceMatches: [], objectTags: ["拦截", "收费站", "目标车辆"], confidence: 0.91))
            ], relatedLeadIDs: []),
            
            Lead(id: UUID(), title: "物流寄递拆解结果", location: "某快递分拣中心", timestamp: Date().addingTimeInterval(-7200), content: "在申通某网点分拣过程中，嗅探犬发现疑似烟草包裹 50 件。", reporter: "分拣员", status: .resolved, aiAnalysis: "物流寄递：分散发货，化整为零，涉及多个虚假收货地址。", imageName: "package", evidences: [
                Evidence(id: UUID(), type: .photo, timestamp: Date().addingTimeInterval(-7200), rawContent: "parcels.jpg", structuredData: StructuredData(ocrText: "发件地址：云南省昆明市\n收件人：王某 / 李某 / 赵某\n内容物：日用品", transcription: nil, licensePlates: [], faceMatches: [], objectTags: ["包裹", "快递单", "分拣中心"], confidence: 0.89))
            ], relatedLeadIDs: []),
            
            Lead(id: UUID(), title: "上门兜售抓获现场", location: "中山南路零售店", timestamp: Date().addingTimeInterval(-86400), content: "嫌疑人正在向无证户兜售'散支'卷烟，已现场控制。", reporter: "便衣稽查", status: .resolved, aiAnalysis: "上门兜售：属于'游击'式非法销售，货源不明。", imageName: "seller", evidences: [
                Evidence(id: UUID(), type: .photo, timestamp: Date().addingTimeInterval(-86400), rawContent: "scene_photo.jpg", structuredData: StructuredData(ocrText: "烟草专卖零售许可证\n证号：3301XXXX2024XXXX\n有效期至：2025-12-31", transcription: nil, licensePlates: [], faceMatches: [FaceMatch(id: UUID(), name: "李某某", matchScore: 0.89, database: "涉烟前科人员库")], objectTags: ["柜台", "卷烟", "散支", "零售店"], confidence: 0.86)),
                Evidence(id: UUID(), type: .text, timestamp: Date().addingTimeInterval(-86100), rawContent: "现场笔录：嫌疑人承认从'上家'处以每条 80 元购入假冒中华卷烟，再以每条 150 元兜售。", structuredData: nil)
            ], relatedLeadIDs: [])
        ]
        
        self.warnings = [
            Warning(id: UUID(), type: "制假预警", title: "疑似制假窝点能耗激增", description: "该区域本月工业用电量超过过去 3 个月均值 500%。", severity: .critical),
            Warning(id: UUID(), type: "走私提示", title: "海上雷达轨迹异常", description: "一艘货船在非港区徘徊，并有小艇靠抵，疑似海上过驳。", severity: .high),
            Warning(id: UUID(), type: "寄递频率", title: "快递代收点异常收货", description: "单日出现 50 件以上发自边境敏感地区的卷烟规格包裹。", severity: .medium),
            Warning(id: UUID(), type: "串货提醒", title: "跨区调拨预警", description: "零售商扫码数据显示存在大量非本地喷码卷烟。", severity: .high)
        ]
        
        // Save initial mock data
        saveData()
    }
    
    // MARK: - Public API
    func addLead(_ lead: Lead) {
        leads.insert(lead, at: 0)
        saveData()
    }
    
    func deleteLead(at offsets: IndexSet) {
        leads.remove(atOffsets: offsets)
        saveData()
    }
    
    func updateLeadStatus(_ leadID: UUID, to newStatus: Lead.LeadStatus) {
        if let index = leads.firstIndex(where: { $0.id == leadID }) {
            leads[index] = Lead(
                id: leads[index].id,
                title: leads[index].title,
                location: leads[index].location,
                timestamp: leads[index].timestamp,
                content: leads[index].content,
                reporter: leads[index].reporter,
                status: newStatus,
                aiAnalysis: leads[index].aiAnalysis,
                imageName: leads[index].imageName,
                evidences: leads[index].evidences,
                relatedLeadIDs: leads[index].relatedLeadIDs
            )
            saveData()
        }
    }
    
    func addEvidence(_ evidence: Evidence, to leadID: UUID) {
        if let index = leads.firstIndex(where: { $0.id == leadID }) {
            leads[index].evidences.append(evidence)
            saveData()
        }
    }
    
    // MARK: - Reset Data (for testing or user-initiated reset)
    func resetToMockData() {
        leads.removeAll()
        warnings.removeAll()
        setupMockData()
    }
}