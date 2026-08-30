# PWS_Engineering_Implementation_Blueprint_v0.1.md

## Tujuan
Dokumen ini mendefinisikan arsitektur teknis, stack, proses implementasi, dan deployment untuk MVP Premium Wedding SaaS. Dokumen ini dipakai sebagai batas teknis sebelum coding, bukan izin otomatis untuk coding.

## Posisi Tahap
Status proyek saat ini: **documentation readiness**. Implementasi baru boleh dimulai setelah seluruh gate pada dokumen ini dan dokumen upstream disetujui eksplisit oleh pengguna.

### 1. Keputusan yang sudah final
| Area | Keputusan | Alasan |
|------|-----------|--------|
| **Framework UI** | **Next.js + TypeScript** – satu repo full‑stack, integrasi mudah dengan Supabase Auth, API Routes untuk backend, ISR untuk halaman publik. |
| **Hosting** | **Vercel** – free tier cukup untuk beta, CI/CD otomatis, preview deploy, edge caching untuk invitation static page. |
| **Media storage** | **Supabase Storage** – terintegrasi dengan RLS, kuota gratis cukup untuk gambar kecil selama beta. |
| **Data test/dev** | **Data sintetis** – generator dummy data untuk development & CI, tidak memakai data tamu nyata. |
| **Payment provider** | **Midtrans** (locked per ADR-010) – provider Indonesia dengan webhook signed, cocok untuk SaaS subscription. |
| **Public RSVP expiry** | **Valid sampai akhir event** – token tetap aktif hingga `event.end_at`; setelah itu otomatis dianggap kedaluwarsa. |
| **Client edit permission** | **Read‑only untuk client/couple** – hanya staff yang dapat mengubah data wedding, website, dan guest; client hanya dapat melihat. |
| **Check‑in mode** | **Online‑only** – check‑in harus terhubung ke API realtime; tidak ada fallback offline untuk MVP. |

### 2. Komponen teknis MVP
| Komponen | Teknologi | Catatan |
|----------|-----------|--------|
| **Frontend publik** | Next.js + TypeScript + TailwindCSS | SSR untuk SEO, halaman invitation publik, dan admin portal terpisah secara route. |
| **Admin portal** | Next.js protected routes + Supabase Auth SDK | UI role-based, hanya untuk staff/client sesuai kontrak akses. |
| **API / Business logic** | Next.js API Routes atau server actions terpilih | Menggunakan Supabase JS client dan service layer domain. Pilihan detail runtime tetap harus mengikuti keputusan implementasi yang disetujui. |
| **Realtime** | Supabase Realtime (WebSocket) | Untuk dashboard dan status operasional yang memang memerlukan update cepat. |
| **Database** | PostgreSQL (Supabase) | Mengikuti `PWS_Physical_Database_Schema_v0.1.md`; RLS aktif pada private tables. |
| **Job / Worker** | Supabase Edge Functions atau mekanisme worker yang disetujui | Dipakai untuk webhook handling, retry, dan side effect asinkron. |
| **Observability** | Log dasar Vercel + Supabase | Detail stack observability lanjutan tetap *deferred* sampai keputusan khusus disetujui. |
| **CI/CD** | GitHub Actions + Vercel | Lint, type-check, test, dan deploy preview/production. |
| **Backup** | Backup otomatis Supabase | Retensi dan recovery mengikuti dokumen backup-retention yang sudah dibuat. |

### 3. Alur Build & Deploy (pipeline)
1. **Commit** → PR → *Review* → **GitHub Actions**
   - `npm ci` → `npm run lint` → `npm run typecheck` → `npm test` (unit + integration).
   - Jika semua lulus → **Vercel Preview Deploy** (branch preview).
2. **Merge ke `main`** → Vercel Production Deploy (auto).
3. **Post‑deploy**
   - Jalankan migrasi DB: `supabase db push`.
   - Seed system roles/permissions (`seed_roles_permissions.ts`).
   - Verifikasi RLS dengan script `scripts/verify-rls.sh`.

### 4. Keputusan *deferred* dan status penyelesaian
| Topik | Status | Dokumen / Tindakan |
|------|--------|----------------------|
| **Public RSVP expiry policy** | Resolved for MVP | `PWS_Public_RSVP_Expiry_Spec_v0.1.md`. |
| **Client writable fields** | Resolved for MVP | `PWS_Client_Writable_Fields_v0.1.md`; client read-only. |
| **Offline / degraded check-in** | Resolved for MVP | `PWS_Checkin_Offline_Strategy_v0.1.md`; online-only. |
| **Backup retention (RPO/RTO)** | Baseline defined | `PWS_Operations_Backup_Retention_v0.1.md`; perlu review operasional sebelum production. |
| **Observability baseline** | Baseline defined | `PWS_Observability_Architecture_v0.1.md`; threshold final tetap perlu review. |
| **Payment implementation detail** | Resolved for MVP | `PWS_Payment_Architecture_v0.1.md` (Midtrans). |
| **Event lifecycle states** | Resolved for MVP | `PWS_Use_Cases_State_Machines_v0.1.md`. |
| **Rate limit defaults** | Resolved | 100 req/min/user, 1000 req/min/org. |
| **403 vs 404 mapping** | Resolved | 403: authd-but-forbidden; 404: not-found-or-enumeration. |
| **Compliance baseline** | Resolved | Indonesia PDP (UU 27/2022). |
| **Messaging implementation detail** | Open | Wajib dibuat: `PWS_Messaging_Architecture_v0.1.md`. |
| **UI/UX implementation detail** | Open | Wajib dibuat: `PWS_UI_UX_Specification_v0.1.md`. |
| **Data governance/privacy** | Open | Wajib dibuat: `PWS_Data_Governance_and_Privacy_v0.1.md`. |
| **Deployment/runbook** | Open | Wajib dibuat: `PWS_Deployment_Guide_and_Runbook_v0.1.md`. |
| **Incident response** | Open | Wajib dibuat: `PWS_Incident_Response_Playbook_v0.1.md`. |
| **Integration test plan** | Open | Wajib dibuat: `PWS_Integration_Test_Plan_v0.1.md`. |
| **MFA / session policy** | Deferred | Revisi Security/NFR bila perlu sebelum production. |

### 5. Struktur repository (contoh)
```
/src
 ├─ /pages          // Next.js pages (public + admin)
 ├─ /components     // UI components (Tailwind)
 ├─ /services       // Domain services (Invitation, RSVP, Check‑in, Souvenir, Billing)
 ├─ /utils          // Helper: auth, rls, idempotency, logger
 └─ /lib            // Supabase client init
/scripts
 ├─ migrate.sh     // DB migration wrapper
 ├─ seed_roles_permissions.ts
 └─ verify-rls.sh
/tests
 ├─ unit/
 └─ integration/
```

### 6. Checklist gate sebelum **Build** dimulai
- [ ] Blueprint ini disetujui eksplisit oleh pengguna.
- [ ] Seluruh dokumen wajib upstream direview dan tidak contradictory.
- [ ] Payment architecture Midtrans disetujui (per ADR-010, locked).
- [ ] Messaging architecture disetujui, atau messaging MVP dinyatakan out of scope.
- [ ] UI/UX specification disetujui.
- [ ] Data governance/privacy disetujui.
- [ ] Deployment guide dan incident runbook disetujui.
- [ ] Integration test plan disetujui.
- [ ] RLS policy SQL dan migration order direview.
- [ ] CI/CD implementation disetujui sebelum file konfigurasi dibuat.
- [ ] Pengguna memberi izin eksplisit untuk mulai membuat file implementasi.

### 7. Aturan Perubahan
- Dokumen ini tidak memberi izin otomatis untuk coding, build, install dependency, deploy, atau membuat konfigurasi.
- Setiap tindakan tersebut harus dimintakan konfirmasi eksplisit terlebih dahulu.
- Keputusan baru yang memengaruhi tenant, authorization, payment, security, atau lifecycle harus dicatat melalui dokumen/ADR yang disetujui.
- AI Agent tidak boleh mengisi bagian yang belum diputuskan dengan asumsi pribadi.

> Catatan: Dokumen ini adalah blueprint teknis, bukan perintah eksekusi.

---

#### Referensi
- `PWS_PRD_v0.1.md`
- `PWS_Architecture_Decision_Record_v0.1.md`
- `PWS_Physical_Database_Schema_v0.1.md`
- `PWS_Authorization_RLS_Specification_v0.1.md`
- `PWS_Release_Roadmap_and_Zero_Cost_Strategy_v0.1.md`
- `PWS_Security_NFR_Specification_v0.1.md`
