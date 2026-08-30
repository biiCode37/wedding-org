# PWS_Deployment_Guide_and_Runbook_v0.1.md

## 1. Tujuan
Dokumen ini menetapkan panduan deployment dan runbook operasional untuk Premium Wedding SaaS MVP.

Fokus dokumen ini:
- lingkungan deployment;
- alur release;
- variabel environment;
- migrasi database;
- rollback;
- verifikasi pascadeploy;
- pembaruan staging;
- langkah dasar recovery operasional.

Dokumen ini menjadi acuan sebelum implementasi CI/CD dan sebelum production release.

## 2. Lingkungan MVP
MVP memakai tiga lingkungan:

1. **Local**
   - untuk development harian;
   - memakai data sintetis;
   - tidak boleh memakai credential production.

2. **Staging**
   - untuk verifikasi sebelum production;
   - memakai konfigurasi mendekati production;
   - dipakai untuk validasi migrasi, RLS, dan smoke test.

3. **Production**
   - lingkungan aktif untuk pengguna nyata;
   - perubahan hanya melalui release terverifikasi.

## 3. Prinsip Deployment
1. Build harus repeatable.
2. Migrasi harus versioned.
3. Release tidak boleh bergantung pada aksi manual yang tidak terdokumentasi.
4. Production hanya boleh menerima perubahan setelah lint, typecheck, test, dan approval lulus.
5. Secret tidak boleh masuk source code.
6. Staging harus cukup mirip production agar kesalahan besar dapat ditemukan sebelum live.

## 4. Stack Deployment
- Aplikasi web: Vercel.
- Database: Supabase PostgreSQL.
- Auth: Supabase Auth.
- Storage: Supabase Storage.
- Migrasi DB: Supabase CLI.
- Environment variable: Vercel env dan Supabase env.

## 5. Variabel Environment
### 5.1 Prinsip
Semua secret harus disimpan di environment, bukan di code.

### 5.2 Contoh kelompok env
- application public config;
- Supabase URL dan anon key;
- Supabase service role key untuk server trust boundary;
- Midtrans server key dan client key;
- provider messaging key;
- webhook secret;
- request correlation config;
- staging-specific config.

### 5.3 Aturan
- Production secret tidak boleh dipakai di local tanpa izin.
- Staging secret harus terpisah dari production secret.
- Tidak ada secret di file commit.
- Tidak ada secret di log biasa.

## 6. Alur Release
```text
1. Developer commit ke branch kerja
2. Pull request dibuka
3. CI menjalankan lint, typecheck, test
4. Review manual dilakukan
5. Jika lulus, merge ke branch release/main
6. Vercel deploy preview atau staging
7. Smoke test dilakukan di staging
8. Approval produksi diberikan
9. Production deploy dilakukan
10. Verifikasi pascadeploy
```

## 7. Release Gate
Release hanya boleh lanjut jika:
- lint lulus;
- typecheck lulus;
- test lulus;
- perubahan schema sudah direview;
- RLS policy terkait sudah diperiksa;
- tidak ada conflict dengan dokumen upstream;
- approval eksplisit pengguna sudah ada.

## 8. Migrasi Database
### 8.1 Prinsip
- gunakan Supabase CLI;
- migrasi harus versioned dan berurutan;
- migrasi harus dapat diulang di staging;
- perubahan schema harus disimpan sebagai file migrasi, bukan SQL ad hoc tersebar.

### 8.2 Urutan umum
```text
1. Buat migration file
2. Jalankan migration di local
3. Jalankan test schema/RLS
4. Apply ke staging
5. Verifikasi data dan query
6. Apply ke production setelah approve
```

### 8.3 Aturan aman
- hindari migrasi destruktif tanpa rencana rollback;
- perubahan constraint harus diuji di staging;
- data sensitive migration harus dicatat.

## 9. Rollback
Strategi rollback MVP:

1. **Redeploy commit sebelumnya** untuk rollback aplikasi.
2. Migration rollback dilakukan hanya bila aman dan sudah didesain.
3. Jika data rusak, gunakan recovery database atau restore backup sesuai runbook.

### Aturan rollback
- rollback aplikasi tidak otomatis memperbaiki schema rusak;
- jika migrasi membuat data tidak kompatibel, prioritaskan pemulihan data yang aman;
- rollback harus dicatat di audit operasional.

## 10. Verifikasi Pascadeploy
Setelah deploy, lakukan:
- cek halaman public invitation;
- cek login staff;
- cek dashboard utama;
- cek query dasar ke staging/production;
- cek RLS untuk resource utama;
- cek webhook endpoint sehat;
- cek check-in basic path bila fitur aktif;
- cek billing page untuk owner bila fitur aktif.

## 11. Staging Runbook
Staging harus dipakai untuk:
- validasi migrasi;
- smoke test aplikasi;
- verifikasi layout public invitation;
- verifikasi login dan scope;
- verifikasi webhook non-production;
- verifikasi perubahan UI sebelum production.

Staging tidak boleh dianggap production. Data staging harus sintetis atau tersamarkan.

## 12. Production Runbook Dasar
### 12.1 Sebelum release
- pastikan approval eksplisit ada;
- pastikan artifact sudah lulus CI;
- pastikan migrasi sudah lulus staging;
- pastikan env production lengkap;
- pastikan backup terbaru tersedia.

### 12.2 Sesudah release
- verifikasi endpoint utama;
- cek error rate;
- cek webhook delivery;
- cek audit event yang diharapkan;
- cek data read-only atau write path sesuai status billing.

## 13. Incident Contact
Untuk MVP:
- **Organization Owner**
- **Platform Admin**

Keduanya menjadi kontak utama untuk insiden operasional dan billing.

## 14. Prosedur Incident Ringkas
```text
1. Deteksi masalah
2. Identifikasi scope
3. Cek apakah issue UI, API, DB, atau webhook
4. Tahan release baru bila perlu
5. Rollback aplikasi bila aman
6. Restore data bila diperlukan
7. Catat incident
8. Perbaiki root cause
```

## 15. Aturan Security Operasional
- jangan menjalankan perintah deploy tanpa approval;
- jangan mengubah secret melalui code commit;
- jangan memakai credential production di local;
- jangan menonaktifkan RLS untuk debugging;
- jangan melewati staging untuk perubahan schema kritis;
- jangan menyimpan data nyata di environment yang tidak disetujui.

## 16. Acceptance Criteria
- Local, staging, dan production terdefinisi jelas.
- Migrasi schema memakai Supabase CLI.
- Release hanya lanjut jika lint, typecheck, test, dan approval lulus.
- Rollback aplikasi dapat dilakukan dengan redeploy commit sebelumnya.
- Secret tersimpan di Vercel env dan Supabase env.
- Staging dipakai sebelum production.
- Contact incident jelas: owner dan platform admin.

## 17. Guardrail untuk AI Agent Code
AI Agent Code harus:
- tidak membuat deploy tanpa approval;
- tidak menganggap staging sama dengan production;
- tidak menulis secret ke repo;
- tidak menjalankan migrasi ad hoc tanpa file migration;
- tidak melewati smoke test;
- tidak menambah environment baru tanpa alasan yang disetujui;
- tidak melakukan rollback destruktif tanpa persetujuan eksplisit.

## 18. Status
**Baseline deployment dan runbook MVP selesai.**

## 19. Referensi
- `PWS_Engineering_Implementation_Blueprint_v0.1.md`
- `PWS_Security_NFR_Specification_v0.1.md`
- `PWS_Operations_Backup_Retention_v0.1.md`
- `PWS_Testing_Acceptance_Criteria_v0.1.md`
- `PWS_Data_Governance_and_Privacy_v0.1.md`
