# PWS_Glossary_v0.1.md

## 1. Tujuan
Dokumen ini menetapkan arti istilah utama Premium Wedding SaaS agar product owner, designer, developer, tester, dan AI Agent Code memakai istilah yang sama.

Jika istilah pada dokumen lain bertentangan dengan glossary ini, konflik harus direview sebelum implementasi.

## 2. Aturan Penggunaan
- Gunakan istilah yang sama pada UI, API, schema, test, dan dokumentasi.
- Jangan membuat sinonim permission tanpa keputusan eksplisit.
- Jangan memakai istilah dari domain lain sebagai bagian domain wedding SaaS.
- Istilah teknis standar seperti API, RLS, UUID, webhook, dan CI tetap dipakai dalam bahasa teknis aslinya.

## 3. Product dan Tenant
| Istilah | Definisi |
|---|---|
| Platform | Layanan SaaS Premium Wedding SaaS secara global. |
| Organization | Bisnis wedding/event organizer yang memakai platform. Menjadi tenant boundary utama. |
| Tenant | Boundary isolasi data milik satu Organization. |
| Workspace | Satu proyek wedding/client milik satu Organization pada MVP. |
| Workspace scope | Batas akses terhadap satu Workspace tertentu. |
| Platform Admin | Actor global yang mengelola platform. Bukan staff Organization biasa. |
| Organization Owner | Pemilik Organization dengan akses manajemen organisasi dan billing sesuai policy. |
| Organization Admin | Staff Organization dengan kemampuan administrasi sesuai permission dan scope. |
| Event Manager | Staff yang mengelola wedding/event pada Workspace yang ditugaskan. |
| Guest/Invitation Manager | Staff yang mengelola guest, invitation, dan RSVP sesuai scope. |
| Check-in Staff | Staff dengan akses operasional check-in pada Event yang ditugaskan. |
| Couple/Client | Pengguna terautentikasi dengan `client_access` terbatas pada Workspace. Read-only pada MVP. |
| Public Guest | Guest yang mengakses invitation dengan public token. Bukan staff atau client. |

## 4. Identity, Authorization, dan Scope
| Istilah | Definisi |
|---|---|
| Authentication | Verifikasi identitas user atau caller. |
| Authorization | Keputusan apakah actor boleh melakukan aksi pada resource tertentu. |
| RBAC | Role-Based Access Control; model role dan permission. |
| Role | Kumpulan capability/permission. Role bukan scope. |
| Permission | Hak aksi dengan bentuk `resource.action`, contoh `guest.update`. |
| Scope | Lokasi/batas berlaku permission: Organization, Workspace, atau Event. |
| Ownership | Jalur kepemilikan deterministik resource menuju Organization. |
| Organization membership | Hubungan staff dengan Organization melalui `organization_member`. |
| Client access | Hubungan Couple/Client dengan Workspace melalui `client_access`. Tidak memberi staff permission. |
| Effective permission | Hasil evaluasi membership aktif, role, permission, scope, ownership, dan domain rule. |
| Tenant isolation | Jaminan bahwa data tenant A tidak dapat diakses tenant B tanpa otoritas eksplisit. |
| RLS | Row Level Security PostgreSQL sebagai defense-in-depth untuk isolasi data. |
| Service role | Credential backend tepercaya yang dapat bypass RLS. Bukan identitas user dan tidak boleh di frontend. |

## 5. Wedding dan Event
| Istilah | Definisi |
|---|---|
| Wedding profile | Informasi utama wedding pada satu Workspace. |
| Couple person | Individu yang menjadi bagian couple/client pada wedding. |
| Event | Acara spesifik dalam Workspace, misalnya akad atau resepsi. |
| Event scope | Batas akses yang hanya berlaku untuk satu Event. |
| Venue | Lokasi fisik yang dipakai Event. |
| Event guest | Association antara Guest dan Event. Menyatakan partisipasi guest dalam event tersebut. |
| Event assignment | Penugasan guest ke Event melalui `event_guest`. |

## 6. Guest, Invitation, dan RSVP
| Istilah | Definisi |
|---|---|
| Guest | Identitas tamu yang scoped pada satu Workspace. Bukan directory global. |
| Guest group | Pengelompokan guest untuk kebutuhan operasional atau komunikasi. |
| Guest tag | Label untuk segmentasi guest. |
| Invitation Party | Unit undangan yang diwakili satu QR. Memiliki satu primary guest. |
| Primary guest | Guest utama yang menjadi referensi Invitation Party. |
| Invited person count | Jumlah orang yang diundang oleh Invitation Party. |
| Actual attendee count | Jumlah orang yang benar-benar hadir. Berbeda dari invited person count. |
| Invitation | Entitas lifecycle undangan: draft, publish, send, cancel, dan delivery state. |
| Invitation token | Credential random/non-guessable untuk public guest context. Bukan UUID resource dan bukan staff credential. |
| QR | Kode yang merepresentasikan satu Invitation Party atau public invitation context sesuai policy. |
| RSVP | Respons kehadiran Guest terhadap Event. |
| RSVP current state | State RSVP terbaru yang dipakai untuk query operasional. |
| RSVP history | Riwayat perubahan RSVP yang bersifat append-only bila diperlukan. |
| Accepted RSVP | State bahwa guest menyatakan hadir. |
| Declined RSVP | State bahwa guest menyatakan tidak hadir. |
| Pending RSVP | State bahwa guest belum mengirim respons. |

## 7. Check-in dan Souvenir
| Istilah | Definisi |
|---|---|
| Check-in | Pencatatan kedatangan event guest pada Event. |
| Check-in record | Evidence check-in yang berhasil. |
| Check-in correction | Aksi privileged untuk memperbaiki check-in tanpa menghapus evidence sebelumnya. |
| Idempotency | Sifat command yang menghasilkan satu efek bisnis walaupun request yang sama diulang. |
| Idempotency key | Key opaque untuk mengenali retry logical request yang sama. |
| Souvenir entitlement | Hak jumlah souvenir untuk Invitation Party. |
| Default entitlement | Jumlah souvenir default, sama dengan invited person count kecuali ada override valid. |
| Entitlement override | Perubahan jumlah entitlement dengan permission dan reason. |
| Souvenir claim | Pencatatan pengambilan souvenir. |
| Proxy claim | Claim yang dilakukan atas nama pihak lain dan membutuhkan staff confirmation. |
| Remaining entitlement | `final_quantity - claimed_quantity`. |

## 8. Website dan Media
| Istilah | Definisi |
|---|---|
| Website | Invitation website milik satu Workspace pada MVP. |
| Draft | State website yang masih dapat diedit. |
| Published version | Snapshot website yang sudah dipublikasi dan immutable. |
| Theme preset | Paket token desain yang dapat dipilih untuk invitation website. |
| Design token | Nilai desain reusable seperti warna, typography, spacing, radius, shadow, dan motion. |
| Section | Bagian konten website, misalnya cover, couple, event, RSVP, atau gallery. |
| Media asset | Metadata file media yang tersimpan di object storage. |
| Public media | Media yang eksplisit diizinkan tampil publik. |
| Private media | Media yang hanya dapat diakses sesuai authorization. |

## 9. Billing dan Payment
| Istilah | Definisi |
|---|---|
| SaaS billing | Penagihan platform kepada Organization. |
| Wedding payment | Pembayaran/gift terkait wedding. Domain ini berbeda dari SaaS billing. |
| Subscription | Hubungan billing Organization dengan SaaS plan. |
| SaaS plan | Paket layanan dan entitlement yang dapat dipilih Organization. |
| Entitlement | Ketersediaan fitur berdasarkan plan/subscription. Berbeda dari permission. |
| Invoice | Rekaman tagihan untuk Organization. |
| Payment provider | Layanan eksternal pemroses pembayaran, Midtrans pada MVP. |
| Midtrans Snap | Hosted checkout Midtrans untuk metode pembayaran yang tersedia. |
| Webhook | Callback server-to-server dari provider tentang event, misalnya status pembayaran. |
| Settlement | Status provider bahwa pembayaran berhasil terverifikasi. |
| Read-only | State akses Organization saat billing tidak aktif; data dapat dibaca sesuai policy, mutation dibatasi. |
| Refund | Pengembalian dana. Pada MVP diproses manual oleh Platform Admin. |

## 10. Messaging
| Istilah | Definisi |
|---|---|
| Message template | Template pesan reusable untuk email atau WhatsApp. |
| Message campaign | Pengiriman pesan ke banyak recipient dalam satu konteks. |
| Recipient | Tujuan pesan yang valid dalam scope tenant. |
| Delivery attempt | Satu percobaan pengiriman ke provider. |
| Delivery status | Status internal pesan, misalnya queued, sent, delivered, failed, atau retrying. |
| Consent | Persetujuan recipient untuk menerima komunikasi sesuai policy. |
| Opt-out | Preferensi recipient untuk tidak menerima jenis komunikasi tertentu. |
| Retryable failure | Kegagalan sementara yang aman untuk dicoba ulang. |

## 11. Engineering dan Operasional
| Istilah | Definisi |
|---|---|
| API contract | Aturan stabil untuk endpoint, request, response, error, identity context, dan authorization. |
| Domain service | Lapisan yang menjalankan perilaku bisnis dan invariant, bukan CRUD table biasa. |
| Domain invariant | Kondisi bisnis yang selalu harus benar. |
| Transaction boundary | Batas operasi database yang harus berhasil atau gagal secara atomik. |
| Outbox | Pola menyimpan side effect/event internal sebelum worker memprosesnya. |
| Realtime | Pengiriman update cepat ke client; bukan source of truth. |
| Authoritative snapshot | Data terbaru dari API/database yang dipakai saat reconnect atau resync. |
| Request ID | Identifier untuk menghubungkan log, audit, dan response satu request. |
| Audit log | Evidence perubahan sensitif atau penting. Bukan source of permission. |
| Security event | Evidence kejadian keamanan, misalnya access denial atau token revoke. |
| Migration | Perubahan schema database yang versioned dan repeatable. |
| Staging | Environment sebelum production untuk verifikasi release. |
| Production | Environment aktif untuk pengguna nyata. |
| CI | Proses otomatis untuk validasi lint, typecheck, test, dan build. |
| E2E test | Test alur pengguna melalui aplikasi/browser secara end-to-end. |

## 12. Status
**Baseline glossary MVP selesai.**

## 13. Referensi
- `PWS_PRD_v0.1.md`
- `PWS_Architecture_Decision_Record_v0.1.md`
- `PWS_Authorization_RLS_Specification_v0.1_updated.md`
- `PWS_API_Contract_v0.1.md`
- `PWS_Domain_Services_Business_Rules_v0.1.md`
- `PWS_UI_UX_Specification_v0.1.md`
- `PWS_Payment_Architecture_v0.1.md`
- `PWS_Messaging_Architecture_v0.1.md`
