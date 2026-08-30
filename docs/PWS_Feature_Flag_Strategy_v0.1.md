# PWS_Feature_Flag_Strategy_v0.1.md

## 1. Tujuan
Dokumen ini menetapkan strategi feature flag untuk Premium Wedding SaaS MVP.

Feature flag dipakai untuk mengontrol fitur yang berisiko, ditunda, atau perlu rollout terarah tanpa mengubah source code secara terus-menerus.

## 2. Ruang Lingkup
Feature flag pada MVP hanya dipakai untuk:
- fitur deferred;
- fitur kritis yang perlu kill switch;
- rollout manual per tenant;
- pengendalian perilaku yang belum siap dibuka umum.

Feature flag tidak dipakai sebagai pengganti desain produk atau keputusan arsitektur.

## 3. Keputusan MVP
| Area | Keputusan |
|---|---|
| Scope | Platform, organization, dan workspace. |
| Model | Boolean sederhana. |
| Target | Fitur deferred saja. |
| Storage | Database table + server evaluation. |
| Rollout | Manual per tenant. |
| Kill switch | Wajib untuk fitur kritis. |
| Audit | Wajib. |
| UI exposure | Server-side saja. |
| Default | Off by default. |
| Lifecycle | created → enabled → disabled → archived. |

## 4. Prinsip Dasar
1. Flag harus mudah dipahami.
2. Flag harus bisa diputus di server, bukan hanya di UI.
3. Flag default harus aman.
4. Flag change harus bisa diaudit.
5. Flag tidak boleh dipakai untuk mengaburkan keputusan yang sebenarnya belum dibuat.
6. Flag kritis harus bisa dimatikan cepat.
7. Flag tidak boleh diekspos ke client sebagai sumber keputusan final.

## 5. Skop Flag
### 5.1 Platform
Flag di level platform dipakai untuk:
- menyalakan fitur global bertahap;
- mematikan fitur berbahaya secara cepat;
- mengontrol akses fitur yang baru keluar dari fase dokumentasi.

### 5.2 Organization
Flag di level organization dipakai untuk:
- mengaktifkan fitur tertentu hanya untuk tenant tertentu;
- rollout manual ke satu organizer sebelum tenant lain.

### 5.3 Workspace
Flag di level workspace dipakai untuk:
- mengaktifkan fitur pada wedding/project tertentu;
- eksperimen terbatas pada satu workspace.

## 6. Model Flag
Flag menggunakan model boolean:
- `true` = aktif;
- `false` = nonaktif.

Aturan:
- tidak ada percentage rollout pada MVP;
- tidak ada multistate yang rumit;
- tidak ada kalkulasi otomatis berdasarkan cohort;
- jika perlu rollout bertahap, lakukan manual per tenant.

## 7. Penyimpanan
Flag disimpan pada database table khusus.

Aturan penyimpanan:
- server membaca flag dari database;
- client tidak menjadi source of truth;
- perubahan flag harus tercatat sebagai data operasional;
- akses perubahan flag harus dibatasi.

Struktur detail tabel boleh ditentukan saat implementasi, tetapi harus mendukung:
- scope;
- key flag;
- nilai boolean;
- created by;
- updated by;
- status lifecycle;
- audit reference.

## 8. Evaluasi Flag
Evaluasi flag dilakukan di server.

Urutan evaluasi:
```text
1. Tentukan scope request
2. Identifikasi flag key
3. Cari value pada scope paling spesifik
4. Jika tidak ada, fallback ke scope di atasnya bila policy mengizinkan
5. Kembalikan true atau false
```

Fallback scope harus eksplisit. Jangan mengasumsikan fallback diam-diam.

## 9. Rollout Manual
Rollout dilakukan manual per tenant.

Aturan:
- satu tenant dapat diaktifkan terlebih dahulu;
- tenant lain tetap off sampai disetujui;
- perubahan rollout harus dicatat;
- tidak ada otomatisasi percentage rollout pada MVP.

## 10. Kill Switch
Fitur kritis harus punya kill switch.

Contoh fitur kritis:
- payment flow;
- webhook handler;
- messaging delivery;
- check-in command;
- fitur baru yang berisiko security atau data integrity.

Aturan:
- kill switch harus bisa dimatikan cepat;
- kill switch tidak boleh merusak state valid yang sudah tersimpan;
- kill switch harus diproteksi oleh authorization dan audit.

## 11. Audit
Semua perubahan flag wajib dicatat.

Audit minimal menyimpan:
- siapa yang mengubah;
- flag apa yang diubah;
- scope mana yang terkena;
- nilai lama dan baru;
- waktu perubahan;
- alasan bila diperlukan;
- request_id bila ada.

## 12. UI Exposure
Flag tidak diekspos sebagai kontrol bebas di UI umum.

Aturan:
- client tidak boleh menentukan flag sendiri;
- UI admin boleh menampilkan status flag bila actor berwenang;
- keputusan aktif/nonaktif tetap server-side;
- flag tidak boleh dipakai sebagai shortcut authorization.

## 13. Lifecycle Flag
Lifecycle flag:

```text
created
  ↓
enabled
  ↓
disabled
  ↓
archived
```

### Aturan lifecycle
- `created`: flag dibuat tetapi belum aktif.
- `enabled`: flag aktif untuk scope yang diizinkan.
- `disabled`: flag dimatikan tetapi masih ada sebagai record.
- `archived`: flag tidak dipakai lagi dan hanya disimpan untuk historis bila perlu.

## 14. Hubungan dengan Deferred Decisions
Feature flag hanya boleh dipakai untuk keputusan yang memang layak ditunda sementara.

Aturan:
- flag tidak boleh menggantikan keputusan product yang wajib final sebelum build;
- flag tidak boleh menyembunyikan gap requirement yang sebenarnya belum selesai;
- jika fitur belum aman, lebih baik tetap off daripada dipaksa hidup lewat flag.

## 15. Kapan Flag Dipakai
Flag dipakai jika:
- fitur belum siap untuk semua tenant;
- fitur butuh kill switch;
- fitur perlu observasi bertahap;
- fitur masih bergantung pada keputusan operasional tertentu.

Flag tidak dipakai jika:
- keputusan produk belum jelas;
- fungsi inti belum selesai dirancang;
- flag hanya menjadi alasan untuk menunda dokumentasi.

## 16. Acceptance Criteria
- Flag bisa diaktifkan per platform, organization, dan workspace.
- Flag default off.
- Flag dievaluasi server-side.
- Flag disimpan di database.
- Flag change diaudit.
- Rollout bisa dilakukan manual per tenant.
- Kill switch tersedia untuk fitur kritis.
- UI tidak menjadi source of truth untuk flag.
- Lifecycle flag jelas dan sederhana.

## 17. Guardrail untuk AI Agent Code
AI Agent Code harus:
- tidak membuat percentage rollout pada MVP;
- tidak menaruh flag decision di client sebagai source of truth;
- tidak mengaktifkan fitur default tanpa persetujuan;
- tidak menggunakan flag untuk menggantikan keputusan arsitektur;
- tidak menambahkan UI flag editor tanpa izin;
- tidak menghapus audit perubahan flag;
- tidak memakai flag untuk membenarkan implementasi fitur yang belum disetujui.

## 18. Status
**Baseline feature flag strategy MVP selesai.**

## 19. Referensi
- `PWS_Release_Process_and_Change_Log_v0.1.md`
- `PWS_Engineering_Implementation_Blueprint_v0.1.md`
- `PWS_Security_NFR_Specification_v0.1.md`
- `PWS_Testing_Acceptance_Criteria_v0.1.md`
- `PWS_AI_Agent_Operating_Rules_v0.1.md`
