# Premium Wedding SaaS — Release Roadmap & Zero-Cost Beta Strategy

**Document ID:** PWS-ROADMAP-001  
**Version:** 0.1  
**Status:** Draft  
**Date:** 2026-08-24  
**Product:** Premium Wedding SaaS

---

# 1. Purpose

This document defines:

1. Release boundaries for MVP, V1, V2, and Future.
2. Feature priorities.
3. Dependency order.
4. Beta strategy using a **0-cost / near-zero-cost infrastructure target**.
5. Rules for deciding when to move from free services to paid infrastructure.

This document intentionally does **not** finalize the production technology stack.

---

# 2. Release Philosophy

The product should evolve in controlled layers:

```text
FOUNDATION
   ↓
MVP
   ↓
PREMIUM V1
   ↓
ADVANCED V2
   ↓
WEDDING OPERATING SYSTEM
   ↓
ECOSYSTEM / MARKETPLACE
```

The team should avoid adding features from a later phase into an earlier release unless the feature is required by a critical dependency.

---

# 3. Priority Model

## P0 — Critical

Required for the product to function.

## P1 — Core Premium

Strong commercial value and directly improves the primary wedding workflow.

## P2 — Differentiator

Meaningful differentiation but not required for initial commercial validation.

## P3 — Future

Useful expansion, enterprise, ecosystem, or platform capability.

---

# 4. MVP — Commercial Beta

## Goal

Prove the fundamental product loop:

```text
Organization
→ Wedding
→ Invitation Website
→ Guest Database
→ Personalized Invitation
→ RSVP
→ QR Check-in
→ Attendance Dashboard
→ SaaS Billing
```

## P0 MVP Modules

### Platform

- Authentication
- Organization
- Workspace
- Basic roles
- Basic permissions
- Subscription state

### Wedding

- Couple
- Wedding profile
- Event
- Venue

### Website

- Theme
- Core sections
- Basic customization
- Preview
- Publish
- Mobile responsive
- Personalized guest URL

### Guests

- Guest CRUD
- Groups
- Tags
- Import CSV/Excel
- Export
- Search/filter

### Invitation

- Unique token
- Personalized greeting
- Share link
- QR
- Basic invitation status

### RSVP

- RSVP
- Plus-one
- Attendance state
- RSVP dashboard

### Check-in

- QR scanner
- Manual lookup
- Check-in
- Duplicate protection
- Attendance count

### Billing

- SaaS subscription
- One payment gateway
- Payment status
- Receipt/invoice record

### Analytics

- Guest count
- RSVP count
- Attendance
- Invitation state

---

# 5. MVP Out of Scope

Explicitly defer:

- Full CRM
- Vendor marketplace
- White-label
- Advanced automation engine
- AI assistant
- Complex seating intelligence
- Full WhatsApp API automation
- Multi-provider payment routing
- Advanced financial settlement
- Marketplace
- Theme marketplace

These can be designed for future compatibility without implementing them.

---

# 6. V1 — Premium Commercial Release

## Goal

Turn the beta into a clearly premium product.

### Guest Operations

- Advanced segmentation
- Duplicate detection
- Guest history
- Family relationships
- Advanced bulk tools

### Messaging

- WhatsApp integration
- Email
- Templates
- Variables
- Scheduling
- Reminder campaigns
- Delivery status

### Event

- Multiple events
- Event-specific guests
- Event-specific RSVP

### Seating

- Table manager
- Capacity
- Guest assignment
- Visual planner

### Gift

- Digital gift
- QRIS readiness
- Payment link
- Gift history

### Media

- Guest uploads
- Live gallery
- Moderation readiness

### Analytics

- Invitation funnel
- RSVP conversion
- Check-in trends
- Gift analytics

### Team

- Staff permissions
- Assignments
- Activity timeline

---

# 7. V2 — Advanced Operations

## Goal

Create strong operational differentiation.

### Automation

```text
Trigger
→ Condition
→ Action
```

### Check-in

- Multiple gates
- Offline operation
- Reconciliation
- Live gate metrics

### Seating intelligence

- Smart recommendations
- Relationship-aware grouping
- Conflict detection

### CRM

- Leads
- Pipeline
- Proposals
- Contract state
- Client history
- Follow-up
- Referral tracking

### Analytics

- Predictive readiness
- Operational insights
- Financial trends

### AI

- Wedding Copilot
- Copy generation
- Analytics assistant
- Guest segmentation assistant
- Seating recommendation

### Platform

- Custom domains
- Advanced theme builder
- Advanced permissions

---

# 8. Future — Wedding Operating System

## Goal

Move from event product to complete wedding-business platform.

### White-label

- Custom brand
- Custom domain
- Custom login
- Custom templates
- Custom messaging identity
- Custom packaging

### Marketplace

- Venue
- Photographer
- MUA
- Decoration
- Catering
- Entertainment
- Souvenir
- Other vendors

### Vendor System

- Vendor CRM
- Contracts
- Scheduling
- Payments
- Ratings

### Ecosystem

- Public API
- Webhooks
- Integration marketplace
- Theme marketplace
- Automation marketplace
- Third-party applications

---

# 9. Dependency Graph

Recommended dependency order:

```text
AUTH
  ↓
ORGANIZATION
  ↓
WORKSPACE
  ↓
RBAC
  ↓
WEDDING
  ↓
EVENT
  ↓
WEBSITE / THEME
  ↓
GUEST
  ↓
INVITATION
  ↓
RSVP
  ↓
QR
  ↓
CHECK-IN
  ↓
ANALYTICS
```

Parallel capability tracks:

```text
PAYMENT
COMMUNICATION
MEDIA
AUDIT
OBSERVABILITY
```

Advanced dependencies:

```text
GUEST + INVITATION + RSVP
          ↓
      AUTOMATION

GUEST + EVENT + RSVP
          ↓
       SEATING

ORGANIZATION + CLIENT + WEDDING
          ↓
          CRM

ALL DOMAINS
          ↓
         AI
```

---

# 10. Zero-Cost Beta Strategy

## Target

During beta, the infrastructure goal is:

> **$0 monthly infrastructure spend where practical, while preserving a migration path to production-grade paid plans.**

"Zero cost" does not mean "production SLA." Free plans may have restrictions such as pausing, quotas, limited backups, low resource limits, or missing enterprise features.

Therefore:

```text
BETA
Free / open-source
    ↓
VALIDATION
Low-cost
    ↓
PRODUCTION
Paid / managed
```

---

# 11. Candidate Beta Infrastructure

These are **candidates**, not final architecture decisions.

## Option A — Supabase-centered

Potential role:

- PostgreSQL
- Authentication
- Realtime
- Basic storage
- Server-side functions

Current official pricing information lists a Free plan at $0 with 500 MB database size per project, 1 GB file storage, 5 GB egress, and 50,000 monthly active users. Free projects can pause after inactivity and the Free tier has limitations such as no automatic backups. Re-validate limits before implementation. 

Candidate fit:

```text
Database       ✅
Auth           ✅
Realtime       ✅
Basic Storage  ✅
```

Main caution:

- Free-tier database/storage limits
- Pausing
- Production backup requirements
- Media-heavy wedding galleries can consume storage quickly

---

## Option B — Cloudflare-centered

Potential role:

- Edge application/API
- Static/public invitation delivery
- Object storage
- Cache/CDN
- Scheduled/edge workloads

Cloudflare Workers Free currently includes 100,000 requests/day, with defined CPU and platform limits. Cloudflare R2 currently lists a free tier of 10 GB-month storage, 1 million Class A requests/month, 10 million Class B requests/month, and no egress bandwidth charges. Re-validate before implementation. 

Candidate fit:

```text
Public Invitation     ✅
Edge API               ✅
Media/Object Storage   ✅
CDN                    ✅
Scheduled Work         ✅
```

Main caution:

- Platform-specific runtime constraints
- More architectural decisions around persistence
- Need careful separation between domain logic and provider APIs

---

# 12. Recommended Beta Architecture Direction

Without locking the framework, the preferred beta direction is:

```text
                    USER
                     │
        ┌────────────┴────────────┐
        │                         │
 Public Invitation           Admin App
        │                         │
        └────────────┬────────────┘
                     │
                Application
                    API
                     │
        ┌────────────┼────────────┐
        │            │            │
     Postgres      Storage      Jobs
        │            │            │
        └────────────┴────────────┘
                     │
                Integrations
              ┌──────┼──────┐
              │      │      │
           Payment WhatsApp Email
```

Preferred design rule:

> Business logic must not be tightly coupled to one hosting/provider SDK.

---

# 13. Zero-Cost Rules

## Rule 1 — No paid dependency for core business logic

Authentication, guests, weddings, RSVP, and check-in must not require a paid third-party service just to function.

## Rule 2 — Provider abstraction

Create internal interfaces for:

- Payment
- Messaging
- Storage
- Email
- Analytics

## Rule 3 — Media discipline

Do not treat high-resolution original media as unlimited free storage.

## Rule 4 — Usage visibility

Free-tier usage should be monitored.

## Rule 5 — No accidental paid overages

Development credentials and production credentials must be separated.

## Rule 6 — Webhook-first payments

Payment status must be verified from provider events, not assumed from frontend redirects.

## Rule 7 — Exportability

Core data must be exportable.

---

# 14. Payment Strategy

## Phase MVP

Implement one gateway through an abstraction layer.

Required capabilities:

- Create payment
- Receive callback/webhook
- Verify transaction
- Update payment status
- Handle failure
- Record transaction
- Idempotency

## V1

Add:

- Digital gift payments
- Multiple payment methods
- Payment link
- Gift history
- Financial reporting

## V2

Potentially add:

- Multiple providers
- Provider fallback
- Split payment
- Settlement tracking
- Reconciliation
- Refund workflow

## Future

Potentially:

- Marketplace payments
- Vendor payouts
- Platform commissions
- Multi-party settlement

Payment architecture must clearly distinguish:

```text
SaaS Billing
≠
Wedding Gift
≠
Vendor Marketplace Payment
```

---

# 15. Messaging Strategy

## MVP

Manual share / basic communication.

## V1

- WhatsApp integration
- Email
- Templates
- Variables
- Campaigns
- Reminders
- Delivery status

## V2

- Automated workflows
- Scheduled campaigns
- Event-triggered messages

## Future

- Omnichannel communication
- Campaign analytics
- CRM messaging
- Vendor/client messaging

---

# 16. AI Cost Strategy

AI should not be a mandatory dependency for MVP.

Recommended progression:

```text
MVP
No AI dependency
       ↓
V1
Optional AI utilities
       ↓
V2
AI Copilot
       ↓
Future
AI-powered operations
```

For beta experimentation, a provider with a free allocation can be evaluated. For example, Cloudflare Workers AI currently provides a free allocation of 10,000 neurons/day, although some models now require the Workers Paid plan. This must be treated as an experimental capability, not a guarantee of a zero-cost production AI layer. 

---

# 17. Release Gates

## MVP Gate

Do not leave MVP until:

- End-to-end invitation flow works.
- RSVP data is consistent.
- QR check-in works reliably.
- Tenant isolation is verified.
- Payment webhook handling is verified.
- Data export works.
- Core mobile experience is acceptable.

## V1 Gate

Do not leave V1 until:

- Messaging is reliable.
- Guest segmentation works.
- Seating workflow is usable.
- Gift/payment flow is auditable.
- Analytics are actionable.

## V2 Gate

Do not leave V2 until:

- Automation is observable.
- Check-in recovery behavior is defined.
- CRM workflows are coherent.
- AI outputs are bounded and reviewable.

---

# 18. Beta to Production Migration Triggers

Move away from free infrastructure when any of these become true:

- Data size approaches service limits.
- Free project pausing becomes unacceptable.
- Backup requirements exceed free capabilities.
- Traffic becomes commercially significant.
- Realtime usage becomes large.
- Media storage becomes expensive or operationally risky.
- Support/SLA requirements appear.
- Payment volume becomes material.
- Organization isolation requires stronger infrastructure controls.

---

# 19. Planned Documentation Sequence

The project should maintain a versioned documentation set.

## Product

1. `Premium_Wedding_SaaS_PRD`
2. `Premium_Wedding_SaaS_Release_Roadmap_and_Zero_Cost_Strategy`
3. Product glossary
4. User stories
5. Acceptance criteria
6. Feature entitlement matrix

## Architecture

7. Domain model
8. System architecture
9. Multi-tenant architecture
10. Data model
11. API contract
12. Event/workflow model
13. ADR set

## Security

14. Security baseline
15. RBAC matrix
16. Threat model
17. Data privacy model
18. Audit log policy

## Payments

19. Payment architecture
20. SaaS billing specification
21. Digital gift specification
22. Payment webhook specification
23. Reconciliation specification

## Product Experience

24. UX architecture
25. Design system
26. Invitation theme specification
27. Admin dashboard specification
28. Check-in experience specification

## Operations

29. Test strategy
30. Deployment guide
31. Monitoring
32. Incident response
33. Backup/recovery
34. Environment management
35. Release checklist

---

# 20. Current Decision Log

| Decision | Status | Notes |
|---|---|---|
| Product is SaaS | Approved | Multi-client wedding/event organization |
| Multi-tenant model | Approved | Foundational requirement |
| Premium positioning | Approved | Not a basic invitation generator |
| MVP/V1/V2/Future separation | Approved | Controlled scope |
| Payment gateway | Required | Provider not permanently locked |
| Digital gift | Required | V1 target |
| CRM | Planned | V2 |
| Automation engine | Planned | V2 |
| AI | Planned | V2 |
| White-label | Future | Enterprise direction |
| Marketplace | Future | Ecosystem direction |
| Tech stack | Not locked | Must follow architecture review |
| Beta infrastructure | 0-cost target | Validate limits before implementation |

---

# 21. Immediate Next Documentation Gate

Before coding, create and approve:

1. **Domain Model**
2. **Core Entity/Data Model**
3. **Multi-Tenant Architecture**
4. **RBAC & Permission Matrix**
5. **Payment Architecture**
6. **Invitation Token / Guest Identity Specification**
7. **Messaging Architecture**
8. **MVP User Stories + Acceptance Criteria**
9. **UI/UX Information Architecture**
10. **Architecture Decision Records**

Only after those documents are stable should the final technology stack be selected.

---

# 22. Current Recommendation

The strongest path for the beta is:

```text
Keep the PRODUCT scope ambitious
        +
Keep the MVP implementation narrow
        +
Keep the DOMAIN architecture extensible
        +
Keep infrastructure cost near zero
        +
Keep provider dependencies replaceable
```

This prevents the beta from becoming either:

- a tiny throwaway invitation site that requires a migration later, or
- an overbuilt enterprise system that cannot validate the business quickly.

---

# 23. Documentation Rule

Every major product/architecture decision should be documented before implementation.

Do not rely on chat history as the project's only source of truth.

The repository/project documentation should become the canonical record.
