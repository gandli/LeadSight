import XCTest
@testable import LeadSight

final class AIServiceTests: XCTestCase {
    
    // MARK: - Image Analysis Tests
    
    func testAnalyzeImageReturnsValidStructuredData() {
        // When
        let result = AIService.analyzeImage(named: "test")
        
        // Then
        XCTAssertNotNil(result, "analyzeImage should always return non-nil StructuredData")
        XCTAssertGreaterThanOrEqual(result.confidence, 0.0, "Confidence should be >= 0")
        XCTAssertLessThanOrEqual(result.confidence, 1.0, "Confidence should be <= 1")
    }
    
    func testAnalyzeImageReturnsConsistentConfidence() {
        // Given
        var results: [StructuredData] = []
        
        // When - Run multiple times to verify no crashes
        for _ in 0..<100 {
            results.append(AIService.analyzeImage(named: "test"))
        }
        
        // Then - All results should have valid confidence
        for result in results {
            XCTAssertGreaterThanOrEqual(result.confidence, 0.0)
            XCTAssertLessThanOrEqual(result.confidence, 1.0)
        }
    }
    
    func testAnalyzeImageIncludesOCRText() {
        // When
        let result = AIService.analyzeImage(named: "test")
        
        // Then - At least some scenarios should have OCR text
        // Run multiple times since it's random
        var hasOCRText = false
        for _ in 0..<20 {
            let r = AIService.analyzeImage(named: "test")
            if r.ocrText != nil {
                hasOCRText = true
                break
            }
        }
        XCTAssertTrue(hasOCRText, "Some scenarios should include OCR text")
    }
    
    // MARK: - Audio Analysis Tests
    
    func testAnalyzeAudioReturnsValidStructuredData() {
        // When
        let result = AIService.analyzeAudio()
        
        // Then
        XCTAssertNotNil(result, "analyzeAudio should always return non-nil StructuredData")
        XCTAssertNotNil(result.transcription, "Audio analysis should include transcription")
        XCTAssertFalse(result.objectTags.isEmpty, "Audio analysis should include keywords")
    }
    
    func testAnalyzeAudioTranscriptionContainsKeywords() {
        // When
        let result = AIService.analyzeAudio()
        
        // Then - Keywords should be a subset of what's mentioned in transcription
        if let transcription = result.transcription {
            for keyword in result.objectTags {
                XCTAssertTrue(
                    transcription.contains(keyword) || keyword.count <= 2,
                    "Keyword '\(keyword)' should appear in transcription"
                )
            }
        }
    }
    
    // MARK: - Correlation Analysis Tests
    
    func testFindCorrelationsReturnsEmptyForNoMatches() {
        // Given
        let lead = Lead(
            id: UUID(),
            title: "Test Lead",
            location: "Test Location",
            timestamp: Date(),
            content: "Test content",
            reporter: "Test Reporter",
            status: .pending,
            aiAnalysis: nil,
            imageName: "test",
            evidences: [],
            relatedLeadIDs: []
        )
        let otherLeads: [Lead] = [
            Lead(
                id: UUID(),
                title: "Other Lead",
                location: "Other Location",
                timestamp: Date(),
                content: "Other content",
                reporter: "Other Reporter",
                status: .pending,
                aiAnalysis: nil,
                imageName: "test",
                evidences: [],
                relatedLeadIDs: []
            )
        ]
        
        // When
        let correlations = AIService.findCorrelations(for: lead, in: otherLeads)
        
        // Then - Geographic correlation is simulated, so we expect at least that
        // But no license plate or face match correlations
        let licensePlateCorrelations = correlations.filter { $0.type == .licensePlate }
        let faceMatchCorrelations = correlations.filter { $0.type == .faceMatch }
        
        XCTAssertTrue(licensePlateCorrelations.isEmpty, "No license plate correlations without matching plates")
        XCTAssertTrue(faceMatchCorrelations.isEmpty, "No face match correlations without matching faces")
    }
    
    func testFindCorrelationsDetectsLicensePlateMatch() {
        // Given
        let sharedPlate = "京A·12345"
        let lead = Lead(
            id: UUID(),
            title: "Test Lead",
            location: "Test Location",
            timestamp: Date(),
            content: "Test content",
            reporter: "Test Reporter",
            status: .pending,
            aiAnalysis: nil,
            imageName: "truck",
            evidences: [
                Evidence(
                    id: UUID(),
                    type: .photo,
                    timestamp: Date(),
                    rawContent: "test.jpg",
                    structuredData: StructuredData(
                        ocrText: nil,
                        transcription: nil,
                        licensePlates: [sharedPlate],
                        faceMatches: [],
                        objectTags: ["truck"],
                        confidence: 0.9
                    )
                )
            ],
            relatedLeadIDs: []
        )
        let otherLead = Lead(
            id: UUID(),
            title: "Other Lead",
            location: "Other Location",
            timestamp: Date(),
            content: "Other content",
            reporter: "Other Reporter",
            status: .pending,
            aiAnalysis: nil,
            imageName: "factory",
            evidences: [
                Evidence(
                    id: UUID(),
                    type: .photo,
                    timestamp: Date(),
                    rawContent: "test2.jpg",
                    structuredData: StructuredData(
                        ocrText: nil,
                        transcription: nil,
                        licensePlates: [sharedPlate, "沪B·99999"],
                        faceMatches: [],
                        objectTags: ["factory"],
                        confidence: 0.85
                    )
                )
            ],
            relatedLeadIDs: []
        )
        
        // When
        let correlations = AIService.findCorrelations(for: lead, in: [otherLead])
        
        // Then
        let licensePlateCorrelation = correlations.first { $0.type == .licensePlate }
        XCTAssertNotNil(licensePlateCorrelation, "Should detect license plate correlation")
        XCTAssertEqual(licensePlateCorrelation?.matchedLeadIDs.count, 1, "Should match one other lead")
        XCTAssertTrue(licensePlateCorrelation?.matchedLeadIDs.contains(otherLead.id) ?? false, "Should match the correct lead")
    }
    
    func testFindCorrelationsConfidenceIsValid() {
        // Given
        let lead = DataStore().leads[0]
        let allLeads = DataStore().leads
        
        // When
        let correlations = AIService.findCorrelations(for: lead, in: allLeads)
        
        // Then
        for correlation in correlations {
            XCTAssertGreaterThanOrEqual(correlation.confidence, 0.0, "Confidence should be >= 0")
            XCTAssertLessThanOrEqual(correlation.confidence, 1.0, "Confidence should be <= 1")
        }
    }
}