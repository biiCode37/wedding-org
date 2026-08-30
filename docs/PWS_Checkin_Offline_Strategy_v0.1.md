# PWS_Checkin_Offline_Strategy_v0.1.md

## 1. Tujuan
Dokumen ini menetapkan perilaku check-in ketika koneksi bermasalah pada MVP Premium Wedding SaaS.

Keputusan MVP adalah **online-only**. Sistem tidak menyimpan antrean check-in lokal dan tidak melakukan sinkronisasi offline otomatis.

## 2. Alasan Keputusan
Check-in mengubah attendance state yang bersifat kritis. Mode offline menambah risiko:
- duplicate check-in saat sinkronisasi;
- konflik antar perangkat/gate;
- status dashboard tidak akurat;
- audit evidence tidak lengkap;
- kebocoran data pada penyimpanan perangkat.

MVP memprioritaskan integritas check-in dibanding kemampuan offline.

## 3. Ruang Lingkup
Dokumen ini mengatur:
- kondisi koneksi check-in;
- perilaku UI saat koneksi gagal;
- retry request;
- authoritative state;
- batasan implementasi MVP.

Dokumen ini tidak mendesain offline queue, service worker queue, background sync, atau rekonsiliasi multi-device. Fitur tersebut di luar scope MVP.

## 4. Status Operasional
| Status | Kondisi | Aksi UI |
|---|---|---|
| `ONLINE_READY` | API dan sesi valid | Scanner dan manual lookup dapat digunakan. |
| `REQUEST_IN_PROGRESS` | Request check-in sedang dikirim | Cegah submit ulang dari tombol yang sama sampai respons diterima atau timeout. |
| `NETWORK_UNAVAILABLE` | Browser/device tidak memiliki koneksi | Nonaktifkan check-in; tampilkan bahwa check-in tidak tersimpan. |
| `API_UNAVAILABLE` | API, database, atau dependency kritis gagal | Nonaktifkan check-in; tampilkan error retryable. |
| `AUTHORIZATION_FAILED` | Sesi, permission, atau scope tidak valid | Nonaktifkan check-in; minta login ulang atau hubungi admin. |
| `RECONNECTING` | Koneksi kembali tetapi snapshot belum diperbarui | Jangan izinkan check-in baru hingga resync selesai. |

## 5. Alur Check-in MVP
```text
Scan QR / pilih guest manual
    ↓
Cek koneksi client
    ↓
Kirim command ke API
    ↓
Server authenticate + authorize
    ↓
Server validasi event guest
    ↓
Transaction idempotent
    ↓
Commit check-in + audit
    ↓
Kirim response authoritative
    ↓
UI tampilkan hasil
```

Hasil check-in dianggap sukses hanya setelah server mengembalikan respons sukses.

## 6. Aturan Saat Koneksi Gagal
### 6.1 Sebelum request dikirim
Jika browser mendeteksi tidak ada koneksi:
- jangan buat record lokal;
- jangan mengubah attendance count lokal;
- jangan tampilkan status `CHECKED_IN`;
- tampilkan status gagal dengan aksi retry setelah koneksi kembali.

### 6.2 Setelah request dikirim tetapi respons tidak diterima
UI tidak tahu apakah transaksi berhasil atau tidak. UI harus:
1. mempertahankan `Idempotency-Key` yang sama untuk retry command yang sama;
2. melakukan reconnect atau retry manual;
3. meminta hasil dari API dengan key/context yang sama;
4. memakai respons server sebagai source of truth.

UI tidak boleh mengirim command baru dengan key baru hanya karena timeout.

### 6.3 Setelah koneksi kembali
Sebelum scanner diaktifkan lagi:
1. refresh sesi autentikasi jika perlu;
2. ambil snapshot check-in authoritative untuk event;
3. sinkronkan dashboard/count dari server;
4. baru set status menjadi `ONLINE_READY`.

## 7. Idempotency
Setiap command check-in wajib memakai `Idempotency-Key`.

Aturan:
```text
key sama + payload logis sama
→ kembalikan hasil check-in yang sama

key sama + payload berbeda
→ reject idempotency conflict

scan berbeda untuk event guest yang sudah checked-in
→ kembalikan current successful state atau conflict sesuai API Contract
```

Idempotency tetap wajib walaupun MVP online-only karena timeout dan reconnect masih dapat terjadi.

## 8. QR dan Manual Lookup
QR scan dan manual lookup hanya membantu menemukan `event_guest`. Keduanya bukan bukti bahwa check-in sudah berhasil.

Server tetap wajib memverifikasi:
- actor memiliki `checkin.create`;
- actor memiliki event scope yang sesuai;
- `event_guest` berada pada event target;
- event guest belum memiliki check-in sukses yang bertentangan;
- ownership organization/workspace/event konsisten.

## 9. Dashboard dan Realtime
Realtime hanya mempercepat tampilan dashboard. Database/API tetap source of truth.

Saat reconnect:
- jangan menghitung ulang dari event realtime yang mungkin terlewat;
- ambil snapshot authoritative;
- gunakan realtime hanya untuk perubahan setelah snapshot berhasil dimuat.

Jika realtime gagal namun API masih sehat, check-in boleh tetap berjalan. Dashboard dapat memakai polling atau refresh manual sesuai implementasi, tanpa membuat source of truth kedua.

## 10. Keamanan Perangkat
Karena online-only:
- jangan menyimpan guest list penuh di persistent local storage;
- jangan menyimpan QR token mentah lebih lama dari kebutuhan request;
- jangan menyimpan service-role credential;
- jangan cache private check-in data untuk pemakaian offline;
- logout atau perubahan scope harus menghentikan akses check-in.

## 11. Perilaku Error
| Kondisi | Hasil |
|---|---|
| QR tidak valid | Tolak; tidak ada state change. |
| Guest milik event lain | Tolak; tidak ada state change. |
| Guest sudah check-in | Return current result idempotent atau conflict sesuai API Contract. |
| Koneksi putus sebelum request | Tidak ada check-in lokal. |
| Timeout setelah request | Retry dengan `Idempotency-Key` sama. |
| API/database gagal | Tidak ada sukses yang ditampilkan tanpa respons server. |
| Permission/scope dicabut | Tolak dan hentikan check-in. |

## 12. Acceptance Criteria
- Browser offline tidak dapat membuat check-in lokal.
- UI tidak menandai guest hadir sebelum respons server sukses.
- Timeout dapat di-retry dengan `Idempotency-Key` sama.
- Retry tidak menghasilkan dua check-in sukses.
- Setelah reconnect, UI mengambil snapshot server sebelum menerima check-in baru.
- Check-in staff event E1 tidak dapat check-in guest pada E2.
- Realtime gagal tidak mengubah database sebagai source of truth.
- Private guest data tidak disimpan sebagai offline cache persisten.

## 13. Guardrail untuk AI Agent Code
AI Agent Code harus:
- tidak membuat offline queue pada MVP;
- tidak membuat optimistic `CHECKED_IN` state tanpa respons server;
- tidak menyimpan check-in pending di `localStorage`, IndexedDB, atau browser cache;
- memakai idempotency pada timeout/retry;
- menjalankan resync server setelah reconnect;
- tidak menjadikan event realtime sebagai source of truth;
- tidak melemahkan authorization atau RLS untuk mempercepat scanning.

## 14. Kapan Offline Mode Boleh Ditambahkan
Offline mode hanya boleh dimulai pada V1/V2 setelah ada dokumen keputusan yang mendefinisikan:
- storage perangkat dan enkripsi;
- masa simpan data lokal;
- sinkronisasi dan conflict resolution;
- idempotency lintas perangkat;
- rekonsiliasi attendance;
- audit trail;
- device enrollment/revocation;
- pengujian network partition dan concurrent sync.

## 15. Status
**Baseline complete untuk MVP. Check-in hanya online.**

## 16. Referensi
- `PWS_API_Contract_v0.1.md`
- `PWS_Authorization_RLS_Specification_v0.1_updated.md`
- `PWS_Domain_Services_Business_Rules_v0.1.md`
- `PWS_Use_Cases_State_Machines_v0.1.md`
- `PWS_Security_NFR_Specification_v0.1.md`
- `PWS_Testing_Acceptance_Criteria_v0.1.md`
