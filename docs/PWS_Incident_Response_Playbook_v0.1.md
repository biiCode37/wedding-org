# PWS_Incident_Response_Playbook_v0.1.md

## 1. Tujuan
Dokumen ini menetapkan playbook respons insiden untuk Premium Wedding SaaS MVP.

Fokus dokumen ini:
- klasifikasi severity;
- deteksi dan triage;
- komunikasi insiden;
- penahanan dampak;
- pemulihan;
- postmortem;
- evidence retention.

Dokumen ini digunakan oleh Organization Owner dan Platform Admin sebagai runbook awal.

## 2. Prinsip Dasar
1. Insiden ditangani berdasarkan dampak terhadap tenant, security, data, dan operasional.
2. Evidence harus dipertahankan sesuai kebutuhan insiden.
3. Perbaikan aman lebih penting daripada tindakan cepat yang merusak data.
4. Rollback boleh dilakukan, tetapi bukan default tanpa pertimbangan.
5. Komunikasi harus jelas, singkat, dan tidak membocorkan data sensitif.
6. Postmortem wajib untuk insiden serius.

## 3. Severity Model
### 3.1 P1
Insiden kritis yang berdampak besar.

Contoh:
- tenant isolation gagal;
- data sensitif bocor;
- billing atau payment state salah secara luas;
- check-in atau RSVP rusak pada event berjalan;
- sistem tidak dapat dipakai untuk fungsi inti.

### 3.2 P2
Insiden penting yang mengganggu fungsi utama tetapi belum kritis secara total.

Contoh:
- sebagian fitur gagal;
- performa turun signifikan;
- webhook gagal sementara;
- satu modul tidak dapat dipakai oleh sebagian user.

### 3.3 P3
Insiden ringan atau gangguan terbatas.

Contoh:
- UI error kecil;
- teks salah;
- layout issue;
- log noise;
- bug non-kritis tanpa dampak data besar.

## 4. Aktor
| Aktor | Peran |
|---|---|
| Organization Owner | Menentukan dampak bisnis, menyetujui tindakan besar, menerima komunikasi. |
| Platform Admin | Menangani insiden platform, billing, atau security. |
| System / Logs | Sumber evidence dan indikator masalah. |

## 5. Alur Respons Insiden
```text
Detect
  ↓
Classify severity
  ↓
Contain impact
  ↓
Choose repair-first or rollback
  ↓
Recover service
  ↓
Verify stability
  ↓
Document incident
  ↓
Postmortem jika serius
```

## 6. Deteksi
Insiden dapat terdeteksi dari:
- error rate naik;
- user report;
- audit evidence;
- webhook failure;
- RLS denial aneh;
- billing status tidak konsisten;
- check-in atau RSVP anomali;
- log error berulang.

## 7. Triage
Langkah triage:
1. Tentukan apakah insiden menyangkut UI, API, database, webhook, payment, atau authorization.
2. Tentukan scope: satu user, satu workspace, satu organization, atau seluruh sistem.
3. Tentukan severity P1/P2/P3.
4. Tentukan apakah data berisiko atau hanya layanan yang terganggu.
5. Pilih tindakan awal.

## 8. Komunikasi Insiden
Komunikasi MVP hanya ke:
- Organization Owner;
- Platform Admin;
- internal log.

Aturan:
- gunakan bahasa singkat dan jelas;
- jangan membocorkan secret atau payload sensitif;
- jangan menyebarkan detail yang belum diverifikasi;
- jika perlu, beri status sementara: investigating, contained, recovering, resolved.

## 9. Target Respons
Dokumen ini tidak mengunci angka SLA.

Aturan target:
- P1 diprioritaskan paling tinggi;
- P2 ditangani setelah P1 stabil;
- P3 ditangani dalam siklus normal;
- respons diukur berdasarkan prioritas, bukan angka tetap.

## 10. Containment
Containment dapat berupa:
- menghentikan endpoint tertentu;
- menonaktifkan fitur yang bermasalah;
- menahan webhook;
- memblokir release baru;
- menyalakan mode read-only bila perlu;
- membatasi akses admin tertentu sementara.

Containment harus membatasi dampak tanpa merusak data yang sudah valid.

## 11. Repair-First vs Rollback-First
Keputusan MVP: **repair-first** bila aman.

### Repair-first
Dipilih jika:
- masalah bisa diperbaiki cepat tanpa memperluas kerusakan;
- data tidak perlu diputar balik;
- root cause jelas;
- rollback berisiko lebih besar.

### Rollback-first
Dipilih jika:
- release baru menyebabkan kerusakan besar;
- kondisi sebelumnya terbukti stabil;
- rollback tidak merusak data valid;
- repair akan memakan waktu lebih lama dari risiko yang diterima.

## 12. Pemulihan
Setelah containment:
1. pulihkan service yang terdampak;
2. verifikasi state penting;
3. cek data integrity;
4. cek webhook/payment bila relevan;
5. cek RLS/authorization bila terkait;
6. kembalikan fitur secara bertahap bila perlu.

## 13. Notifikasi Pengguna
Notifikasi pengguna hanya bila perlu.

Dipakai bila:
- insiden berdampak langsung ke pengguna nyata;
- ada risiko kehilangan data;
- ada downtime yang terlihat;
- ada perubahan billing atau access state penting.

Tidak semua insiden perlu broadcast ke pengguna akhir.

## 14. Evidence Retention
Evidence insiden disimpan sesuai jenis insiden.

Contoh evidence:
- log request;
- audit event;
- webhook payload yang disanitasi;
- screenshot atau rekaman bila perlu;
- catatan tindakan operator;
- hasil verifikasi pascarecovery.

Aturan:
- evidence security-sensitive tidak boleh dihapus sembarangan;
- evidence harus cukup untuk investigasi akar masalah;
- retensi detail mengikuti kebutuhan insiden dan kebijakan data governance.

## 15. Postmortem
Postmortem wajib untuk insiden serius.

Insiden serius termasuk:
- P1;
- insiden berulang;
- insiden yang melibatkan data loss, data leak, atau authorization failure;
- insiden yang menuntut tindakan korektif permanen.

Isi postmortem minimal:
- ringkasan insiden;
- waktu kejadian;
- dampak;
- root cause;
- langkah containment;
- langkah recovery;
- tindakan pencegahan;
- owner tindakan lanjut.

## 16. On-call MVP
On-call MVP:
- Organization Owner;
- Platform Admin.

Keduanya harus bisa:
- menerima notifikasi insiden;
- membaca log utama;
- memutuskan containment dasar;
- menyetujui rollback bila perlu.

## 17. Panduan Insiden per Area
### 17.1 Authorization / RLS
Jika tenant isolation atau scope gagal:
- klasifikasikan minimal P1;
- hentikan mutasi yang relevan;
- verifikasi policy dan query path;
- jangan lanjut release sampai masalah jelas.

### 17.2 Billing / Payment
Jika status invoice, webhook, atau subscription tidak konsisten:
- tahan aksi billing lebih lanjut;
- verifikasi webhook dan idempotency;
- bandingkan state internal dan provider.

### 17.3 Check-in / RSVP
Jika check-in atau RSVP rusak saat event:
- prioritaskan service recovery;
- pertahankan evidence;
- jangan hapus record yang sudah valid;
- lakukan koreksi hanya lewat jalur yang diaudit.

### 17.4 Messaging
Jika delivery gagal besar:
- tahan campaign baru;
- cek provider;
- cek consent;
- retry hanya untuk error yang retryable.

## 18. Acceptance Criteria
- Severity P1/P2/P3 dapat dipilih dengan jelas.
- Komunikasi insiden mencakup owner, platform admin, dan log internal.
- Repair-first menjadi default bila aman.
- Postmortem tersedia untuk insiden serius.
- Evidence insiden dipertahankan sesuai jenisnya.
- On-call MVP jelas.
- Notifikasi pengguna hanya diberikan jika perlu.

## 19. Guardrail untuk AI Agent Code
AI Agent Code harus:
- tidak menyembunyikan insiden P1 sebagai P3;
- tidak menghapus log atau evidence tanpa instruksi;
- tidak mengubah state produksi tanpa containment yang jelas;
- tidak membuat komunikasi publik tanpa persetujuan;
- tidak memutuskan rollback tanpa mempertimbangkan data integrity;
- tidak mengarang SLA numerik;
- tidak mengabaikan insiden authorization atau data leak.

## 20. Status
**Baseline incident response MVP selesai.**

## 21. Referensi
- `PWS_Security_NFR_Specification_v0.1.md`
- `PWS_Operations_Backup_Retention_v0.1.md`
- `PWS_Deployment_Guide_and_Runbook_v0.1.md`
- `PWS_Observability_Architecture_v0.1.md`
- `PWS_Testing_Acceptance_Criteria_v0.1.md`
