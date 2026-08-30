# PWS_Payment_Architecture_v0.1.md

## 1. Tujuan
Dokumen ini menetapkan arsitektur pembayaran SaaS untuk Premium Wedding SaaS MVP.

Fokus dokumen ini:
- penagihan SaaS ke `Organization`;
- integrasi Midtrans;
- model langganan fleksibel;
- status invoice dan subscription;
- webhook verification;
- audit dan idempotency;
- kebijakan akses saat gagal bayar.

Dokumen ini tidak mengatur wedding gift/payment. Wedding gift/payment adalah domain terpisah.

## 2. Ruang Lingkup MVP
MVP hanya mencakup:
- pembayaran SaaS organisasi;
- Midtrans sebagai payment provider;
- Midtrans Snap untuk checkout;
- model billing bulanan, tahunan, atau per wedding;
- invoice lifecycle dasar;
- status read-only saat invoice tidak aktif;
- refund/cancellation manual oleh platform admin.

## 3. Prinsip Dasar
1. SaaS billing adalah domain organisasi.
2. Pembayaran diverifikasi dari webhook Midtrans, bukan dari redirect browser.
3. Payment state adalah hasil verifikasi server.
4. Subscription dan invoice harus dapat diaudit.
5. Payment flow harus idempotent.
6. Akses organisasi yang tidak aktif berubah menjadi read-only.
7. Refund MVP dilakukan manual.

## 4. Aktor
| Aktor | Peran |
|---|---|
| Organization Owner | Melihat paket, memilih billing plan, membayar invoice, melihat status billing. |
| Platform Admin | Melihat semua billing, memproses refund manual, menangani koreksi. |
| System / Midtrans Webhook | Mengirim status pembayaran terverifikasi. |

## 5. Model Billing
Organisasi boleh memilih salah satu model berikut.

### 5.1 Bulanan
- Tagihan berulang setiap bulan.
- Cocok untuk organisasi yang ingin biaya rutin ringan.
- Status langganan diperpanjang setelah pembayaran berhasil.

### 5.2 Tahunan
- Tagihan berulang setiap tahun.
- Cocok untuk organisasi yang ingin komitmen lebih panjang.
- Dapat diberikan harga khusus bila disetujui bisnis.

### 5.3 Per Wedding
- Tagihan satu kali per workspace/wedding.
- Bukan subscription berulang.
- Cocok bila organisasi ingin membayar per proyek.

### 5.4 Hybrid
- Subscription dasar bulanan atau tahunan.
- Tambahan biaya per wedding bila diperlukan.
- Hanya dipakai jika keputusan bisnis menyetujuinya.

## 6. Keputusan MVP
MVP harus mendukung **beberapa opsi billing** agar fleksibel:
- bulanan;
- tahunan;
- per wedding.

Namun implementasi awal boleh aktif hanya pada subset yang disetujui untuk rilis pertama.

## 7. Status Subscription
Status minimum:
- `DRAFT`
- `PENDING_PAYMENT`
- `ACTIVE`
- `PAST_DUE`
- `READ_ONLY`
- `CANCELLED`
- `EXPIRED`

### Aturan status
- `PENDING_PAYMENT` dipakai saat invoice sudah dibuat tetapi belum dibayar.
- `ACTIVE` dipakai saat pembayaran settlement berhasil.
- `PAST_DUE` dipakai saat jatuh tempo lewat tetapi sistem masih memberi grace bila kebijakan mengizinkan.
- `READ_ONLY` dipakai saat pembayaran gagal, expired, atau jatuh tempo lewat sesuai policy MVP.
- `CANCELLED` dipakai saat platform admin atau owner menghentikan billing.
- `EXPIRED` dipakai saat siklus billing selesai tanpa perpanjangan.

## 8. Status Invoice
Status minimum:
- `DRAFT`
- `PENDING`
- `SETTLED`
- `EXPIRED`
- `CANCELLED`
- `REFUNDED`

### Aturan invoice
- invoice dibuat sebelum checkout;
- invoice dianggap aktif saat Midtrans Snap token dibuat;
- settlement mengubah status menjadi `SETTLED`;
- pending tetap menunggu settlement atau expiry;
- expired dan cancelled menutup akses billing aktif.

## 9. Alur Pembayaran
```text
Organization Owner memilih plan
    ↓
Server membuat invoice
    ↓
Server meminta Snap token ke Midtrans
    ↓
Midtrans mengembalikan snap_token
    ↓
UI menampilkan Snap checkout
    ↓
User menyelesaikan pembayaran
    ↓
Midtrans mengirim webhook
    ↓
Server verifikasi signature
    ↓
Server update invoice/subscription
    ↓
Akses organisasi disesuaikan
```

## 10. Kontrak API Billing
Endpoint billing minimal:
- `GET /v1/organizations/{organizationUuid}/subscription`
- `GET /v1/organizations/{organizationUuid}/invoices`
- `POST /v1/organizations/{organizationUuid}/invoices`
- `POST /v1/payments/midtrans/snap-token`
- `POST /v1/webhooks/midtrans`
- `POST /v1/organizations/{organizationUuid}/billing/cancel`

## 11. Midtrans Snap
### 11.1 Tujuan
Midtrans Snap dipakai karena:
- mendukung banyak metode pembayaran;
- cocok untuk checkout cepat;
- mengurangi beban UI pembayaran;
- mudah dipakai untuk beta.

### 11.2 Data yang dikirim
Payload minimum:
- `order_id`
- `gross_amount`
- `customer_details`
- `item_details`
- `callbacks` bila diperlukan
- `expiry` bila diset

### 11.3 Aturan `order_id`
`order_id` harus:
- unik;
- tidak bisa ditebak;
- mengandung referensi invoice atau subscription internal;
- tidak memakai identifier sensitif sebagai satu-satunya rahasia.

## 12. Webhook Midtrans
Webhook wajib menjadi source of truth status pembayaran.

### Event yang diproses
- `pending`
- `settlement`
- `expire`
- `cancel`

### Aturan webhook
1. Verifikasi signature.
2. Cocokkan `order_id`.
3. Pastikan webhook belum pernah diproses untuk state yang sama.
4. Update invoice dan subscription secara atomik.
5. Catat audit event.

### Idempotency webhook
Jika event yang sama diterima ulang:
- hasil akhir harus sama;
- tidak boleh membuat invoice ganda;
- tidak boleh memperpanjang subscription lebih dari sekali.

## 13. Kebijakan Akses Saat Pembayaran Gagal
Jika invoice belum dibayar, expired, atau cancellation selesai:
- organisasi menjadi `READ_ONLY`;
- staff masih dapat melihat data penting;
- mutation yang membutuhkan billing aktif ditolak;
- billing page tetap dapat diakses oleh Organization Owner.

Dokumen ini tidak mengubah tenant boundary atau authorization model.

## 14. Refund / Cancellation
Refund MVP:
- dilakukan manual oleh Platform Admin;
- tidak otomatis;
- harus tercatat di audit;
- status invoice dapat berubah ke `REFUNDED` setelah proses manual selesai.

Cancellation:
- dapat menghentikan perpanjangan subscription;
- tidak otomatis memicu refund;
- kebijakan final refund mengikuti keputusan bisnis manual.

## 15. Data yang Harus Disimpan
Minimal data payment:
- organization;
- subscription;
- invoice;
- payment status;
- provider reference;
- webhook payload yang sudah disanitasi bila perlu;
- audit trail;
- waktu transaksi.

## 16. Aturan Keamanan
- Secret Midtrans hanya di server environment.
- Jangan simpan secret di frontend.
- Jangan mengandalkan redirect browser sebagai bukti pembayaran.
- Jangan menerima webhook tanpa signature verification.
- Jangan mengubah ownership invoice dari client request.
- Jangan membuat payment flow yang bypass audit.

## 17. Acceptance Criteria
- Organization Owner dapat memilih plan billing.
- Server dapat membuat invoice dan Snap token.
- Webhook settlement mengaktifkan subscription.
- Webhook pending/expire/cancel memperbarui status dengan benar.
- Invoice yang gagal bayar membuat organisasi read-only.
- Refund manual dapat dicatat oleh Platform Admin.
- Event webhook yang sama tidak menciptakan side effect ganda.
- Status billing dapat ditelusuri melalui audit.

## 18. Guardrail untuk AI Agent Code
AI Agent Code harus:
- memisahkan SaaS billing dari wedding payment;
- memakai Midtrans Snap untuk checkout;
- memverifikasi webhook sebelum update status;
- mengimplementasi idempotency pada invoice dan webhook;
- tidak membuat auto-refund;
- tidak memberi akses mutasi saat status read-only;
- tidak mengarang model pembayaran lain tanpa persetujuan.

## 19. Status
**Baseline billing SaaS MVP selesai.**

## 20. Referensi
- `PWS_PRD_v0.1.md`
- `PWS_Release_Roadmap_and_Zero_Cost_Strategy_v0.1.md`
- `PWS_Architecture_Decision_Record_v0.1.md`
- `PWS_Physical_Database_Schema_v0.1.md`
- `PWS_Authorization_RLS_Specification_v0.1_updated.md`
- `PWS_Security_NFR_Specification_v0.1.md`
- `PWS_Testing_Acceptance_Criteria_v0.1.md`
