# PWS_Client_Writable_Fields_v0.1.md

## 1. Tujuan
Dokumen ini menetapkan batas akses Couple/Client pada MVP Premium Wedding SaaS. Pada MVP, Couple/Client menggunakan akses terautentikasi terbatas dan bersifat **read-only**.

Dokumen ini menjadi batas implementasi untuk API, UI, RLS, domain service, dan pengujian.

## 2. Keputusan MVP
Couple/Client:
- dapat login melalui Supabase Auth;
- dihubungkan ke workspace melalui `client_access`;
- hanya dapat membaca data yang ditandai client-visible;
- tidak dapat membuat, mengubah, atau menghapus data melalui MVP;
- tidak memperoleh staff role atau staff permission;
- tidak dapat mengakses workspace lain.

## 3. Matriks Akses
| Area | Baca | Buat | Ubah | Hapus |
|---|---:|---:|---:|---:|
| Workspace dasar | Ya, field terbatas | Tidak | Tidak | Tidak |
| Wedding profile | Ya, field client-visible | Tidak | Tidak | Tidak |
| Couple profile | Ya, field client-visible | Tidak | Tidak | Tidak |
| Event dan venue | Ya, data public/client-visible | Tidak | Tidak | Tidak |
| Website draft | Tidak, kecuali preview yang diizinkan | Tidak | Tidak | Tidak |
| Website published | Ya, preview/published content | Tidak | Tidak | Tidak |
| Guest | Ya, agregat atau field yang diizinkan | Tidak | Tidak | Tidak |
| Invitation | Ya, status/agregat yang diizinkan | Tidak | Tidak | Tidak |
| RSVP | Ya, agregat/status yang diizinkan | Tidak melalui client portal | Tidak | Tidak |
| Seating | Ya, hanya bila ditandai client-visible | Tidak | Tidak | Tidak |
| Check-in | Ya, agregat saja | Tidak | Tidak | Tidak |
| Billing organisasi | Tidak | Tidak | Tidak | Tidak |
| Role dan membership | Tidak | Tidak | Tidak | Tidak |
| Audit dan security event | Tidak | Tidak | Tidak | Tidak |
| Media | Ya, media client-visible | Tidak | Tidak | Tidak |

## 4. Field yang Boleh Dibaca
API boleh mengembalikan field berikut jika workspace dan field tersebut client-visible:

### Workspace
- `uuid`
- `name`
- `status`
- `timezone`
- `locale`

### Wedding profile
- `title`
- `wedding_date`
- `status`
- `description`

### Couple profile
- `display_name`
- `first_name`
- `last_name`
- `role`
- foto atau media yang telah ditandai client-visible

### Event
- `uuid`
- `name`
- `event_type`
- `starts_at`
- `ends_at`
- `timezone`
- `visibility`
- informasi venue yang client-visible

### Dashboard
- jumlah guest;
- jumlah RSVP;
- jumlah tamu hadir;
- jumlah undangan berdasarkan status;
- status website published.

Nilai internal, catatan staff, nomor telepon/email guest, token, data billing, dan security evidence tidak boleh dikembalikan kecuali ada keputusan eksplisit baru.

## 5. Data yang Tidak Boleh Diakses
Couple/Client tidak boleh membaca:
- organization membership;
- role, permission, dan delegation data;
- client access milik user lain;
- data workspace lain;
- guest contact data secara massal;
- invitation token mentah atau hash token;
- audit log dan security event;
- SaaS subscription, invoice, dan payment transaction organisasi;
- internal notes staff;
- service credentials;
- raw provider payload;
- data yang belum ditandai client-visible.

## 6. Kontrak Authorization
Setiap request Couple/Client harus memeriksa:

```text
Authenticated session
    ↓
Active client_access
    ↓
Target workspace sesuai client_access
    ↓
Resource client-visible
    ↓
Field-level response filtering
    ↓
ALLOW
```

Kegagalan salah satu pemeriksaan menghasilkan `DENY`.

`workspaceUuid` dari client tidak menjadi bukti akses. Server harus mencocokkannya dengan `client_access`.

## 7. Kontrak API
Endpoint staff tidak boleh dipakai langsung oleh Couple/Client dengan response yang lebih luas.

Endpoint client harus:
- memiliki identity context `client`;
- memiliki daftar resource dan field yang diizinkan;
- menerapkan workspace ownership;
- tidak menerima field mutation tersembunyi;
- tidak mengizinkan mass assignment;
- mengembalikan error sesuai API Contract.

Pada MVP, client portal hanya memerlukan operasi baca. Tidak perlu membuat endpoint `POST`, `PATCH`, atau `DELETE` khusus client.

## 8. Realtime
Couple/Client hanya dapat berlangganan channel workspace yang diizinkan dan hanya menerima payload client-visible.

Channel tidak boleh mengirim:
- perubahan internal staff;
- data guest pribadi;
- data billing;
- audit/security event;
- resource workspace lain.

Setelah reconnect, client harus mengambil snapshot authoritative dari API.

## 9. UI Behavior
UI client:
- tidak menampilkan form edit;
- tidak menampilkan tombol operasi staff;
- tidak menjadikan UI sebagai batas keamanan;
- menampilkan data yang sedang tersedia untuk client;
- menampilkan status read-only secara jelas.

UI hiding tidak menggantikan pemeriksaan server-side.

## 10. Audit
Login, akses yang ditolak, dan operasi sensitif mengikuti kebijakan audit/security yang berlaku. Karena MVP tidak menyediakan mutation client, client tidak menghasilkan audit mutation biasa.

Percobaan mengakses staff-only atau workspace lain harus ditolak dan dapat menghasilkan security evidence sesuai kebijakan.

## 11. Acceptance Criteria
- Client aktif dapat membaca workspace yang ditugaskan.
- Client tidak dapat membaca workspace lain.
- Client tidak dapat membaca atau mengubah role dan membership.
- Client tidak dapat membaca billing organisasi.
- Client tidak dapat membaca token invitation.
- Client tidak dapat mengubah wedding profile, website, guest, event, RSVP, atau media.
- Request mutation manual dari client tetap ditolak server.
- Response client tidak memuat field staff-private.
- Realtime client tidak mengirim payload di luar client-visible scope.
- Client yang access-nya dicabut kehilangan akses efektif.

## 12. Guardrail untuk AI Agent Code
AI Agent Code harus:
- memakai `client_access`, bukan `organization_member`, sebagai dasar akses client;
- menerapkan allowlist resource dan field;
- menolak semua mutation client pada MVP;
- tidak memberi client permission staff secara implisit;
- tidak mengandalkan route guard atau hidden UI saja;
- tidak mengembalikan raw database row tanpa filtering;
- tidak mengarang field client-write sebelum dokumen ini direvisi.

## 13. Perubahan ke Depan
Client-write dapat ditambahkan melalui dokumen revisi terpisah. Setiap field baru harus menetapkan:
- alasan bisnis;
- actor yang boleh mengubah;
- workspace scope;
- validasi input;
- approval bila diperlukan;
- audit requirement;
- dampak API, RLS, dan testing.

## 14. Status
**Baseline complete untuk MVP. Couple/Client bersifat read-only.**

## 15. Referensi
- `PWS_Architecture_Decision_Record_v0.1.md`
- `PWS_Authorization_RLS_Specification_v0.1_updated.md`
- `PWS_API_Contract_v0.1.md`
- `PWS_Domain_Services_Business_Rules_v0.1.md`
- `PWS_Security_NFR_Specification_v0.1.md`
- `PWS_Testing_Acceptance_Criteria_v0.1.md`
