# Premium Wedding SaaS — Domain Services + Business Rules

**Document ID:** PWS-DSBR-001  
**Version:** 0.1  
**Status:** Baseline Domain Service & Business Rule Specification  
**Date:** 2026-08-28  
**Upstream:** PRD, Release Roadmap, Domain/Core/RBAC, ADR, Physical Database Schema, Authorization + RLS, API Contract  
**Downstream:** Use Cases + State Machines, Security + NFR, Testing + Acceptance Criteria, Engineering / Implementation Blueprint

---

## 1. Purpose

Dokumen ini mendefinisikan lapisan **Domain Services** dan **Business Rules** setelah API Contract.

Tujuannya:

- menerjemahkan endpoint/API menjadi command dan query domain;
- menetapkan aggregate boundary dan ownership boundary;
- menetapkan invariant yang wajib selalu benar;
- menetapkan transaction boundary untuk operasi kritis;
- memisahkan domain rules dari authorization/RLS;
- menetapkan side effects yang harus terjadi setelah state berhasil berubah;
- mencegah coding agent mengubah business rules menjadi CRUD biasa;
- menjadi baseline untuk Use Cases dan State Machines.

Dokumen ini **tidak** mengunci framework, ORM, transport, controller, queue product, atau SQL implementation detail.

---

# 2. Architectural Position

Dependency chain:

```text
PRD
 ↓
Release Roadmap
 ↓
Domain + Core Data + Multi-Tenant/RBAC
 ↓
ADR
 ↓
Physical Database Schema
 ↓
Authorization + RLS
 ↓
API Contract
 ↓
THIS DOCUMENT
 ↓
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

Core rule:

> API menjelaskan boundary kontrak. Domain Service menjelaskan perilaku bisnis. Business Rule menentukan kondisi valid/tidak valid. Persistence hanya menyimpan hasil keputusan domain.

---

# 3. Source-Derived Constraints

Business rules di bawah harus konsisten dengan source berikut:

- Organization adalah tenant boundary.
- Workspace adalah wedding/client project boundary.
- Guest identity scoped per workspace.
- Event participation menggunakan association `event_guest`.
- RSVP memiliki current state dan history bila diperlukan.
- Check-in harus idempotent.
- Invitation Party memiliki satu primary guest dan satu QR per Invitation Party.
- Souvenir entitlement default mengikuti invited count, dapat di-override dengan permission + reason.
- Souvenir claim harus atomic, idempotent, dan tidak boleh melebihi entitlement.
- Proxy claim membutuhkan staff confirmation.
- Website published versions immutable.
- SaaS billing terpisah dari wedding payment/gift.
- RBAC, scope, ownership, dan domain validation adalah lapisan berbeda.
- Daily plotting adalah source of truth untuk domain operasional yang memang menggunakannya; default profile bukan fallback operational assignment.

Physical schema mengunci invariant guest/invitation/RSVP/check-in/souvenir/website/RBAC tersebut. Domain/Core juga menetapkan current-state/history, explicit ownership, dan server-side enforcement sebagai fondasi. 

---

# 4. Domain Layering

Recommended application structure:

```text
API / Transport
      ↓
Application Use Case
      ↓
Authorization Context
      ↓
Domain Service / Aggregate Command
      ↓
Domain Invariants
      ↓
Repository / Transaction Boundary
      ↓
Persistence
      ↓
Outbox / Side Effect Dispatch where required
```

### Separation

**Authorization** menjawab:

```text
Siapa boleh melakukan apa pada scope mana?
```

**Domain Service** menjawab:

```text
Apakah operasi tersebut valid secara bisnis dan bagaimana state berubah?
```

Kedua layer wajib sukses.

---

# 5. Aggregate Principles

Aggregate dipilih berdasarkan boundary invariant, bukan semata-mata satu tabel.

## 5.1 Organization Aggregate

Primary concerns:

- organization lifecycle;
- membership/role administration;
- organization settings;
- organization-level subscription relationship.

## 5.2 Workspace Aggregate

Primary concerns:

- wedding/client project identity;
- workspace lifecycle;
- wedding profile;
- website root configuration.

## 5.3 Event Aggregate

Primary concerns:

- event identity;
- event lifecycle;
- venue/schedule references;
- event-level guest scope.

## 5.4 Guest / Invitation Context

Guest identity dan invitation party memiliki relationship kuat, tetapi tidak boleh dipaksa menjadi satu giant aggregate.

Critical invariants:

```text
Guest
 ↓
Invitation Party
 ↓
Invitation / Token
```

## 5.5 Event Participation Aggregate

Conceptual relationship:

```text
Guest + Event
      ↓
Event Guest
      ├── RSVP current state
      ├── RSVP history
      ├── Seating assignment
      └── Check-in records
```

## 5.6 Souvenir Claim Aggregate

```text
Invitation Party
      ↓
Souvenir Entitlement
      ├── Override History
      └── Claim History
```

Claim concurrency must be protected inside the transaction boundary.

## 5.7 Website Aggregate

```text
Website
 ├── Draft configuration
 └── Website Versions
       └── Published Version(s)
```

Published version is immutable.

---

# 6. Domain Service Catalog

The service names below are logical boundaries. Implementation may use classes/modules/functions with different names as long as semantics remain identical.

## 6.1 Organization Services

- `OrganizationLifecycleService`
- `OrganizationMembershipService`
- `RoleManagementService`
- `ClientAccessService`

Responsibilities:

```text
create organization
update allowed organization attributes
add/remove member
assign/revoke role
grant/revoke client access
```

Security-sensitive role/membership operations must use explicit authorization and produce audit evidence.

## 6.2 Workspace Services

- `WorkspaceLifecycleService`
- `WeddingProfileService`
- `WorkspaceSettingsService`

Rules include deterministic organization ownership.

## 6.3 Guest Services

- `GuestService`
- `GuestMergeService`
- `GuestGroupService`
- `GuestRelationshipService`

Guest identity remains workspace-scoped.

## 6.4 Event Services

- `EventLifecycleService`
- `EventGuestService`
- `VenueService`

`event_guest` is the association boundary for event participation.

## 6.5 RSVP Services

- `RsvpService`
- `RsvpHistoryService`

Responsibilities:

```text
submit RSVP
update current RSVP
record response history where required
validate attendee count
```

## 6.6 Seating Services

- `SeatingPlanService`
- `SeatingAssignmentService`

Responsibilities:

```text
create/update seating plan
manage tables
assign guest to table/seat
validate capacity/conflicts
```

## 6.7 Check-in Services

- `CheckinService`
- `CheckinCorrectionService`

Critical requirements:

```text
idempotency
exactly one successful check-in per event_guest
correction is explicit and auditable
```

## 6.8 Invitation Services

- `InvitationService`
- `InvitationPartyService`
- `InvitationTokenService`
- `InvitationDeliveryService`

Responsibilities:

```text
create/update invitation
publish invitation
issue/revoke access token
send invitation
record delivery outcome
```

Token is a security credential and must not be treated as ordinary content.

## 6.9 Souvenir Services

- `SouvenirEntitlementService`
- `SouvenirClaimService`
- `SouvenirProxyClaimService`

These services contain the strongest transaction/concurrency requirements in the current schema.

## 6.10 Website Services

- `WebsiteDraftService`
- `WebsitePublishService`
- `WebsiteVersionService`

Publishing must create immutable published version state rather than mutating the already-published version.

## 6.11 Media Services

- `MediaAssetService`
- `MediaModerationService`

This document defines only domain boundaries; storage implementation is downstream.

## 6.12 Communication Services

- `MessageTemplateService`
- `CampaignService`
- `MessageDispatchService`

External delivery is a side effect; source-of-truth message/campaign state remains internal.

## 6.13 Gift / Registry Services

- `GiftConfigurationService`
- `GiftTransactionService`
- `GiftReconciliationService`

Wedding gift/payment remains separate from SaaS billing.

## 6.14 Billing Services

- `SubscriptionService`
- `InvoiceService`
- `BillingPaymentService`
- `PaymentWebhookService`

Verified payment state comes from provider webhook/event processing, not browser redirect.

## 6.15 Audit Services

- `ActivityLogService`
- `SecurityAuditService`

Audit is evidence, not authorization source.

---

# 7. Cross-Cutting Domain Services

## 7.1 OwnershipResolver

Purpose:

```text
resolve deterministic organization/workspace/event ownership path
```

It must not invent ownership from client-supplied IDs.

## 7.2 IdempotencyService

Used for critical commands:

```text
check-in
souvenir claim
invitation send
critical webhook processing
```

Rule:

```text
same key + same logical request
→ same business result

same key + different logical request
→ reject
```

## 7.3 ConcurrencyGuard

Used for critical aggregate mutation where optimistic locking alone is insufficient.

Mandatory for souvenir claim.

## 7.4 DomainClock

Time-dependent rules must use an injectable/domain clock rather than scattered direct system-time calls.

This makes lifecycle and expiry behavior testable.

---

# 8. Global Business Rules

These rules apply across the product.

### BR-GEN-01 — Tenant Isolation

A private business entity must belong to exactly one organization ownership path.

### BR-GEN-02 — Explicit Ownership

Ownership cannot be inferred from untrusted client parameters.

### BR-GEN-03 — Authorization Precondition

A valid authentication context alone never implies permission.

### BR-GEN-04 — Scope Precondition

Permission must apply to the target organization/workspace/event scope.

### BR-GEN-05 — Current State vs History

Do not rewrite historical evidence merely to simplify current-state reads.

### BR-GEN-06 — Critical Commands Are Idempotent

Critical externally retriable commands must define idempotency behavior.

### BR-GEN-07 — Domain Validation Survives UI Validation Failure

Server/domain layer is the final business-rule validator.

### BR-GEN-08 — Ownership Reassignment Is Not Ordinary CRUD

Changing tenant ownership or aggregate ownership requires an explicit domain workflow or is prohibited.

### BR-GEN-09 — Audit Security-Sensitive Mutations

Role, access, critical correction, entitlement override, and similar operations require audit evidence where specified.

### BR-GEN-10 — Deferred Decisions Stay Deferred

A coding agent must not silently invent unresolved product decisions.

---

# 9. Organization Rules

### BR-ORG-01
Organization is the tenant boundary.

### BR-ORG-02
A membership is active only while its status/state permits access under authorization rules.

### BR-ORG-03
Removing membership removes effective staff access.

### BR-ORG-04
Role assignment cannot cross organizations.

### BR-ORG-05
A caller cannot grant authority above its permitted delegation boundary.

### BR-ORG-06
Client access is not staff membership.

### BR-ORG-07
Organization-level security changes are auditable.

---

# 10. Workspace Rules

### BR-WS-01
Workspace belongs to exactly one organization.

### BR-WS-02
Workspace ownership is not changed through ordinary CRUD.

### BR-WS-03
Workspace-scoped role access does not imply access to another workspace.

### BR-WS-04
Child workspace resources must resolve ownership back to the same organization.

### BR-WS-05
For MVP, workspace is the primary wedding/client project boundary.

---

# 11. Wedding / Couple Rules

### BR-WED-01
Wedding profile is workspace-owned.

### BR-WED-02
Couple/client access is limited by client access policy and is not inherited from staff RBAC.

### BR-WED-03
Client-visible information is intentionally narrower than staff operational data.

Any exact client-editable field not already defined by the source remains a downstream use-case decision.

---

# 12. Event Rules

### BR-EVT-01
An event belongs to one workspace.

### BR-EVT-02
Event scope cannot cross its workspace ownership.

### BR-EVT-03
Event participation is represented through `event_guest`.

### BR-EVT-04
A guest participating in multiple events must not be duplicated as multiple guest identities merely to model participation.

---

# 13. Guest Rules

### BR-GST-01
Guest identity is scoped per workspace.

### BR-GST-02
Name/email/phone are not assumed to be global unique identity.

### BR-GST-03
Duplicate guest handling requires an explicit merge/split workflow where supported.

### BR-GST-04
Guest merge must preserve valid invitation/RSVP/check-in history and must not silently destroy evidence.

### BR-GST-05
Guest deletion, where permitted, must respect dependent domain records and retention/audit rules.

---

# 14. Invitation Party Rules

### BR-IP-01
Invitation Party is the business unit represented by one invitation QR.

### BR-IP-02
One QR = one Invitation Party.

### BR-IP-03
Invitation Party has one primary guest reference.

### BR-IP-04
Invitation token is not equivalent to staff authorization.

### BR-IP-05
Public token access is limited to the invitation context and allowed guest-facing resources.

### BR-IP-06
Token must be non-guessable and revocable/expirable according to the downstream public-access policy.

---

# 15. Invitation Rules

### BR-INV-01
Invitation lifecycle state is separate from guest identity.

### BR-INV-02
Publishing an invitation is a domain transition, not a generic status update.

### BR-INV-03
Sending an invitation may create external side effects and therefore requires idempotency semantics.

### BR-INV-04
Delivery state/history must not overwrite evidence needed for troubleshooting.

### BR-INV-05
External provider response must be translated into internal domain state; provider-specific payload must not become the product's primary domain model.

---

# 16. RSVP Rules

### BR-RSVP-01
There is one current RSVP state per `event_guest`.

### BR-RSVP-02
RSVP changes may append history when response history has business/audit value.

### BR-RSVP-03
Attendee count must obey the constraints defined by the physical schema/domain rules.

### BR-RSVP-04
RSVP state changes are domain commands, not unrestricted field patching.

### BR-RSVP-05
Public RSVP update/expiry timing remains deferred until the dedicated Use Case/Security specification.

---

# 17. Seating Rules

### BR-SEAT-01
Seating assignment must reference a valid event participation context.

### BR-SEAT-02
A guest cannot be assigned to incompatible seating allocations for the same seating plan.

### BR-SEAT-03
Table capacity/conflict validation is server-side.

### BR-SEAT-04
Concurrent seating edits must use an explicit conflict strategy where the aggregate is versioned.

---

# 18. Check-in Rules

### BR-CI-01
Only event guests belonging to the target event are eligible for check-in.

### BR-CI-02
One successful check-in per event guest.

### BR-CI-03
Duplicate scans are idempotent.

### BR-CI-04
Check-in mutation must be atomic with its current-state update.

### BR-CI-05
Correction is a separate privileged action.

### BR-CI-06
Correction must preserve audit evidence and must not erase the fact that an earlier check-in occurred.

### BR-CI-07
The check-in flow must not rely on UI-only duplicate prevention.

---

# 19. Souvenir Entitlement Rules

### BR-SOUV-01
Default entitlement equals `invited_person_count` unless a valid override exists.

### BR-SOUV-02
`invited_person_count`, `actual_attendee_count`, and `souvenir_entitlement` are distinct concepts.

### BR-SOUV-03
Entitlement override requires explicit permission.

### BR-SOUV-04
Entitlement override requires a non-empty reason.

### BR-SOUV-05
Final entitlement cannot be reduced below already claimed quantity.

### BR-SOUV-06
Override history is preserved.

---

# 20. Souvenir Claim Rules

### BR-CLAIM-01
Claim quantity must be positive.

### BR-CLAIM-02
Claim quantity cannot exceed remaining entitlement.

### BR-CLAIM-03
Claim is atomic.

### BR-CLAIM-04
Concurrent claims cannot collectively exceed final entitlement.

### BR-CLAIM-05
Claim is idempotent for the same logical retry.

### BR-CLAIM-06
Same idempotency key with materially different command is rejected.

### BR-CLAIM-07
Entitlement exhaustion results in deny/failure.

### BR-CLAIM-08
Claim history is retained as evidence.

### BR-CLAIM-09
Claim must be evaluated against effective entitlement at transaction time.

### BR-CLAIM-10
Possession of an invitation QR does not grant staff-only override or correction authority.

---

# 21. Proxy Souvenir Claim Rules

### BR-PROXY-01
Proxy claim is a distinct command from ordinary guest self-claim.

### BR-PROXY-02
Proxy claim requires staff authorization.

### BR-PROXY-03
Staff confirmation is mandatory.

### BR-PROXY-04
Proxy claim must satisfy the same entitlement/concurrency invariants as ordinary claim.

### BR-PROXY-05
Proxy metadata must be preserved sufficiently for audit/evidence.

---

# 22. Website Rules

### BR-WEB-01
MVP supports one website root per workspace.

### BR-WEB-02
Draft changes must not mutate an already published immutable version.

### BR-WEB-03
Publishing creates a new published version boundary.

### BR-WEB-04
Published version is immutable after publication.

### BR-WEB-05
Public website read path may differ from staff draft management path.

---

# 23. Media Rules

### BR-MEDIA-01
Media belongs to its owning workspace/domain context.

### BR-MEDIA-02
Media visibility must follow authorization policy.

### BR-MEDIA-03
Delete/moderation operations are explicit domain commands where business evidence matters.

### BR-MEDIA-04
Storage-provider identifiers do not replace domain media identity.

---

# 24. Communication Rules

### BR-MSG-01
Message/campaign state is owned internally; external delivery is a side effect.

### BR-MSG-02
Send operations are idempotent where retries could create duplicate external messages.

### BR-MSG-03
Delivery attempts/history are preserved when needed for operational troubleshooting.

### BR-MSG-04
Template management is distinct from message delivery.

---

# 25. Gift / Registry Rules

### BR-GIFT-01
Wedding gift/payment is separate from SaaS billing.

### BR-GIFT-02
Gift transaction state must not be inferred from SaaS invoice/payment state.

### BR-GIFT-03
Reconciliation is an explicit domain operation.

### BR-GIFT-04
Verified external payment state must originate from trusted provider event/webhook processing where applicable.

---

# 26. Billing Rules

### BR-BILL-01
SaaS billing is organization-owned.

### BR-BILL-02
Subscription and invoice lifecycles are separate from wedding gift/payment.

### BR-BILL-03
Provider-specific payment state must be normalized into internal billing state.

### BR-BILL-04
Browser redirect is not source of truth for payment verification.

### BR-BILL-05
Webhook/event processing must be idempotent.

### BR-BILL-06
RBAC permission and subscription entitlement remain separate concerns.

---

# 27. Role / Client Access Rules

### BR-AUTH-01
Role determines capabilities; scope determines where those capabilities apply.

### BR-AUTH-02
Multiple active roles can contribute to effective permissions.

### BR-AUTH-03
Effective permissions are the union of valid role grants applicable to the target scope.

### BR-AUTH-04
Scoped roles do not implicitly escalate to broader scopes.

### BR-AUTH-05
Client access does not inherit staff role permissions.

### BR-AUTH-06
Self-escalation is prohibited.

### BR-AUTH-07
Cross-tenant role assignment is prohibited.

### BR-AUTH-08
Removing membership removes effective staff access.

---

# 28. Operational Scope Rules

### BR-SCOPE-01
Operational assignment mengikuti scope Organization, Workspace, dan Event.

### BR-SCOPE-02
Event-scoped actor tidak dapat melakukan aksi pada Event lain tanpa assignment valid.

### BR-SCOPE-03
Workspace-scoped actor tidak memperoleh akses organization-wide secara implisit.

### BR-SCOPE-04
MVP tidak menggunakan daily plotting, PDO, depot, rute, atau shift operasional.

---

# 29. Transaction Boundaries

## 29.1 Single-Aggregate Transaction

Use one transaction when an invariant spans a single aggregate and its immediate owned records.

Examples:

```text
create/update event
update current RSVP + history
publish website version
create check-in
```

## 29.2 Critical Claim Transaction

Souvenir claim requires:

```text
load effective entitlement
        ↓
validate remaining quantity
        ↓
reserve/update claim state
        ↓
write claim evidence
        ↓
commit atomically
```

Concurrency control must make the invariant true under concurrent requests.

## 29.3 External Side Effects

Do not hold a database transaction open while waiting on an external provider unless the integration explicitly requires it.

Preferred pattern:

```text
commit internal state
   ↓
outbox/domain event
   ↓
external side effect
   ↓
record outcome
```

Implementation mechanism may vary; semantics must preserve retryability and evidence.

---

# 30. Domain Events / Side Effects

Domain events should represent meaningful state transitions, not every column update.

Candidate events:

```text
OrganizationMemberAdded
OrganizationMemberRemoved
RoleChanged
ClientAccessGranted
ClientAccessRevoked
WorkspaceCreated
GuestCreated
GuestMerged
InvitationPublished
InvitationSent
InvitationTokenRevoked
RsvpSubmitted
RsvpChanged
SeatingAssignmentChanged
CheckinCreated
CheckinCorrected
SouvenirEntitlementOverridden
SouvenirClaimCreated
SouvenirProxyClaimCreated
WebsitePublished
SubscriptionChanged
BillingPaymentVerified
```

Events are internal integration signals. They do not replace current-state persistence or authorization checks.

---

# 31. Side-Effect Rules

### SE-01
Domain state must be committed before non-transactional external side effects where possible.

### SE-02
External side effects must be retry-safe.

### SE-03
Provider callbacks/webhooks must be idempotent.

### SE-04
A failed notification/send must not roll back an already-valid core domain mutation unless the business rule explicitly defines the external action as a hard prerequisite.

### SE-05
If a feature explicitly defines an external operation as a hard prerequisite, its transaction/use-case contract must state that clearly.

---

# 32. Error Taxonomy

Domain errors should be semantic rather than database-error-shaped.

Recommended categories:

```text
AUTHORIZATION_DENIED
RESOURCE_NOT_FOUND_OR_HIDDEN
INVALID_STATE_TRANSITION
VALIDATION_FAILED
INVARIANT_VIOLATION
CONFLICT
IDEMPOTENCY_CONFLICT
ENTITLEMENT_EXHAUSTED
CONCURRENCY_CONFLICT
EXTERNAL_PROVIDER_FAILURE
DEPENDENCY_UNAVAILABLE
```

API maps these categories to HTTP response codes according to the API/Security contract.

---

# 33. Forbidden Domain Anti-Patterns

Coding agent MUST NOT:

1. implement domain behavior as arbitrary controller-to-table CRUD;
2. rely on frontend validation for invariants;
3. recalculate current state by replaying history on every request when a current-state field exists;
4. delete audit evidence as part of correction;
5. use raw provider objects as permanent domain entities without translation;
6. make public token itself equal to a business entity UUID secret;
7. implement souvenir claim as read-then-write without concurrency protection;
8. make check-in non-idempotent;
9. mutate immutable published website versions;
10. combine SaaS billing and wedding gift payment semantics;
11. silently invent deferred client/public RSVP rules;
12. bypass operational scope Organization → Workspace → Event;
13. create a second authorization system separate from the accepted authorization contract;
14. change accepted business invariants without ADR/addendum.

---

# 34. Domain Service Acceptance Checklist

A domain service is implementation-ready only when:

```text
[ ] Aggregate boundary identified
[ ] Ownership path identified
[ ] Authorization prerequisite identified
[ ] Command/query semantics identified
[ ] Input/domain validation identified
[ ] Business invariants identified
[ ] Transaction boundary identified
[ ] Concurrency behavior identified where needed
[ ] Idempotency behavior identified where needed
[ ] Audit requirement identified
[ ] Side effects identified
[ ] Retry behavior identified
[ ] Failure semantics identified
[ ] Deferred decisions not silently invented
```

---

# 35. Traceability to API Contract

API commands must resolve into domain operations.

Examples:

```text
POST /invitations/{id}/publish
    → InvitationService.publish()

POST /events/{id}/check-ins
    → CheckinService.create()

POST /invitation-parties/{id}/souvenir-claims
    → SouvenirClaimService.claim()

POST /invitation-parties/{id}/souvenir-entitlement/overrides
    → SouvenirEntitlementService.override()

POST /invitation-parties/{id}/souvenir-claims/proxy
    → SouvenirProxyClaimService.proxyClaim()

POST /websites/{id}/publish
    → WebsitePublishService.publish()
```

The exact method names are not public API. They are logical domain boundaries.

---

# 36. Traceability to Physical Schema

Important mapping:

```text
Organization
 → organization
 → organization_member
 → role / permission / member_role

Workspace
 → workspace
 → wedding_profile

Guest
 → guest
 → event_guest

Invitation
 → invitation_party
 → invitation
 → invitation_token
 → invitation_delivery/history

RSVP
 → rsvp
 → rsvp_response_history

Check-in
 → checkin_record

Souvenir
 → souvenir_entitlement
 → souvenir_entitlement_override
 → souvenir_claim

Website
 → website
 → website_version
 → website_section

Billing
 → subscription
 → invoice
 → billing_payment_transaction
```

Persistence model may contain additional technical tables; those do not automatically become domain services.

---

# 37. Explicitly Deferred Rules

The following remain intentionally deferred because upstream source does not provide final product semantics:

| Topic | Status |
|---|---|
| Exact public RSVP update/expiry window | Deferred |
| Exact client writable fields | Open |
| Detailed platform support authority model | Deferred |
| Exact billing feature matrix | Deferred |
| Exact offline/degraded check-in behavior | Deferred |
| Exact audit retention | Deferred |
| Exact provider retry/timeout policy | Deferred |
| Final 403 vs 404 mapping | Deferred |
| Exact pagination/rate limits | Deferred |

Use Cases + State Machines and Security/NFR must resolve these before implementation of affected flows.

---

# 38. Next Document

```text
Domain Services + Business Rules
        ↓
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

Next required artifact:

**`Premium_Wedding_SaaS_Use_Cases_State_Machines_v0.1.md`**

This document must convert the business rules above into actor-driven use cases, preconditions, main flows, alternate/error flows, state transition tables, and acceptance-oriented invariants.

---

# 39. Status

**Domain Services + Business Rules v0.1 — Baseline complete.**

No new architecture decision is required to proceed to Use Cases + State Machines, provided deferred product decisions are resolved only where the affected use case requires them.
