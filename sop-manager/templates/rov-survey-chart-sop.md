---
title: "ROV Survey Chart SOP Template"
version: "1.0.0"
status: draft
owner: ""
created: YYYY-MM-DD
last_reviewed: YYYY-MM-DD
next_review: YYYY-MM-DD
tags: [sop, charting, rov, survey, navigation]
related_sops: []
survey_phase: ""  # planning | operations | post-survey
rov_type: ""
---

## Purpose

[Describe the ROV survey chart purpose - planning, real-time operations, or post-survey deliverable]

## Scope

**Applies to:**
- ROV survey type: [inspection/construction/survey]
- Survey phase: [planning/operations/post-survey]
- Vessel/ROV system: [if specific]

**Does not apply to:**
- [Exclusions - different ROV types, survey methods]

## Prerequisites

### Data Requirements
- [ ] ROV operational limits documented
- [ ] Survey corridor/area defined
- [ ] Seabed features/hazards identified
- [ ] Target locations confirmed
- [ ] Water depth data available

### Planning Data (if planning chart)
- [ ] Vessel approach corridors defined
- [ ] Umbilical management constraints known
- [ ] Tide/current windows identified

### Software/Tools
- [ ] [Charting software] configured
- [ ] ROV track overlay capability
- [ ] Real-time data feed (if operations)

## Roles & Responsibilities

| Role | Responsibility |
|------|----------------|
| Survey Lead | Define survey requirements |
| ROV Supervisor | Confirm operational feasibility |
| Chart Creator | Produce navigation chart |
| QC Reviewer | Verify accuracy |
| Client Rep | Approve (if deliverable) |

## Procedure

### 1. Survey Area Definition

1. Import survey boundaries
   - Source: [project coordinates]
   - Buffer: [operational buffer distance]
   - Verify: Boundaries include ROV turning radius

2. Define work corridors
   - Width: [based on ROV/umbilical]
   - Overlap: [percentage between runs]
   - Verify: Full coverage achieved

### 2. Navigation Layers

1. Add bathymetry
   - Source: [bathymetry data]
   - Contour interval: [specify]
   - Color scheme: [depth-coded]
   - Verify: Depth values match survey data

2. Add seabed features
   - Hazards: [symbology - red/high visibility]
   - Targets: [symbology - labeled]
   - Infrastructure: [symbology - per standard]
   - Verify: All known features plotted

3. Add operational boundaries
   - No-go zones: [clearly marked]
   - Caution areas: [clearly marked]
   - Safe corridors: [highlighted]

### 3. ROV-Specific Elements

1. Add survey lines/waypoints
   - Line spacing: [based on sensor coverage]
   - Waypoint naming: [convention]
   - Turn points: [marked for umbilical management]
   - Verify: Achievable with ROV system

2. Add depth constraints
   - Max depth indicators
   - Depth-limited zones
   - Verify: Within ROV operational envelope

3. Add current/environmental notes
   - Current direction indicators
   - Tide windows (if applicable)
   - Environmental constraints

### 4. Operational Information

1. Add reference points
   - Vessel position reference
   - USBL/LBL beacon locations
   - Verify: Positioning system coverage

2. Add scale and coordinates
   - Scale bar prominent
   - Grid with coordinates
   - North arrow
   - Verify: Usable for real-time navigation

3. Add operational notes
   - Umbilical length constraints
   - Communication checkpoints
   - Emergency procedures reference

### 5. Quality Control

1. Technical review
   - [ ] Survey lines achievable
   - [ ] Depths within ROV limits
   - [ ] All hazards marked
   - [ ] Waypoints correctly positioned
   - [ ] Scale appropriate for operations

2. Operational review (ROV team)
   - [ ] Umbilical management feasible
   - [ ] Turn points achievable
   - [ ] No-go zones clearly visible
   - [ ] Emergency egress routes clear

### 6. Export and Distribution

1. Export formats
   - Operations: [format for real-time display]
   - Planning: [format for briefings]
   - Archive: [format for records]

2. Distribution
   - ROV team: [delivery method]
   - Vessel bridge: [delivery method]
   - Client: [if required]

## Verification

### Pre-Operations Checks
- [ ] Chart reviewed by ROV Supervisor
- [ ] All survey lines plotted correctly
- [ ] Hazards and no-go zones visible
- [ ] Depth constraints marked
- [ ] Waypoint coordinates verified against source
- [ ] Chart loaded to navigation system

### During Operations (if live chart)
- [ ] ROV track overlay functioning
- [ ] Position accuracy acceptable
- [ ] Updates applied as needed

## Troubleshooting

| Issue | Cause | Solution |
|-------|-------|----------|
| Position offset | Datum mismatch | Verify vessel nav system datum matches chart |
| Missing coverage | Line spacing error | Recalculate based on sensor specs |
| Umbilical conflicts | Turn radius too tight | Adjust waypoints for larger turns |
| Depth data mismatch | Different survey vintage | Note data source and date, use most recent |

## References

- [[rov-operational-limits]]
- [[survey-line-planning-sop]]
- [[umbilical-management-guidelines]]
- [ROV system specifications]

## Version History

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0.0 | YYYY-MM-DD | | Initial draft |
