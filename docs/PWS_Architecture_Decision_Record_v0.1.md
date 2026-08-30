# Premium Wedding SaaS — Architecture Decision Record (ADR)

**Document ID:** PWS-ADR-001  
**Version:** 0.1  
**Status:** Accepted — Baseline Architecture Decisions  
**Date:** 2026-08-24  
**Product:** Premium Wedding SaaS  
**Primary Sources:** `Premium_Wedding_SaaS_PRD_v0.1.md`, `Premium_Wedding_SaaS_Release_Roadmap_and_Zero_Cost_Strategy_v0.1.md`, `Premium_Wedding_SaaS_Domain_Core_Data_MultiTenant_RBAC_v0.1.md`

---

## 1. Purpose

Dokumen ini mengunci keputusan arsitektur penting yang telah disepakati sebelum pembuatan:

- Physical Database Schema
- RLS / Authorization Matrix
- API Contract
- Domain Service Design
- Workflow / Automation Design
- Migration Plan
- Implementation Blueprint

ADR ini menjadi **constraint** untuk dokumen dan implementation berikutnya. Keputusan yang berstatus **Accepted** tidak boleh diubah oleh coding agent hanya karena menemukan alternatif implementasi lain.

Perubahan terhadap keputusan Accepted harus melalui ADR revision/addendum.

---

## 2. Decision Status Convention

| Status | Arti |
|---|---|
| Proposed | Masih dalam pembahasan |
| Accepted | Sudah diputuskan dan menjadi constraint |
| Superseded | Digantikan keputusan baru |
| Deferred | Sengaja ditunda ke fase tertentu |
| Rejected | Opsi dipertimbangkan tetapi ditolak |

Semua keputusan pada versi 0.1 di bawah berstatus **Accepted**, kecuali bagian yang secara eksplisit ditandai Deferred/Not Yet Decided.

---

# 3. Architecture Decision Records

## ADR-001 — Organization sebagai Tenant Boundary

**Status:** Accepted

### Decision

`Organization` menjadi **tenant root** dan boundary utama isolasi data.

```text
Platform
  ↓
Organization
  ↓
Workspace
  ↓
Domain Data
```

### Rationale

- Sesuai model multi-tenant SaaS pada PRD.
- Satu organization dapat memiliki banyak wedding/client workspace.
- Memudahkan tenant isolation, billing, membership, audit, dan RLS.

### Consequences

Semua private business data harus dapat ditelusuri ke satu `organization` melalui ownership chain yang deterministic atau `organization_id` eksplisit pada tabel yang security-sensitive.

Cross-tenant access bukan pola normal untuk user organization.

---

## ADR-002 — Workspace sebagai Satu Proyek Wedding/Client

**Status:** Accepted

### Decision

Untuk MVP, satu `Workspace` merepresentasikan satu proyek wedding/client.

```text
Organization
├── Workspace A = Wedding A
├── Workspace B = Wedding B
└── Workspace C = Wedding C
```

Workspace tetap menggunakan istilah yang cukup generik agar tidak mengunci platform pada jenis event tertentu di masa depan.

### Rationale

- Sederhana untuk MVP.
- Cocok dengan PRD yang menjadikan workspace sebagai container wedding/client.
- Memberikan boundary yang jelas untuk guest, invitation, event, website, seating, dan check-in.

### Rejected Alternative

**Generic project tanpa asumsi wedding** ditolak untuk MVP karena akan menambah kompleksitas domain sebelum diperlukan.

### Consequences

Workspace ownership tidak boleh berubah melalui ordinary CRUD. Perubahan ownership tenant merupakan controlled migration/admin operation dan harus diaudit.

---

## ADR-003 — Couple/Client sebagai Client Access Terpisah dari Staff RBAC

**Status:** Accepted

### Decision

Couple/Client memiliki **authenticated access context terpisah** dari staff organization RBAC.

```text
Staff
  → Organization Membership
  → Staff RBAC

Couple/Client
  → Client Access
  → Limited Workspace Scope
```

Couple/Client boleh login dan berinteraksi dengan workspace tertentu, tetapi tidak diperlakukan sebagai staff organization biasa.

### Rationale

- Membatasi blast radius akses client.
- Sesuai kebutuhan limited couple access.
- Menghindari pemberian permission staff yang terlalu luas.
- Memisahkan security model internal staff dan external/client access.

### Consequences

Physical schema dan authorization layer harus dapat membedakan:

- staff identity;
- organization membership;
- client/couple access.

Client access tidak boleh otomatis mendapatkan hak organization administration.

---

## ADR-004 — User Mendukung Multiple Roles

**Status:** Accepted

### Decision

Satu organization member dapat memiliki **lebih dari satu role aktif**.

Contoh:

```text
Budi
├── Organization Admin
├── Event Manager
└── Check-in Staff
```

Effective permission merupakan hasil gabungan role yang valid pada scope terkait.

### Rationale

- Lebih realistis untuk wedding organization kecil/menengah.
- Menghindari pembuatan terlalu banyak role gabungan.
- Sesuai arah model `member_role` pada domain model.

### Consequences

Authorization engine harus melakukan permission resolution dari seluruh active role yang relevan, bukan hanya satu role.

---

## ADR-005 — Role dapat memiliki Scope Organization dan Workspace/Event

**Status:** Accepted

### Decision

Role capability dan scope dipisahkan.

Model:

```text
Role
  → Permission
  → Scope
```

Scope hierarchy:

```text
Organization
    ↓
Workspace
    ↓
Event
```

Organization-level role dapat berlaku seluruh organization. Role tertentu dapat dibatasi ke workspace atau event.

### Rationale

Membuat authorization cukup fleksibel tanpa membuat role yang berbeda untuk setiap kombinasi proyek.

Contoh:

```text
Organization Admin
→ seluruh organization

Event Manager
→ Workspace W-001

Check-in Staff
→ Event E-001
```

### Consequences

Role **tidak sama dengan scope**. Permission saja juga belum cukup untuk memberikan akses.

Authorization harus memeriksa:

1. authentication;
2. organization membership / client access;
3. permission;
4. scope;
5. object ownership.

---

## ADR-006 — Guest Identity Distinct per Workspace pada MVP

**Status:** Accepted

### Decision

`Guest` menjadi identity yang reusable **di dalam satu workspace**, bukan global directory lintas workspace.

```text
Workspace A
└── Guest Budi

Workspace B
└── Guest Budi
```

Seorang guest yang hadir pada beberapa event dalam workspace yang sama direferensikan melalui association seperti `event_guest`, bukan dengan menduplikasi guest identity.

### Rationale

- Mengurangi kompleksitas identity matching.
- Menghindari merge/conflict lintas wedding.
- Lebih aman untuk privacy dan tenant isolation.
- Cukup untuk MVP.

### Deferred

Global person directory atau cross-workspace identity matching dapat dipertimbangkan pada fase future setelah kebutuhan nyata terbukti.

### Consequences

Jangan menggunakan nama guest sebagai unique global identity.

---

## ADR-007 — Entitlement Dipisahkan dari RBAC tetapi Dapat menjadi Feature Gate

**Status:** Accepted

### Decision

Dua konsep harus dipisahkan:

```text
RBAC
= "Apakah user ini boleh melakukan aksi?"

Entitlement
= "Apakah feature ini tersedia pada plan/subscription?"
```

Sebuah operasi dapat diizinkan hanya jika kedua lapisan terpenuhi ketika feature tersebut memang memiliki plan gate.

```text
Permission ✅
Entitlement ✅
→ ALLOW

Permission ✅
Entitlement ❌
→ DENY
```

### Rationale

Memungkinkan SaaS packaging tanpa mencampur business role dengan subscription plan.

### Consequences

Authorization/application service harus dapat mengevaluasi entitlement saat feature memang gated. Tidak semua resource harus di-gate oleh billing.

---

## ADR-008 — Website Published Version bersifat Immutable

**Status:** Accepted

### Decision

Website menggunakan model draft → publish → immutable published version.

```text
Draft
  ↓ publish
Published Version 1

Draft
  ↓ publish
Published Version 2
```

Published version yang telah diterbitkan tidak diedit langsung.

### Rationale

- Menjaga website publik tetap konsisten.
- Memungkinkan rollback/version history.
- Memisahkan editing state dan public state.

### Consequences

Website editor bekerja terhadap draft/current editable state. Public renderer bekerja terhadap published version.

---

## ADR-009 — Authentication menggunakan Supabase Auth

**Status:** Accepted

### Decision

Authentication provider untuk baseline architecture adalah **Supabase Auth**.

Application domain tetap memiliki layer profile/membership sendiri dan tidak menggantungkan seluruh domain model langsung pada provider auth.

```text
Supabase Auth Identity
        ↓
Application User/Profile
        ↓
Organization Membership
        ↓
Role / Scope
```

### Rationale

- Selaras dengan arsitektur PostgreSQL/Supabase yang sudah digunakan sebagai fondasi.
- Memudahkan integrasi identity dengan RLS/security context.
- Menghindari penyimpanan password application secara manual.

### Consequences

Provider-managed identity ID menjadi source of truth untuk authentication identity. Pola `id + uuid` aplikasi tetap berlaku untuk business tables yang memang dimiliki aplikasi.

Application tidak boleh menyimpan raw password sendiri.

---

## ADR-010 — Payment Provider belum Dikunci; Gunakan Abstraction Layer

**Status:** Accepted / Deferred Provider Selection

### Decision

Payment gateway belum dipilih pada ADR v0.1.

Arsitektur harus menggunakan **payment provider abstraction** sehingga domain billing tidak tergantung pada satu gateway.

```text
Billing Domain
      ↓
Payment Provider Interface
      ↓
Provider Adapter
      ├── Provider A
      ├── Provider B
      └── Provider C
```

### Rationale

- Provider belum menjadi keputusan bisnis final.
- Menghindari vendor lock-in terlalu dini.
- Memungkinkan provider dipilih berdasarkan target market, fee, reliability, dan availability saat implementation billing.

### Mandatory Constraint

Payment state harus berasal dari **verified provider events/webhooks**, bukan hanya browser redirect.

### Deferred Decision

Provider pertama yang benar-benar digunakan untuk production akan ditetapkan melalui ADR terpisah sebelum billing production implementation.

---

## ADR-011 — Billing SaaS dan Wedding Payment adalah Dua Domain Berbeda

**Status:** Accepted

### Decision

SaaS billing dan wedding gift/payment dipisahkan.

```text
SaaS Billing
Organization
→ Subscription
→ Invoice
→ Billing Payment Transaction

Wedding Payment / Gift
Workspace
→ Gift Configuration
→ Payment Intent
→ Verified Gift Transaction
```

### Rationale

Kedua pembayaran mempunyai tujuan, ownership, lifecycle, dan reconciliation yang berbeda.

### Consequences

Jangan membuat satu generic `payments` table yang tidak memiliki domain semantics yang jelas.

---

## ADR-012 — Multiple Roles tidak Menghapus Workspace Assignment

**Status:** Accepted

### Decision

Multiple roles dan scope assignment berjalan bersama.

Contoh:

```text
User A
├── Organization Admin
└── Event Manager → Workspace W-001
```

User dapat memiliki role global organization sekaligus role scoped.

### Rationale

Memberi fleksibilitas tanpa memaksa semua permission menjadi global.

### Consequences

Effective permission harus dihitung berdasarkan role + scope yang paling tepat. Tidak boleh ada implicit escalation dari role scoped ke seluruh organization.

---

## ADR-013 — Server-side Authorization + Database Isolation sebagai Defense in Depth

**Status:** Accepted

### Decision

Authorization tidak boleh hanya ditangani UI.

Baseline:

```text
Client
  ↓
API / Server Action / RPC
  ↓
Authorization Context
  ↓
Tenant / Scope Check
  ↓
Domain Validation
  ↓
Database
  ↓
RLS / Equivalent Isolation
```

### Rationale

PRD menetapkan server-side permission enforcement dan tenant/workspace isolation sebagai security boundary.

### Consequences

- Hidden button bukan authorization.
- API tetap harus menolak unauthorized requests.
- Database isolation menjadi defense-in-depth.
- RLS/equivalent harus dirancang berdasarkan authorization matrix, bukan ditulis secara ad hoc.

---

## ADR-014 — Public Guest Access Dipisahkan dari Staff RBAC

**Status:** Accepted

### Decision

Guest public access menggunakan token/signed access context yang sangat terbatas.

Public token tidak menjadi staff membership dan tidak memperoleh organization role.

Allowed use cases dapat mencakup:

- melihat invitation;
- RSVP sesuai policy;
- melihat event information yang memang public;
- mendapatkan QR bila diizinkan.

### Security Constraints

Token harus:

- non-guessable;
- tidak berupa raw database ID;
- tidak memperluas tenant scope;
- dapat dicabut/expired sesuai policy.

### Consequences

Invitation token harus diperlakukan sebagai security credential dan tidak boleh disimpan/ditampilkan secara sembrono.

---

## ADR-015 — Current State dan History Dipisahkan bila History Bernilai Bisnis

**Status:** Accepted

### Decision

Gunakan pola:

```text
Current State = optimized for current reads
History       = append-only evidence when required
```

Contoh:

```text
RSVP current state
        +
RSVP response history

Invitation current delivery state
        +
Delivery attempts

Check-in current record
        +
Correction/audit history
```

### Rationale

Mempertahankan query current-state tetap sederhana sekaligus menyediakan auditability.

### Consequences

Tidak semua tabel harus mempunyai event/history table. History dibuat bila business, audit, compliance, atau operational value memang membutuhkannya.

---

## ADR-016 — Idempotency untuk Action Kritis

**Status:** Accepted

### Decision

Action kritis yang dapat diulang akibat retry, reconnect, double click, atau network issue harus dirancang idempotent.

Contoh:

- check-in;
- payment webhook handling;
- invitation send jobs;
- critical mutation API.

### Rationale

Mencegah duplicate side effects.

### Consequences

API/domain service harus menentukan idempotency key atau equivalent uniqueness strategy untuk action yang memang membutuhkan protection tersebut.

---

## ADR-017 — Internal ID + UUID Public Identifier Convention

**Status:** Accepted

### Decision

Business tables aplikasi menggunakan:

```text
id   = BIGINT identity / auto-increment
uuid = UUID unique
```

Kecuali entity provider-managed yang memang memiliki identifier sendiri.

### Rationale

- `id` memudahkan internal relation, audit, dan ordering.
- `uuid` cocok untuk external/public reference.
- Memisahkan internal database implementation dari public identifier.

### Consequences

Public API tidak boleh secara default mengekspos internal sequential `id` sebagai resource identifier.

---

## ADR-018 — Soft Delete bukan Default Global

**Status:** Accepted

### Decision

Soft delete digunakan hanya pada entity yang memang membutuhkan historical retention/recovery/business semantics.

### Rationale

Soft delete pada semua tabel menambah kompleksitas query, indexing, uniqueness, dan RLS.

### Consequences

Setiap table harus menentukan lifecycle/deletion strategy secara eksplisit pada Physical Database Schema.

---

## ADR-019 — Ownership Harus Explicit dan Deterministic

**Status:** Accepted

### Decision

Setiap private business row harus mempunyai ownership path yang dapat ditentukan secara deterministic.

Pada tabel security-sensitive/high-traffic, `organization_id` dapat disimpan secara eksplisit walaupun dapat diinfer dari workspace/event.

Contoh:

```text
organization_id
workspace_id
event_id
```

bila memang relevan.

### Rationale

- Menyederhanakan RLS.
- Menurunkan risiko accidental cross-tenant joins.
- Memudahkan indexing tenant-aware.
- Memudahkan audit.

### Constraint

Redundansi ownership harus dijaga konsistensinya melalui FK, constraints, trusted write path, atau domain service yang tepat.

---

## ADR-020 — MVP tidak Membawa Kompleksitas Future Domain ke Core Transaction Path

**Status:** Accepted

### Decision

MVP hanya mengimplementasikan entity/capability yang masuk release scope.

Future domain seperti:

- full CRM;
- advanced automation;
- marketplace;
- white-label;
- AI assistant;
- sophisticated seating intelligence;
- multi-provider payment routing;
- advanced vendor management

tidak boleh memaksa kompleksitas ke core MVP transaction path.

### Rationale

Menjaga scope, token usage, development cost, dan reliability tetap terkendali.

### Consequences

Schema/API boleh menyediakan extension point yang sehat, tetapi future feature tidak boleh dibuat hanya karena kemungkinan akan berguna nanti.

---

# 4. Decisions Not Yet Final

Bagian berikut **sengaja belum dikunci** karena tidak diperlukan untuk menyelesaikan ADR baseline dan sebaiknya diputuskan pada dokumen yang tepat.

| Topic | Status | Akan Diputuskan di |
|---|---|---|
| Exact physical table schema | Deferred | Physical Database Schema |
| Exact RLS policies | Deferred | Authorization & RLS Specification |
| Complete role-permission matrix | Deferred | Authorization & RLS Specification |
| Complete API endpoints/payloads | Deferred | API Contract |
| Public RSVP update/expiry policy | Deferred | Use Case + Security Specification |
| Check-in offline-first vs degraded-online | Deferred | Use Case + Technical/NFR Specification |
| Exact SaaS pricing model | Deferred | Billing/Product Specification |
| Exact payment gateway for production | Deferred | Payment/Billing ADR |
| Detailed retention/backup periods | Deferred | NFR + Security/Operations |
| Exact observability stack | Deferred | Engineering Blueprint |

---

# 5. Non-Negotiable Architecture Guardrails for Coding Agents

Coding agent **MUST NOT**:

1. membuat tenant model baru yang berbeda dari `Organization → Workspace`;
2. membuat global `user_role` yang mengabaikan tenant/scope;
3. menganggap UI visibility sebagai authorization;
4. menyimpan password aplikasi sendiri;
5. menggunakan sequential internal `id` sebagai public resource identifier secara default;
6. mencampur SaaS billing dengan wedding payment menjadi domain pembayaran yang ambigu;
7. mengubah published website langsung tanpa version boundary;
8. menganggap browser redirect sebagai source of truth payment;
9. membuat cross-tenant query normal untuk organization member;
10. memasukkan future feature complexity ke MVP tanpa requirement yang sah;
11. mengganti keputusan ADR ini secara diam-diam;
12. menyelesaikan ambiguity arsitektur dengan asumsi pribadi bila keputusan bisnis/arsitektur belum ditetapkan.

Jika implementation memerlukan keputusan baru yang dapat memengaruhi architecture, agent harus menandainya sebagai **Architecture Decision Needed** dan tidak mengunci keputusan tersebut secara diam-diam.

---

# 6. Decision Dependency Chain

```text
PRD
 ↓
Release Roadmap
 ↓
Domain + Core Data + Multi-Tenant/RBAC
 ↓
THIS ADR  ← Architecture constraints locked here
 ↓
Physical Database Schema
 ↓
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

---

# 7. Change Management

Setiap perubahan terhadap keputusan Accepted harus:

1. menjelaskan keputusan lama;
2. menjelaskan masalah yang memicu perubahan;
3. menyediakan opsi baru yang dipertimbangkan;
4. menjelaskan impact terhadap database/API/security;
5. menghasilkan ADR revision atau addendum;
6. memastikan dokumen downstream tidak menjadi contradictory.

Tidak boleh ada perubahan arsitektur penting hanya melalui code commit tanpa dokumentasi keputusan.

---

# 8. Decision Summary

| ID | Decision | Status |
|---|---|---|
| ADR-001 | Organization = Tenant Boundary | Accepted |
| ADR-002 | Workspace = Wedding/Client Project | Accepted |
| ADR-003 | Couple/Client = Separate Client Access | Accepted |
| ADR-004 | Multiple Roles per Member | Accepted |
| ADR-005 | Organization/Workspace/Event Scope | Accepted |
| ADR-006 | Guest identity distinct per Workspace for MVP | Accepted |
| ADR-007 | RBAC and Entitlement separated | Accepted |
| ADR-008 | Immutable Published Website Versions | Accepted |
| ADR-009 | Supabase Auth | Accepted |
| ADR-010 | Payment Provider via abstraction; provider deferred | Accepted/Deferred |
| ADR-011 | SaaS Billing ≠ Wedding Payment | Accepted |
| ADR-012 | Multiple Roles + Scope Assignment | Accepted |
| ADR-013 | Server Authorization + DB Isolation | Accepted |
| ADR-014 | Public Guest Access separated from Staff RBAC | Accepted |
| ADR-015 | Current State + History where needed | Accepted |
| ADR-016 | Idempotency for critical actions | Accepted |
| ADR-017 | `id` + `uuid` convention | Accepted |
| ADR-018 | Soft Delete not global default | Accepted |
| ADR-019 | Explicit deterministic ownership | Accepted |
| ADR-020 | Keep future complexity out of MVP core path | Accepted |

---

# 9. Source Traceability

Keputusan pada dokumen ini diturunkan dari:

- `Premium_Wedding_SaaS_PRD_v0.1.md` — product structure, multi-tenant model, user/role concepts, limited couple access, billing, security boundary, workspace isolation, and MVP scope.
- `Premium_Wedding_SaaS_Release_Roadmap_and_Zero_Cost_Strategy_v0.1.md` — release boundaries, MVP scope, future/deferred capabilities, and implementation philosophy.
- `Premium_Wedding_SaaS_Domain_Core_Data_MultiTenant_RBAC_v0.1.md` — domain ownership, data model, tenant hierarchy, RBAC foundation, current-state/history principles, public token constraints, website versioning, and implementation guardrails.

---

# 10. Next Document Contract

Dokumen berikutnya harus menggunakan ADR ini sebagai constraint.

**Next:** `Premium_Wedding_SaaS_Physical_Database_Schema_v0.1.md`

Sebelum dokumen tersebut dibuat, seluruh **remaining ambiguities yang memang berdampak terhadap physical schema** harus diperiksa kembali. Jika ada keputusan yang belum ditetapkan, keputusan tersebut harus diminta kepada product owner terlebih dahulu dengan opsi rekomendasi, bukan diasumsikan oleh author atau coding agent.
