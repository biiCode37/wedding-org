# PWS_Data_Governance_and_Privacy_v0.1.md

## 1. Tujuan
Dokumen ini menetapkan kebijakan data governance dan privacy untuk Premium Wedding SaaS MVP.

Fokus dokumen ini:
- klasifikasi data;
- data yang boleh ditampilkan;
- retensi;
- ekspor data tenant;
- penghapusan data;
- masking data sensitif;
- cookie/session/privacy notice;
- batas penggunaan data untuk AI;
- backup dan akses data sensitif.

Dokumen ini menjadi acuan untuk UI, API, storage, audit, backup, dan operasional.

## 2. Prinsip Dasar
1. Data ditampilkan dengan prinsip **minimum necessary**.
2. Data sensitif harus dimasking pada UI dan tercatat pada audit bila diakses.
3. Organization berhak mengekspor data tenant sendiri.
4. Soft delete digunakan hanya pada entitas yang memang membutuhkan historis.
5. Data tenant tidak boleh dipakai untuk training AI.
6. Backup boleh berisi data sensitif, tetapi harus dilindungi akses dan enkripsi.
7. Privacy notice wajib ditampilkan pada MVP.

## 3. Klasifikasi Data
### 3.1 Public
Data yang boleh tampil tanpa autentikasi atau dengan akses publik terkontrol.

Contoh:
- invitation publik;
- event details yang memang dipublikasikan;
- konten website publik;
- informasi lain yang memang ditandai public.

### 3.2 Internal
Data operasional yang hanya untuk staff terautentikasi.

Contoh:
- dashboard internal;
- status operasional;
- metadata kerja.

### 3.3 Tenant-private
Data milik organization/workspace yang tidak boleh keluar dari scope tenant.

Contoh:
- guest data;
- RSVP;
- check-in;
- invitation token;
- media private;
- billing organisasi;
- note internal.

### 3.4 Security-sensitive
Data yang jika bocor dapat menimbulkan risiko keamanan atau privasi yang tinggi.

Contoh:
- invitation token;
- credential provider;
- audit/security event;
- payment webhook payload sensitif;
- secret environment value.

### 3.5 Credential/Secret
Data yang tidak boleh muncul pada UI biasa, log biasa, atau response publik.

Contoh:
- access token;
- secret key;
- service role key;
- webhook secret;
- password.

## 4. Prinsip Minimum Necessary
Setiap UI, API, export, atau laporan hanya boleh menampilkan data yang diperlukan untuk tujuan tersebut.

Aturan:
- field yang tidak perlu harus disembunyikan;
- data sensitif dimasking jika masih perlu ditampilkan;
- tenant lain tidak boleh muncul;
- internal note tidak boleh tampil ke client/public;
- data identity tidak boleh dibuka massal tanpa alasan yang sah.

## 5. Masking Data Sensitif
### 5.1 Data yang dimasking
Contoh data yang wajib dimasking di UI bila tidak diperlukan penuh:
- nomor telepon;
- email;
- token;
- identifier internal tertentu;
- payment reference sensitif;
- catatan yang mengandung data pribadi.

### 5.2 Bentuk masking
Contoh:
- `sinta@example.com` → `s***@example.com`
- `081234567890` → `0812******90`
- token → hanya 4 karakter awal dan akhir bila perlu

### 5.3 Aturan audit
Setiap akses atau tindakan yang menampilkan data sensitif harus dapat ditelusuri melalui audit jika konteksnya security-sensitive.

## 6. Retensi Data
Retensi MVP ditetapkan **30 hari** untuk data operasional tertentu yang relevan dengan guest/RSVP/check-in.

### 6.1 Retensi minimum yang dicatat
- guest operational history yang aktif;
- RSVP response history;
- check-in record;
- delivery attempts messaging;
- audit security event yang relevan.

### 6.2 Aturan umum retensi
- data operasional disimpan minimal 30 hari bila dibutuhkan untuk audit, support, atau rekonsiliasi;
- data historis yang memiliki nilai bisnis dapat disimpan lebih lama bila diperlukan oleh domain;
- retensi yang lebih panjang harus dinyatakan eksplisit per entitas, bukan asumsi umum.

### 6.3 Penghapusan setelah retensi
Setelah retensi habis:
- data yang tidak lagi dibutuhkan dapat diarsipkan atau dihapus sesuai lifecycle entitas;
- evidence audit yang wajib dipertahankan tidak boleh dihapus sembarangan.

## 7. Export Data Organization
Organization Owner berhak mengekspor data tenant sendiri.

### 7.1 Batas export
Export boleh mencakup:
- workspace milik organization;
- guest data tenant sendiri;
- RSVP;
- event;
- invitation metadata;
- billing organisasi;
- audit yang diizinkan oleh policy;
- media metadata yang diizinkan.

### 7.2 Batas export
Export tidak boleh mencakup:
- tenant lain;
- credential;
- secret;
- service role key;
- data yang tidak termasuk scope permission;
- payload internal provider yang tidak dibutuhkan.

### 7.3 Format export
Format export harus dapat dibaca mesin dan manusia bila diperlukan. Implementasi detail format boleh ditetapkan di dokumen operasional atau API export.

## 8. Penghapusan Data
### 8.1 Soft delete selektif
Soft delete hanya dipakai pada entitas yang memang membutuhkan historis atau pemulihan.

Contoh kandidat:
- guest;
- invitation;
- message;
- media metadata;
- workspace archive;
- billing state tertentu.

### 8.2 Hard delete
Hard delete boleh dipakai bila:
- entitas tidak butuh historis;
- data tidak menjadi evidence;
- tidak melanggar audit atau compliance internal.

### 8.3 Aturan umum
- penghapusan tidak boleh menghapus evidence audit yang wajib dipertahankan;
- penghapusan tidak boleh memutus integritas referensi secara diam-diam;
- penghapusan harus mengikuti domain lifecycle dan RLS.

## 9. Cookie, Session, dan Privacy Notice
### 9.1 Privacy notice
Privacy notice wajib tampil pada MVP.

Minimal harus menjelaskan:
- data apa yang dikumpulkan;
- tujuan penggunaan data;
- siapa yang dapat mengakses data;
- kontak untuk pertanyaan privasi;
- penggunaan cookie/session bila relevan.

### 9.2 Cookie/session
- session harus mengikuti kebijakan autentikasi yang disetujui;
- cookie atau storage yang dipakai untuk autentikasi tidak boleh dibagikan ke domain tak sah;
- data sensitif tidak boleh disimpan di local storage tanpa alasan eksplisit.

## 10. AI Data Policy
Data tenant **tidak dipakai untuk training AI**.

Aturan:
- data guest, RSVP, billing, audit, dan media tidak boleh dipakai untuk melatih model AI internal/eksternal;
- data boleh dipakai hanya untuk menjalankan fitur AI runtime bila ada persetujuan fitur dan scope yang jelas;
- jika suatu saat data dianonimkan untuk riset, itu memerlukan keputusan baru.

## 11. Backup dan Data Sensitif
Backup boleh berisi data sensitif.

Aturan:
- backup harus tetap terenkripsi;
- akses backup harus sangat terbatas;
- restore harus melalui prosedur yang disetujui;
- backup tidak boleh disimpan di storage publik;
- akses ke backup harus tercatat bila memungkinkan.

## 12. Data Subject dan Tenant Rights
Tenant memiliki hak untuk:
- melihat data sendiri sesuai permission;
- mengekspor data sendiri;
- meminta penghapusan sesuai lifecycle dan kebijakan yang berlaku;
- meminta koreksi data tertentu;
- melihat status billing dan operasional yang relevan.

Hak tersebut tidak boleh melampaui batas tenant atau menghapus evidence yang diwajibkan oleh sistem.

## 13. Aturan Logging
Logging harus:
- tidak menyimpan password;
- tidak menyimpan token mentah;
- tidak menyimpan secret;
- meminimalkan payload sensitif;
- menyertakan `request_id` bila relevan;
- mendukung audit akses sensitif.

## 14. API dan UI Enforcement
Kebijakan data governance harus diterapkan di:
- UI;
- API;
- export;
- worker/job;
- audit;
- backup;
- realtime payload.

UI hiding tidak cukup. Server tetap harus menegakkan kebijakan minimum necessary dan tenant isolation.

## 15. Acceptance Criteria
- Data sensitif dimasking pada UI yang relevan.
- Organization Owner dapat mengekspor data tenant sendiri.
- Retensi operasional 30 hari dapat diterapkan sesuai policy.
- Soft delete hanya dipakai pada entitas yang memang membutuhkan historis.
- Privacy notice tampil pada MVP.
- Data tenant tidak dipakai untuk training AI.
- Backup boleh berisi data sensitif tetapi terlindungi akses dan enkripsi.
- Tenant lain tidak muncul dalam export atau UI.

## 16. Guardrail untuk AI Agent Code
AI Agent Code harus:
- menerapkan minimum necessary;
- memask data sensitif di UI dan export bila perlu;
- tidak memakai data tenant untuk training AI;
- tidak membuat export lintas tenant;
- tidak menonaktifkan masking demi kemudahan implementasi;
- tidak menghapus evidence audit sembarangan;
- tidak menyimpan secret di log atau UI.

## 17. Status
**Baseline data governance dan privacy MVP selesai.**

## 18. Referensi
- `PWS_PRD_v0.1.md`
- `PWS_Security_NFR_Specification_v0.1.md`
- `PWS_Testing_Acceptance_Criteria_v0.1.md`
- `PWS_Operations_Backup_Retention_v0.1.md`
- `PWS_Observability_Architecture_v0.1.md`
- `PWS_API_Contract_v0.1.md`
