# Sprint Change Proposal: Epic 1 Readiness Cleanup

**Date:** 2026-05-03  
**Project:** FoodLife  
**Triggering artifact:** `_bmad-output/planning-artifacts/implementation-readiness-report-2026-05-02.md`  
**Mode:** Batch  
**Recommended scope:** Moderate backlog adjustment

## 1. Issue Summary

The implementation readiness assessment found FoodLife ready to begin implementation, with no critical blockers and full PRD functional coverage across epics. However, it identified two major cleanup items that should be resolved before starting Epic 1:

1. Epic 1 contains necessary technical foundation stories, but those stories need clearer limits so implementation does not expand into generic infrastructure work.
2. Baseline CI/setup verification is missing as an explicit early story, even though the architecture requires web install/typecheck/test/build and schema-contract validation.

The report also flagged two minor refinements:

1. Story 1.1 lacks explicit runnable verification criteria.
2. Accessibility and responsive hardening stories are broad and should use explicit surface-level test matrices.

This is not a PRD scope change. The issue is a backlog quality and implementation-control gap discovered before sprint execution.

## 2. Checklist Analysis

| Item | Status | Finding |
| --- | --- | --- |
| 1.1 Triggering story | [N/A] | Trigger came from readiness review before implementation, not from an in-flight story. |
| 1.2 Core problem | [x] | Issue type: implementation-readiness gap. Epic 1 needs tighter demonstrable outcomes and baseline automation. |
| 1.3 Supporting evidence | [x] | Readiness report lists missing CI/CD setup, broad accessibility/responsive stories, Story 1.1 verification gap, and technical-heavy Epic 1 risk. |
| 2.1 Current epic impact | [x] | Epic 1 remains viable but needs one early story and clearer foundation guardrails. |
| 2.2 Epic-level changes | [x] | Modify Epic 1 notes and Story 1.1; add new early CI/verification story. |
| 2.3 Remaining epic impact | [x] | Epics 3, 4, and 6 need explicit accessibility/responsive test matrices; no sequencing change required. |
| 2.4 Future epic validity | [x] | No epics are obsolete and no new product epic is needed. |
| 2.5 Order/priority | [x] | Add CI/setup verification immediately after Story 1.1 or Story 1.2. Recommended after Story 1.2 so schema validation has a concrete target. |
| 3.1 PRD conflicts | [x] | No PRD conflict. PRD already requires local-first reliability, accessibility, responsive behavior, conformance tests, and PRD review for real scope changes. |
| 3.2 Architecture conflicts | [x] | No architecture conflict. Architecture already specifies CI direction and schema-contract validation. Epics need to reflect it. |
| 3.3 UX conflicts | [x] | No UX conflict. UX already defines accessibility and responsive behavior. Epics need test-matrix precision. |
| 3.4 Other artifacts | [!] | Sprint/backlog tracking should be updated after approval if a sprint-status file exists. |
| 4.1 Direct Adjustment | [x] Viable | Low effort, low risk. Adds one story and tightens acceptance criteria. |
| 4.2 Rollback | [N/A] | No implementation work has started, so rollback is irrelevant. |
| 4.3 PRD MVP Review | [N/A] | MVP remains achievable; no scope reduction needed. |
| 4.4 Recommended path | [x] | Direct Adjustment. |
| 5.1-5.5 Proposal components | [x] | Included below. |
| 6.1-6.2 Final review | [x] | Proposal is internally consistent and actionable. |
| 6.3 User approval | [!] | Pending explicit approval from yiming. |
| 6.4 Sprint status update | [!] | Pending approval and presence of sprint-status artifact. |
| 6.5 Handoff plan | [x] | Route to Product Owner / Developer for backlog edit, then Developer for implementation. |

## 3. Impact Analysis

### Epic Impact

**Epic 1: Local-First FoodLife Foundation** is affected directly. It should remain the foundation epic, but it needs:

- A short guardrail note limiting foundation work to FoodLife MVP outcomes.
- Stronger runnable verification criteria in Story 1.1.
- A new early story for CI/setup verification.

**Epics 3, 4, and 6** are affected lightly. Their accessibility/responsive hardening stories remain valid, but should define the exact view/state matrix to avoid late ambiguous cleanup.

No epic should be removed, deferred, or reordered beyond inserting the new CI/setup story early in Epic 1.

### Story Impact

Affected stories:

- Story 1.1: add runnable verification acceptance criteria.
- New Story 1.3: add baseline CI and verification workflow.
- Existing Stories 1.3-1.6: renumber to 1.4-1.7 if the new story is inserted after Story 1.2.
- Story 3.4, Story 4.5, Story 6.5: add explicit accessibility/responsive verification matrices.

### Artifact Conflicts

**PRD:** No edit required. Existing NFR17, NFR18, NFR23, NFR24, and NFR25 already support these changes.

**Architecture:** No edit required. The architecture already specifies:

- Web CI: install, typecheck, test, build.
- Schema contract CI: validate fixtures and conformance outputs.
- iOS CI when an Xcode-capable environment exists.

**UX Design:** No edit required. The UX already specifies responsive viewport classes, WCAG 2.2 AA, VoiceOver/Dynamic Type expectations, map alternatives, and non-color-only type distinctions.

**Epics:** Edit required.

### Technical Impact

The change adds early project automation and verification discipline. It should reduce future implementation risk without changing product behavior.

Expected implementation impact:

- Add root and package scripts once app shells exist.
- Add web typecheck/test/build command coverage.
- Add schema-contract validation coverage.
- Document iOS local Xcode verification if CI cannot run Xcode yet.
- Optionally add CI workflow files once repository structure exists.

## 4. Recommended Approach

Use **Direct Adjustment**.

Rationale:

- The readiness report found no critical blocker and no missing FR coverage.
- The architecture already made the needed technical decisions.
- The PRD and UX are aligned with the proposed cleanup.
- The change is small, cheap before implementation, and more expensive once multiple agents start building on inconsistent assumptions.

Effort estimate: Low to Medium.  
Risk level: Low.  
Timeline impact: Adds one small early story but should reduce downstream rework.

## 5. Detailed Change Proposals

### Epic 1 Guardrail Note

**Artifact:** `_bmad-output/planning-artifacts/epics.md`  
**Section:** `## Epic 1: Local-First FoodLife Foundation`

**Current text:**

```md
Users can open complete iOS and web app shells, navigate the core product structure, and rely on a shared local-first FoodMemory model that preserves metadata and photo references across sessions.
```

**Proposed text:**

```md
Users can open complete iOS and web app shells, navigate the core product structure, and rely on a shared local-first FoodMemory model that preserves metadata and photo references across sessions.

Implementation guardrail: Epic 1 foundation work must stay limited to demonstrable FoodLife MVP outcomes: app shells that run, shared schema fixtures and validation, local repository/photo-reference boundaries, conformance tests, and navigation/design-token placeholders required by later stories. Do not introduce generic infrastructure, backend placeholders, authentication, cloud sync, or reusable platform abstractions beyond the documented FoodLife contracts.
```

**Rationale:** Keeps technical foundation stories tied to product-readiness outcomes and prevents open-ended infrastructure work.

### Story 1.1 Acceptance Criteria

**Story:** `Story 1.1: Set Up Initial Project from Starter Templates`  
**Section:** Acceptance Criteria

**Current ending:**

```md
**And** the iOS app shell is initialized from the native SwiftUI Xcode app template with matching conceptual navigation placeholders
**And** no backend, authentication, cloud sync, or placeholder server API is introduced.
```

**Proposed ending:**

```md
**And** the iOS app shell is initialized from the native SwiftUI Xcode app template with matching conceptual navigation placeholders
**And** the web app dependency install, initial test command, typecheck command, and production build command are documented and verified locally
**And** the iOS app build path is verified in Xcode, or any local Xcode-only verification constraint is documented in the story completion notes
**And** no backend, authentication, cloud sync, or placeholder server API is introduced.
```

**Rationale:** Prevents Story 1.1 from being marked complete when shells exist but cannot be reliably run or verified.

### New Story 1.3

**Insert after:** `Story 1.2: Define FoodMemory v1 Schema Contract`  
**Renumber existing Stories 1.3-1.6 to 1.4-1.7.**

```md
### Story 1.3: Establish Baseline CI and Verification Commands

As a FoodLife implementer,
I want baseline project verification commands and automation,
So that schema, web, and app-shell changes can be checked consistently before feature work expands.

**Requirements:** NFR16, NFR23, NFR24

**Acceptance Criteria:**

**Given** the web app shell and schema contract package exist
**When** baseline verification is configured
**Then** the repository documents root-level commands for web install, web typecheck, web test, web build, and schema-contract validation
**And** those commands run successfully against the starter web app and FoodMemory v1 fixtures
**And** schema-contract validation fails on invalid fixtures and passes on valid Made and Found fixtures
**And** CI workflow configuration is added for web install/typecheck/test/build and schema-contract validation, or the exact reason CI cannot be enabled yet is documented
**And** iOS build/test automation is added when an Xcode-capable runner is available, or the local Xcode verification path is documented
**And** no backend, auth, cloud, deployment, or production release automation is introduced beyond MVP verification needs.
```

**Rationale:** Aligns epics with architecture CI direction and gives future agents a consistent verification contract.

### Accessibility/Responsive Hardening Stories

**Stories:** Story 3.4, Story 4.5, Story 6.5  
**Section:** Acceptance Criteria

**Proposed addition to Story 3.4:**

```md
**And** verification covers Made gallery and Made detail in default, empty, loading, image-fallback, and error states across mobile narrow, tablet, desktop, and wide desktop web viewport classes, plus iOS VoiceOver/readable text scaling checks where feasible.
```

**Proposed addition to Story 4.5:**

```md
**And** verification covers Found map, marker/list alternative, preview, fallback, and detail states across mobile narrow, tablet, desktop, and wide desktop web viewport classes, plus iOS VoiceOver/readable text scaling checks where feasible.
```

**Proposed addition to Story 6.5:**

```md
**And** verification covers Home and Timeline in enough-memories, few-memories, no-memories, loading, image-fallback, and navigation-return states across mobile narrow, tablet, desktop, and wide desktop web viewport classes, plus iOS VoiceOver/readable text scaling checks where feasible.
```

**Rationale:** Keeps these as hardening stories but makes “accessible and responsive” measurable.

## 6. Implementation Handoff

### Scope Classification

**Moderate:** backlog reorganization is required, but no PRD/architecture/UX replan is needed.

### Route

Route to **Product Owner / Developer** for backlog edit and story renumbering, then to **Developer agent** for Story 1.1 implementation.

### Responsibilities

**Product Owner / Developer backlog update:**

- Apply the `epics.md` edits above.
- Renumber Epic 1 stories if the new story is inserted after Story 1.2.
- Update any sprint-status tracking artifact if present.
- Confirm no PRD, architecture, or UX document changes are required.

**Developer implementation:**

- Start with Story 1.1 only after the epic edits are approved.
- Report exact verification commands and outcomes in story completion notes.
- Keep Epic 1 implementation limited to app shells, schema-contract setup, local-first boundaries, and documented verification.

### Success Criteria

- `epics.md` contains the Epic 1 guardrail note.
- Story 1.1 includes runnable verification acceptance criteria.
- New baseline CI/verification story exists in Epic 1.
- Accessibility/responsive hardening stories contain explicit verification matrices.
- Any sprint-status tracking is synchronized with the approved story set.
- Implementation can begin with Story 1.1 without hidden CI/setup ambiguity.

## 7. Approval Request

This proposal is ready for review.

Approval options:

- **Approve:** apply the proposed `epics.md` edits and update sprint tracking if present.
- **Revise:** adjust story placement, wording, or scope before editing artifacts.
- **Reject:** keep the current epics unchanged and accept the readiness-report risks.
