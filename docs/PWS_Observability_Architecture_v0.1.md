# PWS_Observability_Architecture_v0.1.md

## 1. Tujuan
Dokumen ini menjelaskan arsitektur observabilitas yang akan diterapkan pada MVP Premium Wedding SaaS. Fokusnya pada pengumpulan log, metrik, trace, serta alert yang cukup untuk mendeteksi masalah keamanan, performa, dan reliability tanpa menambah biaya signifikan pada fase beta.

## 2. Lingkup MVP
- **Log**: Vercel request logs, Supabase database logs, Supabase auth logs.
- **Metrik**: request count, latency, error rate, check‑in success rate, souvenir claim rate, RLS denial count.
- **Trace**: distribusi request ID (`request_id`) di seluruh layanan (frontend, API, Supabase Edge Function).
- **Alert**: threshold sederhana pada error rate, RLS denial spikes, backup failure, webhook verification failure.
- **Dashboard**: Vercel analytics + optional Grafana (deferred).

Komponen yang **tidak** termasuk dalam MVP: distributed tracing dengan OpenTelemetry, log aggregation ke Loki/Elastic, APM premium, long‑term retention > 30 hari. Semua akan ditambahkan pada fase V1/V2.

## 3. Komponen Observabilitas
| Komponen | Deskripsi | Implementasi MVP |
|----------|-----------|-----------------|
| **Request Logging** | Setiap HTTP request menghasilkan log struktur JSON yang berisi `timestamp`, `request_id`, `method`, `path`, `status`, `latency_ms`, `tenant_id`, `user_id`, `actor_type` (staff, client, public). | Vercel automatically logs request details. Custom middleware di Next.js menambahkan `request_id` ke header `x-request-id` dan merangkumnya ke log.
| **Database Logging** | Log query yang gagal, RLS denial, dan audit events (`member.removed`, `invitation.token.revoked`, `souvenir.claim.created`). | Supabase audit log (`audit_log` table) sudah ada; di‑enable `log_statement = 'all'` pada free tier default. 
| **Auth Logging** | Log login success/failure, token revocation, MFA (jika nanti). | Supabase Auth menyediakan audit event `auth_event` yang dapat di‑query.
| **Metric Collection** | Counter untuk: total request, successful request, error (5xx), RLS denial, check‑in success, souvenir claim success, webhook success/failure. Histogram latency per endpoint. | Vercel analytics menyediakan hit count & latency; custom endpoint `/api/metrics` mengekspor JSON untuk prom‑push ke external service (deferred). 
| **Alerting** | Alert ketika: error rate > 5 % per 5 menit, RLS denial spike > 100 per menit, backup job gagal, webhook verification gagal. | Vercel Alerts (email/Slack) untuk error rate; GitHub Action yang memeriksa backup log dan mengirim ke Slack bila gagal.
| **Dashboard** | Visualisasi request volume, latency, error rate, check‑in / souvenir claim KPI, audit events terakhir. | Vercel dashboard + static page `docs/observability.html` yang menampilkan data dari `/api/metrics` (JSON). 

## 4. Alur Data Observability
```text
Client → Vercel Edge (Next.js) → Middleware (add request_id) → API Route → Supabase JS client → DB
   ↑                     ↓                                   ↓
  Log (Vercel)   →   Log (custom)                →   Audit log (Supabase)
```
- **Request ID**: Dihasilkan di middleware, diteruskan ke semua panggilan internal (API, Edge Function, webhook). 
- **Correlation**: Semua log (frontend, API, Edge Function, DB) menyertakan `request_id` sehingga dapat dikelompokkan.
- **Retention**: Log Vercel dipertahankan selama 30 hari (free tier). Supabase audit log dipertahankan selama 7 hari (sesuai backup retention).

## 5. Implementasi Middleware (Next.js)
```js
import { v4 as uuidv4 } from 'uuid'
export default function handler(req, res) {
  const requestId = req.headers['x-request-id'] ?? uuidv4()
  res.setHeader('x-request-id', requestId)
  // attach to supabase client for db audit
  req.context = { requestId }
  // proceed to actual handler
}
```
- Middleware menambahkan `request_id` ke setiap response.
- Di setiap service, gunakan `req.context.requestId` untuk mencatat audit.

## 6. Metric Endpoint (optional prom‑push)
`/api/metrics` mengembalikan JSON:
```json
{ "requests_total": 1245, "requests_success": 1190, "requests_error": 55, "latency_ms": { "p50": 120, "p95": 350 }, "checkin_success": 342, "souvenir_claim_success": 78 }
```
Vercel dapat meng‑export ke external Prometheus pada fase V1.

## 7. Alert Routing
- **Slack channel** `#ops-alerts` (dibuat di workspace). 
- **Email** ke `ops@example.com` untuk fallback.
- **Alert webhook** untuk backup failure: GitHub Action `backup-check.yml` mengirimkan status ke Slack.

## 8. Acceptance Criteria (MVP)
1. Setiap request memiliki `x-request-id` dan tercatat di Vercel logs.
2. Audit log mencatat semua perubahan kritis (role, member, invitation token, souvenir claim).
3. Metrik request count, error rate, dan latency dapat di‑lihat di Vercel dashboard.
4. Alert error rate > 5 % selama 5 menit terkirim ke Slack.
5. Alert backup failure (script exit non‑zero) terkirim ke Slack.
6. RLS denial count dapat di‑query dan tidak melebihi 0 pada operasi staff yang sah.
7. Log tidak mengandung credential, secret, atau payload sensitif.
8. Semua log dipertahankan minimal 30 hari (Vercel) atau 7 hari (Supabase) sesuai kebijakan.

## 9. Guardrail untuk AI Agent Code
- **Jangan** menulis log yang berisi `password`, `token`, atau `secret`.
- **Jangan** mengirim `request_id` ke client selain header `x-request-id`.
- **Jangan** menonaktifkan logging pada endpoint kritis.
- **Jangan** mengubah struktur log setelah produksi tanpa migrasi versi.
- **Jangan** menambah penyimpanan log di luar free tier tanpa keputusan budget.

## 10. Roadmap ke V1/V2 (deferred)
- Integrasi Grafana + Loki untuk log aggregation.
- OpenTelemetry SDK untuk distributed tracing.
- Retention log > 30 hari dan audit archive.
- Alert threshold koreksi (dynamic baselines).
- Dashboard custom dengan Grafana.

## 11. Status
**Baseline MVP selesai** – observabilitas dasar tersedia melalui Vercel, Supabase logs, dan simple alert.

## 12. Referensi
- `PWS_Release_Roadmap_and_Zero_Cost_Strategy_v0.1.md`
- `PWS_Security_NFR_Specification_v0.1.md`
- `PWS_Engineering_Implementation_Blueprint_v0.1.md`
- Vercel docs: *Logging & Analytics*.
- Supabase docs: *Audit Log* dan *RLS*.
