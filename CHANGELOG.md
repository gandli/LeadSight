# Changelog

All notable changes to the LeadSight project will be documented in this file.

## [0.1.0] - 2026-03-05

### Added

- **Case Management System**: Full-featured case management with creation, status tracking, priority levels, and note-taking.
- **Correlation Graph Visualization**: Interactive network graph showing relationships between leads based on license plates, face matches, geography, and supply chain connections.
- **Advanced Search**: Multi-filter search with status, enforcement stage, and time range filters.
- **Location & Map Integration**: Map visualization for leads with navigation support and nearby lead discovery.
- **Enhanced Lead Details**: Added case association, quick access to correlation graph and location map.

### Improved

- **Lead List View**: Added status filter chips and enhanced row display with case association badges.
- **Main Navigation**: Added Cases tab for comprehensive case management.

## [0.0.1] - 2026-03-01

### Added

- **Tobacco Monopoly Enforcement Customization**: Updated mock data and business terminology specifically for the tobacco monopoly law enforcement domain.
- **Five-Stage Enforcement Model**: Implemented scenarios for **Outbound Solicitation**, **Specialized Vehicle Transport**, **Logistics & Parcel Delivery**, **Maritime Smuggling**, and **Production Dens**.
- **iOS Design Modernization**: Refactored UI using `NavigationStack`, `.regularMaterial` backgrounds, and SF Symbol effects.
- **Accessibility**: Added comprehensive VoiceOver support and Dynamic Type compatibility.
- **State Management**: Introduced a centralized `DataStore` using the Swift `@Observable` macro.
- **Initial Project Scaffolding**: Set up the core Home, Leads, and Profile views.
- **Core Data Models**: Added foundational `Lead` and `Warning` data structures.
- **Premium Visual Foundation**: Established the base design system for the premium tier.
