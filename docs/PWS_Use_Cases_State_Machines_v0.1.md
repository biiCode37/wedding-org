# Premium Wedding SaaS — Use Cases + State Machines

**Document ID:** PWS-UCSM-001  
**Version:** 0.1  
**Status:** Baseline Specification  
**Date:** 2026-08-28  
**Upstream:** PRD, ADR, Physical Database Schema, Authorization + RLS, API Contract, Domain Services + Business Rules  
**Downstream:** Security + NFR, Testing + Acceptance Criteria, Engineering / Implementation Blueprint

---

## 1. Purpose

Dokumen ini menerjemahkan Domain Services + Business Rules menjadi:

- actor-driven use cases;
- preconditions;
- commands;
- main flows;
- alternate/error flows;
- transaction boundaries;
- state transitions;
- invariants;
- idempotency behavior;
- side effects.

Dokumen ini tidak mengganti authorization model atau business rules upstream.

---

# 2. Global Execution Contract

Setiap protected use case mengikuti:

```text
Authenticate
  ↓
Authorize
  ↓
Load Aggregate / Context
  ↓
Validate Preconditions
  ↓
Execute Domain Command
  ↓
Persist Atomically
  ↓
Record Audit/History where required
  ↓
Dispatch Side Effects after successful commit
```

Jika authorization atau domain invariant gagal:

```text
NO STATE CHANGE
```

Critical actions wajib idempotent bila dapat menerima retry.

---

# 3. Actors

| Actor | Boundary |
|---|---|
| Platform Admin | Platform |
| Organization Owner | Organization |
| Organization Admin | Organization |
| Event Manager / Project Manager | Workspace |
| Guest / Invitation Manager | Workspace |
| Check-in Staff | Event |
| Couple / Client | Limited Workspace |
| Public Guest | Invitation Party / public context |
| System / Worker | Trusted backend execution |
| External Provider | External side-effect source |

---

# 4. Use Case Catalog

## Organization & Access

| ID | Use Case |
|---|---|
| UC-ORG-01 | Create Organization |
| UC-ORG-02 | Manage Organization |
| UC-ORG-03 | Manage Membership |
| UC-ORG-04 | Assign/Revoke Role |
| UC-ORG-05 | Grant/Revoke Client Access |

## Workspace / Wedding

| ID | Use Case |
|---|---|
| UC-WS-01 | Create Workspace |
| UC-WS-02 | Update Wedding Profile |
| UC-WS-03 | Manage Workspace |

## Guests & Event

| ID | Use Case |
|---|---|
| UC-GST-01 | Create Guest |
| UC-GST-02 | Update Guest |
| UC-GST-03 | Merge Guest |
| UC-EVT-01 | Create Event |
| UC-EVT-02 | Update Event |
| UC-EVT-03 | Add Guest to Event |
| UC-EVT-04 | Remove Guest from Event |

## Invitation / RSVP

| ID | Use Case |
|---|---|
| UC-INV-01 | Create Invitation Party |
| UC-INV-02 | Create/Update Invitation |
| UC-INV-03 | Publish Invitation |
| UC-INV-04 | Issue/Revoke Invitation Token |
| UC-INV-05 | Send Invitation |
| UC-RSVP-01 | Submit RSVP |
| UC-RSVP-02 | Update RSVP |

## Seating

| ID | Use Case |
|---|---|
| UC-SEAT-01 | Create Seating Plan |
| UC-SEAT-02 | Manage Table |
| UC-SEAT-03 | Assign Guest Seating |

## Check-in

| ID | Use Case |
|---|---|
| UC-CI-01 | Check In Event Guest |
| UC-CI-02 | Correct Check-in |

## Souvenir

| ID | Use Case |
|---|---|
| UC-SOUV-01 | Resolve Entitlement |
| UC-SOUV-02 | Override Entitlement |
| UC-SOUV-03 | Claim Souvenir |
| UC-SOUV-04 | Proxy Claim Souvenir |

## Website

| ID | Use Case |
|---|---|
| UC-WEB-01 | Update Website Draft |
| UC-WEB-02 | Publish Website Version |

---

# 5. Organization & Access Use Cases

## UC-ORG-01 — Create Organization

**Actor:** authenticated user / permitted platform flow.

**Preconditions:**
- authenticated;
- no conflicting creation rule;
- organization creation is permitted.

**Main flow:**
1. Validate identity.
2. Create organization.
3. Create owner membership.
4. Assign initial owner role.
5. Commit atomically.
6. Write audit evidence.

**Invariant:**
Owner must belong to created organization.

---

## UC-ORG-03 — Manage Membership

**Actor:** Organization Owner/Admin with `organization.members.manage`.

**Main flow:**
1. Resolve target organization.
2. Authorize caller.
3. Validate target user.
4. Create/update membership.
5. Commit.
6. Audit.

**Alternate:**
- target already active → return idempotent/current state where operation semantics permit;
- caller lacks delegation authority → deny;
- cross-organization target → deny.

**Postcondition:**
Active membership produces staff access only through valid role assignment.

---

## UC-ORG-04 — Assign/Revoke Role

**Preconditions:**
- caller has role-management permission;
- target membership belongs to same organization;
- target role is valid;
- scope belongs to same organization;
- caller may delegate that authority.

**Main flow:**
1. Resolve role.
2. Resolve scope.
3. Validate delegation boundary.
4. Create/update role assignment.
5. Audit.
6. Commit.

**Forbidden:**
- self-escalation;
- cross-tenant assignment;
- event scope belonging to another workspace;
- workspace scope belonging to another organization.

---

# 6. Workspace / Wedding Use Cases

## UC-WS-01 — Create Workspace

**Preconditions:**
- organization authorization;
- workspace ownership established from organization context.

**Main flow:**
1. Authorize.
2. Validate workspace data.
3. Create workspace.
4. Initialize required wedding/project state.
5. Commit.
6. Audit.

Workspace ownership is not client-selectable as an arbitrary foreign organization.

---

# 7. Guest & Event Use Cases

## UC-GST-01 — Create Guest

**Preconditions:**
- workspace access;
- `guest.create`.

**Main flow:**
1. Resolve workspace.
2. Authorize.
3. Validate guest fields.
4. Create workspace-scoped guest.
5. Commit.

**Invariant:**
Guest identity is scoped to workspace. Name/email/phone are not assumed globally unique.

---

## UC-GST-03 — Merge Guest

**Preconditions:**
- merge permission;
- both guests belong to same workspace;
- merge is semantically valid.

**Main flow:**
1. Load source and target guest.
2. Validate same workspace.
3. Resolve dependent invitation/event/history records.
4. Execute merge transaction.
5. Preserve evidence/history.
6. Audit.
7. Commit.

**Forbidden:**
- cross-workspace merge;
- silent destruction of invitation/RSVP/check-in evidence.

---

## UC-EVT-03 — Add Guest to Event

**Main flow:**
1. Authorize workspace/event.
2. Validate guest belongs to workspace.
3. Validate event belongs to same workspace.
4. Create `event_guest`.
5. Initialize required event participation state.
6. Commit.

**Invariant:**

```text
guest.workspace_id = event.workspace_id
```

---

# 8. Invitation Use Cases

## UC-INV-01 — Create Invitation Party

**Preconditions:**
- authorized workspace context;
- primary guest belongs to workspace.

**Main flow:**
1. Resolve guest.
2. Validate ownership.
3. Create Invitation Party.
4. Establish one-QR identity.
5. Initialize entitlement according to invited count.
6. Commit.

**Invariant:**

```text
1 QR = 1 Invitation Party
1 Invitation Party = 1 primary guest
```

---

## UC-INV-03 — Publish Invitation

**Main flow:**
1. Authenticate.
2. Authorize.
3. Load invitation.
4. Validate publishable state.
5. Execute publish domain transition.
6. Persist.
7. Audit.
8. Dispatch required side effects.

Publishing is not a generic status patch.

---

## UC-INV-04 — Issue/Revoke Invitation Token

**Issue:**
1. Authorize invitation party.
2. Generate non-guessable credential.
3. Persist protected token representation.
4. Return public-safe access reference.

**Revoke:**
1. Authorize.
2. Mark token unusable.
3. Persist.
4. Audit.

Token is not staff authorization.

---

## UC-INV-05 — Send Invitation

**Main flow:**
1. Authorize.
2. Validate invitation sendable state.
3. Resolve recipient.
4. Create idempotent send operation.
5. Commit internal send state.
6. Dispatch external delivery.
7. Record provider outcome/history.

Retry must not create unintended duplicate domain side effects.

---

# 9. RSVP Use Cases

## UC-RSVP-01 — Submit RSVP

**Actor:** Public Guest or authorized client/staff context.

**Preconditions:**
- valid invitation/public context;
- target event guest exists;
- RSVP operation allowed by current policy.

**Main flow:**
1. Resolve invitation party / event guest.
2. Validate access.
3. Validate response.
4. Validate attendee count.
5. Update current RSVP state.
6. Append history when required.
7. Commit.

**Invariant:**

```text
actual_attendee_count >= 0
actual_attendee_count <= invited_person_count
```

Public RSVP expiry remains deferred until Security/Use Case policy finalization.

---

## UC-RSVP-02 — Update RSVP

Same invariant as submit.

The operation is a domain command, not unrestricted field patching.

---

# 10. Seating Use Cases

## UC-SEAT-03 — Assign Guest Seating

**Preconditions:**
- event guest exists;
- seating plan belongs to same event;
- caller has seating permission.

**Main flow:**
1. Load event participation.
2. Load seating plan.
3. Validate table/seat.
4. Validate capacity/conflict.
5. Persist assignment atomically.
6. Audit where required.

Concurrent edits must follow the defined conflict strategy.

---

# 11. Check-in Use Cases

## UC-CI-01 — Check In Event Guest

**Actor:** Check-in Staff / authorized event operator.

**Preconditions:**
- event scope authorized;
- event guest exists;
- guest belongs to target event.

**Main flow:**
1. Resolve event guest.
2. Authorize event scope.
3. Validate eligibility.
4. Attempt idempotent check-in.
5. Persist current state + record.
6. Commit.
7. Return current check-in result.

### Duplicate scan

```text
Already checked in
      ↓
Return existing successful state
      ↓
No second successful check-in
```

### Cross-event scan

```text
Event Guest not in target event
      ↓
DENY
```

---

## UC-CI-02 — Correct Check-in

**Preconditions:**
- explicit `checkin.correct` permission;
- existing check-in;
- valid correction reason/policy.

**Main flow:**
1. Authorize privileged correction.
2. Load existing record.
3. Validate correction.
4. Preserve previous evidence.
5. Apply correction state.
6. Audit.
7. Commit.

Correction must never erase the historical fact that the earlier check-in occurred.

---

# 12. Souvenir Use Cases

## UC-SOUV-01 — Resolve Entitlement

Resolution:

```text
Invitation Party
      ↓
Override exists?
   ├─ YES → valid final override
   └─ NO  → invited_person_count
```

Invariant:

```text
final_entitlement >= claimed_quantity
```

`actual_attendee_count` does not silently replace entitlement.

---

## UC-SOUV-02 — Override Entitlement

**Preconditions:**
- authorized staff;
- entitlement belongs to authorized invitation party;
- explicit permission;
- non-empty reason;
- new quantity satisfies domain constraints.

**Main flow:**
1. Authorize.
2. Load entitlement.
3. Calculate claimed quantity.
4. Validate new entitlement.
5. Persist override + reason.
6. Audit.
7. Commit.

Forbidden:

```text
new entitlement < already claimed quantity
```

---

## UC-SOUV-03 — Claim Souvenir

**Preconditions:**
- valid invitation party;
- claimant authorized for the operation;
- entitlement available.

**Main flow:**
1. Resolve invitation party.
2. Lock/reconcile entitlement inside transaction boundary.
3. Calculate remaining quantity.
4. Validate requested quantity.
5. Create claim.
6. Update consumed/remaining state.
7. Commit atomically.
8. Return claim result.

### Concurrency

Two concurrent claims must not produce:

```text
total_claimed > final_entitlement
```

### Retry

Same idempotency key/request must not create duplicate claim.

### Exhausted

```text
remaining = 0
→ DENY new claim
```

---

## UC-SOUV-04 — Proxy Claim Souvenir

**Preconditions:**
- proxy claim context valid;
- staff confirmation required;
- staff has required permission;
- entitlement available.

**Flow:**

```text
Proxy request
    ↓
Staff confirmation
    ↓
Authorization
    ↓
Atomic claim
    ↓
Audit
```

Without staff confirmation:

```text
DENY
```

---

# 13. Website Use Cases

## UC-WEB-01 — Update Website Draft

**Preconditions:**
- workspace authorization;
- website editable.

**Main flow:**
1. Authorize.
2. Load draft.
3. Validate section/content rules.
4. Persist draft.
5. Commit.

Published version is not mutated directly.

---

## UC-WEB-02 — Publish Website Version

**Main flow:**
1. Authorize.
2. Load current draft.
3. Validate publishability.
4. Create immutable version.
5. Mark published version.
6. Commit.
7. Audit.

### Invariant

Published version is immutable.

---

# 14. State Machine Principles

State machines represent business lifecycle, not arbitrary database status fields.

Rules:

1. Only declared transitions are valid.
2. Invalid transitions are rejected.
3. Transition may require authorization.
4. Transition may require domain preconditions.
5. Side effects occur only after successful state transition.
6. History is append-only where business evidence is required.
7. Idempotent transitions return current state where appropriate.

---

# 15. Invitation State Machine

Baseline conceptual states:

```text
DRAFT
  ↓ publish
PUBLISHED
  ↓ send
SENT
  ↓ provider outcome
DELIVERED / FAILED
```

Possible terminal/administrative transition:

```text
PUBLISHED/SENT
  ↓ cancel
CANCELLED
```

Rules:

- draft can be edited;
- publish requires publish authorization;
- sending requires sendable invitation;
- provider status does not redefine internal domain semantics.

---

# 16. Invitation Token State Machine

```text
ACTIVE
  ↓ revoke
REVOKED

ACTIVE
  ↓ expiry
EXPIRED
```

Only active, non-expired tokens may establish public access context.

---

# 17. RSVP State Machine

Conceptual:

```text
PENDING
  ├── accept → ACCEPTED
  ├── decline → DECLINED
  └── update → current valid state
```

RSVP may be updated according to public/client policy.

Each accepted transition must preserve attendee-count invariants.

---

# 18. Check-in State Machine

```text
NOT_CHECKED_IN
      ↓ check-in
CHECKED_IN
      ↓ correction
CORRECTED / CURRENT_VALID_STATE
```

History:

```text
check-in evidence
      +
correction evidence
```

Duplicate check-in:

```text
CHECKED_IN
   ↓ duplicate command
CHECKED_IN
```

No duplicate successful record.

---

# 19. Souvenir Claim State Machine

```text
ELIGIBLE
   ↓ claim
CLAIMED / PARTIALLY_CLAIMED
   ↓ remaining = 0
EXHAUSTED
```

Invalid:

```text
EXHAUSTED → claim
    ↓
DENY
```

Proxy:

```text
PROXY_REQUESTED
      ↓ staff confirmation
ELIGIBLE → CLAIMED
```

Without confirmation:

```text
PROXY_REQUESTED → DENY
```

---

# 20. Website State Machine

Draft:

```text
DRAFT
  ↓ publish
PUBLISHED_VERSION
```

Published version:

```text
PUBLISHED_VERSION
      ↓
IMMUTABLE
```

A new publication creates a new version rather than mutating the published version.

---

# 21. Workspace Lifecycle

The exact workspace lifecycle states were not fully specified upstream.

Therefore this document does **not** invent a final state vocabulary.

Required downstream rule:

```text
Workspace lifecycle
→ must define valid creation/edit/archive transitions
→ before implementation of lifecycle-specific behavior
```

---

# 22. Event Lifecycle

Same principle:

The source establishes event ownership and event participation, but does not provide a complete final event state machine.

Therefore:

```text
No invented lifecycle enum
```

until the lifecycle states are defined by the product/use-case specification.

---

# 23. Transaction Boundaries

Must be atomic for:

### Check-in

```text
eligibility
+
duplicate protection
+
check-in state
+
evidence
```

### Souvenir Claim

```text
entitlement lock/resolution
+
remaining quantity validation
+
claim creation
+
consumption update
```

### Role Assignment

```text
authorization
+
scope validation
+
role assignment
+
audit
```

### Guest Merge

```text
source/target validation
+
dependent relationship migration
+
evidence preservation
+
merge state
```

### Website Publish

```text
draft validation
+
version creation
+
published pointer/state
```

---

# 24. Idempotency Contract

Required for:

```text
check-in
souvenir claim
invitation send
payment webhook handling
other critical retryable mutation
```

Idempotency result categories:

```text
FIRST EXECUTION
→ execute normally

RETRY SAME OPERATION
→ return equivalent existing result

CONFLICTING REUSE
→ reject
```

Idempotency must not be implemented by blindly swallowing all duplicate requests.

---

# 25. Error Categories

Domain errors should remain semantically distinct:

```text
UNAUTHORIZED
FORBIDDEN
NOT_FOUND
INVALID_STATE_TRANSITION
DOMAIN_INVARIANT_VIOLATION
CONFLICT
DUPLICATE_OPERATION
ENTITLEMENT_EXHAUSTED
INVALID_SCOPE
INVALID_OWNERSHIP
TOKEN_INVALID
TOKEN_EXPIRED
TOKEN_REVOKED
```

API mapping is defined downstream by API Contract.

---

# 26. Side-Effect Rules

External side effects should occur after successful internal state commit whenever possible.

Examples:

```text
Invitation published
  ↓
notification/delivery side effect

Invitation sent
  ↓
provider call

Website published
  ↓
cache/revalidation side effect
```

Provider failure must not silently corrupt internal domain state.

---

# 27. Domain Events

Recommended logical events:

```text
OrganizationCreated
MemberAdded
RoleAssigned
ClientAccessGranted

WorkspaceCreated
GuestCreated
GuestMerged
EventCreated
GuestAddedToEvent

InvitationPublished
InvitationSent
InvitationTokenRevoked

RsvpSubmitted
RsvpUpdated

GuestCheckedIn
CheckinCorrected

SouvenirEntitlementOverridden
SouvenirClaimed
SouvenirProxyClaimed

WebsitePublished
```

Events represent committed domain facts. They are not authorization decisions.

---

# 28. Cross-Cutting Invariants

Always enforce:

```text
Tenant isolation
Scope validity
Ownership consistency
Active membership
Explicit permission
Domain state validity
Current-state/history consistency
Idempotency
Concurrency safety
Auditability where required
```

---

# 29. Deferred Decisions

Tidak boleh mengarang:

- exact public RSVP expiry;
- exact client writable fields;
- exact platform support authority;
- exact billing feature matrix;
- exact offline/degraded check-in behavior;
- exact audit retention;
- exact provider retry policy;
- exact 403/404 mapping.

Affected use cases remain explicitly marked until downstream Security/NFR/API decisions resolve them.

---

# 30. Acceptance-Oriented Invariants

Minimum acceptance criteria:

```text
1. Cross-tenant command is denied.
2. Inactive membership cannot execute staff command.
3. Scoped role cannot access unrelated scope.
4. Client cannot inherit staff administration.
5. Public token cannot enumerate guests.
6. Invitation Party has one QR identity.
7. RSVP attendee count never exceeds invited count.
8. Duplicate check-in is idempotent.
9. Check-in correction preserves evidence.
10. Entitlement override requires permission + reason.
11. Entitlement cannot fall below claimed quantity.
12. Concurrent souvenir claims cannot exceed entitlement.
13. Duplicate claim retry is idempotent.
14. Proxy claim without staff confirmation is denied.
15. Published website version is immutable.
16. Critical side effects do not execute from rolled-back transactions.
```

---

# 31. Implementation Guardrails

Coding agent MUST:

- implement use cases as application/domain commands, not raw CRUD;
- validate authorization before domain mutation;
- enforce invariants server-side;
- keep transaction boundaries explicit;
- preserve audit/history where required;
- use idempotency for critical retryable commands;
- protect concurrent quantity/state mutations;
- never infer missing lifecycle states;
- never silently resolve deferred product decisions;
- never bypass RLS/security boundaries.

---

# 32. Downstream Contract

```text
Use Cases + State Machines
        ↓
Security + NFR
        ↓
Testing + Acceptance Criteria
        ↓
Engineering / Implementation Blueprint
        ↓
Coding
```

Security/NFR must resolve security-specific deferred behavior.

Testing must convert every invariant and transition into executable acceptance tests.

Engineering Blueprint must map each use case to concrete modules, transaction boundaries, repositories, events, and integration adapters.

---

# 33. Status

**Use Cases + State Machines v0.1 — Baseline complete.**

No architecture change is introduced by this document.
