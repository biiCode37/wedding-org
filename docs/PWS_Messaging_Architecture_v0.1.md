# PWS_Messaging_Architecture_v0.1.md

## 1. Tujuan
Dokumen ini menetapkan arsitektur messaging untuk Premium Wedding SaaS MVP.

Fokus dokumen ini:
- email dan WhatsApp sebagai channel awal;
- provider messaging;
- template dan personalisasi;
- status delivery;
- retry;
- consent dan opt-out;
- audit dan keamanan.

Dokumen ini tidak mengubah model otorisasi, tenant boundary, atau domain invitation yang sudah ada.

## 2. Ruang Lingkup MVP
MVP harus mendukung:
- pengiriman email;
- pengiriman WhatsApp;
- template pesan;
- variabel personalisasi;
- status delivery;
- retry untuk kegagalan sementara;
- consent/opt-out;
- audit pesan sensitif.

## 3. Keputusan MVP
- Channel messaging: **Email + WhatsApp**.
- Provider awal: **provider email + provider WhatsApp** yang disetujui saat implementasi.
- Status delivery wajib disimpan.
- Retry otomatis wajib untuk kegagalan sementara.
- Consent dan opt-out wajib sejak MVP.

Jika provider final belum ditetapkan, dokumen ini tetap menjadi kontrak perilaku, bukan kontrak vendor.

## 4. Prinsip Dasar
1. Messaging adalah side effect, bukan source of truth.
2. State internal harus disimpan sebelum side effect eksternal dilakukan bila memungkinkan.
3. Delivery status harus dapat diaudit.
4. Retry harus idempotent.
5. Kontak yang opt-out tidak boleh dikirimi pesan marketing/reminder yang melanggar preferensi.
6. Template harus aman dari injection variabel.
7. Data sensitif tidak boleh bocor ke provider tanpa kebutuhan.

## 5. Aktor
| Aktor | Peran |
|---|---|
| Organization Staff | Membuat campaign, mengirim reminder, melihat status delivery. |
| System / Worker | Menjalankan pengiriman, retry, dan sinkronisasi delivery status. |
| External Provider | Mengirim email/WhatsApp ke penerima. |
| Guest / Recipient | Menerima pesan dan membuka link yang sesuai. |

## 6. Domain Messaging
### 6.1 Entitas utama
- `message_template`
- `message_campaign`
- `message_recipient`
- `message`
- `message_delivery_attempt`

### 6.2 Makna domain
- **Template**: isi pesan yang dapat dipakai ulang.
- **Campaign**: pengiriman yang ditargetkan.
- **Recipient**: tujuan pesan pada konteks tertentu.
- **Message**: instance pesan yang dibuat dari template.
- **Delivery attempt**: jejak percobaan pengiriman ke provider.

## 7. Channel dan Use Case
### 7.1 Email
Dipakai untuk:
- invitation reminder;
- RSVP reminder;
- notifikasi operasional;
- pesan follow-up.

### 7.2 WhatsApp
Dipakai untuk:
- invitation reminder;
- RSVP reminder;
- notifikasi operasional;
- pesan follow-up;
- pengiriman yang membutuhkan respons cepat.

Channel WhatsApp mengikuti kebijakan provider dan template yang diizinkan.

## 8. Provider Strategy
MVP menggunakan provider terpisah untuk email dan WhatsApp.

Aturan:
- provider dipanggil dari server/trusted worker;
- secret provider tidak boleh ada di frontend;
- provider response harus dinormalisasi ke model internal;
- provider-specific payload tidak menjadi domain utama;
- retry hanya untuk error yang memang retryable.

Jika provider diganti nanti, model internal tidak boleh berubah besar.

## 9. Template dan Variabel
### 9.1 Template
Template harus:
- memiliki nama;
- memiliki channel;
- memiliki versi;
- memiliki status aktif/nonaktif;
- dapat dipreview.

### 9.2 Variabel
Contoh variabel:
- `{{guest_name}}`
- `{{workspace_name}}`
- `{{event_name}}`
- `{{event_date}}`
- `{{rsvp_link}}`
- `{{invitation_link}}`

Aturan:
- variabel yang tidak dikenal harus ditolak atau diganti sesuai policy yang eksplisit;
- template tidak boleh memuat kode eksekusi;
- template harus lolos validasi sebelum kirim.

## 10. Consent dan Opt-out
Consent wajib di MVP.

Aturan:
- setiap recipient harus punya status consent yang jelas;
- opt-out harus dihormati;
- pesan marketing tidak boleh dikirim ke kontak yang opt-out;
- reminder operasional boleh dikirim hanya jika policy dan consent mengizinkan;
- consent perubahan harus tercatat.

Jika recipient tidak punya consent valid, pengiriman harus ditolak atau diarahkan sesuai policy yang disetujui.

## 11. Delivery Lifecycle
Status minimum:
- `DRAFT`
- `QUEUED`
- `SENDING`
- `SENT`
- `DELIVERED`
- `FAILED`
- `RETRYING`
- `CANCELLED`
- `OPTED_OUT`

### Aturan status
- `QUEUED` berarti pesan siap diproses worker.
- `SENDING` berarti request sedang dikirim ke provider.
- `SENT` berarti provider menerima request.
- `DELIVERED` berarti provider mengonfirmasi sampai tujuan jika tersedia.
- `FAILED` berarti pengiriman gagal.
- `RETRYING` berarti worker akan mencoba ulang.
- `CANCELLED` berarti campaign atau message dibatalkan.
- `OPTED_OUT` berarti recipient tidak boleh menerima jenis pesan tersebut.

## 12. Alur Pengiriman
```text
Staff membuat campaign atau message
    ↓
Server validasi template, consent, dan scope
    ↓
Message disimpan sebagai queued
    ↓
Worker mengambil job
    ↓
Worker memanggil provider
    ↓
Provider mengembalikan hasil
    ↓
Server simpan delivery attempt
    ↓
Status message diperbarui
    ↓
Audit dicatat
```

## 13. Retry Policy
Retry wajib untuk kegagalan sementara.

### Retryable
- timeout provider;
- 5xx provider;
- network error sementara;
- rate limit yang bisa dicoba ulang menurut policy.

### Tidak retryable
- consent invalid;
- template invalid;
- recipient opt-out;
- credential provider salah;
- payload validation error;
- invalid scope.

### Aturan retry
- retry harus memakai idempotency context;
- jumlah retry dibatasi;
- backoff harus eksplisit;
- kegagalan berulang harus menandai message sebagai failed.

## 14. Audit dan Evidence
Minimal audit untuk:
- pembuatan campaign;
- pengiriman pesan;
- retry;
- opt-out;
- cancel;
- template publish/update;
- kegagalan provider yang penting.

Audit harus menyimpan:
- actor;
- request_id;
- recipient scope;
- channel;
- status akhir;
- waktu.

## 15. API Contract Messaging
Endpoint minimum:
- `GET /v1/workspaces/{workspaceUuid}/messages`
- `POST /v1/workspaces/{workspaceUuid}/messages`
- `POST /v1/messages/{messageUuid}/send`
- `GET /v1/workspaces/{workspaceUuid}/message-templates`
- `POST /v1/workspaces/{workspaceUuid}/message-templates`

Setiap endpoint harus mengikuti authorization contract dan scope ownership.

## 16. Keamanan
- Secret provider hanya di server.
- Request ke provider harus memakai signature atau mekanisme autentikasi vendor.
- Template tidak boleh membuka data sensitif yang tidak dibutuhkan.
- Contact data harus diproteksi oleh tenant boundary.
- Recipient dari workspace lain tidak boleh ikut campaign.

## 17. Acceptance Criteria
- Email dan WhatsApp bisa dikirim dari MVP.
- Delivery status tersimpan.
- Retry berjalan untuk error sementara.
- Consent dan opt-out dihormati.
- Provider failure tidak merusak state internal.
- Campaign dapat diaudit.
- Pesan tidak terkirim ke workspace atau recipient yang tidak berhak.

## 18. Guardrail untuk AI Agent Code
AI Agent Code harus:
- memisahkan state internal dari provider response;
- menerapkan consent dan opt-out sejak awal;
- menyimpan delivery attempt;
- memakai retry yang idempotent;
- tidak mengirim pesan lintas tenant;
- tidak menyimpan secret provider di frontend;
- tidak mengarang channel tambahan tanpa persetujuan.

## 19. Status
**Baseline messaging MVP selesai.**

## 20. Referensi
- `PWS_PRD_v0.1.md`
- `PWS_Domain_Services_Business_Rules_v0.1.md`
- `PWS_Use_Cases_State_Machines_v0.1.md`
- `PWS_API_Contract_v0.1.md`
- `PWS_Security_NFR_Specification_v0.1.md`
- `PWS_Testing_Acceptance_Criteria_v0.1.md`
