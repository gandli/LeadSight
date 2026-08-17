# Changelog

All notable changes to the LeadSight project will be documented in this file.

## [0.1.1] - 2026-03-05

### Changed

- **Terminology Correction**: Renamed "案件" (Case) to "线索档案" (Lead Case/Archive) to align with tobacco enforcement domain terminology. This includes:
  - `EnforcementCase` → `EnforcementLead`
  - `CaseManager` → `LeadCaseManager`
  - `CaseNote` → `LeadNote`
  - `CaseStatus` → `LeadStatus`
  - `CasePriority` → `LeadPriority`
  - Renamed `Views/Cases/` files to `LeadCaseListView`, `LeadCaseDetailView`, `NewLeadCaseView`
  - Updated Tab label from "案件" to "档案"
  - Updated UI text throughout: "案件管理" → "线索档案", "新建案件" → "新建档案"

## [0.1.0] - 2026-03-05

### Added

- **Lead Archive System**: Full-featured lead archive management with creation, status tracking, priority levels, and note-taking.
- **Correlation Graph Visualization**: Interactive network graph showing relationships between leads based on license plates, face matches, geography, and supply chain connections.
- **Advanced Search**: Multi-filter search with status, enforcement stage, and time range filters.
- **Location & Map Integration**: Map visualization for leads with navigation support and nearby lead discovery.
- **Enhanced Lead Details**: Added archive association, quick access to correlation graph and location map.

### Improved

- **Lead List View**: Added status filter chips and enhanced row display with archive association badges.
- **Main Navigation**: Added Archive tab for comprehensive lead case management.

## [0.0.1] - 2026-03-01

### Added

- **Tobacco Monopoly Enforcement Customization**: Updated mock data and business terminology specifically for the tobacco monopoly law enforcement domain.
- **Five-Stage Enforcement Model**: Implemented scenarios for **Outbound Solicitation**, **Specialized Vehicle Transport**, **Logistics & Parcel Delivery**, **Maritime Smuggling**, and **Production Dens**.
- **iOS Design Modernization**: Refactored UI using `NavigationStack`, `.regularMaterial` backgrounds, and SF Symbol effects.
- **Accessibility**: Added comprehensive VoiceOver support and Dynamic Type compatibility.
- **State Management**: Introduced a centralized `DataStore` using the Swift `@Observable` macro.
- **Initial Project Scaffolding**: Set up the core Home, Leads, and Profile views.