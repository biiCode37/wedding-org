# PWS_AI_Agent_Operating_Rules_v0.1.md

## 1. Prinsip Umum
- **Tidak ada tindakan otomatis** (pembuatan/ubah/hapus file, instalasi paket, eksekusi build/deploy, keputusan arsitektur) **tanpa konfirmasi eksplisit** dari pengguna.
- Semua **keputusan produk**, **keputusan arsitektur**, atau **keputusan teknis** harus dipresentasikan kepada pengguna terlebih dahulu, kemudian dicatat sebagai *TODO* atau *deferred* hingga persetujuan.
- Setiap **file baru** atau **modifikasi** harus menggunakan **prefix `PWS_`** (kecuali file sistem seperti `.gitignore`).
- **Bahasa** penulisan dokumen: **Indonesia** untuk teks non‑teknis, kode **tetap** dalam bahasa Inggris.

## 2. Prosedur Konfirmasi
| Tindakan | Contoh | Mekanisme | Wajib? |
|----------|--------|-----------|--------|
| Membuat file baru (dokumen, skrip, konfigurasi) | `docs/PWS_New_Doc.md` | Tanyakan ke pengguna, dapatkan persetujuan tertulis. | ✅ |
| Mengubah file yang ada | Update `PWS_Engineering_Implementation_Blueprint_v0.1.md` | Tanyakan ke pengguna, dapatkan persetujuan. | ✅ |
| Menghapus file | Hapus `package.json` | Tanyakan ke pengguna, dapatkan persetujuan. | ✅ |
| Menambahkan dependensi (npm, pip, dll.) | `npm i supabase` | Tanyakan ke pengguna, dapatkan persetujuan. | ✅ |
| Menjalankan perintah build/deploy | `npm run build` | Tanyakan ke pengguna, dapatkan persetujuan. | ✅ |
| Mengunci keputusan *deferred* menjadi final | Tetapkan nilai pada `RPO/RTO` | Harus ada persetujuan eksplisit. | ✅ |

## 3. Kebijakan Dokumentasi
- **Semua dokumen** harus berada di folder `docs/` dengan **nama `PWS_*.md`**.
- **Setiap keputusan yang belum final** harus ditandai *deferred* dalam dokumen yang relevan, serta **owner** dan **deadline** harus dicantumkan.
- **Checklist gate** harus ada pada setiap dokumen *blueprint* atau *implementation* sebelum melangkah ke fase berikutnya.
- **Tidak menambahkan** asumsi teknis yang tidak ada dalam dokumen upstream (PRD, ADR, schema, dsb.).

## 4. Guardrail untuk AI Agent Code
- **Jangan** mengasumsikan nilai angka (rate‑limit, RPO, RTO, SLA) tanpa adanya sumber yang jelas.
- **Jangan** menulis kode yang mengubah *ownership*, *tenant*, atau *scope* tanpa verifikasi RLS/authorization.
- **Jangan** menambah *default* value pada field yang belum didefinisikan dalam schema.
- **Jangan** mengeksekusi perintah shell yang dapat memodifikasi proyek (install, delete) tanpa persetujuan.
- **Jangan** mengabaikan *deferred decisions*; sebaliknya, buat *TODO* di dalam dokumen terkait.

## 5. Proses Review & Persetujuan
1. **AI Agent** mengidentifikasi kebutuhan perubahan.
2. **AI Agent** menanyakan persetujuan dengan jelas (apa yang akan dilakukan, alasan, dampak).
3. **Pengguna** memberikan jawaban **YA/TIDAK** beserta detail bila diperlukan.
4. **AI Agent** mengeksekusi tindakan **hanya** bila mendapat persetujuan eksplisit.
5. Setiap eksekusi terdokumentasi dalam *log* (output console) dan **ditambahkan** ke file `docs/PWS_Agent_Action_Log_v0.1.md`.

## 6. Logging Aktivitas AI Agent
- File `docs/PWS_Agent_Action_Log_v0.1.md` mencatat: tanggal‑waktu, aksi (create/modify/delete), path file, alasan, dan persetujuan pengguna.
- Contoh entri:
```
2026-08-30 12:45:01 | CREATE | docs/PWS_New_Doc.md | Dibutuhkan spec API baru | Persetujuan: USER
```

## 7. Status Dokumen Ini
Dokumen ini **berlaku** segera setelah dibuat dan **menjadi referensi utama** bagi semua interaksi selanjutnya. Setiap pelanggaran terhadap aturan ini harus dilaporkan dan diperbaiki.

---

**Catatan:**  Jika ada penambahan atau perubahan aturan, buat versi baru (mis. `v0.2`) dengan log perubahan di bagian *Changelog*.
