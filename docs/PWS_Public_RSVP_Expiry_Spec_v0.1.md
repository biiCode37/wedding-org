# PWS_Public_RSVP_Expiry_Spec_v0.1.md

## 1. Tujuan
Dokumen ini menetapkan aturan expiry untuk public RSVP pada MVP Premium Wedding SaaS. Fokus utama dokumen ini adalah menjaga keamanan token public guest tanpa membuat alur RSVP menjadi ambigu untuk AI Agent Code.

## 2. Ruang Lingkup
Dokumen ini hanya mengatur:
- validitas token public RSVP;
- kapan token dianggap expired;
- apa yang terjadi setelah event selesai;
- perilaku revocation;
- hubungan dengan state RSVP.

Dokumen ini tidak mengubah model otorisasi staff, struktur database, atau kontrak API yang sudah ada.

## 3. Keputusan Final
### 3.1 Masa berlaku token
Public RSVP token berlaku sampai **akhir event terakhir** pada workspace yang bersangkutan.

Definisi praktis:
- `token_expiry_at = max(event.end_at) + grace_period`
- `grace_period` pada MVP ditetapkan **0 menit** kecuali ada override operasional yang disetujui.

### 3.2 Setelah event selesai
Jika waktu server sudah melewati `token_expiry_at`, maka:
- token dianggap expired;
- public RSVP tidak bisa dibuat atau diubah;
- sistem mengembalikan penolakan sesuai kontrak API/security;
- data RSVP lama tetap tersimpan sebagai evidence.

### 3.3 Revocation
Token dapat direvoke sebelum expiry.

Efek revocation:
- akses public langsung ditolak;
- token tidak boleh dipakai ulang;
- revocation wajib tercatat pada audit bila jalurnya sensitif.

## 4. Aturan Perhitungan Expiry
### 4.1 Sumber waktu
Sumber waktu harus dari server, bukan dari client.

### 4.2 Referensi waktu event
Expiry dihitung dari event dengan nilai `end_at` paling akhir pada scope invitation yang valid.

Jika event tidak memiliki `end_at`, sistem tidak boleh menebak sendiri. Kasus ini harus ditolak atau dipaksa pakai keputusan data yang eksplisit sebelum public RSVP diaktifkan.

### 4.3 Zonasi waktu
Perhitungan memakai timezone event/workspace yang sudah menjadi sumber data utama.

## 5. State Behavior
### 5.1 State aktif
Token aktif jika:
- token valid;
- belum revoked;
- belum expired;
- invitation party masih valid;
- workspace dan event masih sesuai scope.

### 5.2 State expired
Token expired jika:
- waktu server > `token_expiry_at`;
- atau event sudah berstatus selesai sesuai domain state yang dipakai implementasi.

### 5.3 State revoked
Token revoked jika:
- staff melakukan revoke;
- workspace/event diarsipkan dengan policy yang menutup public access;
- ada security decision yang memaksa penutupan akses.

## 6. Perilaku API
### 6.1 Read public invitation
Endpoint public invitation hanya boleh mengembalikan data minimum jika token masih valid.

### 6.2 Submit RSVP
Jika token expired atau revoked:
- request ditolak;
- tidak ada perubahan state RSVP;
- response tidak boleh membocorkan detail internal yang tidak perlu.

### 6.3 Update RSVP
Update hanya boleh terjadi bila token masih valid dan policy update masih dibuka.

## 7. Aturan Data
Sistem harus menyimpan minimal:
- `expires_at`
- `revoked_at`
- `last_used_at`
- jejak RSVP yang sudah pernah terjadi

Jika suatu row butuh history, current state dan history tetap dipisahkan.

## 8. Acceptance Rule
MVP dianggap benar bila:
- token valid sebelum expiry;
- token ditolak setelah expiry;
- token ditolak setelah revoke;
- RSVP yang sudah tersimpan tetap utuh setelah token kedaluwarsa;
- server tidak bergantung pada jam client.

## 9. Guardrail untuk AI Agent Code
AI Agent Code harus mengikuti aturan ini:
- jangan menganggap token public sebagai credential staff;
- jangan memperpanjang expiry otomatis tanpa keputusan eksplisit;
- jangan membuat fallback expiry berbasis client time;
- jangan menghapus data RSVP lama saat token expired.

## 10. Status
**Baseline complete untuk public RSVP expiry MVP.**

## 11. Referensi
- `PWS_API_Contract_v0.1.md`
- `PWS_Authorization_RLS_Specification_v0.1_updated.md`
- `PWS_Domain_Services_Business_Rules_v0.1.md`
- `PWS_Use_Cases_State_Machines_v0.1.md`
- `PWS_Security_NFR_Specification_v0.1.md`
