# PWS_Integration_Test_Plan_v0.1.md

## 1. Tujuan
Dokumen ini menetapkan rencana integration test untuk Premium Wedding SaaS MVP.

Integration test memeriksa interaksi nyata antara API, database, RLS, domain service, webhook, messaging, realtime, dan browser. Unit test saja tidak cukup untuk membuktikan tenant isolation, transaction integrity, idempotency, dan concurrency.

## 2. Keputusan Test MVP
| Area | Keputusan |
|---|---|
| Database test | Supabase project khusus test. |
| API test | Test route secara langsung. |
| RLS test | Otomatis dan wajib dijalankan di CI. |
| Payment test | Midtrans Sandbox dan mock provider. |
| Messaging test | Provider sandbox/test recipient dan mock provider. |
| Concurrency test | Wajib dijalankan otomatis. |
| Browser E2E | Playwright. |
| Test data | Data sintetis yang terisolasi per test. |
| CI blocking | Kegagalan test memblokir merge. |
| Cleanup | Reset database setelah test. |

## 3. Ruang Lingkup
### 3.1 Termasuk
- authentication context;
- organization dan membership;
- RBAC dan scope;
- RLS;
- workspace dan event;
- guest dan event guest;
- invitation party dan token;
- public RSVP;
- check-in;
- souvenir entitlement dan claim;
- website draft dan publish;
- billing webhook;
- messaging delivery;
- realtime authorization;
- export tenant;
- failure dan retry behavior.

### 3.2 Tidak termasuk
- offline check-in;
- AI feature;
- marketplace;
- CRM penuh;
- white-label;
- provider production tanpa sandbox;
- load test production.

## 4. Test Environment
### 4.1 Supabase test project
Gunakan Supabase project khusus untuk integration test.

Aturan:
- tidak berbagi database production;
- credential test terpisah;
- data hanya sintetis;
- RLS production-like;
- migration dijalankan dari awal pada environment bersih.

### 4.2 Environment browser
Playwright harus menjalankan test terhadap environment test/staging yang terisolasi.

### 4.3 Provider
| Provider | Mode |
|---|---|
| Midtrans | Sandbox untuk alur provider, mock untuk error deterministik. |
| Email | Sandbox/test recipient untuk delivery, mock untuk failure dan retry. |
| WhatsApp | Sandbox/test recipient bila tersedia, mock untuk failure dan retry. |

Secret test hanya boleh berada pada environment test.

## 5. Test Data
Setiap test membuat data sintetisnya sendiri.

Data minimum:
- Organization A;
- Organization B;
- active member;
- removed member;
- organization-scoped role;
- workspace-scoped role;
- event-scoped role;
- client access;
- Workspace A dan B;
- Event A dan B;
- guest dan event_guest;
- invitation party;
- valid, expired, dan revoked token;
- invoice dan subscription;
- entitlement dengan quantity yang diketahui.

Aturan:
- jangan memakai data dari test lain;
- jangan memakai data tamu nyata;
- identifier test harus unik;
- secret dan token test tidak ditulis ke log.

## 6. Siklus Test
```text
Create isolated test data
    ↓
Run migration/schema setup
    ↓
Run integration test
    ↓
Verify state and audit evidence
    ↓
Reset test database
```

Cleanup harus berjalan setelah test berhasil maupun gagal.

## 7. API Integration Test
Test route langsung tanpa browser untuk memeriksa:
- HTTP method dan path;
- request validation;
- authentication;
- permission;
- scope;
- ownership;
- response envelope;
- error envelope;
- idempotency;
- transaction behavior.

Setiap endpoint terlindungi wajib diuji dengan:
- authenticated dan unauthenticated;
- active dan removed membership;
- organization benar dan salah;
- workspace benar dan salah;
- event benar dan salah;
- permission allow dan deny;
- client dan staff boundary.

## 8. RLS Integration Test
RLS test wajib otomatis di CI.

### 8.1 Matriks minimum
| Skenario | Hasil |
|---|---|
| Organization A membaca data A | Allow |
| Organization A membaca data B | Deny |
| Workspace W1 membaca W1 | Allow |
| Workspace W1 membaca W2 | Deny |
| Event E1 membaca E1 | Allow |
| Event E1 membaca E2 | Deny |
| Member inactive membaca private data | Deny |
| Client W1 membaca data client-visible W1 | Allow |
| Client W1 membaca W2 | Deny |
| Anonymous membaca private table | Deny |
| Cross-tenant insert | Deny |
| Cross-tenant update | Deny |
| Cross-tenant delete | Deny |
| Ownership reassignment | Deny |

### 8.2 Mutation test
`USING` dan `WITH CHECK` harus diuji terpisah pada table kritis.

Test harus mencoba mengubah:
- `organization_id`;
- `workspace_id`;
- `event_id`;
- relasi guest/event;
- role scope;
- ownership invoice.

## 9. Domain Integration Test
### 9.1 Guest dan event
- guest hanya dapat ditambahkan ke event dalam workspace sama;
- duplicate `event_guest` ditolak;
- cross-workspace association gagal tanpa partial write;
- guest merge mempertahankan evidence.

### 9.2 Invitation dan token
- invitation party memiliki satu primary guest;
- token valid dapat membuka context yang sesuai;
- token expired/revoked ditolak;
- token tidak dapat mengakses guest lain;
- publish menghasilkan state valid;
- send retry tidak menghasilkan side effect ganda.

### 9.3 RSVP
- submit valid memperbarui current state;
- count tidak boleh negatif;
- count tidak boleh melebihi invited count;
- perubahan menyimpan history bila diperlukan;
- token expired tidak dapat mengubah RSVP.

### 9.4 Check-in
- actor dengan scope benar dapat check-in;
- actor untuk event lain ditolak;
- duplicate scan mengembalikan hasil idempotent;
- concurrent scan tidak membuat dua check-in sukses;
- correction membutuhkan permission dan menyimpan evidence.

### 9.5 Souvenir
- entitlement default sama dengan invited count;
- override membutuhkan permission dan reason;
- quantity tidak boleh di bawah claimed quantity;
- claim melebihi remaining ditolak;
- concurrent claims tidak boleh melebihi entitlement;
- retry key sama menghasilkan hasil sama;
- key sama dengan payload berbeda ditolak;
- proxy claim tanpa confirmation ditolak.

### 9.6 Website
- draft dapat diubah oleh actor berwenang;
- publish membuat version baru;
- published version immutable;
- dua publish concurrent tidak membuat state invalid.

## 10. Payment Integration Test
### 10.1 Midtrans Sandbox
Uji:
- Snap token berhasil dibuat;
- payment pending;
- payment settlement;
- payment expired;
- payment cancelled;
- invoice dan subscription berubah sesuai webhook.

### 10.2 Mock provider
Mock dipakai untuk:
- invalid signature;
- malformed payload;
- timeout;
- provider 5xx;
- duplicate webhook;
- status transition invalid.

### 10.3 Aturan
- redirect browser tidak boleh mengubah paid state;
- webhook invalid tidak boleh mengubah state;
- webhook duplicate tidak boleh menggandakan side effect;
- status subscription harus berasal dari server verification.

## 11. Messaging Integration Test
### 11.1 Sandbox/test recipient
Uji:
- email terkirim;
- WhatsApp terkirim;
- delivery status diterima;
- template dan variabel dirender benar;
- consent valid mengizinkan pengiriman;
- opt-out mencegah pengiriman.

### 11.2 Mock provider
Uji:
- timeout;
- 5xx;
- rate limit;
- invalid recipient;
- invalid template;
- retryable dan non-retryable classification.

### 11.3 Aturan
- delivery attempt disimpan;
- retry memakai idempotency context;
- kegagalan provider tidak merusak state internal;
- recipient lintas tenant tidak dapat masuk campaign.

## 12. Concurrency Test
Concurrency test wajib otomatis.

### 12.1 Souvenir claim
Jalankan:
- N request untuk entitlement N;
- N+1 request untuk entitlement N;
- request berbeda dengan key berbeda;
- retry dengan key sama;
- key sama dengan payload berbeda.

Hasil wajib:
```text
total_claimed <= final_entitlement
```

### 12.2 Check-in
Jalankan beberapa request bersamaan untuk event guest sama.

Hasil wajib:
```text
successful_checkin_count <= 1
```

### 12.3 RBAC
Uji:
- revoke role saat mutation berjalan;
- membership removal lalu akses ulang;
- concurrent role assignment;
- scope assignment invalid.

### 12.4 Website
Uji:
- dua publish bersamaan;
- update draft saat publish berjalan.

## 13. Playwright E2E
Playwright digunakan untuk alur utama:

1. Organization Owner login.
2. Membuat workspace.
3. Mengisi wedding profile.
4. Membuat event.
5. Membuat dan publish invitation.
6. Membuat guest dan invitation party.
7. Guest membuka public invitation.
8. Guest mengirim RSVP.
9. Staff melihat perubahan RSVP.
10. Check-in staff membuka scanner atau manual lookup.
11. Staff melakukan check-in online.
12. Dashboard menampilkan attendance.
13. Owner membuka billing dan invoice.

E2E juga harus menguji:
- client read-only;
- akses workspace salah;
- token invalid/expired/revoked;
- loading/error state;
- responsive flow utama.

## 14. Realtime Integration Test
Uji:
- subscription channel authorized;
- subscription cross-tenant ditolak;
- payload hanya memuat data yang boleh dilihat;
- membership revoke memengaruhi akses channel sesuai policy;
- reconnect mengambil snapshot authoritative;
- event yang terlewat tidak menyebabkan count salah.

## 15. Export Integration Test
Uji:
- Organization Owner dapat export tenant sendiri;
- export tidak memuat tenant lain;
- export tidak memuat secret;
- export mengikuti permission;
- export besar tidak menggunakan memory tanpa batas;
- file export tidak public secara tidak sengaja.

## 16. Failure dan Resilience Test
Simulasikan:
- database timeout;
- provider timeout;
- provider 5xx;
- network interruption;
- reconnect;
- duplicate webhook;
- duplicate command;
- transaction rollback;
- worker retry.

Hasil wajib:
- tidak ada current state korup;
- tidak ada duplicate critical effect;
- retry aman;
- evidence tetap koheren.

## 17. Cleanup Database
Setelah setiap test:
- hapus atau reset data test;
- reset state transaction;
- hapus token test;
- bersihkan file export;
- bersihkan mock provider state;
- pastikan test berikutnya tidak mewarisi state.

Reset database harus berjalan pada success dan failure.

## 18. CI Pipeline
CI wajib menjalankan urutan:

```text
Install dependencies
    ↓
Validate environment
    ↓
Apply migrations
    ↓
Seed synthetic test data
    ↓
Run unit tests
    ↓
Run domain/integration tests
    ↓
Run RLS tests
    ↓
Run concurrency tests
    ↓
Run API contract tests
    ↓
Run Playwright E2E
    ↓
Cleanup/reset
```

Kegagalan salah satu test memblokir merge.

## 19. Test Reporting
Setiap test run harus menghasilkan:
- status pass/fail;
- test name dan ID;
- environment;
- request ID bila relevan;
- error ringkas tanpa secret;
- artifact Playwright bila gagal;
- hasil cleanup.

## 20. Acceptance Criteria
- Supabase test project terpisah digunakan.
- Semua test memakai data sintetis terisolasi.
- RLS test berjalan otomatis di CI.
- Midtrans Sandbox dan mock provider diuji.
- Provider messaging sandbox/test recipient dan mock diuji.
- Concurrency test berjalan otomatis.
- Playwright menguji critical user journey.
- CI memblokir merge saat test gagal.
- Database reset setelah setiap test.
- Critical requirement upstream memiliki test executable.

## 21. Guardrail untuk AI Agent Code
AI Agent Code harus:
- tidak memakai database production untuk test;
- tidak memakai data tamu nyata;
- tidak melewati RLS test;
- tidak mengganti concurrency test menjadi test sequential saja;
- tidak mengganti provider sandbox dengan production credential;
- tidak menonaktifkan cleanup;
- tidak menghapus test yang gagal untuk membuat CI lulus;
- tidak menaruh secret pada test artifact;
- tidak menandai integration test selesai hanya karena endpoint mengembalikan HTTP 200.

## 22. Status
**Baseline integration test plan MVP selesai.** Implementasi test runner, Playwright, CI workflow, dan test helper masih memerlukan persetujuan eksplisit sebelum file dibuat.

## 23. Referensi
- `PWS_Testing_Acceptance_Criteria_v0.1.md`
- `PWS_Security_NFR_Specification_v0.1.md`
- `PWS_API_Contract_v0.1.md`
- `PWS_Authorization_RLS_Specification_v0.1_updated.md`
- `PWS_Domain_Services_Business_Rules_v0.1.md`
- `PWS_Use_Cases_State_Machines_v0.1.md`
- `PWS_Payment_Architecture_v0.1.md`
- `PWS_Messaging_Architecture_v0.1.md`
- `PWS_Deployment_Guide_and_Runbook_v0.1.md`
