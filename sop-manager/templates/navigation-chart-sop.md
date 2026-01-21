---
title: "Navigation Chart SOP Template"
version: "1.0.0"
status: draft
owner: ""
created: YYYY-MM-DD
last_reviewed: YYYY-MM-DD
next_review: YYYY-MM-DD
tags: [sop, charting, navigation, client-deliverable]
related_sops: []
chart_type: ""  # survey-planning | client-deliverable | rov-operations
project_phase: ""  # pre-survey | active-survey | post-survey
---

## Purpose

[Describe the specific navigation chart purpose and when it's needed]

## Scope

**Applies to:**
- [Chart type/survey type]
- [Project phase]
- [Client requirements if applicable]

**Does not apply to:**
- [Exclusions]

## Prerequisites

### Data Requirements
- [ ] Survey area boundaries defined
- [ ] Coordinate system confirmed (UTM zone, datum)
- [ ] Client specifications received (if deliverable)
- [ ] Source data validated

### Software/Tools
- [ ] [Charting software] licensed and updated
- [ ] [Data format] import capability confirmed
- [ ] Template files accessible

### Approvals
- [ ] Project manager sign-off on scope
- [ ] Client requirements confirmed (if applicable)

## Roles & Responsibilities

| Role | Responsibility |
|------|----------------|
| Chart Creator | Produce chart per specifications |
| QC Reviewer | Verify accuracy and completeness |
| Project Manager | Final approval |
| Client Contact | Requirement clarification |

## Procedure

### 1. Project Setup

1. Create project folder
   - Location: [standard path]
   - Naming: `[ProjectID]-[ChartType]-[Version]`
   - Verify: Folder structure matches template

2. Import reference data
   - Source: [data source]
   - Format: [file format]
   - Verify: Data bounds match survey area

### 2. Chart Configuration

1. Set coordinate system
   - Datum: [specify]
   - Projection: [specify]
   - Units: [specify]
   - Verify: Grid lines align with reference

2. Configure scale
   - Target scale: [specify or client requirement]
   - Paper size: [specify]
   - Verify: All features legible at scale

3. Apply symbology
   - Standard: [symbology standard reference]
   - Colors: [color scheme]
   - Line weights: [specifications]

### 3. Content Population

1. Add survey lines/waypoints
   - Source: [data source]
   - Symbology: [standard]
   - Labels: [naming convention]
   - Verify: All lines present and correctly labeled

2. Add navigation features
   - [Feature type 1]: [specification]
   - [Feature type 2]: [specification]
   - Verify: Features match source data

3. Add annotations
   - Title block: [requirements]
   - Legend: [required elements]
   - Notes: [standard notes]
   - Verify: All text legible and correctly positioned

### 4. Quality Control

1. Self-review checklist
   - [ ] Coordinate system correct
   - [ ] Scale appropriate
   - [ ] All data layers present
   - [ ] Labels readable
   - [ ] No overlapping elements
   - [ ] Title block complete

2. Peer review
   - Reviewer: [assign]
   - Checklist: [reference QC SOP]
   - Verify: All review items addressed

### 5. Export and Delivery

1. Export chart
   - Format: [PDF/other]
   - Resolution: [DPI]
   - Naming: `[ProjectID]_[ChartType]_[Version]_[Date].[ext]`

2. Metadata documentation
   - Record: Coordinate system, datum, scale
   - Record: Data sources and dates
   - Record: Software version

3. Delivery (if client deliverable)
   - Method: [delivery method]
   - Confirmation: [how to confirm receipt]

## Verification

### Pre-Delivery Checks
- [ ] Chart matches project scope
- [ ] Coordinate system verified against reference
- [ ] All survey lines/features present
- [ ] Labels and annotations correct
- [ ] QC review completed and signed
- [ ] Export file opens correctly
- [ ] Metadata documented

### Client Acceptance (if applicable)
- [ ] Delivered per client specifications
- [ ] Client confirmation received
- [ ] Revision requests documented

## Troubleshooting

| Issue | Cause | Solution |
|-------|-------|----------|
| Data misalignment | Coordinate system mismatch | Verify datum and projection in source and project |
| Missing features | Import filter | Check import settings, re-import with correct parameters |
| Label overlap | Scale/density | Adjust scale or use leader lines |
| Export quality poor | Resolution setting | Increase DPI, check export format settings |
| File size too large | High resolution imagery | Reduce imagery resolution or split charts |

## References

- [Company charting standards document]
- [Client specification document if applicable]
- [[related-qc-sop]]
- [[related-data-validation-sop]]

## Version History

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0.0 | YYYY-MM-DD | | Initial draft |
