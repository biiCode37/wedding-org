# Premium Wedding SaaS — Testing + Acceptance Criteria

**Document ID:** PWS-TEST-AC-001  
**Version:** 0.1  
**Status:** Baseline Specification  
**Date:** 2026-08-29

## 1. Purpose

Dokumen ini mengubah seluruh requirement upstream menjadi acceptance criteria yang dapat diuji.

Upstream:
- PRD
- Release Roadmap
- Architecture Decision Record
- Physical Database Schema
- Authorization + RLS
- API Contract
- Domain Services + Business Rules
- Use Cases + State Machines
- Security + NFR

Target:
- functional correctness;
- authorization/RLS;
- tenant/scope isolation;
- state transitions;
- domain invariants;
- idempotency;
- concurrency;
- public access security;
- audit/evidence;
- realtime;
- reliability;
- performance;
- recovery;
- external dependency failure.

Acceptance criteria adalah contract implementasi. Happy-path saja tidak cukup.

---

# 2. Test Strategy

Testing pyramid:

```text
Unit
  ↓
Domain / Service
  ↓
Integration
  ↓
Database / RLS
  ↓
API / Contract
  ↓
E2E
  ↓
Security / Concurrency / Resilience
```

Critical business paths wajib memiliki integration coverage dan E2E coverage yang sesuai risk.

---

# 3. Definition of Done

Sebuah feature/use case dinyatakan DONE apabila:

1. happy path pass;
2. invalid input pass;
3. unauthorized/forbidden case pass;
4. tenant/scope isolation pass;
5. domain invariants pass;
6. valid state transitions pass;
7. invalid transitions reject;
8. idempotency tested bila required;
9. concurrency tested bila required;
10. audit/history verified bila required;
11. external failure behavior verified bila applicable;
12. RLS tests pass;
13. API contract remains conformant;
14. no deferred decision was silently invented.

---

# 4. Global Acceptance Criteria

## AC-GLOBAL-01 — Tenant Isolation

**Given** user belongs to Organization A  
**When** user accesses a private resource owned by Organization B  
**Then** access is denied and existence-sensitive information is not leaked.

## AC-GLOBAL-02 — Scope Isolation

**Given** user has Workspace W1 scope  
**When** user requests W2 resource  
**Then** access is denied.

## AC-GLOBAL-03 — Server Authorization

**Given** UI hides a protected action  
**When** client manually calls the mutation  
**Then** server/API must still deny without required permission.

## AC-GLOBAL-04 — RLS Defense in Depth

**Given** application-layer authorization is accidentally bypassed  
**When** database query reaches RLS-protected table  
**Then** unauthorized tenant/scope rows remain inaccessible.

## AC-GLOBAL-05 — No Ownership Reassignment

**When** client attempts to change tenant/workspace ownership through ordinary CRUD  
**Then** mutation is rejected.

---

# 5. Authentication Tests

## AC-AUTH-01

Invalid/expired/revoked authentication context cannot create effective application access.

## AC-AUTH-02

Application never stores or logs raw passwords.

## AC-AUTH-03

Authentication errors do not expose credentials, tokens, SQL details, or internal stack traces.

---

# 6. Authorization & RBAC Tests

## AC-RBAC-01 — Active Membership

Active organization member with valid role and permission can access authorized resource.

## AC-RBAC-02 — Removed Membership

Removed/inactive member cannot execute previously permitted staff mutation.

## AC-RBAC-03 — Multiple Roles

User with multiple active role assignments receives the union of valid permissions applicable to target scope.

## AC-RBAC-04 — Workspace Scope

Workspace-scoped role for W1 cannot access W2.

## AC-RBAC-05 — Event Scope

Event-scoped role for E1 cannot access E2 or unrelated workspace resources.

## AC-RBAC-06 — No Implicit Escalation

Event/workspace-scoped role does not gain organization-wide permission without an independently valid organization-scoped role.

## AC-RBAC-07 — Self-Escalation

User cannot grant themselves higher authority merely because they can manage some roles.

## AC-RBAC-08 — Delegation Boundary

A role manager cannot grant a role/scope outside the authority they may delegate.

## AC-RBAC-09 — Client Separation

Client access does not inherit staff RBAC.

## AC-RBAC-10 — Platform Separation

Platform administration authority is not exposed as ordinary organization membership.

---

# 7. RLS Test Matrix

Minimum database test matrix:

| Scenario | Expected |
|---|---|
| Org A → Org A resource | ALLOW |
| Org A → Org B resource | DENY |
| W1 scoped role → W1 | ALLOW |
| W1 scoped role → W2 | DENY |
| E1 scoped role → E1 | ALLOW |
| E1 scoped role → E2 | DENY |
| inactive member → private data | DENY |
| client W1 → client-visible W1 data | ALLOW |
| client W1 → W2 | DENY |
| anonymous → private table | DENY |
| ownership reassignment | DENY |
| cross-tenant INSERT | DENY |
| cross-tenant UPDATE | DENY |
| cross-tenant DELETE | DENY |

`USING` dan `WITH CHECK` behavior harus diuji secara terpisah pada mutation-critical tables.

---

# 8. Organization / Membership Use Cases

## AC-ORG-01 — Create Organization

Expected:
- organization created exactly once for one command;
- initial owner relationship valid;
- owner belongs to organization;
- required audit evidence exists.

Failure must rollback partial creation.

## AC-ORG-02 — Membership Management

Expected:
- only authorized caller can manage membership;
- target membership remains inside target organization;
- inactive membership immediately loses effective access;
- operation is audited where required.

## AC-ORG-03 — Role Assignment

Expected:
- target member belongs to same organization;
- target scope belongs to same organization;
- invalid scope relationship rejected;
- self-escalation rejected;
- successful assignment is auditable.

---

# 9. Workspace / Guest / Event Tests

## AC-WS-01 — Workspace Ownership

A workspace cannot be reassigned to another organization through ordinary CRUD.

## AC-GUEST-01 — Guest Scope

Guest created for W1 is accessible only inside W1 authorization boundary.

## AC-GUEST-02 — Guest Merge

Merge requires:
- explicit permission;
- same workspace;
- valid source/target;
- dependent evidence preserved;
- atomic transaction.

Cross-workspace merge must fail without partial changes.

## AC-EVENT-01 — Event Ownership

Event belongs to one workspace and cannot be mutated into an unrelated organization/workspace via ordinary update.

## AC-EVENT-02 — Event Participation

`event_guest` can only associate:
```text
guest.workspace_id = event.workspace_id
```

Cross-workspace association must fail.

---

# 10. Invitation Tests

## AC-INV-01 — Invitation Party

Expected:
- one primary guest;
- one QR identity;
- workspace ownership valid;
- invited count valid.

## AC-INV-02 — Publish

Only authorized user can publish.

Invalid lifecycle transition must be rejected.

## AC-INV-03 — Token

Expected:
- token is non-guessable;
- token does not use resource UUID as secret;
- revoked token denied;
- expired token denied when expiry applies;
- token cannot expand tenant scope.

## AC-INV-04 — Send

Expected:
- send requires authorization;
- internal state remains consistent after provider failure;
- retry with same idempotency key does not create unintended duplicate operation.

---

# 11. RSVP Tests

## AC-RSVP-01 — Submit

Valid invitation/public context can submit RSVP according to current policy.

## AC-RSVP-02 — Count Invariant

Must always satisfy:

```text
invited_person_count >= actual_attendee_count
actual_attendee_count >= 0
```

## AC-RSVP-03 — History

Where history is required, current state changes preserve response history.

## AC-RSVP-04 — Public Scope

A public guest can modify only the invitation/guest context granted by the valid public access token.

Public RSVP expiry window remains a deferred product/security decision.

---

# 12. Seating Tests

## AC-SEAT-01

Guest seating assignment must belong to the same event.

## AC-SEAT-02

Assignment exceeding defined table/seat constraints is rejected.

## AC-SEAT-03

Concurrent conflicting assignments follow the defined conflict behavior and never create invalid final state.

---

# 13. Check-in Tests

## AC-CI-01 — Authorized Check-in

Authorized event-scoped staff can check in an eligible event guest.

## AC-CI-02 — Wrong Event

Guest/event association mismatch is denied.

## AC-CI-03 — Duplicate Check-in

Running the same successful check-in again must be idempotent:

```text
1 successful check-in
+
retry
=
same effective result
```

No second successful check-in may be created.

## AC-CI-04 — Concurrent Check-in

Concurrent requests cannot create more than one successful check-in.

## AC-CI-05 — Correction

Correction requires explicit correction authority and preserves prior evidence/history.

---

# 14. Souvenir Tests

## AC-SOUV-01 — Default Entitlement

Default entitlement equals invited count when no valid override applies.

## AC-SOUV-02 — Override

Override requires:
- authorization;
- reason;
- valid invitation-party ownership;
- entitlement >= claimed quantity.

## AC-SOUV-03 — Claim

Valid claim must:
- resolve correct invitation party;
- validate remaining quantity;
- execute atomically;
- create claim evidence;
- update current consumption state.

## AC-SOUV-04 — Exhausted

When:

```text
remaining = 0
```

new claim is denied.

## AC-SOUV-05 — Concurrent Claim

For entitlement N, concurrent successful claims must never result in:

```text
total_claimed > N
```

This must be tested with real concurrent transactions, not only sequential unit tests.

## AC-SOUV-06 — Idempotent Retry

Same idempotency key and same logical operation returns equivalent existing result.

Same idempotency key with conflicting payload is rejected.

## AC-SOUV-07 — Proxy Claim

Proxy claim without required staff confirmation is denied.

Proxy claim with valid staff confirmation and permission succeeds.

## AC-SOUV-08 — Evidence

Claim and override evidence is retained according to audit/history requirements.

---

# 15. Website Tests

## AC-WEB-01 — Draft

Authorized workspace user can modify draft.

## AC-WEB-02 — Published Immutability

Published website version cannot be mutated in place.

## AC-WEB-03 — Publish

Publish creates/marks the correct version atomically.

Failed publish must not leave a partially published state.

---

# 16. Billing / Payment Tests

## AC-PAY-01 — Domain Separation

SaaS billing and wedding gift/payment remain separate domain models.

## AC-PAY-02 — Webhook Truth

Verified provider webhook is source of truth for provider-backed payment state.

Browser redirect alone cannot mark payment as verified.

## AC-PAY-03 — Webhook Idempotency

Same webhook event delivered multiple times does not duplicate business effects.

## AC-PAY-04 — Invalid Signature

Unauthenticated/invalid provider event is rejected without state mutation.

---

# 17. Public Security Tests

## AC-PUB-01 — Enumeration

Invalid/other guest token cannot enumerate invitation parties, guests, or workspace resources.

## AC-PUB-02 — Token Scope

Valid token for invitation party A cannot access guest B.

## AC-PUB-03 — No Anonymous Table Browsing

Anonymous client cannot perform unrestricted SELECT on private business tables.

## AC-PUB-04 — Minimum Disclosure

Public responses contain only data required by the public use case.

---

# 18. API Contract Tests

For every endpoint:

1. HTTP method/path matches contract.
2. Request schema validation matches contract.
3. Required auth context is enforced.
4. Permission/scope is enforced.
5. Response shape matches contract.
6. Error category matches defined semantics.
7. Idempotency semantics match where required.
8. No undocumented privileged field is accepted.

Mutation tests must include malicious extra fields such as:

```text
organization_id
workspace_id
event_id
role_id
owner_id
```

where those fields are not caller-controlled.

---

# 19. Domain State Machine Tests

Every declared state machine must test:

```text
valid transition
invalid transition
repeated transition
authorized transition
unauthorized transition
domain invariant failure
transaction rollback
```

### Invitation

```text
DRAFT → PUBLISHED
PUBLISHED/SENT → CANCELLED
```

Invalid backward mutation must be rejected.

### Invitation Token

```text
ACTIVE → REVOKED
ACTIVE → EXPIRED
```

Revoked/expired token cannot become active through ordinary mutation.

### RSVP

```text
PENDING → ACCEPTED
PENDING → DECLINED
```

Invalid attendee count must reject transition.

### Check-in

```text
NOT_CHECKED_IN → CHECKED_IN
CHECKED_IN → valid correction state
```

Duplicate check-in is idempotent.

### Souvenir

```text
ELIGIBLE → PARTIALLY_CLAIMED
PARTIALLY_CLAIMED → EXHAUSTED
```

No claim from exhausted state.

### Website

```text
DRAFT → PUBLISHED_VERSION
```

Published version immutable.

Workspace/Event final lifecycle vocabulary remains deferred and must not be invented by tests until finalized.

---

# 20. Idempotency Test Matrix

Required at minimum for:

```text
check-in
souvenir claim
invitation send
payment webhook
other critical retryable commands
```

Cases:

| Case | Expected |
|---|---|
| first request | execute |
| exact retry | equivalent existing result |
| same key + different payload | reject conflict |
| concurrent same operation | one logical result |
| failed before commit | safe retry |
| failed external side effect | retry-safe according to integration policy |

---

# 21. Concurrency Test Matrix

### Souvenir
- N simultaneous claims against entitlement N;
- N+1 simultaneous claims against entitlement N;
- duplicate idempotency requests;
- different claims with competing quantities.

### Check-in
- simultaneous scans for same event guest;
- repeated scans after success.

### RBAC
- role revoke while mutation begins;
- membership removal followed by access attempt.

### Website
- two publish operations;
- edit draft while publishing.

Expected outcome is always a valid committed state.

---

# 22. Security / Abuse Tests

Must test:

```text
horizontal privilege escalation
vertical privilege escalation
tenant ID tampering
workspace ID tampering
event ID tampering
role ID tampering
mass assignment
ID enumeration
token brute-force resistance at application boundary
rate-limit behavior
credential leakage
stack-trace leakage
SQL error leakage
public data overexposure
```

Exact numeric rate limits remain implementation/hardening decisions.

---

# 23. Realtime Tests

Realtime authorization must reuse the same authorization source of truth.

Test:

1. authorized subscription succeeds;
2. unauthorized scope subscription fails;
3. cross-tenant channel access fails;
4. role/membership change causes required unsubscribe/revocation behavior;
5. reconnect triggers authoritative snapshot resync where specified;
6. realtime payload does not expose unauthorized sensitive data;
7. photo/media events use references/URLs rather than broadcasting binary payloads where the architecture requires it.

The source design explicitly requires reconnect resync because realtime delivery is not replayable, and subscription authorization is not continuously re-evaluated on an already-open connection.

---

# 24. Reliability / Resilience Tests

Simulate:

```text
database timeout
provider timeout
provider 5xx
network interruption
client reconnect
duplicate webhook
duplicate command
transaction rollback
background worker retry
```

Expected:
- no corrupted current state;
- no unintended duplicate critical effect;
- recoverable operations remain retry-safe;
- audit evidence remains coherent.

---

# 25. Backup / Recovery Acceptance

Production readiness must include:

1. backup configuration verified;
2. restore procedure documented;
3. restore successfully tested;
4. migration-aware recovery tested;
5. destructive migration recovery path understood.

Exact RPO/RTO/retention remain deferred until formally decided.

---

# 26. Performance Tests

Performance testing should cover:

- tenant-aware list queries;
- authorization/scope resolution;
- guest/invitation search;
- event guest lookup;
- check-in hot path;
- souvenir claim hot path;
- dashboard current-state reads;
- large export/import flows;
- realtime reconnect snapshot.

Do not invent hard latency targets in this document where source has not established them. Baseline performance targets must be approved in performance testing/hardening.

---

# 27. Scalability Tests

Verify:

- large guest collections remain paginated;
- exports do not require unbounded memory;
- authorization does not degrade through repeated per-row expensive queries;
- tenant-aware indexes are used;
- history/log volume does not break hot current-state queries;
- high-volume operations remain safe under concurrency.

---

# 28. Observability Tests

Verify that important operations produce:

```text
request_id
operation
result
latency
safe actor/tenant context
security event where required
```

Verify that logs do NOT contain:

```text
passwords
access tokens
service-role keys
raw provider secrets
unredacted sensitive payloads
```

---

# 29. Regression Strategy

Before every release:

```text
Schema migration tests
→ RLS tests
→ Domain tests
→ API contract tests
→ Critical integration tests
→ Security regression
→ E2E smoke
```

Critical business flows must run in CI.

---

# 30. Release Blocking Conditions

Release must be blocked when any of these fail:

1. cross-tenant isolation;
2. RLS security;
3. unauthorized role escalation;
4. public token isolation;
5. check-in duplicate/concurrency safety;
6. souvenir entitlement/concurrency safety;
7. idempotency of critical commands;
8. payment webhook verification/idempotency;
9. published-version immutability;
10. audit/security evidence for required actions;
11. secret/log redaction;
12. backup restore verification for production release.

---

# 31. Traceability Matrix

| Upstream | Testing Coverage |
|---|---|
| PRD | feature/use-case acceptance |
| ADR | architecture/security invariants |
| Physical Schema | constraints, FK, uniqueness, transaction integrity |
| Authorization + RLS | RBAC, tenant, scope, client, public access |
| API Contract | request/response/error contract |
| Domain Services + Business Rules | invariants, transaction boundaries, domain commands |
| Use Cases + State Machines | actor flows, valid/invalid transitions |
| Security + NFR | security, abuse, reliability, performance, recovery |

Every critical requirement must map to at least one automated or executable test.

---

# 32. Coding Agent Guardrails

Coding agent MUST NOT mark work complete based solely on:

```text
UI works
+
endpoint returns 200
```

It must verify the relevant:

```text
authorization
RLS
business invariant
state transition
idempotency
concurrency
audit
error behavior
```

Coding agent MUST NOT delete or weaken tests to make a feature pass.

Missing test coverage for a critical invariant is a release gap, not permission to ignore the invariant.

---

# 33. Deferred Decisions

Tests must not invent final behavior for:

- exact public RSVP expiry;
- exact client writable fields;
- detailed platform support authority;
- exact billing feature matrix;
- exact offline/degraded check-in behavior;
- exact audit retention;
- exact provider retry/timeout policy;
- exact rate-limit numbers;
- exact uptime SLA;
- exact RPO/RTO;
- exact backup retention;
- formal regulatory compliance target;
- final Workspace/Event lifecycle vocabulary where upstream has not fixed it.

Affected acceptance criteria should remain explicitly marked until those decisions are finalized.

---

# 34. Final Acceptance Principle

```text
Requirement
    ↓
Use Case
    ↓
Domain Rule
    ↓
Security/Authorization
    ↓
Database Integrity
    ↓
Automated Test
    ↓
Release Gate
```

Core principle:

> Setiap requirement penting harus memiliki bukti yang dapat diuji. Untuk domain kritis, “berfungsi” berarti bukan hanya happy path berjalan, tetapi juga tenant isolation, authorization, invariant, state transition, idempotency, concurrency, auditability, dan failure behavior tetap benar.

---

## Status

**Testing + Acceptance Criteria v0.1 — Baseline complete.**
