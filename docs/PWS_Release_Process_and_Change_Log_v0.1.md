# PWS_Release_Process_and_Change_Log_v0.1.md

## 1. Tujuan
Dokumen ini menetapkan proses release dan pencatatan perubahan untuk Premium Wedding SaaS.

Fokus dokumen ini:
- kapan release boleh dilakukan;
- bagaimana perubahan dicatat;
- bagaimana approval diberikan;
- bagaimana versioning dijaga;
- bagaimana hotfix ditangani.

Dokumen ini berlaku untuk fase dokumentasi sampai build dan release.

## 2. Prinsip Dasar
1. Release tidak boleh terjadi hanya karena pekerjaan teknis selesai.
2. Release harus melewati gate dokumen.
3. Change log harus append-only per versi.
4. Approval release wajib dari pengguna.
5. Versioning tetap di jalur `v0.x` sampai baseline final disetujui.
6. Hotfix tetap butuh approval eksplisit.
7. Dokumen yang kontradiktif harus diselesaikan sebelum release.

## 3. Release Cadence
Keputusan release cadence: **berbasis gate dokumen**.

Artinya release hanya boleh berjalan jika gate berikut terpenuhi:
- dokumen wajib selesai;
- dokumen upstream tidak konflik;
- keputusan deferred yang memengaruhi release sudah jelas;
- approval eksplisit pengguna sudah ada.

Tidak ada jadwal mingguan otomatis atau per sprint yang mengalahkan gate ini.

## 4. Versioning Policy
Sebelum baseline final, semua dokumen dan artefak mengikuti pola:
- `v0.1`, `v0.2`, `v0.3`, dan seterusnya.

Aturan:
- version bump hanya dilakukan jika ada perubahan bermakna;
- perubahan besar harus dibahas dan dicatat;
- `v1.0` hanya dipakai setelah baseline final disetujui.

## 5. Change Log Policy
Change log bersifat **append-only per versi**.

Aturan:
- catatan versi lama tidak dihapus;
- perubahan baru ditambahkan di bawah versi yang relevan;
- setiap entri harus mencatat tanggal, alasan, dan dampak;
- perubahan yang memengaruhi security, authorization, payment, atau data harus diberi penanda khusus.

## 6. Approval Rule
Setiap release memerlukan approval manual dari pengguna.

Approval diperlukan untuk:
- membuat release dokumen final;
- memulai coding/build;
- merge perubahan besar;
- melakukan hotfix;
- mengubah keputusan penting yang sebelumnya sudah ditetapkan.

Tanpa approval, tidak ada tindakan eksekusi release.

## 7. Gate Release
Release boleh berjalan hanya bila:
- semua dokumen wajib sudah ada;
- tidak ada konflik antar dokumen;
- dokumen upstream dan downstream konsisten;
- checklist release terpenuhi;
- perubahan penting sudah disetujui.

Jika ada conflict, dokumen harus diperbaiki dulu. Jangan menutup konflik dengan asumsi sendiri.

## 8. Artifact Release
Pada fase ini, artifact release yang sah adalah **docs dulu**.

Artinya:
- tidak ada code scaffold yang dianggap release artifact;
- tidak ada konfigurasi build yang dibuat tanpa izin;
- tidak ada deploy yang dilakukan tanpa approval;
- dokumen menjadi sumber kebenaran utama.

## 9. Emergency Hotfix
Hotfix hanya boleh dilakukan bila pengguna memberi approval eksplisit.

Aturan hotfix:
- hotfix harus dicatat di change log;
- hotfix harus menyebut alasan dan dampak;
- hotfix tetap harus mengikuti gate minimum yang aman;
- hotfix tidak boleh menimbulkan perubahan arsitektur diam-diam.

## 10. Change Control Flow
```text
Ide atau perubahan ditemukan
    ↓
Tentukan dokumen terdampak
    ↓
Tulis perubahan atau draft revisi
    ↓
Minta approval eksplisit pengguna
    ↓
Jika disetujui, update dokumen
    ↓
Catat di change log
    ↓
Lanjutkan ke tahap berikutnya
```

## 11. Conflict Handling
Jika dokumen saling bertentangan:
1. tandai conflict;
2. jangan lanjut coding/release;
3. minta keputusan pengguna;
4. revisi dokumen yang terdampak;
5. update change log.

## 12. Release Checklist
Sebelum release, pastikan:
- dokumen wajib selesai;
- perubahan tercatat;
- approval manual sudah ada;
- version number benar;
- tidak ada conflict;
- artifact yang di-release memang sesuai fase.

## 13. Format Change Log
Contoh format:

```text
## v0.2
- 2026-08-30: Tambah payment architecture Midtrans.
  Dampak: membuka desain billing SaaS.
- 2026-08-30: Tambah UI/UX spec.
  Dampak: menutup gap desain frontend.
```

## 14. Guardrail untuk AI Agent Code
AI Agent Code harus:
- tidak membuat release tanpa approval;
- tidak menghapus change log lama;
- tidak menaikkan versi secara sembarang;
- tidak menambahkan artifact code saat fase docs only;
- tidak menyelesaikan conflict dengan asumsi sendiri;
- tidak mengubah release cadence tanpa persetujuan.

## 15. Status
**Baseline release process dan change log selesai.**

## 16. Referensi
- `PWS_Engineering_Implementation_Blueprint_v0.1.md`
- `PWS_Data_Governance_and_Privacy_v0.1.md`
- `PWS_Deployment_Guide_and_Runbook_v0.1.md`
- `PWS_Testing_Acceptance_Criteria_v0.1.md`
- `PWS_AI_Agent_Operating_Rules_v0.1.md`
