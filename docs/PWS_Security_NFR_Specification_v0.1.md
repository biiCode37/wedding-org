# Premium Wedding SaaS — Security + NFR Specification

**Document ID:** PWS-SEC-NFR-001  
**Version:** 0.1  
**Status:** Baseline Specification  
**Date:** 2026-08-29  
**Upstream:** PRD, Release Roadmap, Domain/Core/RBAC, ADR, Physical Database Schema, Authorization + RLS, API Contract, Domain Services + Business Rules, Use Cases + State Machines  
**Downstream:** Testing + Acceptance Criteria, Engineering / Implementation Blueprint

---

## 1. Purpose

Menetapkan baseline security dan non-functional requirements untuk implementasi tanpa mengubah keputusan arsitektur yang sudah accepted.

Cakupan utama:
- authentication dan authorization;
- tenant/workspace/event isolation;
- RLS;
- public guest security;
- secrets;
- privacy/data protection;
- audit/evidence;
- API security;
- rate limiting;
- concurrency/idempotency;
- payment/webhook security;
- realtime security;
- reliability;
- performance/scalability;
- backup/recovery;
- observability;
- incident handling;
- security testing.

---

## 2. Security Principles

```text
Authentication
    ↓
Authorization
    ↓
Tenant / Scope Isolation
    ↓
Domain Validation
    ↓
Database RLS
    ↓
Audit / Evidence
    ↓
Monitoring / Response
```

Non-negotiable:
1. Deny by default.
2. Least privilege.
3. Server-side authorization.
4. Defense in depth.
5. Explicit deterministic ownership.
6. Public access terpisah dari authenticated access.
7. Critical mutations idempotent.
8. Sensitive operations auditable.
9. Secrets tidak pernah diekspos ke client.
10. Deferred decisions tidak boleh diam-diam diubah menjadi assumption.

---

## 3. Tenant and Scope Security

`Organization` adalah tenant root.

```text
Organization
  ↓
Workspace
  ↓
Domain Resource
```

Normal organization user tidak boleh cross-tenant.

Scope hierarchy:

```text
Organization → Workspace → Event
```

MVP tidak menggunakan daily plotting, PDO, depot, rute, atau shift operasional. Operational scope mengikuti Organization → Workspace → Event.

---

## 4. Authentication Security

Authentication menggunakan Supabase Auth dengan application profile/membership layer di atasnya.

Requirements:

| ID | Requirement |
|---|---|
| SEC-AUTH-01 | Gunakan provider-managed identity sesuai architecture baseline. |
| SEC-AUTH-02 | Jangan menyimpan raw password application-level. |
| SEC-AUTH-03 | Authentication failure tidak membocorkan data sensitif. |
| SEC-AUTH-04 | Credential/session tidak boleh masuk log secara tidak aman. |
| SEC-AUTH-05 | Revoked/invalid identity tidak boleh menghasilkan effective application access. |

MFA, exact session duration, dan credential-rotation schedule belum dikunci source dan tidak boleh diinvent sendiri.

---

## 5. Authorization Security

Effective access selalu mengikuti:

```text
Identity
+ Permission
+ Scope
+ Ownership
+ Domain Rule
```

Requirements:

| ID | Requirement |
|---|---|
| SEC-AUTHZ-01 | Semua protected operation wajib server-side authorization. |
| SEC-AUTHZ-02 | RLS/database isolation wajib menjadi defense-in-depth. |
| SEC-AUTHZ-03 | Inactive membership tidak memiliki effective staff access. |
| SEC-AUTHZ-04 | Client access tidak mewarisi staff permissions. |
| SEC-AUTHZ-05 | Scoped role tidak implicit-escalate ke scope lebih luas. |
| SEC-AUTHZ-06 | Role delegation harus memvalidasi delegation boundary. |
| SEC-AUTHZ-07 | Ownership-changing CRUD tidak tersedia sebagai ordinary mutation. |
| SEC-AUTHZ-08 | Realtime memakai authorization source yang sama. |

---

## 6. RLS Security

Semua private business tables wajib RLS.

RLS harus melindungi:

```text
SELECT
INSERT
UPDATE
DELETE
```

sesuai kebutuhan table.

`USING` digunakan untuk target/existing row access dan `WITH CHECK` untuk memastikan state hasil INSERT/UPDATE tetap authorized.

Harus dicegah:
- cross-tenant read/write;
- cross-workspace access;
- event scope escape;
- ownership reassignment;
- privilege escalation melalui mutation.

RLS tidak boleh dinonaktifkan hanya karena application code melakukan filtering.

---

## 7. Public Guest Security

Public guest access menggunakan token/access context terbatas.

Requirements:

| ID | Requirement |
|---|---|
| SEC-PUB-01 | Token non-guessable. |
| SEC-PUB-02 | UUID resource bukan secret credential. |
| SEC-PUB-03 | Token dapat revoke/expire sesuai policy. |
| SEC-PUB-04 | Tidak ada unrestricted anonymous SELECT pada private tables. |
| SEC-PUB-05 | Hanya minimum required guest data yang dikembalikan. |
| SEC-PUB-06 | Enumeration harus dicegah. |
| SEC-PUB-07 | Public token tidak boleh memperluas tenant/workspace scope. |

Public RSVP update/expiry window masih deferred.

---

## 8. Secrets Management

- Service-role/API/provider secrets hanya di trusted server environment.
- Tidak boleh di frontend/mobile bundle.
- Tidak boleh disimpan di source control.
- Tidak boleh muncul dalam normal logs/error responses.
- Debug logging harus meredact credentials dan sensitive headers/payloads.

Exact rotation schedule belum dikunci.

---

## 9. Data Protection & Privacy

Data diklasifikasikan secara konseptual menjadi:

```text
Public
Internal
Tenant-private
Security-sensitive
Credential/Secret
```

Contoh tenant-private/security-sensitive:
- guest contact data;
- invitation/RSVP;
- check-in;
- souvenir claim evidence;
- audit/security logs;
- billing data;
- invitation tokens.

Requirements:
- minimum necessary disclosure;
- tenant isolation;
- sensitive snapshot minimization;
- no secret leakage through logs;
- public responses tidak memuat private staff/client data.

Source tidak menetapkan formal regulatory certification tertentu; jangan mengklaim compliance formal tanpa keputusan dan evidence tambahan.

---

## 10. Identifier Security

Business tables menggunakan pasangan:

```text
id
uuid
```

Public API menggunakan UUID/resource identifier secara default.

```text
UUID != Secret
```

Resource UUID tidak boleh menjadi authentication credential.

---

## 11. API Security

Boundary:

```text
Authenticate
→ Authorize
→ Validate
→ Domain Command/Query
→ Transaction
→ Persistence/RLS
```

Requirements:
- strict validation untuk sensitive mutations;
- server-side tenant/scope resolution;
- allowlisted filter/sort;
- request correlation via `request_id`;
- consistent error contract;
- no stack trace/internal SQL detail ke client;
- no cross-tenant existence leak.

---

## 12. Rate Limiting & Abuse Protection

Stricter controls diperlukan minimal untuk:
- authentication-sensitive endpoints;
- public invitation/token endpoints;
- public RSVP;
- invitation send;
- message send;
- public QR/token resolution;
- webhook ingress bila abuse risk relevan.

**Exact numeric limits belum ditentukan oleh source.** Angka final ditetapkan pada hardening/testing stage.

---

## 13. Critical Mutation Security

Critical actions:

```text
check-in
souvenir claim
proxy souvenir claim
entitlement override
role assignment
invitation send
payment webhook handling
website publish
```

Harus memenuhi:

```text
authorization
+ domain validation
+ transaction safety
+ idempotency
+ audit/evidence where required
```

---

## 14. Concurrency & Integrity

Invariants wajib tetap benar terhadap concurrent requests:

### Check-in
```text
successful_checkin_count <= 1 per event_guest
```

### Souvenir
```text
total_claimed <= final_entitlement
```

### Website
```text
published version is immutable
```

### RBAC
```text
scope ownership remains valid
```

Frontend locking bukan protection final. Database constraints, transactions, dan domain service rules menjadi enforcement utama.

---

## 15. Audit & Security Evidence

Sensitive events minimal mencakup:

```text
member_added
member_removed
role_assigned
role_revoked
client_access_granted
client_access_revoked
invitation_token_revoked
permission_denied_sensitive
cross_scope_access_attempted
souvenir_entitlement_overridden
souvenir_claim_created
proxy_claim_created
checkin_created
checkin_corrected
billing_webhook_processed
support_access_granted
```

Audit context, where applicable:

```text
organization_id
workspace_id
actor_user_id
actor_type
action
resource_type
resource_id
before_snapshot
after_snapshot
request_id
ip_address
user_agent
created_at
```

Sensitive snapshots wajib diminimalkan.

---

## 16. Current State vs History

Untuk business evidence:

```text
Current State
+
Append-only History
```

Contoh:
- RSVP changes;
- invitation delivery attempts;
- check-in corrections;
- billing webhook events;
- website publication versions;
- security/audit events;
- souvenir claims.

Correction tidak boleh diam-diam menghapus evidence sebelumnya.

---

## 17. Payment Security

SaaS billing dan wedding gift/payment tetap domain terpisah.

Verified payment state berasal dari provider event/webhook:

```text
Provider event/webhook
   ↓ verify
   ↓ idempotency
   ↓ domain validation
   ↓ update payment state
```

Browser redirect bukan source of truth.

Production payment provider tetap deferred ke ADR terpisah.

---

## 18. Webhook Security

Webhook handler wajib:
1. verifikasi authenticity/signature bila provider mendukung;
2. reject event malformed/unauthenticated;
3. enforce idempotency;
4. validate state transition;
5. persist evidence;
6. tidak mempercayai browser-side payment state.

Provider-specific verification mechanism merupakan implementation detail.

---

## 19. Storage & Media Security

Media private by default kecuali explicitly public/published.

Requirements:
- tidak ada accidental bucket-wide exposure;
- access melalui authorization-aware path;
- public media harus explicit;
- URL/token tidak boleh menjadi permanent unintended credential;
- file type/size validation;
- private operational media tidak otomatis dibroadcast melalui realtime.

---

## 20. Realtime Security

Realtime menggunakan authorization source yang sama dengan ordinary data access.

Requirements:

| ID | Requirement |
|---|---|
| SEC-RT-01 | Tidak mengandalkan channel-name obscurity. |
| SEC-RT-02 | Channel access harus scope-authorized. |
| SEC-RT-03 | Cross-tenant event tidak boleh terkirim. |
| SEC-RT-04 | Reconnect melakukan authoritative resync bila ditetapkan architecture. |
| SEC-RT-05 | Scope/membership changes harus memiliki unsubscribe/revocation handling untuk active subscriptions. |

Karena authorization channel dapat diperiksa saat subscribe, active persistent connection membutuhkan explicit handling ketika access berubah.

---

## 21. Reliability

Core state harus selalu authoritative di database.

Requirements:
- critical commands idempotent;
- external side effects retry-safe;
- provider failure tidak merusak committed domain state;
- reconnect/retry tidak membuat duplicate domain effects;
- current-state reads tidak perlu replay seluruh history.

Exact uptime SLA belum ditetapkan source.

---

## 22. Availability & Degraded Modes

System harus membedakan:

```text
Normal
Dependency degraded
Network loss
Provider unavailable
Database unavailable
```

External provider unavailable:

```text
preserve valid internal state
+
record failure
+
retry according to policy
```

Offline/degraded check-in behavior masih deferred.

---

## 23. Performance

Baseline:
- tenant-aware indexes;
- current-state storage untuk hot reads;
- bounded pagination;
- efficient scope helper functions;
- hindari repeated authorization joins bila helper function tersedia;
- jangan replay history pada hot path tanpa kebutuhan.

Exact p95/p99 latency target belum ditetapkan source, sehingga tidak boleh diinvent.

---

## 24. Scalability

Harus mendukung pertumbuhan multi-organization tanpa tenant model rewrite.

Requirements:
- tenant-aware indexing;
- deterministic ownership;
- no single-tenant/global assumptions;
- pagination;
- asynchronous processing untuk non-critical external side effects bila sesuai;
- bounded-memory import/export.

MVP tidak boleh menarik future-domain complexity ke core transaction path tanpa requirement valid.

---

## 25. Database NFR

- Production migrations harus versioned.
- Business invariants memakai DB constraints bila feasible.
- Foreign keys menjaga ownership relationships.
- Uniqueness digunakan untuk idempotency bila applicable.
- RLS tetap aktif.
- Destructive migration memerlukan recovery plan.
- Backup dan restore capability harus tersedia sebelum production readiness.

Physical schema/source juga menetapkan current-state strategy, deterministic ownership, dan untuk high-volume operational logs penggunaan partitioning/`STABLE` scope resolution sesuai domain yang relevan.

---

## 26. Backup & Recovery

Minimum capability:

```text
Backup
  ↓
Restore verification
  ↓
Recovery procedure
```

Wajib tersedia:
- scheduled backups sesuai provider capability;
- documented restore process;
- periodic restore verification;
- migration-aware recovery procedure.

Deferred:
```text
RPO
RTO
exact retention
backup region strategy
DR topology
```

---

## 27. Observability

Coverage minimal:

```text
Logs
Metrics
Request correlation
Security events
Domain events
Provider outcomes
```

Minimum safe request context:

```text
request_id
operation
result
latency
authorized tenant/scope context where safe
```

Jangan log raw credentials atau unnecessary private payloads.

Exact observability stack deferred ke Engineering Blueprint.

---

## 28. Monitoring Signals

Monitor minimal:
- authentication failures;
- authorization denials;
- public token failures;
- cross-scope access attempts;
- rate limiting spikes;
- webhook verification failures;
- duplicate webhook conflicts;
- failed jobs;
- provider/notification failures;
- database errors;
- RLS failures;
- critical domain conflicts;
- souvenir claim conflicts/exhaustion;
- duplicate check-in patterns.

Exact alert thresholds dan routing belum dikunci.

---

## 29. Incident Response

Baseline:

```text
Detect
  ↓
Triage
  ↓
Contain
  ↓
Investigate
  ↓
Recover
  ↓
Document
  ↓
Prevent recurrence
```

Evidence minimal harus memungkinkan investigasi actor, resource, scope, timestamp, request correlation, action, dan result.

Formal incident SLA/breach notification policy belum ditentukan source.

---

## 30. Data Retention & Deletion

Retention harus explicit per entity.

Principles:
- audit/security evidence tidak dihapus sembarangan;
- current-state mengikuti lifecycle domain;
- personal data tidak direplikasi tanpa kebutuhan;
- soft delete bukan default global;
- deletion tidak boleh menghancurkan evidence yang memiliki business/audit value.

Exact retention schedule deferred.

---

## 31. Import / Export Security

Bulk import/export wajib:
- explicit permission;
- input validation;
- tenant scope enforcement;
- resource limits;
- no unauthorized partial write;
- audit evidence untuk export sensitif bila diperlukan;
- generated files protected from unintended public access.

Export tidak boleh menjadi bypass terhadap RLS/authorization.

---

## 32. Mandatory Security Test Surface

### Authentication
```text
invalid credential/session → DENY
revoked/expired session → DENY
```

### Tenant
```text
Org A → Org B = DENY
```

### Workspace/Event
```text
W1 → W2 = DENY
E1 → E2 = DENY
```

### Client
```text
Client → staff administration = DENY
Client W1 → W2 = DENY
```

### Public
```text
invalid token = DENY
expired token = DENY
revoked token = DENY
enumeration = DENY
```

### Escalation
```text
self-promotion = DENY
cross-tenant role assignment = DENY
```

### Critical mutation
```text
duplicate check-in = idempotent
concurrent claim = cannot exceed entitlement
duplicate claim retry = idempotent
proxy claim without confirmation = DENY
unauthorized override = DENY
```

---

## 33. NFR Test Categories

Testing must cover:

```text
Functional correctness
Security
Authorization
Concurrency
Idempotency
Performance
Scalability
Reliability
Recovery
Observability
Privacy/data leakage
External dependency failure
```

Critical operations juga diuji dengan:
- first request;
- same retry;
- same key + different payload;
- concurrent requests;
- partial dependency failure;
- reconnect/retry.

---

## 34. Production Readiness Gates

Minimal gates:
1. Cross-tenant RLS tests pass.
2. Authorization matrix enforced.
3. Critical commands idempotent.
4. Souvenir concurrency invariant verified.
5. Check-in duplicate protection verified.
6. Public token protections verified.
7. Webhook verification/idempotency verified.
8. Audit/security evidence verified.
9. Backup restore procedure verified.
10. Secrets/log redaction verified.
11. Critical monitoring enabled.
12. Deferred production policies resolved or explicitly excluded.

---

## 35. Non-Negotiable Coding Agent Rules

Coding agent MUST NOT:

- bypass RLS;
- expose service-role credentials;
- store raw passwords;
- use UUID as secret;
- create anonymous private-table reads;
- use cross-tenant queries as shortcuts;
- trust client tenant/scope fields as authorization proof;
- remove audit evidence for convenience;
- weaken idempotency/concurrency protection;
- use browser payment redirect as payment truth;
- invent SLA, RPO, RTO, retention, compliance, or rate-limit numbers;
- silently resolve deferred security decisions;
- alter Accepted ADR decisions without revision/addendum.

---

## 36. Explicitly Deferred Decisions

| Topic | Status |
|---|---|
| RPO / RTO | Deferred |
| Backup retention | Deferred |
| Uptime SLA | Deferred |
| Exact rate limits | Deferred |
| MFA/session policy | Deferred |
| Audit retention | Deferred |
| Formal compliance target | Not established |
| Observability stack | Deferred |
| Incident-response SLA | Deferred |
| Public RSVP expiry | Deferred |
| Offline/degraded check-in | Deferred |
| Exact client writable fields | Deferred |
| Production payment provider | Deferred |

---

## 37. Dependency Contract

```text
Authorization + RLS
        ↓
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

Security/NFR menjadi constraint implementasi, bukan sekadar backlog feature.

---

## Status

**Security + NFR Specification v0.1 — Baseline complete.**

No new architecture decision is introduced by this document.

## Source Traceability

Dokumen ini diturunkan dari source baseline yang tersedia: PRD, ADR, Domain/Core/RBAC, Physical Database Schema, Authorization + RLS, API Contract, Domain Services + Business Rules, Use Cases + State Machines, dan glossary.

Key source-derived constraints mencakup tenant boundary, separate client access, Supabase Auth, server-side authorization, public-token isolation, current-state/history, idempotency, deterministic ownership, verified webhook payment state, operational scope Organization → Workspace → Event, serta realtime authorization yang menggunakan source of truth scope yang sama.
