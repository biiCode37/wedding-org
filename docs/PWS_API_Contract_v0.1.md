# Premium Wedding SaaS — API Contract v0.1

**Document ID:** PWS-API-001  
**Version:** 0.1  
**Status:** Baseline API Contract — Draft for Implementation  
**Date:** 2026-08-28  

---

## 1. Purpose

Dokumen ini menerjemahkan Physical Database Schema dan Authorization + RLS Specification menjadi kontrak API yang stabil untuk implementation.

API Contract menetapkan:

- API boundary;
- resource naming;
- authentication context;
- authorization boundary;
- request/response envelope;
- identifiers;
- pagination/filtering/sorting;
- validation semantics;
- mutation semantics;
- idempotency;
- optimistic concurrency;
- public guest access;
- check-in;
- souvenir entitlement/claim;
- auditability;
- error contract;
- versioning;
- operational scope.

Dokumen ini **tidak** mengunci implementasi framework, SQL/RLS migration, internal service classes, UI behavior, payment provider, atau detail business rules yang memang masih downstream.

---

# 2. Source Baseline

API Contract wajib konsisten dengan:

1. `Premium_Wedding_SaaS_PRD_v0.1.md`
2. `Premium_Wedding_SaaS_Release_Roadmap_and_Zero_Cost_Strategy_v0.1.md`
3. `Premium_Wedding_SaaS_Domain_Core_Data_MultiTenant_RBAC_v0.1.md`
4. `Premium_Wedding_SaaS_Architecture_Decision_Record_v0.1.md`
5. `Premium_Wedding_SaaS_Physical_Database_Schema_v0.1.md`
6. `Premium_Wedding_SaaS_Authorization_RLS_Specification_v0.1.md`
7. Operational scope khusus wedding ditentukan oleh Event dan assignment yang disetujui; tidak ada daily plotting pada MVP.

Source decisions yang tidak boleh dilanggar:

- Organization = tenant boundary.
- Workspace = wedding/client project pada MVP.
- Client access terpisah dari staff RBAC.
- Multiple roles diperbolehkan.
- Role dan scope berbeda.
- Organization → Workspace → Event adalah scope hierarchy foundation.
- Server-side authorization wajib.
- RLS adalah defense-in-depth/database isolation.
- Public guest access terpisah dari staff RBAC.
- Public token harus non-guessable dan bukan raw database identifier.
- Public API menggunakan UUID sebagai external-safe identifier secara default.
- Critical actions harus idempotent.
- Current state dan history dipisahkan bila history memiliki business/audit value.
- Ownership harus deterministic.
- SaaS billing dan wedding payment adalah domain berbeda.

---

# 3. API Design Principles

## 3.1 Server-authoritative

Client tidak pernah menjadi source of truth untuk:

- tenant ownership;
- authorization;
- current status;
- entitlement;
- payment verification;
- check-in state;
- souvenir remaining quantity.

## 3.2 Resource-oriented

API menggunakan resource-oriented paths dan explicit action endpoints hanya bila action merupakan domain command, bukan CRUD biasa.

Contoh:

```text
GET    /v1/workspaces/{workspaceUuid}
PATCH  /v1/workspaces/{workspaceUuid}
POST   /v1/events/{eventUuid}/check-ins
POST   /v1/invitation-parties/{partyUuid}/souvenir-claims
```

## 3.3 Public vs authenticated API

Tiga context API:

```text
Authenticated Staff
Authenticated Client
Public Guest
```

Public guest context tidak boleh memperoleh staff authorization hanya karena mengetahui token.

---

# 4. Base URL and Versioning

Logical API root:

```text
/v1
```

Versioning dilakukan pada major API path.

Contoh:

```text
/v1/organizations
/v1/workspaces
/v1/events
```

Breaking changes membutuhkan versi API baru atau migration strategy eksplisit.

Non-breaking additions diperbolehkan:

- optional response fields;
- new filter parameters;
- new non-conflicting resources;
- new enum values hanya bila client compatibility sudah diperhitungkan.

---

# 5. Authentication Headers

Authenticated requests:

```http
Authorization: Bearer <supabase-access-token>
```

Critical mutating requests MAY use:

```http
Idempotency-Key: <opaque-key>
```

Optimistic concurrency MAY use:

```http
If-Match: <version-or-etag>
```

Correlation/request tracing:

```http
X-Request-ID: <client-request-id>
```

Server harus menghasilkan request ID bila caller tidak mengirimkannya.

---

# 6. Identity Contexts

## 6.1 Staff

```text
Supabase Auth
 → user profile
 → organization membership
 → roles
 → permissions
 → scope
```

## 6.2 Client

```text
Supabase Auth
 → user profile
 → client_access
 → workspace
 → client capability
```

## 6.3 Public Guest

```text
Invitation token
 → invitation party
 → allowed guest resource
```

Public guest token tidak digunakan sebagai general authentication token untuk private staff APIs.

---

# 7. Identifier Contract

Public resource identifier:

```text
{resourceUuid}
```

Default example:

```text
GET /v1/workspaces/5f6b...uuid...
```

Sequential database `id` tidak boleh menjadi default public identifier.

Internal `id` boleh digunakan internal service/database relation.

Public token/secret berbeda dari resource UUID.

---

# 8. Standard Response Envelope

## 8.1 Success

Single resource:

```json
{
  "data": {
    "uuid": "...",
    "name": "..."
  },
  "meta": {
    "request_id": "..."
  }
}
```

Collection:

```json
{
  "data": [],
  "meta": {
    "request_id": "...",
    "pagination": {
      "page": 1,
      "per_page": 25,
      "total": 100,
      "has_next": true
    }
  }
}
```

Command response:

```json
{
  "data": {
    "result": "..."
  },
  "meta": {
    "request_id": "..."
  }
}
```

API boleh mengubah pagination backend menjadi cursor-based pada resource dengan volume tinggi tanpa mengubah authorization semantics.

## 8.2 Empty mutation response

Untuk operation yang tidak membutuhkan representation baru:

```http
204 No Content
```

---

# 9. Standard Error Contract

Format:

```json
{
  "error": {
    "code": "RESOURCE_NOT_FOUND",
    "message": "Resource was not found.",
    "details": [],
    "request_id": "..."
  }
}
```

Canonical classes:

| HTTP | Code family | Meaning |
|---|---|---|
| 400 | `INVALID_REQUEST` | Malformed request |
| 401 | `UNAUTHENTICATED` | Authentication missing/invalid |
| 403 | `FORBIDDEN` | Authenticated but unauthorized |
| 404 | `RESOURCE_NOT_FOUND` | Resource unavailable/not disclosed |
| 409 | `CONFLICT` | State/concurrency/domain conflict |
| 422 | `VALIDATION_ERROR` | Semantically invalid payload |
| 429 | `RATE_LIMITED` | Rate limit exceeded |
| 500 | `INTERNAL_ERROR` | Unexpected server error |
| 503 | `SERVICE_UNAVAILABLE` | Temporary dependency/service failure |

Exact 403 vs 404 behavior remains security/API implementation policy. Cross-tenant resource existence must never be disclosed merely because the caller lacks access.

---

# 10. Validation Contract

Validation terjadi minimal pada tiga level:

```text
Schema validation
 → Authorization
 → Domain validation
```

Client-supplied:

```text
organization_id
workspace_id
ownership fields
permission/scope fields
```

tidak dianggap sebagai proof of authorization.

Unknown fields:

```text
Recommended: reject or ignore according to endpoint contract.
```

Untuk security-sensitive mutation, preferred behavior adalah strict schema rejection.

---

# 11. Pagination / Filtering / Sorting

Collection endpoints default:

```text
page=1
per_page=25
```

Recommended maximum:

```text
per_page <= 100
```

Filter parameters harus resource-specific.

Sorting harus memakai allowlisted fields.

Client tidak boleh mengirim arbitrary SQL field/expression sebagai sort/filter parameter.

Tenant scope selalu diterapkan server-side sebelum query result dikembalikan.

---

# 12. Core Resource API

## 12.1 Organizations

### GET `/v1/organizations`

Mengembalikan organization yang accessible oleh authenticated caller sesuai permission/scope.

### GET `/v1/organizations/{organizationUuid}`

Requires:

```text
organization.read
```

### PATCH `/v1/organizations/{organizationUuid}`

Requires:

```text
organization.update
```

Ownership/tenant cannot be changed through this endpoint.

---

# 13. Organization Membership

### GET `/v1/organizations/{organizationUuid}/members`

Requires:

```text
organization.members.read
```

### POST `/v1/organizations/{organizationUuid}/members`

Requires:

```text
organization.members.manage
```

### PATCH `/v1/organizations/{organizationUuid}/members/{memberUuid}`

Requires:

```text
organization.members.manage
```

### DELETE `/v1/organizations/{organizationUuid}/members/{memberUuid}`

Requires:

```text
organization.members.manage
```

Removal must revoke effective access.

Role changes are security-sensitive and require delegation-boundary validation.

---

# 14. Roles and Permissions

### GET `/v1/organizations/{organizationUuid}/roles`

Requires:

```text
organization.roles.read
```

### POST `/v1/organizations/{organizationUuid}/roles`

Requires:

```text
organization.roles.manage
```

### PATCH `/v1/organizations/{organizationUuid}/roles/{roleUuid}`

Requires:

```text
organization.roles.manage
```

### DELETE `/v1/organizations/{organizationUuid}/roles/{roleUuid}`

Requires:

```text
organization.roles.manage
```

System roles cannot be mutated through normal organization role CRUD.

Role assignment must prevent:

- self-escalation;
- cross-tenant assignment;
- invalid workspace/event scope;
- delegation beyond caller authority.

---

# 15. Workspaces

### GET `/v1/workspaces`

Returns only authorized workspaces for current context.

### POST `/v1/organizations/{organizationUuid}/workspaces`

Requires appropriate workspace creation permission.

Request example:

```json
{
  "name": "Wedding Budi & Sinta",
  "slug": "budi-sinta"
}
```

### GET `/v1/workspaces/{workspaceUuid}`

Requires:

```text
workspace.read
```

### PATCH `/v1/workspaces/{workspaceUuid}`

Requires:

```text
workspace.update
```

### POST `/v1/workspaces/{workspaceUuid}/archive`

Requires:

```text
workspace.archive
```

Workspace ownership/organization cannot be changed by ordinary CRUD.

---

# 16. Wedding Profile

### GET `/v1/workspaces/{workspaceUuid}/wedding-profile`

Requires:

```text
wedding.read
```

### PUT `/v1/workspaces/{workspaceUuid}/wedding-profile`

Requires:

```text
wedding.update
```

The endpoint updates the current workspace wedding profile representation.

---

# 17. Events

### GET `/v1/workspaces/{workspaceUuid}/events`

Requires:

```text
event.read
```

### POST `/v1/workspaces/{workspaceUuid}/events`

Requires:

```text
event.create
```

### GET `/v1/events/{eventUuid}`

Requires:

```text
event.read
```

### PATCH `/v1/events/{eventUuid}`

Requires:

```text
event.update
```

### DELETE `/v1/events/{eventUuid}`

Requires:

```text
event.delete
```

Event must always resolve to one workspace and organization.

---

# 18. Guests

### GET `/v1/workspaces/{workspaceUuid}/guests`

Requires:

```text
guest.read
```

Supported filters are resource-specific, e.g. status/group/tag.

### POST `/v1/workspaces/{workspaceUuid}/guests`

Requires:

```text
guest.create
```

Example:

```json
{
  "full_name": "Sinta",
  "email": "sinta@example.com",
  "phone": "+62..."
}
```

### GET `/v1/guests/{guestUuid}`

Requires:

```text
guest.read
```

### PATCH `/v1/guests/{guestUuid}`

Requires:

```text
guest.update
```

### DELETE `/v1/guests/{guestUuid}`

Requires:

```text
guest.delete
```

Delete semantics follow physical schema lifecycle policy; API must not assume global soft-delete.

### POST `/v1/workspaces/{workspaceUuid}/guests/import`

Requires:

```text
guest.import
```

### POST `/v1/workspaces/{workspaceUuid}/guests/export`

Requires:

```text
guest.export
```

### POST `/v1/guests/{guestUuid}/merge`

Requires:

```text
guest.merge
```

Merge is a domain command and must preserve invitation/RSVP/audit history according to downstream business rules.

---

# 19. Event Guest Assignment

### GET `/v1/events/{eventUuid}/guests`

Returns event-scoped guest associations, not duplicated guest identities.

### POST `/v1/events/{eventUuid}/guests`

Creates an `event_guest` association after validating guest/workspace same-tenant integrity.

### DELETE `/v1/events/{eventUuid}/guests/{eventGuestUuid}`

Removes/ends association according to domain lifecycle semantics.

Client cannot attach a guest from another workspace.

---

# 20. Invitations

### GET `/v1/workspaces/{workspaceUuid}/invitations`

Requires:

```text
invitation.read
```

### POST `/v1/workspaces/{workspaceUuid}/invitations`

Requires:

```text
invitation.create
```

### GET `/v1/invitations/{invitationUuid}`

Requires:

```text
invitation.read
```

### PATCH `/v1/invitations/{invitationUuid}`

Requires:

```text
invitation.update
```

### POST `/v1/invitations/{invitationUuid}/publish`

Requires:

```text
invitation.publish
```

### POST `/v1/invitations/{invitationUuid}/send`

Requires:

```text
invitation.send
```

This action should support idempotency protection where retries could duplicate delivery side effects.

### POST `/v1/invitations/{invitationUuid}/cancel`

Requires:

```text
invitation.cancel
```

---

# 21. Invitation Party and Public Token

### Authenticated staff: GET `/v1/invitation-parties/{partyUuid}`

Returns invitation-party data according to permission/scope.

### Public: GET `/v1/public/invitations/{token}`

The token resolves exactly one allowed invitation context.

Public response must expose only minimum required fields.

The endpoint must not allow enumeration of:

- all guests;
- all invitation parties;
- organization/workspace records;
- arbitrary UUIDs.

### Public RSVP

Logical endpoint:

```text
POST /v1/public/invitations/{token}/rsvp
```

or, when updating an existing response:

```text
PATCH /v1/public/invitations/{token}/rsvp
```

Exact expiry/update policy is intentionally deferred to Use Case + Security specification.

Public token is the authentication factor for this limited guest context only.

---

# 22. RSVP

### GET `/v1/events/{eventUuid}/rsvps`

Requires:

```text
rsvp.read
```

### GET `/v1/event-guests/{eventGuestUuid}/rsvp`

Requires:

```text
rsvp.read
```

### PATCH `/v1/event-guests/{eventGuestUuid}/rsvp`

Requires:

```text
rsvp.update
```

Current RSVP is authoritative for current state; response history remains a separate concern.

Repeated equivalent update may return current state without creating duplicate business side effects when the domain operation is idempotent.

---

# 23. Seating

### GET `/v1/events/{eventUuid}/seating`

Requires:

```text
seating.read
```

### PATCH `/v1/events/{eventUuid}/seating`

Requires:

```text
seating.update
```

### POST `/v1/events/{eventUuid}/seating/assignments`

Requires:

```text
seating.assign
```

### POST `/v1/events/{eventUuid}/seating/export`

Requires:

```text
seating.export
```

Server must validate capacity/conflicts; UI validation alone is insufficient.

Concurrent edits should support optimistic concurrency where the aggregate is configured for version checking.

---

# 24. Check-in

## 24.1 Read

### GET `/v1/events/{eventUuid}/check-ins`

Requires:

```text
checkin.read
```

### GET `/v1/event-guests/{eventGuestUuid}/check-in`

Requires:

```text
checkin.read
```

## 24.2 Create Check-in

### POST `/v1/events/{eventUuid}/check-ins`

Requires:

```text
checkin.create
```

Request example:

```json
{
  "event_guest_uuid": "...",
  "attendance_count": 2,
  "idempotency_key": "..."
}
```

Preferred idempotency can be header-based:

```http
Idempotency-Key: ...
```

Exactly one successful check-in per event guest is a domain invariant. Duplicate scan must be handled idempotently.

## 24.3 Correction

### POST `/v1/check-ins/{checkinUuid}/correct`

Requires:

```text
checkin.correct
```

Correction must be auditable.

---

# 25. Souvenir Entitlement

### GET `/v1/invitation-parties/{partyUuid}/souvenir-entitlement`

Returns current effective entitlement.

### POST `/v1/invitation-parties/{partyUuid}/souvenir-entitlement/overrides`

Requires explicit permission and reason.

Request:

```json
{
  "quantity": 4,
  "reason": "Additional approved entitlement"
}
```

Rules:

- default entitlement follows invited person count;
- entitlement is not automatically actual attendee count;
- final entitlement cannot be lower than already claimed quantity;
- override is auditable.

---

# 26. Souvenir Claim

### POST `/v1/invitation-parties/{partyUuid}/souvenir-claims`

Command semantics.

Request:

```json
{
  "quantity": 2,
  "claim_reference": "optional-client-reference"
}
```

Header:

```http
Idempotency-Key: <required-for-critical-command>
```

Rules:

```text
remaining = effective_entitlement - claimed_quantity
```

Request must fail when:

```text
quantity <= 0
quantity > remaining
party invalid/inaccessible
```

The domain transaction must be atomic and concurrency-safe so concurrent requests cannot claim beyond entitlement.

Duplicate idempotent request must not create a second claim side effect.

---

# 27. Proxy Souvenir Claim

Logical command:

```text
POST /v1/invitation-parties/{partyUuid}/souvenir-claims/proxy
```

Requires authorized staff context and staff confirmation.

Request example:

```json
{
  "quantity": 2,
  "proxy_name": "Andi",
  "confirmation": true,
  "reason": "Family proxy claim"
}
```

The exact proxy identity data model and UI workflow are downstream concerns, but possession of the invitation QR alone does not make the caller staff-authorized.

---

# 28. Website

### GET `/v1/workspaces/{workspaceUuid}/website`

Requires appropriate website read capability where applicable.

### PATCH `/v1/workspaces/{workspaceUuid}/website`

Updates draft/current website state.

### POST `/v1/workspaces/{workspaceUuid}/website/publish`

Publishes a new immutable website version according to versioning rules.

Published versions must not be modified in-place.

Exact website section/media APIs may be split into resources if implementation requires it, without changing ownership/versioning semantics.

---

# 29. Media

### GET `/v1/workspaces/{workspaceUuid}/media`

Requires:

```text
media.read
```

### POST `/v1/workspaces/{workspaceUuid}/media`

Requires:

```text
media.upload
```

### PATCH `/v1/media/{mediaUuid}`

Requires:

```text
media.update
```

### DELETE `/v1/media/{mediaUuid}`

Requires:

```text
media.delete
```

### POST `/v1/media/{mediaUuid}/moderate`

Requires:

```text
media.moderate
```

Storage authorization must follow the same workspace/organization ownership model.

---

# 30. Communication

### GET `/v1/workspaces/{workspaceUuid}/messages`

Requires:

```text
message.read
```

### POST `/v1/workspaces/{workspaceUuid}/messages`

Requires:

```text
message.create
```

### POST `/v1/messages/{messageUuid}/send`

Requires:

```text
message.send
```

Send operation should be idempotent when retry could duplicate external delivery.

Template/campaign management follows explicit permissions from the authorization contract.

---

# 31. Gift / Wedding Payment

Wedding payment is a separate domain from SaaS billing.

Logical resources:

```text
/v1/workspaces/{workspaceUuid}/gift-configuration
/v1/workspaces/{workspaceUuid}/gift-transactions
```

Verified transaction state must originate from the provider event/webhook path, not browser redirect state.

Exact payment provider endpoints are deferred because production gateway is not yet locked.

---

# 32. SaaS Billing

Logical resources:

```text
/v1/organizations/{organizationUuid}/subscription
/v1/organizations/{organizationUuid}/invoices
/v1/organizations/{organizationUuid}/billing-payments
```

SaaS billing is organization-owned.

Billing API must not be combined with wedding gift/payment resources.

---

# 33. Audit and Security Events

### GET `/v1/organizations/{organizationUuid}/audit-logs`

Requires:

```text
audit.read
```

### GET `/v1/organizations/{organizationUuid}/security-events`

Requires:

```text
security_event.read
```

Write paths for audit/security evidence are system-controlled, not arbitrary client CRUD.

---

# 34. Authorization Contract per Endpoint

Every endpoint MUST declare internally:

```text
identity_context
required_permission
required_scope
ownership_path
domain_rules
idempotency_requirement
concurrency_requirement
audit_requirement
```

Example:

```text
POST /v1/events/{eventUuid}/check-ins

identity_context: staff
permission: checkin.create
scope: event
ownership: event → workspace → organization
domain: event_guest belongs to event
idempotency: required
concurrency: required
 audit: yes
```

No endpoint is considered implementation-complete until all fields are resolved.

---

# 35. Client API Contract

Client access is whitelist-based.

Client MUST NOT call staff-only organization administration operations.

Example allowed baseline:

```text
GET workspace
GET wedding profile
GET client-visible event data
GET client-visible guest/invitation/RSVP data
```

Exact client write operations are deliberately not invented here; they must be introduced per use case with explicit field-level authorization.

A client endpoint must never simply map to the equivalent staff CRUD endpoint with broader fields.

---

# 36. Public Guest API Contract

Public endpoints must be isolated under a distinct route namespace:

```text
/v1/public/...
```

Public API MUST:

- resolve one invitation context from a token;
- expose minimum fields;
- prevent guest enumeration;
- prevent workspace/organization browsing;
- prevent staff API reuse;
- enforce expiry/revocation when policy is active;
- preserve tenant containment.

Public API MUST NOT accept `workspaceUuid` as proof of guest authorization.

---

# 37. Operational Scope

MVP Premium Wedding SaaS tidak menggunakan daily plotting, PDO, depot, rute, atau shift operasional sebagai authorization source.

API harus menyelesaikan operational authorization dari hierarchy:

```text
organization
  → workspace
  → event
```

Assignment yang valid harus berasal dari resource dan scope wedding yang ditetapkan pada domain model.


---

# 38. Idempotency Contract

Idempotency is required for operations where retries can produce duplicate business side effects.

Baseline:

```text
check-in
souvenir claim
invitation send
critical webhook processing
other externally-effectful commands
```

Preferred request:

```http
Idempotency-Key: <opaque-value>
```

Server stores enough result metadata to safely recognize a retry according to operation-specific retention policy.

Rules:

```text
same key + same logical request
→ same business result

same key + materially different request
→ reject as idempotency conflict
```

Exact persistence/TTL remains implementation/security concern.

---

# 39. Optimistic Concurrency

For editable aggregates with versioning:

```text
If-Match / version
```

or equivalent application contract may be used.

Conflict should produce:

```http
409 Conflict
```

Examples:

- seating plan;
- website draft;
- workspace settings;
- bulk guest edits;
- operational admin records where concurrent editing matters.

Critical claim/check-in concurrency is stronger than optimistic locking alone and must use the domain's atomic transaction/constraint strategy.

---

# 40. Domain Command vs CRUD

Use CRUD for state resources:

```text
GET guest
PATCH guest
```

Use explicit command endpoints when operation has a domain side effect/state transition:

```text
POST invitation/publish
POST invitation/send
POST event/check-ins
POST souvenir-claims
POST souvenir-entitlement/overrides
POST check-ins/{id}/correct
POST website/publish
```

Command endpoints must be idempotent whenever the underlying business action requires it.

---

# 41. Error Mapping for Critical Domain Rules

Examples:

| Condition | Recommended response |
|---|---|
| Invalid token | 404/403 according to public security policy |
| Expired/revoked token | 404/403 according to policy |
| Unauthorized action | 403/404 |
| Cross-tenant resource | 404/403 without existence leak |
| Invalid RSVP state | 409 or 422 |
| Duplicate check-in retry with same idempotency context | 200/201 equivalent current result |
| Duplicate valid check-in with conflicting command | 409 |
| Souvenir entitlement exhausted | 409 or 422 domain error |
| Souvenir claim > remaining | 409 or 422 domain error |
| Concurrent claim conflict | retryable 409/domain response |
| Proxy claim without staff confirmation | 403 or 422 depending enforcement layer |
| Ownership-changing mutation | 403/422 |
| Role self-escalation | 403/422 |

Final status/code mapping may be refined in Security/NFR and Testing documents.

---

# 42. Request Correlation and Audit

Every API request should have:

```text
request_id
```

Security-sensitive command logs should associate:

```text
request_id
actor
resource
action
organization
workspace where applicable
```

Audit evidence should not be client-forgeable.

---

# 43. Rate Limiting Boundary

At minimum, stricter rate limits should apply to:

- public invitation/token endpoints;
- public RSVP;
- authentication-sensitive endpoints;
- invitation send;
- message send;
- public QR/token resolution.

Exact numeric limits are Security/NFR concerns and not fixed here.

---

# 44. Webhook Boundary

Provider webhooks are server-to-server commands and must not trust browser state.

Webhook handlers should use:

```text
provider signature verification
+
idempotency/event identity
+
state transition validation
+
audit
```

SaaS billing webhook and wedding payment webhook remain separate domain paths.

---

# 45. Realtime API Boundary

Realtime channels are not substitutes for REST/domain authorization.

Channel subscription must reuse authorization/scope context.

After reconnect, client must resync authoritative snapshot; realtime messages are not the sole source of truth for critical current state.

Operational channels harus memakai authorization scope yang sama dengan API dan database.

---

# 46. Security Rules for Coding Agents

Coding agents implementing API MUST NOT:

1. return private rows based solely on caller-supplied tenant IDs;
2. trust hidden UI restrictions;
3. use internal sequential IDs in default public URLs;
4. expose private tables through anonymous endpoints;
5. use resource UUID as a secret token;
6. let client access inherit staff permissions;
7. create endpoint variants that bypass authorization helper logic;
8. mutate organization/workspace ownership through ordinary CRUD;
9. use browser payment redirect as payment source of truth;
10. make critical claim/check-in operations non-idempotent;
11. skip domain validation because RLS exists;
12. membuat operational scope di luar hierarchy organization → workspace → event;
13. expose service-role credentials;
14. create a second realtime authorization model;
15. alter accepted ADR decisions silently.

---

# 47. Mandatory API Test Surface

For every protected endpoint test:

```text
authenticated / unauthenticated
active / removed membership
correct / wrong organization
correct / wrong workspace
correct / wrong event
permission allow / deny
client vs staff boundary
public token valid / invalid / expired / revoked
ownership mutation deny
```

For critical commands additionally:

```text
first request
same retry
same key different payload
concurrent requests
partial dependency failure
reconnect retry
```

---

# 48. Open/Deferred Items

These are intentionally not invented by this document:

| Item | Status | Downstream |
|---|---|---|
| Exact client writable fields | Open | Use Cases / Domain Services |
| Public RSVP expiry/update window | Deferred | Use Cases + Security |
| Exact 403 vs 404 behavior | Deferred | Security/API testing |
| Exact pagination strategy for every high-volume endpoint | Deferred | Engineering/NFR |
| Exact rate limits | Deferred | Security/NFR |
| Payment provider | Deferred | Payment/Billing ADR |
| Offline/degraded check-in behavior | Deferred | Technical/NFR |
| Detailed audit retention | Deferred | Security/Operations |
| Exact SQL/RLS implementation | Deferred | Engineering/Migrations |
| Final platform support API surface | Deferred | Platform Administration |

No deferred item blocks the baseline resource/API architecture.

---

# 49. Implementation Sequence

Recommended order:

```text
1. API foundation + error contract
2. Auth/context middleware
3. Authorization helper integration
4. Organization/workspace endpoints
5. Guest/event/invitation APIs
6. RSVP/seating/check-in
7. Souvenir claim/override commands
8. Website/media/communication
9. Billing/payment webhook boundaries
10. Public guest APIs
11. Audit/security endpoints
12. Realtime integration
13. Contract tests + authorization matrix tests
```

Critical domain commands should be implemented through application/domain services, not direct controller-to-table mutations.

---

# 50. Final API Contract Principle

```text
HTTP Request
    ↓
Authentication
    ↓
Identity Context
    ↓
Authorization
    ↓
Tenant + Scope Resolution
    ↓
Request Validation
    ↓
Domain Command / Query
    ↓
Transaction / Domain Invariants
    ↓
Persistence + RLS
    ↓
Audit / Event where required
    ↓
Response Contract
```

Core rule:

> API adalah boundary kontrak, bukan sekadar wrapper CRUD terhadap database. Endpoint harus mencerminkan identity context, permission, scope, ownership, dan domain behavior yang sudah dikunci oleh dokumen upstream.

---

# 51. Downstream Contract

API Contract menjadi constraint untuk:

```text
API Contract
    ↓
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

Domain service dapat memiliki internal methods yang tidak menjadi public API. Sebaliknya, public endpoint tidak boleh memberikan capability yang tidak didukung authorization model.

---

## Status

**API Contract v0.1 — Baseline complete for downstream domain/use-case design.**

Dokumen ini sengaja tidak mengarang business rule yang masih deferred. Keputusan baru yang mengubah tenant boundary, authorization model, ownership, atau API semantics harus melalui ADR revision/addendum.
