# PWS_Operations_Backup_Retention_v0.1.md

## 1. Tujuan
Dokumen ini mendefinisikan strategi backup, retensi, dan recovery untuk database serta storage pada MVP Premium Wedding SaaS, sesuai kebijakan zero‑cost beta.

## 2. Lingkup
- Backup basis data PostgreSQL (Supabase) 
- Backup metadata Supabase Storage (media)
- Retensi jangka pendek (RPO/RTO)  
- Prosedur restore untuk lingkungan dev, staging, dan production.

## 3. Keputusan MVP (Zero‑Cost)
| Aspek | Keputusan | Alasan |
|------|----------|--------|
| **Backup frequency** | **Harian** (setiap 24 jam) | Supabase free tier menyediakan snapshot harian otomatis; cocok untuk data ukuran kecil‑menengah. |
| **Retention period** | **7 hari** | Mengurangi biaya penyimpanan; masih cukup untuk mengatasi kegagalan kecil selama beta. |
| **Backup type** | **Full logical dump** (pg_dump) | Mudah dieksekusi, dapat di‑restore ke instance baru; tidak memerlukan WAL streaming. |
| **Storage target** | **Supabase Storage bucket `backup`** (private) | Terintegrasi dengan RLS; kontrol akses via service role. |
| **Encryption** | **At‑rest encryption** via Supabase (default) | Data sensitif tetap terenkripsi otomatis. |
| **Verification** | **Checksum + test‑restore** setiap minggu | Pastikan backup tidak korup; manual verifikasi 1x per minggu. |
| **Restore procedure** | **Script `restore.sh`** (pg_restore) | Otomatiskan langkah restore, termasuk user/role recreation. |
| **Disaster Recovery** | **Restore ke cluster baru** dalam 24 jam | RPO ≤ 24 jam, RTO ≤ 24 jam untuk beta. |

## 4. Prosedur Backup Harian (otomatis)
1. **Cron job** pada Supabase Edge Function (atau GitHub Action) dijadwalkan setiap 02:00 UTC.
2. Jalankan `pg_dump --format=custom --no-owner --no-acl -U supabase_admin dbname > backup_$(date +%Y%m%d).dump`.
3. Upload file ke bucket `backup` dengan ACL `private`.
4. Simpan log `backup_$(date).log` di bucket yang sama.
5. Hapus file backup lebih lama dari 7 hari (`find . -mtime +7 -delete`).

### Contoh Edge Function (Node.js)
```js
import { createClient } from '@supabase/supabase-js'
import { exec } from 'child_process'

const supabase = createClient(process.env.SUPABASE_URL, process.env.SUPABASE_SERVICE_ROLE_KEY)

export const handler = async (event, context) => {
  const date = new Date().toISOString().slice(0,10).replace(/-/g,'')
  const dumpPath = `/tmp/backup_${date}.dump`
  await new Promise((res,rej)=>exec(`pg_dump --format=custom --no-owner --no-acl -U ${process.env.PGUSER} ${process.env.PGDATABASE} -f ${dumpPath}`, (e)=>e?rej(e):res()))
  const { error } = await supabase.storage.from('backup').upload(`backup_${date}.dump`, await Deno.readFile(dumpPath))
  if(error) throw error
  return { statusCode:200, body:'Backup OK' }
}
```

## 5. Retensi & Penghapusan
- **Retention window**: 7 hari.
- **Penghapusan otomatis**: skrip harian yang menghapus file > 7 hari.
- **Kebijakan audit**: setiap penghapusan dicatat di audit log `backup_deletion.log`.

## 6. Verifikasi & Test‑Restore
- **Weekly checksum**: `pg_restore --list backup_X.dump | sha256sum`.
- **Test‑restore**: jalankan `restore.sh backup_X.dump` pada clone database staging; validasi schema dan data sample.
- **Failure handling**: bila checksum gagal, notifikasi ke Slack channel `#ops-alerts`.

## 7. Prosedur Restore (manual)
`restore.sh` menerima file dump:
```sh
#!/bin/bash
set -e
FILE=$1
psql -U $PGUSER -d $PGDATABASE -c "DROP SCHEMA public CASCADE; CREATE SCHEMA public;"
pg_restore -U $PGUSER -d $PGDATABASE $FILE
```
- **Langkah**: 1. Pilih backup terkini (≤ RPO). 2. Jalankan script di environment yang bersih. 3. Verifikasi tabel & data.
- **Post‑restore**: jalankan seed script untuk role‑permission (jika diperlukan).

## 8. Disaster Recovery Scenario
| Skenario | Tindakan |
|---|---|
| **Kerusakan DB** (korupsi, human error) | Pilih backup terbaru (≤ 24 jam). Jalankan `restore.sh`. Verifikasi dan aktifkan kembali aplikasi. |
| **Hilang bucket backup** | Hubungi Supabase support, gunakan snapshot provider (jika tersedia). |
| **Kehilangan seluruh cluster** | Deploy cluster baru (Free tier). Restore dari backup harian. |

## 9. Kebijakan Backup untuk Media
- Media yang di‑upload ke **Supabase Storage** otomatis tercakup pada bucket `backup` bila di‑sync secara periodik (copy‑to‑backup bucket). 
- **Retention**: 7 hari, sama dengan DB.
- **Encrypt**: default at‑rest encryption.
- **Verification**: periksa keberadaan file dengan `list` API tiap minggu.

## 10. Guardrail untuk AI Agent Code
- **Jangan** menyimpan backup ke storage publik atau bucket dengan public read.
- **Jangan** menonaktifkan encryption atau RLS pada bucket `backup`.
- **Jangan** menambah retensi > 7 hari tanpa persetujuan budget.
- **Jangan** mengandalkan backup yang belum diverifikasi checksum.
- **Jangan** mengubah struktur DB tanpa memperbarui backup script (misalnya, mengubah schema name).

## 11. Acceptance Criteria
1. Backup harian berhasil > 99 % (log sukses, file ada). 
2. Backup tidak lebih dari 7 hari terjaga. 
3. Checksum verification lulus setiap minggu. 
4. Test‑restore pada staging berhasil tanpa error. 
5. Restore pipeline (script) dapat dijalankan dalam < 30 menit. 
6. Audit log mencatat semua operasi backup, delete, dan restore. 
7. Tidak ada backup yang dapat diakses selain service role.

## 12. Status
**Baseline complete** untuk MVP. Kebijakan retensi dan prosedur dapat direvisi pada fase V1 bila kebutuhan backup lebih panjang atau compliance muncul.

## 13. Referensi
- `PWS_Release_Roadmap_and_Zero_Cost_Strategy_v0.1.md`
- `PWS_Security_NFR_Specification_v0.1.md`
- Supabase docs: *Automatic Daily Backups*, *Storage RLS*.
- `PWS_Engineering_Implementation_Blueprint_v0.1.md` (stack & CI).