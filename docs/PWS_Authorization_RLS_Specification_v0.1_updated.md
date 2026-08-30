# Premium Wedding SaaS — Authorization + RLS Specification

**Document ID:** PWS-AUTH-001  
**Version:** 0.1  
**Status:** Baseline Specification — Draft for Implementation Review  
**Date:** 2026-08-28  

---

## 1. Purpose

Dokumen ini menetapkan authorization contract dan RLS boundary untuk Premium Wedding SaaS berdasarkan dokumen arsitektur, domain/RBAC, dan physical database schema yang sudah tersedia.

Dokumen ini mencakup:

- authentication context;
- staff RBAC;
- client/couple access;
- organization/workspace/event scope;
- permission resolution;
- deterministic ownership;
- public guest access;
- PostgreSQL/Supabase RLS;
- security-sensitive mutation rules;
- audit/security evidence;
- authorization test boundary;
- realtime authorization consistency.

Dokumen ini **tidak** mengunci API endpoint/payload final, public RSVP expiry policy, offline/degraded-mode policy, detail billing feature gating, atau implementation migration SQL final.

---

# 2. Source Baseline and Locked Constraints

Dokumen ini harus konsisten dengan:

1. `Premium_Wedding_SaaS_PRD_v0.1.md`
2. `Premium_Wedding_SaaS_Release_Roadmap_and_Zero_Cost_Strategy_v0.1.md`
3. `Premium_Wedding_SaaS_Domain_Core_Data_MultiTenant_RBAC_v0.1.md`
4. `Premium_Wedding_SaaS_Architecture_Decision_Record_v0.1.md`
5. `Premium_Wedding_SaaS_Physical_Database_Schema_v0.1.md`
6. `PWS_Glossary_v0.1.md` sebagai definisi istilah domain yang berlaku.

Keputusan arsitektur yang sudah Accepted:

- Organization = tenant boundary.
- Workspace = satu wedding/client project pada MVP.
- Couple/Client menggunakan access context terpisah dari staff membership.
- Multiple roles diperbolehkan.
- Role dan scope adalah dua dimensi berbeda.
- Hierarki scope foundation = Organization → Workspace → Event.
- Server-side authorization wajib.
- Database isolation/RLS adalah defense-in-depth.
- Public guest access terpisah dari staff RBAC.
- Public token harus non-guessable, tidak menjadi raw database identifier, dan dapat dicabut/expired sesuai policy.
- Ownership harus deterministic.
- Removing membership menghilangkan effective staff access.
- `id` internal dan `uuid` external-safe tetap dipisahkan.
- Role assignment scoped tidak boleh memperoleh implicit escalation.
- RBAC dan product/subscription entitlement merupakan concern berbeda.

ADR secara eksplisit menetapkan bahwa exact RLS policy dan authorization enforcement harus berasal dari authorization matrix, bukan ditulis ad hoc.

---

# 3. Authorization Model

Model final:

```text
Authentication
      ↓
Identity Classification
      ↓
Access Context
      ├── Staff Membership
      │      ↓
      │   Role Assignment
      │      ↓
      │   Permission
      │      ↓
      │   Scope
      │
      ├── Client Access
      │      ↓
      │   Workspace Scope
      │      ↓
      │   Client Capability
      │
      └── Public Token
             ↓
          Token Context
             ↓
        Guest-specific Resource
      ↓
Object Ownership
      ↓
Domain Rules
      ↓
RLS / Database Isolation
      ↓
ALLOW / DENY
```

Core separation:

```text
Authentication ≠ Authorization
Role ≠ Permission
Role ≠ Scope
Permission ≠ Ownership
UI Visibility ≠ Authorization
Public Token ≠ Staff Role
RBAC ≠ Subscription Entitlement
```

Authorization bersifat **deny by default**.

---

# 4. Authentication Context

## 4.1 Staff Context

```text
Supabase Auth
  ↓
user_profile
  ↓
organization_member
  ↓
member_role
  ↓
role_permission
```

`auth.uid()` menjadi identity root untuk menghubungkan authenticated session dengan application profile.

Application tidak menyimpan raw password sendiri; authentication identity tetap mengikuti Supabase Auth.

## 4.2 Client Context

```text
Supabase Auth
  ↓
user_profile
  ↓
client_access
  ↓
workspace
```

Client **bukan** organization member secara otomatis dan login tidak memberikan staff permission.

## 4.3 Public Guest Context

```text
Invitation Token / Signed Access Context
  ↓
Invitation Party
  ↓
Allowed Guest Resource
```

Public guest context:

- tidak membuat organization membership;
- tidak membuat staff role;
- tidak memperoleh arbitrary tenant access;
- hanya berlaku terhadap resource yang memang diizinkan.

---

# 5. Tenant Boundary

Organization adalah root tenant:

```text
Platform
  ↓
Organization
  ↓
Workspace
  ↓
Domain Data
```

Private business rows harus memiliki ownership path deterministic ke satu organization, baik melalui `organization_id` eksplisit maupun ownership chain yang dapat dibuktikan dengan constraint/trusted write path.

Cross-tenant access adalah **DENY** untuk normal organization users.

Physical schema sudah menyediakan explicit organization/workspace ownership pada tabel security-sensitive dan same-tenant integrity pada beberapa relasi kritis.

---

# 6. Scope Model

## 6.1 Foundation Scope Hierarchy

```text
Organization
    ↓
Workspace
    ↓
Event
```

`member_role` menggunakan kombinasi:

| workspace_id | event_id | Meaning |
|---|---|---|
| NULL | NULL | Organization scope |
| NOT NULL | NULL | Workspace scope |
| NOT NULL | NOT NULL | Event scope |

Invariant:

```text
event_id IS NOT NULL
→ workspace_id IS NOT NULL
```

Event scope harus berada pada workspace yang sama.

## 6.2 Scope Non-Escalation

```text
Workspace W1 → tidak berarti Workspace W2
Event E1 → tidak berarti Event E2
Event E1 → tidak berarti seluruh Workspace
Scoped role → tidak berarti Organization-wide
```

## 6.3 Operational Scope

MVP Premium Wedding SaaS tidak menggunakan daily plotting, PDO, depot, rute, atau shift operasional.

Source of truth operational scope:

```text
Organization
   ↓
Workspace
   ↓
Event
```

Konsekuensinya:

- permission harus divalidasi terhadap scope Organization, Workspace, atau Event;
- assignment event tidak memberi akses ke Event lain;
- tidak ada fallback dari scope sempit ke scope lebih luas;
- authorization operasional mengikuti hierarchy scope yang sama pada API, domain service, RLS, dan realtime.

---

# 7. Role Model

Baseline role:

| Role | Primary Scope | Intent |
|---|---|---|
| Platform Super Admin | Platform | Platform administration |
| Organization Owner | Organization | Full organization management |
| Organization Admin | Organization | Staff/settings/workspace administration |
| Event Manager / Project Manager | Workspace | Wedding/event operational management |
| Guest / Invitation Manager | Workspace | Guest/invitation/RSVP operations |
| Check-in Staff | Event | Check-in + minimal guest lookup |
| Couple / Client | Workspace | Limited client access |

Public guest bukan role organisasi.

### 7.1 System vs Custom Role

Physical schema menetapkan:

```text
System role:
organization_id IS NULL

Custom role:
organization_id IS NOT NULL
```

Custom role hanya boleh menggunakan permission catalog yang tersedia. Custom role tidak boleh memodifikasi tenant boundary.

---

# 8. Permission Model

Permission berbentuk:

```text
resource + action
```

Permission catalog foundation:

```text
organization.read
organization.update
organization.members.read
organization.members.manage
organization.settings.read
organization.settings.update
organization.billing.read
organization.billing.manage
organization.roles.read
organization.roles.manage

workspace.read
workspace.create
workspace.update
workspace.archive
workspace.members.manage

wedding.read
wedding.create
wedding.update

event.read
event.create
event.update
event.delete

guest.read
guest.create
guest.update
guest.delete
guest.import
guest.export
guest.merge

invitation.read
invitation.create
invitation.update
invitation.publish
invitation.send
invitation.cancel

rsvp.read
rsvp.update
rsvp.export

seating.read
seating.update
seating.assign
seating.export

checkin.read
checkin.create
checkin.correct
checkin.export

message.read
message.create
message.send
message.template.manage
message.campaign.manage

media.read
media.upload
media.update
media.delete
media.moderate

gift.read
gift.manage
gift.transaction.read
gift.reconcile

automation.read
automation.create
automation.update
automation.enable
automation.disable

audit.read
security_event.read
```

Physical schema harus memakai normalized permission catalog yang sama. Coding agent tidak boleh membuat permission synonym yang menyebabkan duplicate semantics.

Sensitive actions harus selalu explicit:

```text
organization.members.manage
organization.roles.manage
organization.billing.manage
guest.delete
guest.merge
checkin.correct
gift.reconcile
media.moderate
audit.read
security_event.read
```

---

# 9. Effective Permission Resolution

Effective staff permission:

```text
Active Membership
    +
Active Role Assignment
    +
Role Permission
    +
Valid Scope
    +
Target Ownership
    +
Domain Rules
    ↓
Effective Permission
```

Multiple roles menghasilkan **union** dari permission valid yang tersedia pada scope target.

Tidak boleh ada implicit escalation dari role scoped ke scope yang lebih luas.

Contoh:

```text
Organization Admin
+
Check-in Staff → Event E1
```

User memiliki permission dari keduanya.

Sebaliknya:

```text
Check-in Staff → E1
```

tidak boleh mengakses E2 atau administration organization.

---

# 10. Authorization Decision Algorithm

## Staff

```text
1. Authenticate
2. Resolve user_profile
3. Resolve active organization_member
4. Resolve active member_role
5. Resolve required permission
6. Resolve target organization/workspace/event
7. Validate scope
8. Validate ownership
9. Validate domain rule
10. Allow
```

## Client

```text
1. Authenticate
2. Resolve active client_access
3. Resolve workspace
4. Resolve client-visible capability
5. Validate ownership
6. Validate client operation
7. Allow
```

## Public Guest

```text
1. Validate token
2. Validate revocation/expiry state
3. Resolve invitation_party
4. Resolve allowed resource
5. Validate public capability
6. Allow
```

Semua failure menghasilkan **DENY**.

---

# 11. Object Ownership Contract

## 11.1 Organization-Owned

```text
organization
organization_settings
organization_member
organization roles
subscription / SaaS billing
organization audit/security records
```

## 11.2 Workspace-Owned

```text
workspace
wedding_profile
couple_person
venue
guest
invitation
website
media
workspace automation
gift configuration
```

## 11.3 Event-Owned

```text
event
event_guest
rsvp
checkin
event-specific operational state
```

## 11.4 Souvenir Ownership

```text
Invitation Party
   ↓
Souvenir Entitlement
   ↓
Souvenir Claim
```

Physical schema menetapkan same-tenant consistency untuk jalur tersebut. fileciteturn4file0L1-L12

---

# 12. RLS Architecture

Semua private business tables wajib mengaktifkan RLS.

```sql
ALTER TABLE <private_table> ENABLE ROW LEVEL SECURITY;
```

Policy harus dipisahkan secara semantik menjadi:

```text
SELECT
INSERT
UPDATE
DELETE
```

Gunakan:

- `USING` untuk menentukan existing rows yang boleh dibaca/ditarget;
- `WITH CHECK` untuk memastikan state baru hasil INSERT/UPDATE tetap berada pada authorized boundary.

`WITH CHECK` wajib melindungi dari mutation seperti:

```text
UPDATE guest
SET workspace_id = another_workspace
```

atau:

```text
UPDATE event
SET organization_id = another_organization
```

---

# 13. Authorization Helper Layer

Authorization helper harus menjadi reusable security primitive.

Recommended functions:

```text
current_user_profile_id()
current_organization_ids()
current_workspace_ids()
current_event_ids()

has_permission(resource, action)
has_organization_permission(organization_id, resource, action)
has_workspace_permission(workspace_id, resource, action)
has_event_permission(event_id, resource, action)
```

Untuk domain operasional wedding, gunakan scope resolver yang mengikuti hierarchy Organization → Workspace → Event.

Nama exact dapat mengikuti implementasi, tetapi semantics harus tetap sama.

Helper harus:

- deterministic;
- side-effect free;
- security-conscious;
- menghindari recursive RLS evaluation;
- `STABLE` bila valid secara semantik;
- tidak bergantung pada hidden UI state.

Realtime harus reuse authorization scope yang sama, bukan membuat sistem authorization kedua.

---

# 14. RLS Policy Patterns

## 14.1 Organization Resource

Conceptual read:

```text
organization.id ∈ authorized organization scope
AND has_permission('organization', 'read')
```

Mutation membutuhkan permission yang sesuai.

## 14.2 Workspace Resource

```text
workspace.id ∈ current_workspace_ids()
AND permission('workspace', action)
```

## 14.3 Event Resource

```text
event.id ∈ current_event_ids()
AND permission('event', action)
```

## 14.4 Child Resources

Child rows harus memvalidasi entire ownership path.

Contoh:

```text
event_guest
  ↓ event
workspace
  ↓ organization
```

```text
rsvp
  ↓ event_guest
  ↓ event
  ↓ workspace
  ↓ organization
```

```text
souvenir_claim
  ↓ souvenir_entitlement
  ↓ invitation_party
  ↓ workspace
  ↓ organization
```

Client-supplied foreign key tidak boleh dianggap sebagai proof of authorization.

---

# 15. Preventing Tenant Escape

Database boundary harus menolak normal CRUD seperti:

```text
Organization A user
    ↓
UPDATE row owned by Organization B
```

atau:

```text
INSERT event_guest
(event_id from Org B, guest from Org A)
```

Minimum defense:

1. foreign keys/composite foreign keys bila tepat;
2. RLS `USING`;
3. RLS `WITH CHECK`;
4. trusted write path;
5. domain validation.

Physical schema memang mengharuskan same-tenant integrity pada ownership-sensitive relationships dan menyarankan composite FK bila tepat. fileciteturn4file1L1-L38

---

# 16. Client Authorization

Client access menggunakan `client_access`, bukan staff membership.

Conceptual predicate:

```text
client_access.user_profile_id = current user
AND client_access.status = active
AND target.workspace_id = authorized workspace
```

Client capability harus whitelist-based.

Minimum client restriction:

```text
DENY organization.members.*
DENY organization.roles.*
DENY organization.billing.manage
DENY security_event.*
DENY staff-only operational data
DENY other workspaces
```

Client tidak boleh mewarisi staff role secara implicit.

Exact writable fields belum dikunci oleh source; API/use-case layer harus menetapkannya per use case dan tidak boleh coding agent mengarang broad write access.

ADR-003 menetapkan Couple/Client sebagai separate client access context dan ADR-013 menegaskan server-side enforcement + database isolation. fileciteturn4file2L1-L35

---

# 17. Public Guest Authorization

Public guest access tidak boleh dibuat sebagai unrestricted anonymous SELECT terhadap private tables.

Rejected pattern:

```text
anon → SELECT invitation
```

Preferred:

```text
public token
   ↓
validated token context
   ↓
invitation_party
   ↓
minimum allowed resource
```

Public context harus mencegah:

```text
list all guests
list invitation parties
list all RSVP
browse organization/workspace data
staff endpoints
UUID enumeration as authorization
```

Token adalah security credential.

ADR-014 menetapkan token harus non-guessable, tidak berupa raw database ID, tidak memperluas tenant scope, dan dapat dicabut/expired sesuai policy. fileciteturn4file2L1-L35

---

# 18. Token and QR Security

Jangan menjadikan:

```text
guest.uuid
event.uuid
invitation_party.uuid
```

sebagai secret credential.

Gunakan opaque random secret/token dan simpan representasi hashed/server-side bila implementasi membutuhkan lookup aman.

Satu QR = satu Invitation Party.

QR resolution harus menghasilkan satu invitation-party context lalu menjalankan domain authorization yang sesuai.

Memiliki QR tidak memberi staff authority.

---

# 19. Check-in Authorization

Baseline:

```text
Check-in Staff
   ↓
Assigned Event
   ↓
checkin.read
checkin.create
```

`checkin.correct` adalah permission terpisah.

Check-in staff tidak otomatis mendapatkan:

```text
guest.delete
organization.roles.*
organization.billing.*
```

Physical schema menetapkan uniqueness/idempotency check-in; authorization layer hanya menentukan **siapa** yang boleh mengoperasikan aksi tersebut, sedangkan transaction/domain layer memastikan duplicate scan tidak menghasilkan state yang salah.

---

# 20. Souvenir Authorization

## 20.1 Entitlement Override

```text
authorized staff
  ↓
workspace/event ownership
  ↓
explicit souvenir override permission
  ↓
reason required
  ↓
quantity validation
  ↓
override + audit
```

Constraint dari schema/domain:

```text
default entitlement mengikuti invited count
override membutuhkan alasan
new entitlement tidak boleh < claimed quantity
```

## 20.2 Claim

```text
authorization
+
entitlement resolution
+
remaining quantity validation
+
atomic transaction
+
idempotency
+
audit
```

## 20.3 Proxy Claim

```text
proxy claim
   ↓
staff authorization
   ↓
staff confirmation
   ↓
atomic claim
```

Possession of guest QR bukan pengganti staff confirmation.

---

# 21. Role and Membership Administration

Required permissions:

```text
organization.members.manage
organization.roles.manage
```

Security rules:

- cross-organization role assignment = DENY;
- workspace scope harus berada dalam organization target;
- event scope harus berada dalam workspace target;
- inactive membership tidak menghasilkan effective staff access;
- removal membership harus segera menghilangkan effective access;
- caller tidak boleh mendelegasikan authority yang melampaui delegation boundary-nya.

---

# 22. Self-Escalation Prevention

Harus ditolak:

```text
User
 ↓
organization.roles.manage
 ↓
grant self Organization Owner
```

Juga:

```text
Event-scoped user
 ↓
assign organization-wide authority
```

dan:

```text
Org A role manager
 ↓
assign role in Org B
```

Role administration membutuhkan dua pemeriksaan:

```text
permission to manage roles
+
maximum authority/scope caller may delegate
```

---

# 23. Platform Super Admin

Platform Super Admin berada di platform security context, bukan ordinary organization RBAC.

Platform access harus:

- explicit;
- auditable;
- rare;
- tidak diekspos sebagai generic browser-side role;
- tidak menghapus kebutuhan business authorization ketika bertindak atas nama user.

---

# 24. Service Role / Trusted Backend

Supabase service-role credential bypasses normal RLS.

Karena itu:

```text
service_role ≠ user authorization
```

Service-role hanya boleh dipakai pada trusted backend/system path.

Saat backend bertindak atas nama user, tetap jalankan:

```text
tenant resolution
+
business authorization
+
domain validation
```

Jangan expose service-role credential ke browser, mobile app, atau public guest client.

---

# 25. Billing Entitlement Boundary

RBAC dan subscription entitlement dipisahkan:

```text
Permission
= apakah user boleh melakukan aksi

Entitlement
= apakah feature tersedia pada plan/subscription
```

Untuk feature yang memang gated:

```text
Permission ✅
+
Entitlement ✅
=
ALLOW
```

Entitlement bukan pengganti authorization.

---

# 26. Audit and Security Evidence

Security-sensitive actions minimal menghasilkan audit evidence sesuai domain audit policy.

Baseline event classes:

```text
member.removed
member.role_changed
role.created
role.updated
role.deleted
client_access.granted
client_access.revoked
invitation.token.revoked
checkin.created
checkin.corrected
souvenir.entitlement.overridden
souvenir.claim.created
souvenir.claim.rejected
security-sensitive authorization denial
support/platform access
```

Physical schema memiliki `audit_log` dengan ownership context dan actor/request metadata.

Audit adalah evidence, bukan source of permission.

---

# 27. Denial Semantics

Security layer menghasilkan:

```text
DENY
```

API dapat memetakan unauthorized outcome menjadi 403 atau 404 sesuai security/API contract.

Untuk resource tenant lain, existence tidak boleh dibocorkan hanya karena user tidak authorized.

Exact 403-vs-404 behavior belum dikunci pada dokumen ini.

---

# 28. Realtime Authorization

Realtime tidak boleh mempunyai RBAC kedua.

```text
ordinary authorization scope
        ↓
Realtime authorization
```

Channel authorization wajib reuse scope functions yang sama dengan API dan RLS.

Perubahan membership, role, dan scope harus memengaruhi operational realtime authorization melalui source-of-truth yang sama.

Subscription authorization juga tidak menggantikan resync snapshot setelah reconnect.

---

# 29. Mandatory Authorization Test Matrix

## Tenant Isolation

```text
Org A → Org A resource = ALLOW
Org A → Org B resource = DENY
Anonymous → private resource = DENY
```

## Workspace Scope

```text
W1 scoped user → W1 = ALLOW
W1 scoped user → W2 = DENY
```

## Event Scope

```text
E1 scoped user → E1 = ALLOW
E1 scoped user → E2 = DENY
E1 scoped user → workspace-wide unauthorized mutation = DENY
```

## Membership

```text
Active member → permitted resource = ALLOW
Removed member → same resource = DENY
Inactive member → protected resource = DENY
```

## Multiple Roles

```text
Role A + Role B
→ effective permissions = union of valid grants
```

## Client

```text
Client W1 → allowed client resource W1 = ALLOW
Client W1 → W2 = DENY
Client W1 → staff RBAC = DENY
Client W1 → billing administration = DENY
```

## Public Guest

```text
Valid token → allowed invitation resource = ALLOW
Invalid token → DENY
Expired token → DENY
Revoked token → DENY
Valid token → another guest = DENY
Valid token → organization browse = DENY
```

## Operational Scope

```text
Actor assigned to Event E1
→ E1 operation = ALLOW

Actor assigned to Event E1
→ E2 operation = DENY

Actor assigned to Workspace W1
→ W2 operation = DENY
```

## Escalation

```text
Scoped role → self-promote = DENY
Scoped role → cross-tenant assignment = DENY
Unauthorized role manager → grant Owner = DENY
```

## Critical Mutations

```text
duplicate check-in → idempotent
concurrent souvenir claim → cannot exceed entitlement
duplicate claim retry → idempotent
unauthorized entitlement override → DENY
proxy claim without staff confirmation → DENY
```

---

# 30. Non-Negotiable Coding Agent Guardrails

Coding agent MUST NOT:

1. membuat global `user_role` yang mengabaikan tenant/scope;
2. menjadikan hidden UI sebagai authorization;
3. mempercayai client-supplied `organization_id`, `workspace_id`, atau `event_id` sebagai proof of access;
4. membuat anonymous unrestricted SELECT terhadap private business tables;
5. menggunakan UUID invitation sebagai secret credential;
6. memberikan scoped role implicit organization-wide access;
7. membuat client mewarisi staff permissions;
8. menaruh service-role credential pada frontend/mobile;
9. menonaktifkan RLS untuk mempermudah development;
10. mengizinkan ownership-changing CRUD melalui ordinary client mutation;
11. membuat realtime authorization model kedua;
12. membuat operational scope di luar hierarchy Organization → Workspace → Event;
13. mengubah Accepted ADR tanpa revision/addendum;
14. membuat permission synonyms yang menciptakan duplicate semantics.

---

# 31. Explicitly Deferred Decisions

| Topic | Status | Next Contract |
|---|---|---|
| Exact client writable fields | Open | API / Use Cases |
| Public RSVP expiry | Deferred | Security / Use Cases |
| Detailed platform support permissions | Deferred | Platform Administration |
| Exact 403 vs 404 behavior | Deferred | API Contract |
| Billing feature matrix | Deferred | Billing/Product |
| Audit retention period | Deferred | Security/NFR |
| Offline/degraded authorization | Deferred | Check-in Technical/NFR |
| Exact SQL policy text and migration order | Implementation detail | Engineering/Migrations |

Tidak ada ambiguity pada baseline architecture yang mengharuskan keputusan user baru sebelum API Contract.

---

# 32. Implementation Order

```text
01 Supabase Auth
02 user_profile
03 organization
04 organization_member
05 role
06 permission
07 role_permission
08 workspace
09 member_role
10 client_access
11 authorization helper layer
12 daily operational scope resolver where applicable
13 RLS organization/workspace
14 RLS child domain tables
15 public invitation access path
16 security audit
17 authorization test suite
18 realtime authorization tests
```

Authorization helper layer harus dibuat sebelum puluhan individual table policies supaya semantics tidak terduplikasi.

Physical schema migration order sudah menempatkan helper foundation, identity, RBAC, membership, workspace, scope assignment, client access, lalu domain entities. fileciteturn4file1L1-L45

---

# 33. Final Authorization Contract

```text
                     Supabase Auth
                           ↓
                  Identity Classification
                           ↓
          ┌────────────────┼────────────────┐
          ↓                ↓                ↓
        Staff            Client          Public
          ↓                ↓                ↓
    Membership       client_access      token context
          ↓                ↓                ↓
        Roles          Workspace       Invitation Party
          ↓                ↓                ↓
     Permissions     Client Rules     Guest Capability
          └────────────────┼────────────────┘
                           ↓
                     Scope Resolution
                           ↓
                    Object Ownership
                           ↓
                      Domain Rules
                           ↓
                           RLS
                           ↓
                      ALLOW / DENY
```

Core rule:

> Authentication menentukan identitas. Permission menentukan aksi. Scope menentukan lokasi akses. Ownership menentukan resource boundary. Domain rules menentukan validitas aksi. RLS memastikan database tetap terisolasi ketika application layer mengalami kesalahan.

Untuk domain operasional wedding, Organization → Workspace → Event menjadi source of truth untuk operational scope.

---

# 34. Downstream Contract

Dokumen ini menjadi constraint untuk:

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

API Contract tidak boleh mendefinisikan endpoint yang memberikan akses lebih luas daripada authorization contract ini.

---

# 35. Source Traceability

- Architecture Decision Record — tenant boundary, workspace model, client separation, multiple roles, scope assignment, server-side authorization, public guest separation, current-state/history, id+uuid convention, and deterministic ownership. fileciteturn4file2L1-L35
- Domain/Core/Multi-Tenant/RBAC — conceptual role/permission/scope foundation, ownership, public access constraints, and authorization model. fileciteturn4file15L1-L35
- Physical Database Schema — concrete `organization_member`, `role`, `permission`, `role_permission`, `member_role`, `client_access`, ownership conventions, same-tenant integrity, migration order, and seed baseline. fileciteturn4file0L1-L12 fileciteturn4file4L1-L45
- Realtime authorization — reuse of existing scope functions for channel authorization.
- `PWS_Glossary_v0.1.md` — exclusion of non-wedding operational terms.

---

## Status

**Authorization + RLS Specification v0.1 — Baseline complete.**

No new user decision is required to proceed to the next downstream document: **API Contract v0.1**.
