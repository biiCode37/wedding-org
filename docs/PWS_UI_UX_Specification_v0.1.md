# PWS_UI_UX_Specification_v0.1.md

## 1. Tujuan
Dokumen ini menetapkan pengalaman pengguna dan batas desain UI/UX untuk MVP Premium Wedding SaaS.

Dokumen ini menjadi acuan untuk desain, implementasi frontend, acceptance test, dan review UI. Dokumen ini tidak memberi izin otomatis untuk membuat kode atau file implementasi.

## 2. Keputusan UI/UX MVP
| Area | Keputusan |
|---|---|
| Prioritas perangkat | Mobile-first untuk public invitation dan responsive seimbang untuk admin. |
| Invitation publik | Editorial premium: tipografi kuat, foto dominan, elegan, ringan. |
| Admin portal | Operational dashboard: jelas, cepat, fokus tugas. |
| Sistem tema | Theme preset dengan token customization. |
| Editor website | Form per section dengan live preview. |
| Navigasi admin | Sidebar desktop dan bottom navigation mobile. |
| Halaman MVP | Dashboard, workspace, wedding profile, event, guest, invitation, RSVP, check-in, billing, settings. |
| Alur guest | Invitation → detail event → RSVP → QR/status. |
| Form RSVP | Bertahap. |
| Data RSVP MVP | Pending, hadir, tidak hadir, jumlah tamu. |
| Check-in | Scanner sebagai layar utama; pencarian manual sebagai fallback. |
| Feedback | Toast, status inline, loading state. |
| Aksi kritis | Konfirmasi hanya untuk aksi berisiko. |
| Bahasa | Indonesia dan Inggris. |
| Aksesibilitas | WCAG 2.2 AA. |
| Animasi | Ringan dan dapat dimatikan. |
| Media | Kompresi, preview, validasi tipe dan ukuran. |
| Breakpoint | Breakpoint standar framework. |
| Design token | Warna, typography, spacing, radius, shadow, z-index, motion. |
| Prototipe | Wireframe low-fidelity dan user flow harus disetujui sebelum coding UI. |

## 3. Prinsip Desain
1. Public invitation harus terasa premium tanpa memperlambat perangkat mobile.
2. Admin portal harus mengurangi langkah untuk operasi harian.
3. Informasi penting harus terlihat sebelum elemen dekoratif.
4. Status, error, loading, dan hasil aksi tidak boleh ambigu.
5. UI bukan boundary keamanan. Semua permission tetap divalidasi server-side.
6. Data private hanya ditampilkan pada actor dan scope yang diizinkan.
7. Desain harus mendukung Bahasa Indonesia dan Inggris tanpa memotong atau merusak layout.
8. Desain wajib menyediakan 2 mode tema (Light/Dark) dengan tema Dark sebagai tema default.

## 4. Persona dan Prioritas
| Persona | Tujuan utama | Prioritas UX |
|---|---|---|
| Organization Owner | Mengelola bisnis, workspace, billing. | Ringkasan bisnis dan akses billing jelas. |
| Event Manager | Mengelola wedding, event, guest, RSVP. | Navigasi cepat antar workspace dan event. |
| Guest/Invitation Manager | Mengelola guest dan invitation. | Bulk action, filter, pencarian, status jelas. |
| Check-in Staff | Check-in tamu saat event. | Cepat, minim distraksi, hasil scan jelas. |
| Couple/Client | Melihat data workspace terbatas. | Read-only, status mudah dipahami. |
| Public Guest | Membuka invitation dan RSVP. | Mobile-first, ringan, langkah singkat. |

## 5. Information Architecture
### 5.1 Public invitation
```text
Invitation Landing
├── Cover
├── Couple
├── Event Details
├── Venue / Map
├── RSVP
├── QR / RSVP Status
├── Gift (jika feature aktif)
└── Footer
```

### 5.2 Admin portal
```text
Dashboard
Workspaces
├── Wedding Profile
├── Events
├── Guests
├── Invitations
├── RSVP
├── Check-in
├── Website
├── Media
└── Settings
Organization
├── Members / Roles
├── Billing
└── Organization Settings
```

Halaman yang belum masuk scope MVP tidak boleh muncul sebagai fitur aktif. Bila perlu ditampilkan, gunakan label `Segera hadir` tanpa membuat capability palsu.

## 6. Navigasi
### 6.1 Desktop admin
- Sidebar kiri berisi navigasi utama.
- Workspace switcher selalu terlihat.
- Area konten menampilkan breadcrumb bila navigasi lebih dari satu level.
- Aksi utama halaman terlihat tanpa membuka menu tersembunyi bila aman.

### 6.2 Mobile admin
Bottom navigation memuat maksimal lima tujuan utama:
1. Dashboard
2. Workspaces
3. Guests
4. Check-in
5. More

Menu `More` memuat Invitation, RSVP, Billing, Settings, dan menu lain yang relevan terhadap role.

### 6.3 Public guest
Public invitation memakai navigasi section ringan atau scroll-based navigation. Jangan memaksa guest membuat akun untuk membuka invitation atau mengirim RSVP melalui token valid.

## 7. Public Invitation Experience
### 7.1 Gaya visual
- Editorial premium.
- Foto dan tipografi menjadi fokus utama.
- Ornamen hanya melengkapi konten.
- Kontras teks harus memenuhi WCAG 2.2 AA.
- Halaman harus tetap nyaman saat gambar gagal dimuat.

### 7.2 Theme preset
Tema terdiri dari preset yang menyediakan:
- palette warna;
- font heading dan body;
- spacing;
- radius;
- section layout;
- motion profile.

Kustomisasi MVP dibatasi pada token yang disediakan preset. User tidak dapat menulis CSS, JavaScript, atau layout arbitrer.

### 7.3 Editor website
Editor memakai form per section:
- Cover;
- Couple;
- Event details;
- Venue/map;
- Gallery;
- RSVP;
- Gift bila diaktifkan;
- Footer.

Setiap perubahan draft ditampilkan dalam live preview. Published version tidak boleh diubah langsung. Publish harus mengikuti domain state dan immutable versioning yang sudah ditetapkan.

### 7.4 Animasi
- Animasi harus ringan.
- Hormati `prefers-reduced-motion`.
- User dapat mematikan animasi bila disediakan kontrol tema.
- Animasi tidak boleh memblokir pembacaan konten, RSVP, atau QR.

## 8. Public RSVP Experience
### 8.1 Alur
```text
Guest membuka invitation dengan token valid
    ↓
Guest membuka RSVP
    ↓
Step 1: pilih hadir atau tidak hadir
    ↓
Step 2: isi jumlah tamu bila hadir
    ↓
Review jawaban
    ↓
Submit
    ↓
Tampilkan status RSVP dan QR bila diizinkan
```

### 8.2 Aturan form
- Satu pertanyaan utama per langkah.
- Progress indicator harus terlihat.
- Validasi tampil inline di field terkait.
- Tombol lanjut tidak aktif bila data wajib belum valid.
- Form harus dapat digunakan keyboard dan screen reader.
- Jumlah tamu tidak boleh melebihi invitation entitlement/policy server.

### 8.3 State RSVP
| State | Tampilan |
|---|---|
| `PENDING` | Belum mengirim respons. |
| `ACCEPTED` | Konfirmasi hadir dan jumlah tamu. |
| `DECLINED` | Konfirmasi tidak hadir. |
| Token expired/revoked | Halaman aman tanpa detail private; arahkan untuk menghubungi penyelenggara bila perlu. |

## 9. Admin Dashboard
Dashboard menampilkan informasi operasional, bukan dekorasi.

Kartu minimum:
- workspace aktif;
- total guest;
- RSVP pending, hadir, tidak hadir;
- invitation status;
- attendance/check-in hari ini bila ada event;
- billing status untuk Organization Owner.

Data dashboard harus mengikuti permission, workspace scope, dan client visibility policy.

## 10. Workspace dan Wedding Profile
### 10.1 Workspace list
- Card atau tabel responsive.
- Menampilkan nama, status, tanggal wedding, dan ringkasan event.
- Pencarian dan filter minimal untuk organisasi dengan banyak workspace.

### 10.2 Wedding profile
- Form dikelompokkan menurut konteks: identitas wedding, couple, waktu, venue, media.
- Field wajib ditandai jelas.
- Simpan draft menampilkan loading, sukses, atau error.
- Ownership/organization tidak boleh dapat diubah dari UI ordinary CRUD.

## 11. Guest Management
### 11.1 Guest list
Guest list harus mendukung:
- pencarian;
- filter status/group/tag bila tersedia;
- pagination;
- empty state;
- loading state;
- error state;
- bulk action hanya jika permission mendukung.

### 11.2 Guest detail
Tampilkan:
- identitas yang diizinkan;
- event assignment;
- RSVP current state;
- invitation status;
- check-in state bila relevan.

Data dari workspace lain tidak boleh muncul dalam hasil pencarian atau detail.

## 12. Invitation Management
Halaman invitation memuat:
- daftar invitation party;
- status invitation;
- token status tanpa memperlihatkan token rahasia;
- action publish, send, cancel, revoke bila actor berwenang;
- delivery state;
- error dan retry status bila messaging aktif.

Aksi publish, send, cancel, atau revoke adalah aksi berisiko dan memerlukan konfirmasi sesuai policy UI.

## 13. RSVP Dashboard
Tampilkan:
- total RSVP;
- pending;
- accepted;
- declined;
- jumlah tamu yang dikonfirmasi;
- filter berdasarkan event;
- daftar response bila role mengizinkan.

Dashboard tidak boleh menyimpulkan attendance aktual dari RSVP.

## 14. Check-in Experience
### 14.1 Layout utama
```text
Event selector
Connection status
Scanner viewport
Last scan result
Manual search action
Attendance summary
```

### 14.2 Perilaku scanner
- Scanner menjadi fokus utama.
- Tombol pencarian manual selalu tersedia sebagai fallback.
- Tampilkan status koneksi yang jelas.
- Saat request diproses, cegah submit scan ganda dari kontrol yang sama.
- Jangan tampilkan `CHECKED_IN` sebelum respons server sukses.

### 14.3 Hasil scan
| Hasil | Tampilan |
|---|---|
| Sukses | Status positif, nama guest yang diizinkan, waktu check-in, informasi meja bila diizinkan. |
| Duplicate | Status jelas bahwa guest sudah check-in; tidak dianggap error fatal. |
| QR tidak valid | Pesan aman tanpa membuka data guest. |
| Wrong event | Pesan penolakan aman. |
| Offline/API gagal | UI menonaktifkan check-in dan menjelaskan bahwa data tidak tersimpan. |

Check-in mengikuti strategi online-only pada `PWS_Checkin_Offline_Strategy_v0.1.md`.

## 15. Billing Experience
Billing hanya tersedia untuk Organization Owner.

Halaman billing memuat:
- plan aktif;
- billing model: bulanan, tahunan, atau per wedding;
- invoice history;
- status pembayaran;
- action lanjut bayar untuk invoice pending;
- status read-only jika organisasi tidak aktif.

UI billing tidak boleh menandai invoice sebagai paid dari redirect browser. Status hanya berasal dari state server setelah webhook terverifikasi.

## 16. Settings dan Client Portal
### 16.1 Settings
Settings dipisahkan berdasarkan scope:
- organization settings;
- workspace settings;
- website settings;
- billing settings.

Tampilkan hanya setting yang sesuai role dan scope.

### 16.2 Client portal
Couple/Client bersifat read-only pada MVP:
- dapat melihat informasi client-visible;
- tidak melihat editor, form edit, atau action staff;
- tidak melihat data private staff, billing organisasi, audit, token, atau data workspace lain.

## 17. Feedback dan Error Handling
### 17.1 Loading
- Gunakan skeleton untuk daftar dan dashboard.
- Gunakan disabled/loading state untuk tombol submit.
- Jangan menghapus data lama sebelum data baru valid tersedia bila mengganggu konteks user.

### 17.2 Success
- Toast untuk aksi singkat yang berhasil.
- Status inline untuk perubahan yang perlu tetap terlihat.
- Tampilkan `request_id` di error detail support bila relevan, bukan data sensitif.

### 17.3 Error
- Pesan error harus menjelaskan langkah pengguna tanpa membeberkan detail internal.
- Validation error tampil dekat field.
- Authorization error tidak boleh mengungkap existence resource lintas tenant.
- Network error harus memberi retry yang aman bila operasi mendukung idempotency.

## 18. Konfirmasi Aksi Kritis
Konfirmasi wajib untuk:
- delete guest bila tersedia;
- guest merge;
- publish website/invitation;
- send invitation atau campaign;
- cancel invitation;
- revoke token;
- check-in correction;
- souvenir entitlement override;
- cancellation billing;
- role/membership change.

Konfirmasi harus menjelaskan dampak. Jangan memakai modal konfirmasi untuk aksi rutin berisiko rendah seperti menyimpan draft.

## 19. Bahasa dan Lokalisasi
- UI harus mendukung Bahasa Indonesia dan Inggris.
- Semua label, pesan validasi, empty state, dan error harus memakai key translation, bukan teks hardcoded tersebar.
- Format tanggal, jam, dan angka mengikuti locale user/workspace.
- Panjang teks Inggris dan Indonesia harus diuji agar tidak merusak layout.
- Bahasa default belum ditetapkan dokumen ini; harus mengikuti setting organization/user saat tersedia.

## 20. Aksesibilitas
Target: WCAG 2.2 AA.

Minimum requirement:
- kontras warna memadai;
- semua kontrol keyboard accessible;
- focus state terlihat;
- label form terhubung dengan input;
- pesan error dapat dibaca screen reader;
- gambar bermakna memiliki alt text;
- informasi tidak disampaikan dengan warna saja;
- target sentuh memadai pada mobile;
- motion dapat dikurangi.

## 21. Responsive Design
Gunakan breakpoint standar framework. Implementasi harus diuji minimal pada:
- mobile portrait;
- mobile landscape;
- tablet;
- desktop.

Prioritas responsive:
1. RSVP dan public invitation;
2. check-in;
3. guest list dan search;
4. dashboard;
5. website editor.

## 22. Design Token
Design system MVP wajib memiliki token:

```text
color
font family
font size
font weight
line height
spacing
radius
shadow
z-index
motion duration
easing
breakpoint
```

Token harus menjadi source of truth visual. Nilai ad hoc hanya boleh dipakai bila belum ada token dan harus direview sebelum production.

## 23. Media Upload
Media upload harus menyediakan:
- validasi tipe file;
- validasi ukuran file;
- preview;
- progress upload;
- error state;
- kompresi bila sesuai tipe media;
- alt text atau metadata aksesibilitas bila media dipakai publik.

Media private tidak boleh menjadi public hanya karena berhasil di-upload.

## 24. Wireframe Gate
Sebelum coding UI, wireframe low-fidelity wajib dibuat dan disetujui untuk:
1. Public invitation;
2. RSVP flow;
3. Admin dashboard;
4. Workspace/wedding profile;
5. Guest list dan guest detail;
6. Invitation management;
7. RSVP dashboard;
8. Check-in scanner/manual search;
9. Billing;
10. Client read-only portal.

Setiap wireframe harus mencantumkan actor, route, data utama, action, permission state, loading state, empty state, dan error state.

## 25. Acceptance Criteria
- Invitation publik dapat dipakai nyaman pada mobile.
- RSVP bertahap dapat diselesaikan keyboard dan touch.
- Theme preset tidak mengizinkan CSS/JS arbitrer.
- Published website tidak dapat diedit langsung dari UI.
- Admin navigation responsif untuk desktop dan mobile.
- Guest list memiliki search, pagination, loading, empty, dan error state.
- Check-in tidak mengonfirmasi sukses sebelum server merespons.
- Client hanya melihat data read-only sesuai policy.
- Billing hanya tampil untuk Organization Owner.
- UI mendukung Indonesia dan Inggris.
- WCAG 2.2 AA baseline diuji pada flow utama.
- Aksi kritis memiliki konfirmasi yang jelas.

## 26. Guardrail untuk AI Agent Code
AI Agent Code harus:
- membuat wireframe yang disetujui sebelum menulis UI;
- menggunakan design token, bukan nilai visual acak;
- tidak membangun drag-and-drop builder pada MVP;
- tidak membuat client write capability;
- tidak menampilkan token, secret, atau data private lintas scope;
- tidak membuat check-in offline queue;
- tidak memakai redirect payment sebagai paid state;
- tidak menganggap hidden button sebagai authorization;
- tidak menambah halaman atau fitur di luar scope tanpa persetujuan.

## 27. Status
**Baseline UI/UX MVP selesai. Wireframe masih wajib disetujui sebelum implementasi UI.**

## 28. Referensi
- `PWS_PRD_v0.1.md`
- `PWS_Use_Cases_State_Machines_v0.1.md`
- `PWS_Authorization_RLS_Specification_v0.1_updated.md`
- `PWS_API_Contract_v0.1.md`
- `PWS_Client_Writable_Fields_v0.1.md`
- `PWS_Checkin_Offline_Strategy_v0.1.md`
- `PWS_Payment_Architecture_v0.1.md`
- `PWS_Testing_Acceptance_Criteria_v0.1.md`
